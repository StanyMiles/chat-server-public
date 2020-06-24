//
//  ChatController.swift
//  
//
//  Created by Stanislav Kobiletski on 19.05.2020.
//

import Fluent
import Vapor

struct ChatController {
  
  func fetchUserChats(req: Request) throws -> EventLoopFuture<[Chat.PublicChat]> {
    
    let user = try req.auth.require(User.self)
    
    return User
      .query(on: req.db)
      .filter(\.$id == user.id!)
      .with(\.$chats, { chats in
        chats.with(\.$users)
      })
      .first()
      .unwrap(or: Abort(.internalServerError))
      .flatMap({ user in
        
        user
          .chats
          .map({
        
            $0.getPublicChatEventLoopFuture(
              for: user,
              on: req)
          })
          .flatten(on: req.eventLoop)
      })
  }
  
  func create(req: Request) throws -> EventLoopFuture<Chat.PublicChat> {
    
    let currentUser = try req.auth.require(User.self)
    
    guard
      let userID = req.parameters.get("userID"),
      let userUUID = UUID(userID)
      else { throw Abort(.badRequest) }
    
    return User
      .query(on: req.db)
      .filter(\.$id == userUUID)
      .with(\.$chats, { chats in
        chats.with(\.$users)
      })
      .first()
      .unwrap(or: Abort(.internalServerError))
      .flatMap({ chatUser -> EventLoopFuture<Chat.PublicChat> in
        
        let chat = chatUser
          .chats
          .filter({
            $0.users.contains(where: { $0.id! == currentUser.id! })
          })
          .first
        
        if let chat = chat {
          
          return chat
            .getPublicChatEventLoopFuture(
              for: currentUser,
              on: req)
          
        } else {
          
          let newChat = Chat()
          return newChat
            .save(on: req.db)
            .flatMap({
              
              newChat
                .$users
                .attach([chatUser, currentUser], on: req.db)
                .flatMap({
                  
                  return newChat
                    .getPublicChatEventLoopFuture(
                      for: currentUser,
                      on: req)
                })
            })
        }
      })
  }
}
