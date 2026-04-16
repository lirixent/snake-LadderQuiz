import SwiftUI

struct LobbyView: View {
    let player: Player
    let selectedCategory: String   // ✅ NEW

    @Environment(\.dismiss) var dismiss
    @StateObject private var socketService = SocketService.shared

    @State private var showWebGame = false
    @State private var roomID = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Waiting in \(selectedCategory) Lobby...")
                .font(.title2)
                .bold()

            Text("Room: \(roomID.isEmpty ? "Assigning..." : roomID)")
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 10) {
                Text("Players in this room:")
                    .font(.headline)

                ForEach(socketService.roomPlayers) { p in
                    HStack(spacing: 15) {
                        Image(p.avatar)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                        Text(p.name)
                            .bold()

                        if p.name == player.name {
                            Text("(You)")
                                .foregroundColor(.blue)
                        }

                        if p.isSpectator {
                            Text("(Watching)")
                                .foregroundColor(.gray)
                                .italic()
                        }
                    }
                }
            }
            .padding()
            .frame(maxHeight: 300)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            ProgressView("Waiting for players...")
                .padding(.top, 10)

            Button("Leave Lobby") {
                socketService.leaveRoom(
                    roomID: roomID,
                    category: selectedCategory
                )
                dismiss()
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding()

        .onAppear {
            socketService.connect(
                playerName: player.name,
                avatar: player.avatar,
                category: selectedCategory
            )

            socketService.onRoomAssigned = { assignedRoom in
                DispatchQueue.main.async {
                    roomID = assignedRoom
                }
            }

            socketService.onGameStarted = {
                DispatchQueue.main.async {
                    showWebGame = true
                }
            }
        }

        .fullScreenCover(isPresented: $showWebGame) {
            WebGameView(
                roomID: roomID,
                playerName: player.name,
                avatar: player.avatar
            )
        }

        .onDisappear {
            socketService.disconnect()
        }
    }
}
