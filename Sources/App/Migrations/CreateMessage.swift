//
//  CreateMessage.swift
//  
//
//  Created by Stanislav Kobiletski on 18.05.2020.
//

import Fluent

struct CreateMessage: Migration {
  
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    
    return database.schema(Message.schema)
      .id()
      .field(.chatID, .uuid, .required, .references(Chat.schema, "id"))
      .field(.senderID, .uuid, .required)
      .field(.date, .datetime, .required)
      .field(.text, .string, .required)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(Message.schema).delete()
  }
}
