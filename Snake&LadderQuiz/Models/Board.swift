import Foundation

enum MoveEvent {
    case ladder
    case snake
}


struct Board {
    
    let size = 63
    
    let ladders: [Int: Int] = [
        3: 17,
        20: 33,
        28: 42,
        40: 46,
        47: 61
    ]
    
    let snakes: [Int: Int] = [
        25: 11,
        32: 16,
        48: 34,
        58: 45
    ]
    
    // MAIN LOGIC
    func resolvePosition(_ position: Int) -> (finalPosition: Int, event: MoveEvent?) {
        
        if let ladderTop = ladders[position] {
            return (ladderTop, .ladder)
        }
        
        if let snakeTail = snakes[position] {
            return (snakeTail, .snake)
        }
        
        return (position, nil)
    }
}