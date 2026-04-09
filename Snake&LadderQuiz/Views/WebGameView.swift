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

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let urlString = "https://boardgames-2369.onrender.com/boardgame.html?room=\(roomID)&player=\(playerName)"
        
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            webView.load(URLRequest(url: url))
        }
    }
}
