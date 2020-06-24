//
//  User.swift
//  
//
//  Created by Stanislav Kobiletski on 18.05.2020.
//

import Fluent
import Vapor

final class User: Model, Content {
  
  static let schema = "users"
  
  // MARK: - Properties
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: .username)
  var username: String
  
  @Field(key: .email)
  var email: String
  
  @Field(key: .password)
  var password: String
  
  @Field(key: .avatarUrlString)
  var avatarUrlString: String?
  
  @Field(key: .notificationToken)
  var notificationToken: String?
  
  @Siblings(through: ChatUser.self, from: \.$user, to: \.$chat)
  var chats: [Chat]
  
  var fullAvatarUrlString: String? {
    
    guard let avatarUrlString = avatarUrlString else { return nil }
    
    let serverUrl: String
    
    #if DEBUG
    serverUrl = "http://localhost:8080/"
    #else
    serverUrl = "https://vapor-chat-server-url.com/"
    #endif
    
    return serverUrl + avatarUrlString
  }
  
  // MARK: - init
  
  init() {}
  
  init(
    id: UUID? = nil,
    username: String,
    email: String,
    password: String,
    avatarUrlString: String?
  ) {
    
    self.id               = id
    self.username         = username
    self.email            = email
    self.password         = password
    self.avatarUrlString  = avatarUrlString
  }
  
  init(create: Create) throws {
    id = nil
    username = create.username
    email = create.email
    password = try Bcrypt.hash(create.password)
    avatarUrlString = nil
  }
  
  // MARK: - Funcs
  
  func getPublicUser() -> PublicUser {
    
    PublicUser(
      id: id!,
      username: username,
      email: email,
      avatarUrlString: fullAvatarUrlString)
  }
  
  func generateToken() throws -> Token {
    try .init(
      value: [UInt8].random(count: 16).base64,
      userId: self.requireID())
  }
}

// MARK: - ModelAuthenticatable
extension User: ModelAuthenticatable {
  
  static let usernameKey = \User.$email
  static let passwordHashKey = \User.$password
  
  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.password)
  }
}

// MARK: - Validatable
extension User.Create: Validatable {
  
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty)
    validations.add("email", as: String.self, is: .email)
    validations.add("password", as: String.self, is: .count(6...))
  }
}

// MARK: - Helper Models
extension User {
  
  struct PublicUser: Content {
    let id: UUID
    let username: String
    let email: String
    let avatarUrlString: String?
  }
  
  struct Create: Content {
    let username: String
    let email: String
    let password: String
    let confirmPassword: String
  }
}
