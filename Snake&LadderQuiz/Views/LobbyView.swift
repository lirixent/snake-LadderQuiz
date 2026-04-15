//
//  LobbyView.swift
//  Snake&LadderQuiz
//
//  Created by Olanrewaju.Durojaiye.a1 on 2026-04-08.
//

import SwiftUI

struct LobbyView: View {
    let player: Player
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var socketService = SocketService.shared
    
    @State private var showWebGame = false
    @State private var roomID = "room1"

    

   // @State private var startGame = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Waiting in Multiplayer Lobby...")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                           Text("Players in this session:")
                               .font(.headline)
                           
                           ForEach(socketService.roomPlayers) { p in
                               HStack(spacing: 15) {
                                   Image(p.avatar)
                                       .resizable()
                                       .frame(width: 50, height: 50)
                                       .clipShape(Circle())

                                   Text(p.name)
                                       .bold()
                                   
                                   if p.name == player.name {
                                       Text("(You)")
                                           .foregroundColor(.blue)
                                   }
                                   
                                   if p.isSpectator {
                                       Text("(Watching)")
                                           .foregroundColor(.gray)
                                           .italic()
                                   }
                               }
                           }
                       }
                       .padding()
                       .frame(maxHeight: 300)
                       .background(Color.gray.opacity(0.1))
                       .cornerRadius(10)

                       ProgressView("Waiting for session to start...")
                           .padding(.top, 10)
            
          /** TestFlight has started soit is time to remove it */
            /*
            // 🔧 TEMP TEST ONLY - REMOVE AFTER TESTFLIGHT
            Button("Start Game (Test Mode)") {
                startGame = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 10)
            
            */

                       Button("Leave Lobby") {
                           socketService.leaveRoom(playerName: player.name)
                           dismiss()
                       }
                       .padding()
                       .foregroundColor(.red)
                   }
        .padding()
        .onAppear {
            socketService.connect(
                playerName: player.name,
                avatar: player.avatar
            )

            socketService.onGameStarted = {
                DispatchQueue.main.async {
                    showWebGame = true
                }
            }
        }
        
        .fullScreenCover(isPresented: $showWebGame) {
            WebGameView(
                roomID: roomID,
                playerName: player.name
            )
        }
        
        
                 /*  .onDisappear {
                       socketService.disconnect()
                   }*/
        
     /*   // 🔧 TEMP TEST ONLY - REMOVE AFTER TESTFLIGHT
        Button("Start Game (Test Mode)") {
            startGame = true
        }
      
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding(.top, 10)
      
      */
               }
           }

