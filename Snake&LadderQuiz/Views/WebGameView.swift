//
//  WebGameView.swift
//  Snake&LadderQuiz
//
//  Created by Olanrewaju.Durojaiye.a1 on 2026-04-08.
//

import SwiftUI
import WebKit

struct WebGameView: UIViewRepresentable {
    let roomID: String
    let playerName: String
    let avatar: String
    

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let safePlayer = playerName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? playerName
        let safeAvatar = avatar.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? avatar

        let urlString = "https://boardgames-2369.onrender.com/boardgame.html?room=\(roomID)&player=\(safePlayer)&avatar=\(safeAvatar)"

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    
}
