//
//  SocketService.swift
//  Snake&LadderQuiz
//
//  Created by Olanrewaju.Durojaiye.a1 on 2026-04-08.
//

import Foundation
import Combine
import SocketIO

final class SocketService: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    static let shared = SocketService()
    
    private let manager: SocketManager
    let socket: SocketIOClient
    
    private init() {
        manager = SocketManager(
            socketURL: URL(string: "https://boardgames-2369.onrender.com")!,
            config: [
                .log(true),
                .compress
            ]
        )
        
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) { data, ack in
            print("✅ Socket connected successfully (App Level)")
        }
        
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func joinRoom(roomID: String, playerName: String, avatar: String) {
        socket.emit("joinRoom", [
            "roomID": roomID,
            "playerName": playerName,
            "avatar": avatar
        ])
        
        print("🚪 Joining room \(roomID) as \(playerName)")
    }
    
}
