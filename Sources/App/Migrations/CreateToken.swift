//
//  CreateToken.swift
//  
//
//  Created by Stanislav Kobiletski on 22.05.2020.
//

import Fluent

struct CreateToken: Migration {
  
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(Token.schema)
      .id()
      .field(.value, .string, .required)
      .field(.userID, .uuid, .required, .references(User.schema, "id"))
      .unique(on: .value)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(Token.schema).delete()
  }
}
