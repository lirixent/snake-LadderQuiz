import Foundation
import SwiftUI
import Combine



class GameViewModel: ObservableObject {
    
    // MARK: - Published properties
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var currentPlayer: Player
    @Published var players: [Player] = []
    @Published var diceRolls: [Int] = []
    
    @Published var gameStarted: Bool = false
    
    // Timers
    @Published var universalTimer: Int = 300       // 5 minutes total
    @Published var questionTimer: Int = 30         // per question countdown
    @Published var isQuestionTimeUp: Bool = false
    
    // Round tracking
    @Published var currentRound: Int = 1
    
    // Movement
    @Published var isMoving: Bool = false
    @Published var moveStepsRemaining: Int = 0
    
    // Double six
    @Published var showDoubleSixMessage: Bool = false
    @Published var canRollAgain: Bool = false
    @Published var lastRollWasDoubleSix: Bool = false
    
    
    
    
    
    @Published var pendingDiceSteps: Int = 0
    @Published var showQuestionModal: Bool = false
    @Published var gameMessage: String =  "Tap Roll Dice to start"
    
    
    @Published var playerPosition: Int = 1
        @Published var showRoundWinMessage: Bool = false
        @Published var isChampion: Bool = false
    
    
    @Published var showRoundAlert = false
    @Published var roundMessage = ""
  
    
    @Published var screenWidth: CGFloat = UIScreen.main.bounds.width // default fallback
    
    
    
    
    func updateScreenWidth(_ width: CGFloat) {
            self.screenWidth = width
        }
    
    
    
    private func timerForRound(_ round: Int) -> Int {
        switch round {
        case 1: return 300
        case 2: return 240
        case 3: return 180
        case 4: return 120
        case 5: return 60
        case 6: return 20
        default: return 300
        }
    }
    
    
    
        
    
    
    // MARK: - Private properties
    private var board: Board
    private var universalTimerCancellable: AnyCancellable?
    private var questionTimerCancellable: AnyCancellable?
    
    // MARK: - Init
    init(player: Player) {
        self.currentPlayer = player
        self.players = [player]
        self.board = Board()
    }
    
