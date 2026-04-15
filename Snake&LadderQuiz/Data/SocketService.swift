//
//  SocketService.swift
//  Snake&LadderQuiz
//
//  Created by Olanrewaju.Durojaiye.a1 on 2026-04-08.
//

import Foundation
import SocketIO
import Combine

class SocketService: ObservableObject {
    static let shared = SocketService()

    private var manager: SocketManager
    private var socket: SocketIOClient

    
    private var pendingPlayerName: String?
    private var pendingAvatar: String?
    
    @Published var roomPlayers: [Player] = []
    
    var onGameStarted: (() -> Void)?

    private init() {
        manager = SocketManager(
            socketURL: URL(string: "https://boardgames-2369.onrender.com")!,
            config: [
                .log(true),
                .compress
            ]
        )

        socket = manager.defaultSocket
        setupHandlers()
    }

    func connect(playerName: String, avatar: String) {
        pendingPlayerName = playerName
        pendingAvatar = avatar

        if socket.status == .connected || socket.status == .connecting {
            print("⚠️ Socket already connected/connecting")
            return
        }

        socket.connect()
    }
    
    
    func disconnect() {
        socket.disconnect()
    }

    private func setupHandlers() {
        
        
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self = self else { return }
            
            print("✅ Socket connected successfully")
            
            if let name = self.pendingPlayerName,
               let avatar = self.pendingAvatar {
                self.joinLobby(playerName: name, avatar: avatar)
            }
            
        }
        
        
        socket.on("sessionUpdate") { [weak self] data, _ in
            guard let self = self,
                  let playersData = data.first as? [[String: Any]] else { return }
            
            DispatchQueue.main.async {
                
                self.roomPlayers = playersData.map { item in
                    let name = item["name"] as? String ?? "Unknown"
                    let avatar = item["avatar"] as? String ?? "avartar1"
                    let isSpectator = item["isSpectator"] as? Bool ?? false
                    
                    return Player(
                        name: name,
                        avatar: avatar,
                        isSpectator: isSpectator
                    )
                }
                
                print("👥 Session updated: \(self.roomPlayers.count)")
            }
        }
        
        
        socket.on("gameStarted") { [weak self] data, _ in
            print("🎮 Server started the game automatically")
            self?.onGameStarted?()
        }
        
        
    }
 
       
        
        
        
    func joinLobby(playerName: String, avatar: String) {
        socket.emit("joinLobby", [
            "playerName": playerName,
            "avatar": avatar
        ])

        print("🚪 Joined lobby as \(playerName)")
    }

    func leaveRoom(playerName: String) {
        socket.emit("leaveLobby", [
            "playerName": playerName
        ])

        print("🚪 \(playerName) left lobby")
    }
}
