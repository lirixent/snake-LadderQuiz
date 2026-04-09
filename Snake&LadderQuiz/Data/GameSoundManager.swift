import Foundation
import AVFoundation

class GameSoundManager {
    
    static let shared = GameSoundManager()
    
    private var player: AVAudioPlayer?
    
    private init() {}
    
    func playSound(_ name: String) {
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") ??
                        Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("Sound file not found:", name)
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound:", error)
        }
    }
}
