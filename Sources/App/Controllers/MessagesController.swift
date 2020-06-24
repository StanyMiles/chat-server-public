//
//  MessagesController.swift
//  
//
//  Created by Stanislav Kobiletski on 15.06.2020.
//

import Vapor
import Fluent

final class MessagesController {
  
  func fetchMessages(req: Request) throws -> EventLoopFuture<[Message.PublicMessage]> {
    
    let _ = try req.auth.require(User.self)
    
    guard
      let chatID = req.parameters.get("chatID"),
      let chatUUID = UUID(chatID)
      else { throw Abort(.badRequest) }
    
    return Chat
      .query(on: req.db)
      .with(\.$messages)
      .filter(\.$id == chatUUID)
      .first()
      .unwrap(or: Abort(.internalServerError))
      .map({ chat in
        
        chat
          .messages
          .sorted()
          .reversed()
          .map({ $0.getPublicMessage() })
      })
  }
  
}
