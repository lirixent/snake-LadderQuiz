import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            
            // MARK: - Universal Timer
            Text("Time left: \(viewModel.universalTimer)s")
                .font(.headline)
                .foregroundColor(.red)
                .padding(.top)
            
            // MARK: - Board
            ZStack {
                // Board Image
                Image("snakesandladdersboard")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400)
                
                // Player Avatar
                Image(viewModel.currentPlayer.avatar)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .position(boardPosition(for: viewModel.currentPlayer.position))
            }
            .padding()
            
            // MARK: - Dice
            HStack(spacing: 20) {
                ForEach(viewModel.diceRolls.prefix(2), id: \.self) { roll in
                    Image("dice-\(roll)")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            .padding()
            
            // MARK: - Roll Dice Button
            Button(action: rollDiceTapped) {
                Text(viewModel.canRollAgain ? "Roll Again!" : "Roll Dice")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isMoving ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.isMoving)
            .padding(.horizontal)
            
            // MARK: - Leaderboard (Single-player)
            VStack(spacing: 5) {
                Text("Leaderboard")
                    .font(.headline)
                Text("\(viewModel.currentPlayer.name): \(viewModel.currentPlayer.position)")
            }
            .padding()
            
            // MARK: - Question View
            QuestionView(viewModel: viewModel)
                .padding(.top)
            
            Spacer()
        }
        .onAppear {
            viewModel.startUniversalTimer()
        }
        .onDisappear {
            viewModel.stopUniversalTimer()
        }
    }
    
    // MARK: - Roll Dice Action
    private func rollDiceTapped() {
        let steps = viewModel.rollDice()
        
        if viewModel.canRollAgain {
            // Reset double 6 flags to allow user to roll again
            viewModel.canRollAgain = false
            viewModel.showDoubleSixMessage = false
        } else {
            viewModel.moveCurrentPlayer(steps: steps)
        }
        
        // Start question timer if not already running
        viewModel.startQuestionTimer()
    }
    
    // MARK: - Calculate Player Position on Board (bottom-right zigzag)
    private func boardPosition(for square: Int) -> CGPoint {
        // Board dimensions
        let boardWidth: CGFloat = 400
        let boardHeight: CGFloat = 400 * (2245 / 1578) // Maintain aspect ratio
        
        // Rows and columns
        let totalSquares = 63
        let cols = 7
        let row = (square - 1) / cols
        let colInRow = (square - 1) % cols
        
        // Zigzag: even rows right-to-left, odd rows left-to-right
        let xOffset: CGFloat
        if row % 2 == 0 {
            xOffset = boardWidth - CGFloat(colInRow + 1) * (boardWidth / CGFloat(cols)) + (boardWidth / CGFloat(cols) / 2)
        } else {
            xOffset = CGFloat(colInRow) * (boardWidth / CGFloat(cols)) + (boardWidth / CGFloat(cols) / 2)
        }
        
        let yOffset = boardHeight - CGFloat(row + 1) * (boardHeight / CGFloat((totalSquares / cols) + 1)) + (boardHeight / CGFloat((totalSquares / cols) + 1) / 2)
        
        return CGPoint(x: xOffset, y: yOffset)
    }
}