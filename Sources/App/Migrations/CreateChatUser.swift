//
//  CreateChatUser.swift
//  
//
//  Created by Stanislav Kobiletski on 19.05.2020.
//

import Fluent

struct CreateChatUser: Migration {
  
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(ChatUser.schema)
      .id()
      .field(.chatID, .uuid, .required, .references(Chat.schema, "id"))
      .field(.userID, .uuid, .required, .references(User.schema, "id"))
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(ChatUser.schema).delete()
  }
}
