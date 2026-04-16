import Foundation
import SocketIO
import Combine

class SocketService: ObservableObject {
    static let shared = SocketService()

    private var manager: SocketManager
    private var socket: SocketIOClient

    private var pendingPlayerName: String?
    private var pendingAvatar: String?
    private var pendingCategory: String?

    @Published var roomPlayers: [Player] = []
    @Published var assignedRoomID: String = ""

    var onGameStarted: (() -> Void)?
    var onRoomAssigned: ((String) -> Void)?

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

    // MARK: - CONNECT
    func connect(playerName: String, avatar: String, category: String) {
        pendingPlayerName = playerName
        pendingAvatar = avatar
        pendingCategory = category

        if socket.status == .connected || socket.status == .connecting {
            print("⚠️ Socket already connected/connecting")
            return
        }

        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    // MARK: - SOCKET HANDLERS
    private func setupHandlers() {

        socket.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self = self else { return }

            print("✅ Socket connected successfully")

            if let name = self.pendingPlayerName,
               let avatar = self.pendingAvatar,
               let category = self.pendingCategory {
                self.joinLobby(
                    playerName: name,
                    avatar: avatar,
                    category: category
                )
            }
        }

        socket.on("assignedRoom") { [weak self] data, _ in
            guard let self = self,
                  let roomData = data.first as? [String: Any],
                  let roomID = roomData["roomID"] as? String else { return }

            DispatchQueue.main.async {
                self.assignedRoomID = roomID
                self.onRoomAssigned?(roomID)
                print("🏠 Assigned room: \(roomID)")
            }
        }

        socket.on("roomPlayers") { [weak self] data, _ in
            guard let self = self,
                  let playersData = data.first as? [[String: Any]] else { return }

            DispatchQueue.main.async {
                self.roomPlayers = playersData.map { item in
                    let name = item["name"] as? String ?? "Unknown"
                    let avatar = item["avatar"] as? String ?? "avartar1.png"

                    return Player(
                        name: name,
                        avatar: avatar,
                        isSpectator: false
                    )
                }

                print("👥 Room players updated: \(self.roomPlayers.count)")
            }
        }

        socket.on("gameStarted") { [weak self] _, _ in
            DispatchQueue.main.async {
                print("🎮 Server started game")
                self?.onGameStarted?()
            }
        }
    }

    // MARK: - JOIN LOBBY
    func joinLobby(playerName: String, avatar: String, category: String) {
        socket.emit("joinRoom", [
            "playerName": playerName,
            "avatar": avatar,
            "category": category
        ])

        print("🚪 Joined \(category) lobby as \(playerName)")
    }

    // MARK: - LEAVE ROOM
    func leaveRoom(roomID: String, category: String) {
        socket.emit("leaveRoom", [
            "roomID": roomID,
            "category": category
        ])

        print("🚪 Left room \(roomID)")
    }
}
