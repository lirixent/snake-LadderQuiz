//
//  QR.swift
//  Snake&LadderQuiz
//
//  Created by Olanrewaju.Durojaiye.a1 on 2026-04-08.
//

import SwiftUI

struct QRJoinView: View {
    let player: Player
    @State private var qrCode = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Join Game via QR")
                .font(.title2)
                .bold()

            TextField("Enter QR Code", text: $qrCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Join Game") {
                print("Joining with QR: \(qrCode)")
            }

            Button("Cancel") {
                dismiss()
            }
        }
        .padding()
    }
}
