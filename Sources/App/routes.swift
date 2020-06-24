import Fluent
import Vapor

func routes(_ app: Application) throws {
  
  let v0 = app.grouped("v0")
  
  let passwordProtected = v0.grouped(User.authenticator())
  let tokenProtected = v0.grouped(Token.authenticator())
  
  let userController = UserController()
  let users = tokenProtected.grouped("users")
  
  let chatController = ChatController()
  let chats = tokenProtected.grouped("chats")
  
  let messagesController = MessagesController()
  let messages = tokenProtected.grouped("messages")
  
  // MARK: - Auth
  
  passwordProtected.get("sign-in", use: userController.signIn)
  tokenProtected.get("sign-out", use: userController.signOut)
  
  // MARK: - Users
  
  // register new user
  v0.post("users", use: userController.create)
 
  users.get("search", ":name", use: userController.search)
  users.get("username", ":username", use: userController.updateUsername)
  users.get("password", ":password", use: userController.updatePassword)
 
  users.get("notification-token", ":token",
            use: userController.saveNotificationToken)
  users.on(.POST, "avatar",
           body: .collect(maxSize: 512_000),
           use: userController.uploadImage)

  // MARK: - Chats
  
  chats.get(":userID", use: chatController.create)
  chats.get(use: chatController.fetchUserChats)
  
  // MARK: - Messages
  
  messages.get(":chatID", use: messagesController.fetchMessages)
  
  messages.webSocket("socket", ":chatID") { req, ws in
    
    let currentUser: User
    let chatUUID: UUID
    
    do {
      currentUser = try req.auth.require(User.self)
      
      guard
        let chatID = req.parameters.get("chatID"),
        let uuid = UUID(chatID) else { return }
      
      chatUUID = uuid
      
    } catch {
      _ = ws.close(code: .unacceptableData)
      return
    }
    
    SessionManager.shared.startSession(with: currentUser.id!, websocket: ws)
    
    ws.onText { ws, text in
      
      Chat
        .query(on: req.db)
        .filter(\.$id == chatUUID)
        .with(\.$users)
        .first()
        .unwrap(or: Abort(.internalServerError))
        .whenSuccess({ chat in
          
          let message = Message(
            chatId: chat.id!,
            senderId: currentUser.id!,
            text: text)
          
          message
            .save(on: req.db)
            .whenSuccess({
              
              let publicMessage = message.getPublicMessage()
              
              let encoder = JSONEncoder()
              encoder.dateEncodingStrategy = .iso8601
              
              guard let data = try? encoder.encode(publicMessage) else { return }
              
              let bytes = Array<UInt8>(data)
              ws.send(bytes)
              
              let chatUser = chat
                .users
                .filter({ $0.id != currentUser.id! })
                .first!
              
              if let chatUserSession = SessionManager
                .shared
                .sessions[chatUser.id!] {
                
                chatUserSession.send(bytes)
                
              } else {

                guard let apnToken = chatUser.notificationToken else { return }
                
                let notification = ChatNotification(
                  title: "New message from \(chatUser.username)",
                  message: text,
                  chatId: chat.id!.uuidString)
                
                _ = req.apns.send(notification, to: apnToken)
              }
            })
        })
    }
  }
  
}
