//
//  UserCredentialsAuthenticator.swift
//  
//
//  Created by Stanislav Kobiletski on 22.05.2020.
//

import Vapor
import Fluent

struct UserCredentialsAuthenticator: CredentialsAuthenticator {
  
  struct Input: Content {
    let email: String
    let password: String
  }
  
  typealias Credentials = Input
  
  func authenticate(
    credentials: Credentials,
    for request: Request
  ) -> EventLoopFuture<Void> {
    
    User.query(on: request.db)
      .filter(\.$email == credentials.email)
      .first()
      .map {
        do {
          if let user = $0, try Bcrypt.verify(credentials.password, created: user.password) {
            request.auth.login(user)
          }
        } catch {
          // NOP
        }
    }
  }
}
