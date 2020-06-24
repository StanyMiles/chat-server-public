//
//  UserToken.swift
//  
//
//  Created by Stanislav Kobiletski on 22.05.2020.
//

import Vapor
import Fluent

final class Token: Model, Content {
  
  static var schema = "user_tokens"
  
  // MARK: - Properties
  
  @ID()
  var id: UUID?
  
  @Field(key: .value)
  var value: String
  
  @Parent(key: .userID)
  var user: User
  
  // MARK: - init
  
  init() {}
  
  init(
    id: UUID? = nil,
    value: String,
    userId: User.IDValue
  ) {
    
    self.id       = id
    self.value    = value
    self.$user.id = userId
  }
}

// MARK: - ModelTokenAuthenticatable
extension Token: ModelTokenAuthenticatable {
  
  static let valueKey = \Token.$value
  static let userKey = \Token.$user
  
  var isValid: Bool {
    true
  }
}

// MARK: - Helper Models
extension Token {
  
  struct LoginData: Content {
    let token: String
    let user: User.PublicUser
  }
  
  func getLoginData(for user: User) -> LoginData {
    LoginData(token: value, user: user.getPublicUser())
  }
}
