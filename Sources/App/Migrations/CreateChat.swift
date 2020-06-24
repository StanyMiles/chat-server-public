//
//  CreateChat.swift
//  
//
//  Created by Stanislav Kobiletski on 18.05.2020.
//

import Fluent

struct CreateChat: Migration {
  
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(Chat.schema)
      .id()
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.schema(Chat.schema).delete()
  }
}
