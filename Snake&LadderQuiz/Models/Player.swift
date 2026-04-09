import Foundation

struct Player: Identifiable {
    let id: UUID
    var name: String
    var avatar: String
    var position: Int = 1
    var turnsPlayed: Int = 0
    
    init(name: String, avatar: String) {
        self.id = UUID()
        self.name = name
        self.avatar = avatar
        self.position = 1
        self.turnsPlayed = 0
    }
}