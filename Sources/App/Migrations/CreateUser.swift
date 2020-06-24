//
//  CreateUser.swift
//  
//
//  Created by Stanislav Kobiletski on 18.05.2020.
//

import Fluent

struct CreateUser: Migration {
  
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    
    return database.schema(User.schema)
      .id()
      .field(.username, .string, .required)
      .field(.email, .string, .required)
      .field(.password, .string, .required)
      .field(.avatarUrlString, .string)
      .field(.notificationToken, .string)
      .unique(on: .email)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(User.schema).delete()
  }
}

