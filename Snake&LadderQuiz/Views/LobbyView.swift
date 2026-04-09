//
//  LobbyView.swift
//  Snake&LadderQuiz
//
//  Created by Olanrewaju.Durojaiye.a1 on 2026-04-08.
//

import SwiftUI

struct LobbyView: View {
    let player: Player
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var socketService = SocketService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Waiting in Multiplayer Lobby...")
                .font(.title2)
                .bold()

            Text("Player: \(player.name)")
                .foregroundColor(.gray)

            ProgressView()

            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
        .onAppear {
            socketService.joinRoom(
                roomID: "TEST123",
                playerName: player.name,
                avatar: player.avatar
            )
        }
    }
}
