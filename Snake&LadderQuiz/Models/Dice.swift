import Foundation

struct DiceRoll {
    let first: Int
    let second: Int
}

struct Dice {
    
    private static func rollSingle() -> Int {
        return Int.random(in: 1...6)
    }
    
    static func rollWithDoubleSixRule() -> (total: Int, rolls: [DiceRoll]) {
        
        var total = 0
        var rolling = true
        var rolls: [DiceRoll] = []
        var doubleSixCount = 0
        
        while rolling {
            
            let first = rollSingle()
            let second = rollSingle()
            
            rolls.append(DiceRoll(first: first, second: second))
            
            if first == 6 && second == 6 {
                
                doubleSixCount += 1
                
                if doubleSixCount == 1 {
                    total += 12
                } else {
                    print("Second double 6 ignored.")
                }
                
            } else {
                total += first + second
                rolling = false
            }
        }
        
        return (total, rolls)
    }
}