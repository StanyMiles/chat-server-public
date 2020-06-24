//
//  Message.swift
//  
//
//  Created by Stanislav Kobiletski on 18.05.2020.
//

import Fluent
import Vapor

final class Message: Model, Content {
  
  static let schema = "messages"
  
  // MARK: - Properties
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: .chatID)
  var chat: Chat
  
  @Field(key: .senderID)
  var senderId: UUID
  
  @Field(key: .date)
  var date: Date
  
  @Field(key: .text)
  var text: String
  
  // MARK: - init
  
  init() {}
  
  init(
    id: UUID? = nil,
    chatId: UUID,
    senderId: UUID,
    date: Date = Date(),
    text: String
  ) {
    
    self.id       = id
    self.$chat.id = chatId
    self.senderId = senderId
    self.date     = date
    self.text     = text
  }
  
  // MARK: - Funcs
  
  func getPublicMessage() -> PublicMessage {
    
    PublicMessage(
      id: id!,
      senderId: senderId,
      date: date,
      text: text)
  }
}

// MARK: - Comparable
extension Message: Comparable {
  
  static func < (lhs: Message, rhs: Message) -> Bool {
    lhs.date > rhs.date
  }
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Helper Models
extension Message {
  
  struct PublicMessage: Content {
    let id: UUID
    let senderId: UUID
    let date: Date
    let text: String
  }
}
