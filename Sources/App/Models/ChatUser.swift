//
//  ChatUser.swift
//  
//
//  Created by Stanislav Kobiletski on 19.05.2020.
//

import Fluent
import Vapor

final class ChatUser: Model {
  
  static let schema = "chat_user"
  
  // MARK: - Properties
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: .chatID)
  var chat: Chat
  
  @Parent(key: .userID)
  var user: User
  
  // MARK: - init
  
  init() {}
  
  init(chatId: UUID, userId: UUID) {
    self.$chat.id = chatId
    self.$user.id = userId
  }
}
