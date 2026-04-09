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
                Text(question.questionText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                
                // MARK: - Answer Options
                
                ForEach(question.options.keys.sorted(), id: \.self) { key in
                    Button(action: {
                        checkAnswer(option: key)
                    }) {
                        Text("\(key). \(question.options[key] ?? "")")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.isMoving)
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
        
        if option == question.answer {
            GameSoundManager.shared.playSound("correct")
            
            viewModel.gameMessage = "✅ Correct! Moving \(viewModel.pendingDiceSteps) steps"
            viewModel.moveCurrentPlayer(steps: viewModel.pendingDiceSteps)
            
        } else {
            GameSoundManager.shared.playSound("wrong")
            
            viewModel.gameMessage = "❌ Wrong answer. Stay on current spot"
        }
        
        viewModel.showQuestionModal = false
        viewModel.stopQuestionTimer()
        viewModel.nextQuestion()
    }
}
