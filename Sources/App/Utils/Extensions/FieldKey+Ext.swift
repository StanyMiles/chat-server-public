//
//  File.swift
//  
//
//  Created by Stanislav Kobiletski on 16.06.2020.
//

import Fluent

extension FieldKey {
  
  static let users = FieldKey(stringLiteral: "users")
  static let chatID = FieldKey(stringLiteral: "chat_id")
  static let userID = FieldKey(stringLiteral: "user_id")
  static let senderID = FieldKey(stringLiteral: "sender_id")
  static let date = FieldKey(stringLiteral: "date")
  static let text = FieldKey(stringLiteral: "text")
  static let value = FieldKey(stringLiteral: "value")
  static let username = FieldKey(stringLiteral: "username")
  static let email = FieldKey(stringLiteral: "email")
  static let password = FieldKey(stringLiteral: "password")
  static let avatarUrlString = FieldKey(stringLiteral: "avatar_url_string")
  static let notificationToken = FieldKey(stringLiteral: "notification_token")
}
