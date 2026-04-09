import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
/*
            // ✅ Floating timer overlay
            Text("⏰ Time left: \(viewModel.universalTimer)s")
                .font(.headline)
                .foregroundColor(.red)
                .padding(.top, 55)
                .zIndex(100)
            */
            
            
            // Main game screen
            VStack {
                
                // MARK: - Universal Timer
                // MARK: - Universal Timer (STABLE)
               // Text("Time left: \(viewModel.universalTimer)s")
                //    .font(.headline)
                ///    .foregroundColor(.red)
                //    .padding(.top)


                // MARK: - Game Message (DYNAMIC)
                Text(viewModel.gameMessage)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                
                
                
                // MARK: - Board
                GeometryReader { geo in
                    ZStack {
                        Image("snakesandladdersboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)
                        
                        Image(viewModel.currentPlayer.avatar)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .position(boardPosition(for: viewModel.currentPlayer.position, boardWidth: geo.size.width))
                    }
                    .onAppear {
                       // viewModel.startUniversalTimer()
                        
                        viewModel.updateScreenWidth(geo.size.width)
                    }
                }
                .frame(height: UIScreen.main.bounds.width * (2245 / 1587))
                
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
                
                Spacer()
            }
            
            // MARK: - Question Modal Overlay
            if viewModel.showQuestionModal {
                VStack {
                    Spacer()
                    
                    Color.black.opacity(0.25)
                        .frame(height: UIScreen.main.bounds.width * (2245 / 1587))
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .horizontal)
                
                VStack {
                    Spacer()
                    
                    QuestionView(viewModel: viewModel)
                        .frame(width: 360)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            
            
        }
        
        .safeAreaInset(edge: .top) {
                    Text("⏰ Time left: \(viewModel.universalTimer)s")
                        .font(.headline)
                        .foregroundColor(.red)
            
                        .padding(.top, 20) // extra space from notch/speaker
                        .padding(.top, 50) // drops it below notch/speaker
                                   .padding(.bottom, 8)
            
                }
        
        .alert(viewModel.roundMessage, isPresented: $viewModel.showRoundAlert) {
            Button("OK") {
                if viewModel.universalTimer == 0 {
                    viewModel.resetToRoundOne()
                } else {
                    viewModel.proceedToNextRound()
                }
            }
        }
        
        // MARK: - Timers
        
        //.onAppear {
         //   viewModel.startUniversalTimer()
       // }
        .onDisappear {
            viewModel.stopUniversalTimer()
        }
    }
    
    // MARK: - Roll Dice Action
    private func rollDiceTapped() {
        guard !viewModel.showQuestionModal else { return }
        
        let steps = viewModel.rollDice()
        
        viewModel.pendingDiceSteps = steps
        viewModel.gameMessage = "🎲 You rolled \(steps)"
        viewModel.showQuestionModal = true
        viewModel.startQuestionTimer()
    }
    
    // MARK: - Calculate Player Position on Board (bottom-right zigzag)
    private func boardPosition(for square: Int, boardWidth: CGFloat) -> CGPoint {
        let boardHeight = boardWidth * (2245 / 1587) // preserve ratio
        let totalSquares = 63
        let cols = 7
        
        let row = (square - 1) / cols
        let colInRow = (square - 1) % cols
        
        let xOffset: CGFloat
        if row % 2 == 0 {
            xOffset = boardWidth - CGFloat(colInRow + 1) * (boardWidth / CGFloat(cols)) + (boardWidth / CGFloat(cols) / 2)
        } else {
            xOffset = CGFloat(colInRow) * (boardWidth / CGFloat(cols)) + (boardWidth / CGFloat(cols) / 2)
        }
        
        let yOffset = boardHeight - CGFloat(row + 1) * (boardHeight / CGFloat((totalSquares / cols) + 1)) + (boardHeight / CGFloat((totalSquares / cols) + 1) / 2)
        
        return CGPoint(x: xOffset, y: yOffset - 4)
    }
    
    
    // MARK: - Handle Round Alert
    private func handleRoundAlert() {
        if viewModel.universalTimer == 0 {
            viewModel.resetToRoundOne()
        } else {
            viewModel.proceedToNextRound()
        }
    }
}
