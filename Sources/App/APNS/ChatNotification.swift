//
//  ChatNotification.swift
//  
//
//  Created by Stanislav Kobiletski on 21.06.2020.
//

import Foundation
import APNSwift

struct ChatNotification: APNSwiftNotification {
  
  let aps: APNSwiftPayload
  let chatId: String
  
  init(title: String, message: String, chatId: String) {
    aps = .init(alert: .init(title: title, subtitle: message), badge: 1)
    self.chatId = chatId
  }
  
}
