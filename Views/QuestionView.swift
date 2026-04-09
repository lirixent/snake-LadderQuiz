import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            
            // MARK: - Question Timer
            if let _ = viewModel.currentQuestion {
                Text("Time left: \(viewModel.questionTimer)s")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            // MARK: - Question Text
            if let question = viewModel.currentQuestion {
                Text(question.text)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // MARK: - Answer Options
                ForEach(question.options, id: \.self) { option in
                    Button(action: {
                        checkAnswer(option: option)
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.isMoving) // Disable while player is moving
                }
            } else {
                // Loading state
                Text("Loading Question...")
                    .foregroundColor(.gray)
            }
            
            // MARK: - Double 6 Message
            if viewModel.showDoubleSixMessage {
                Text("DOUBLE 6! Roll again!")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.top, 5)
            }
        }
        .padding()
        .onAppear {
            // Start question timer when view appears
            viewModel.startQuestionTimer()
        }
    }
    
    // MARK: - Check Answer
    private func checkAnswer(option: String) {
        guard let question = viewModel.currentQuestion else { return }
        
        if option == question.correctAnswer {
            // Correct answer sound
            GameSoundManager.shared.playSound("correct")
            
            // Roll dice after correct answer
            let steps = viewModel.rollDice()
            
            // 🚨 Only move if NOT double 6
            if !viewModel.lastRollWasDoubleSix {
                viewModel.moveCurrentPlayer(steps: steps)
            }
            
        } else {
            // Wrong answer sound
            GameSoundManager.shared.playSound("wrong")
        }
        
        // Move to next question
        viewModel.nextQuestion()
    }
}