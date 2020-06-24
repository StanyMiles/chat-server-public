//
//  SessionManager.swift
//  
//
//  Created by Stanislav Kobiletski on 14.06.2020.
//

import Vapor

final class SessionManager {
  
  // MARK: - Properties
  
  static let shared = SessionManager()
  
  private(set) var sessions: LockedDictionary<UUID, WebSocket> = [:]
  
  // MARK: - Funcs
  
  func startSession(with id: UUID, websocket: WebSocket) {
    
    guard sessions[id] == nil else { return }
    
    sessions[id] = websocket
    
    _ = websocket.onClose.always { [weak self] _ in
      
      guard let self = self else { return }
      
      _ = self.sessions[id]?.close(code: .goingAway)
      self.sessions[id] = nil
    }
  }
  
}