    // MARK: - Current Question
    var currentQuestion: Question? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }
    
    // MARK: - Question Loading
    func loadQuestions(category: String, character: String, completion: @escaping () -> Void) {
        // Check SQLite first
        let count = QuestionDatabase.shared.questionCount(category: category, character: character)
        
        if count > 0 {
            // Load from local DB
            print("✅ Loading questions from SQLite")
            self.questions = QuestionDatabase.shared
                .loadQuestions(category: category, character: character)
                .shuffled()
            self.gameStarted = true
            self.startQuestionTimer()
            completion()
            
            syncQuestionsInBackground(category: category, character: character)
            
        } else {
            // Fetch from local Node.js server
            print("🌍 Downloading questions from Render")
            fetchQuestionsFromServer(category: category, character: character, completion: completion)
        }
    }
    
    private func fetchQuestionsFromServer(category: String, character: String,completion: @escaping () -> Void) {
        
        let baseURL = "https://boardgames-2369.onrender.com/api/questions"
        
        
        let urlString = "\(baseURL)/load-game?category=\(category)&character=\(character)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            
            print("Invalid URL")
            return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching questions:", error?.localizedDescription ?? "Unknown")
                return
            }
            
            do {
                // 3️⃣ Decode the JSON using your model
                
                let response = try JSONDecoder().decode(QuestionsResponse.self, from: data)
                
                
                let decodedQuestions = response.questions
                
                DispatchQueue.main.async {
                    
                    
                    self.questions = decodedQuestions.shuffled()
                    
                    
                    self.gameStarted = true
                    
                    // 4️⃣ Save each question to SQLite
                    
                    
                    for q in decodedQuestions {
                        
                        
                        QuestionDatabase.shared.save(question: q)
                    }
                    
                    // Start question timer
                    self.startQuestionTimer()
                    
                    // ✅ Complete callback
                    completion()
                }
            } catch {
                
                // 6️⃣ Debugging: print raw JSON if decoding fails
                print("Decoding error:", error.localizedDescription)
                
                if let jsonString = String(data: data, encoding: .utf8) {
                                print("Received JSON:\n", jsonString)
                            }
                
            }
        }.resume()
    }
    
    
    
    private func syncQuestionsInBackground(category: String, character: String) {
        fetchQuestionsFromServer(
            category: category,
            character: character
        ) {
            print("🔄 Selected question pack synced in background")
        }
    }
    
    
    
    
    
    // MARK: - Game Actions
    func rollDice() -> Int {
        let result = Dice.rollWithDoubleSixRule()
        self.diceRolls = result.rolls.flatMap { [$0.first, $0.second] }
        
        // Dice sound
        GameSoundManager.shared.playSound("dice-roll")
        
        // Double 6 logic
        if let first = result.rolls.first, first.first == 6 && first.second == 6 {
            GameSoundManager.shared.playSound("double6")
            DispatchQueue.main.async {
                self.showDoubleSixMessage = true
                self.canRollAgain = true
                self.lastRollWasDoubleSix = true
            }
        } else {
            self.lastRollWasDoubleSix = false
        }
        
        return result.total
    }
    
    func moveCurrentPlayer(steps: Int) {
        guard !isMoving else { return }

        /*if min(currentPlayer.position + steps, 63) == 63
        
        
        {
            currentPlayer.position = 63
            players[0] = currentPlayer

            // ✅ CLOSE QUESTION MODAL FIRST
            showQuestionModal = false

            // ✅ play success sound
            GameSoundManager.shared.playSound("success")

            // ✅ show clean round alert
            roundMessage = "🎉 Round \(currentRound) Complete!"
            showRoundAlert = true

            return
        }*/

        isMoving = true
        moveStepsRemaining = steps
        moveStepByStep()
    }
    
    
    
    private func moveStepByStep() {
        guard moveStepsRemaining > 0 else {
            finishMovement()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentPlayer.position += 1
            self.players[0] = self.currentPlayer
            self.moveStepsRemaining -= 1
            self.moveStepByStep()
        }
    }
    
    private func finishMovement() {
        let result = board.resolvePosition(currentPlayer.position)
        
        if let event = result.event {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentPlayer.position = result.finalPosition
                self.players[0] = self.currentPlayer
                
                // Play ladder/snake sound
                switch event {
                case .ladder:
                    GameSoundManager.shared.playSound("slide")
                    self.gameMessage = "🪜 Ladder! Climb up"
                case .snake:
                    GameSoundManager.shared.playSound("snake")
                    
                    self.gameMessage = "🐍 Snake bite! Move down"
                }
                
                self.isMoving = false
                
                self.checkRoundCompletion()
            }
        } else {
            isMoving = false
            
            checkRoundCompletion()
        }
    }
    
    // MARK: - Question Timer
    func startQuestionTimer() {
        questionTimer = 30
        isQuestionTimeUp = false
        
        questionTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.questionTimer > 0 {
                    self.questionTimer -= 1
                } else {
                    self.questionTimerCancellable?.cancel()
                    self.isQuestionTimeUp = true
                    
                    
                    self.gameMessage = "⏰ Time up! No movement"
                    self.showQuestionModal = false
                    self.nextQuestion()
                    
                    
                }
            }
    }
    
    func stopQuestionTimer() {
        questionTimerCancellable?.cancel()
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            startQuestionTimer()
        } else {
           // endRound()
            prepareNextRound()

        }
    }
    
   
    /*
    // MARK: - Round Management
    private func endRound() {
        stopUniversalTimer()

        if currentRound == 6 {
            roundMessage = "🏆 Champion!"
            isChampion = true
            showRoundAlert = true
            return
        }

        roundMessage = "🎉 Win Round \(currentRound)"
        showRoundAlert = true
    }
    */
    
    
    
    func proceedToNextRound() {
        currentRound += 1
        currentPlayer.position = 1
        players[0] = currentPlayer

        switch currentRound {
        case 2:
            universalTimer = 240
        case 3:
            universalTimer = 180
        case 4:
            universalTimer = 120
        case 5:
            universalTimer = 60
        case 6:
            universalTimer = 20
        default:
            isChampion = true
            roundMessage = "👑 Champion of Time Chase!"
            showRoundAlert = true
            return
        }

        gameMessage = "🔥 Round \(currentRound)"
        startUniversalTimer()
    }
    
   
    
    
    func resetToRoundOne() {
        stopUniversalTimer()
        stopQuestionTimer()

        currentRound = 1
        universalTimer = timerForRound(1)

        currentPlayer.position = 1
        players[0] = currentPlayer

        currentQuestionIndex = 0
        questions.shuffle()

        isChampion = false
        gameMessage = "🔥 Round 1"

        startUniversalTimer()
        startQuestionTimer()
    }
    
    
    
    
    
    
    
    
    /*
    func resetToRoundOne() {
        currentRound = 1
        universalTimer = 300
        currentPlayer.position = 1
        players[0] = currentPlayer
        isChampion = false
        gameMessage = "🔥 Round 1"
        startUniversalTimer()
    }
    */
    
    /*
    private func checkRoundCompletion() {
        if currentPlayer.position >= 63 {
            currentPlayer.position = 63
            players[0] = currentPlayer

            // ✅ success sound using your existing manager
            GameSoundManager.shared.playSound("success")

            gameMessage = "🎉 Round \(currentRound) Won!"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.prepareNextRound()
            }
        }
    }
    */
    
    private func checkRoundCompletion() {
        guard currentPlayer.position >= 63 else { return }

        currentPlayer.position = 63
        players[0] = currentPlayer

        GameSoundManager.shared.playSound("success")

        gameMessage = "🎉 Round \(currentRound) Won!"

        stopUniversalTimer()
        stopQuestionTimer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.prepareNextRound()
        }
    }
    
    
    
    
    
    
    
    
    
    
    /*
    private func prepareNextRound() {
        if currentRound >= 6 {
            gameMessage = "🏆 CHAMPION! Restarting Time Chase"
            resetToRoundOne()
            return
        }

        currentRound += 1
        universalTimer = timerForRound(currentRound)

        currentPlayer.position = 1
        players[0] = currentPlayer

        currentQuestionIndex = 0
        questions.shuffle()

        gameMessage = "🎮 Round \(currentRound) Started"
    }
    */
    
    
    private func prepareNextRound() {
        if currentRound >= 6 {
            gameMessage = "🏆 CHAMPION! Restarting Time Chase"
            resetToRoundOne()
            return
        }

        currentRound += 1

        currentPlayer.position = 1
        players[0] = currentPlayer

        currentQuestionIndex = 0
        questions.shuffle()

        universalTimer = timerForRound(currentRound)

        gameMessage = "🔥 Round \(currentRound)"
        startUniversalTimer()
        startQuestionTimer()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   /*
    // MARK: - Universal Timer
    func startUniversalTimer() {
        universalTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.universalTimer > 0 {
                    self.universalTimer -= 1
                } else {
                    self.universalTimerCancellable?.cancel()
                    self.gameStarted = false
                    print("⏱️ Universal timer finished! Game over.")
                }
            }
    }
    
    */
    
    
    func startUniversalTimer() {
        universalTimerCancellable?.cancel()

        universalTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                if self.universalTimer > 0 {
                    self.universalTimer -= 1
                } else {
                    self.universalTimerCancellable?.cancel()

                    // ✅ remove dark modal before alert
                    self.showQuestionModal = false

                    self.roundMessage = "⏰ Time Up!\nGame Over"
                    self.showRoundAlert = true
                }
                
                
            }
    }
    
    func resetCurrentRound() {
        currentPlayer.position = 1
        players[0] = currentPlayer
        universalTimer = timerForRound(currentRound)
        startUniversalTimer()
    }
    
    /*
    func resetToRoundOne() {
            // Reset rounds, timer, player position
            universalTimer = 300
            isChampion = false
            currentPlayer.position = 1
            currentRound = 1
        }
*/
    
    
    func stopUniversalTimer() {
        universalTimerCancellable?.cancel()
    }
}
