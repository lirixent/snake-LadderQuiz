import Foundation

struct GameState {
    
    // MARK: - Properties
    var players: [Player]
    var currentPlayerIndex: Int = 0
    let board: Board
    let boardSize: Int
    
    // MARK: - Init
    init(players: [Player], boardSize: Int = 100) {
        self.players = players
        self.boardSize = boardSize
      //  self.board = Board(size: boardSize)
      self.board = Board()
    }
    
    // Current player
    var currentPlayer: Player {
        return players[currentPlayerIndex]
    }
    
    // MARK: - Game Logic
    
    // Roll dice and move current player
    mutating func takeTurn() -> String {
        let diceResult = Dice.rollWithDoubleSixRule()
        let totalMove = diceResult.total
        
        var player = players[currentPlayerIndex]
        var newPosition = player.position + totalMove
        
        // Handle bounce back if exceeds board
        if newPosition > boardSize {
            let overflow = newPosition - boardSize
            newPosition = boardSize - overflow
        }
        
        // Apply snake or ladder
        let result = board.resolvePosition(player.position)
        player.position = result.finalPosition
        player.turnsPlayed += 1
        
        players[currentPlayerIndex] = player
        
        // Build message for this turn
        let message = buildTurnMessage(player: player, diceResult: diceResult, snakeOrLadder: eventToString(result.event))
        
        // Check win
        if player.position == boardSize {
            return "🏆 \(player.name) wins the game!"
        }
        
        // Switch turn
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        
        return message
    }
    
    // Helper function
    
    func eventToString(_ event: MoveEvent?) -> String? {
        switch event {
        case .ladder:
            return "ladder"
        case .snake:
            return "snake"
        default:
            return nil
        }
    }
    
    
    
    
    // MARK: - Helper
    
    private func buildTurnMessage(player: Player, diceResult: (total: Int, rolls: [DiceRoll]), snakeOrLadder: String?) -> String {
        var rollDetails = ""
        for roll in diceResult.rolls {
            rollDetails += "[\(roll.first), \(roll.second)] "
        }
        
        var message = "🎲 Rolls: \(rollDetails)\n➡️ Moved to position \(player.position)"
        
        if let type = snakeOrLadder {
            if type == "ladder" {
                message += "\n🪜 Climbed a ladder!"
            } else if type == "snake" {
                message += "\n🐍 Bitten by a snake!"
            }
        }
        return message
    }
}
