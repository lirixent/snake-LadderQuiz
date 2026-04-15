import Foundation

struct Player: Identifiable {
    let id: UUID
    var name: String
    var avatar: String
    var position: Int
    var turnsPlayed: Int
    var isSpectator: Bool

    init(
        id: UUID = UUID(),
        name: String,
        avatar: String,
        position: Int = 1,
        turnsPlayed: Int = 0,
        isSpectator: Bool = false
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.position = position
        self.turnsPlayed = turnsPlayed
        self.isSpectator = isSpectator
    }
}
