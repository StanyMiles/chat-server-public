import Fluent
import Vapor

struct UserController {
  
  func create(req: Request) throws -> EventLoopFuture<User.PublicUser> {
    
    try User.Create.validate(req)
    let newUser = try req.content.decode(User.Create.self)
    
    guard newUser.password == newUser.confirmPassword else {
      throw Abort(.badRequest, reason: "Passwords did not match")
    }
    
    let user = try User(create: newUser)
    return user
      .save(on: req.db)
      .map { user.getPublicUser() }
  }
  
  func search(req: Request) throws -> EventLoopFuture<[User.PublicUser]> {
    
    let user = try req.auth.require(User.self)
    
    guard let name = req.parameters.get("name") else {
      throw Abort(.badRequest)
    }
    
    return User
      .query(on: req.db)
      .filter(\.$username ~~ name)
      .filter(\.$id, .notEqual, user.id!)
      .sort(\.$username)
      .all()
      .map({
        $0.map({ $0.getPublicUser() })
      })
  }
  
  func saveNotificationToken(req: Request) throws -> EventLoopFuture<HTTPStatus> {
    
    let user = try req.auth.require(User.self)
    
    guard let token = req.parameters.get("token") else {
      throw Abort(.badRequest)
    }
    
    user.notificationToken = token
    
    return user
      .save(on: req.db)
      .map({ .ok })
  }
  
  func signIn(req: Request) throws -> EventLoopFuture<Token.LoginData> {
    
    let user = try req.auth.require(User.self)
    let token = try user.generateToken()
    
    return token
      .save(on: req.db)
      .map({ token.getLoginData(for: user) })
  }
  
  func signOut(req: Request) throws -> EventLoopFuture<Response> {
    
    let token = req.headers.bearerAuthorization?.token
    
    let okResponse = Response(
      status: .ok,
      version: req.version,
      headers: .init(),
      body: .empty)
    
    return Token
      .query(on: req.db)
      .filter("value", .equal, token)
      .first()
      .flatMap({ token in
        
        guard let token = token else {
          return req.eventLoop.makeSucceededFuture(okResponse)
        }
        
        return token
          .delete(on: req.db)
          .map({ okResponse })
      })
  }
  
  func updateUsername(req: Request) throws -> EventLoopFuture<HTTPStatus> {
    
    let user = try req.auth.require(User.self)
    
    guard let username = req.parameters.get("username") else {
      throw Abort(.badRequest)
    }
    
    user.username = username
    
    return user
      .save(on: req.db)
      .map({ .ok })
  }
  
  func updatePassword(req: Request) throws -> EventLoopFuture<HTTPStatus> {
    
    let user = try req.auth.require(User.self)
    
    guard let password = req.parameters.get("password") else {
      throw Abort(.badRequest)
    }
    
    user.password = try Bcrypt.hash(password)
    
    return user
      .save(on: req.db)
      .map({ .ok })
  }
  
  func uploadImage(req: Request) throws -> EventLoopFuture<String> {
    
    let user = try req.auth.require(User.self)
    
    let rootDirectory = req.application.directory.publicDirectory

    let uploadDirectory = URL(
      fileURLWithPath: "\(rootDirectory)images/\(user.id!.uuidString)",
      isDirectory: true)
    
    struct UserFile: Content {
      var image: Data
    }
    
    let userFile = try req.content.decode(UserFile.self)
    
    let fileManager = FileManager.default
    let imageName = UUID().uuidString + ".jpg"
    
    let avatarUrl = "images/\(user.id!.uuidString)/\(imageName)"

    if !fileManager.fileExists(atPath: uploadDirectory.path) {
      try fileManager.createDirectory(
        at: uploadDirectory,
        withIntermediateDirectories: true)
    }
    
    let localFileUrl = uploadDirectory.appendingPathComponent(imageName)
    let data = userFile.image

    fileManager.createFile(
      atPath: localFileUrl.path,
      contents: data)
    
    if let currentUrl = user.avatarUrlString,
      let oldAvatarUrl = URL(string: rootDirectory + currentUrl) {

      try fileManager.removeItem(at: oldAvatarUrl)
    }
    
    user.avatarUrlString = avatarUrl
    
    return user
      .save(on: req.db)
      .flatMap({
        req
          .eventLoop
          .makeSucceededFuture(user.fullAvatarUrlString!)
      })
  }
}
