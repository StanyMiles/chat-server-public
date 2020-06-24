//
//  Chat.swift
//  
//
//  Created by Stanislav Kobiletski on 18.05.2020.
//

import Fluent
import Vapor

final class Chat: Model, Content {
  
  static let schema = "chats"
  
  // MARK: - Properties
  
  @ID(key: .id)
  var id: UUID?
  
  @Siblings(through: ChatUser.self, from: \.$chat, to: \.$user)
  var users: [User]
  
  @Children(for: \.$chat)
  var messages: [Message]
  
  // MARK: - init
  
  init() {}
  
  init(
    id: UUID? = nil,
    users: [User]
  ) {
    
    self.id = id
    self.users = users
  }
  
  // MARK: - Funcs
  
  func getPublicChatEventLoopFuture(
    for user: User,
    on req: Request
  ) -> EventLoopFuture<PublicChat> {
    
    $users
      .get(on: req.db)
      .flatMap({ users in

        let publicUsers = users
          .filter({ $0.id != user.id })
          .map({ $0.getPublicUser() })
        
        return self.$messages
          .get(on: req.db)
          .map({ messages in
            
            let lastMessage = messages
              .sorted()
              .first?
              .getPublicMessage()
            
            return PublicChat(
              id: self.id!,
              users: publicUsers,
              lastMessage: lastMessage)
          })
      })
  }
}

// MARK: - Helper Models
extension Chat {
  
  struct PublicChat: Content {
    let id: UUID
    let users: [User.PublicUser]
    let lastMessage: Message.PublicMessage?
  }
}
