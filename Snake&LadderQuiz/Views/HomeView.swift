import SwiftUI
import SocketIO


struct CategoriesResponse: Codable {
    let success: Bool
    let total: Int
    let categories: [String]
}

struct CharactersResponse: Codable {
    let success: Bool
    let total: Int
    let characters: [String]
}



struct HomeView: View {
    @StateObject private var viewModel = GameViewModel(
        player: Player(
            name: UserDefaults.standard.string(forKey: "playerName") ?? "Player1",
            avatar: UserDefaults.standard.string(forKey: "playerAvatar") ?? "avartar1"
        )
    )
    
    @StateObject private var socketService = SocketService.shared
    
    @State private var username: String = UserDefaults.standard.string(forKey: "playerName") ?? ""
    @State private var selectedAvatar: String = UserDefaults.standard.string(forKey: "playerAvatar") ?? "avartar1"
    
    @State private var categories: [String] = []
    @State private var selectedCategory: String = ""
    
    @State private var characters: [String] = []
    @State private var selectedCharacter: String = ""
    
    @State private var showGameView: Bool = false
    
    
    @State private var showLobbyView = false
    @State private var showQRJoinView = false
    
    
    
    @State private var isLoadingCategories = true
    @State private var isLoadingCharacters = false
    
    @State private var isLoadingGame = false
 
    
    @State private var showWebGame = false
    @State private var roomID: String = ""
    
    private let baseURL = "https://boardgames-2369.onrender.com/api/questions"
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: - Username
                TextField("Enter Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // MARK: - Avatar Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(1...11, id: \.self) { i in
                            let avatarName = "avartar\(i)"
                            Image(avatarName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(selectedAvatar == avatarName ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedAvatar = avatarName
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Category Picker
                VStack(alignment: .leading) {
                    Text("Select Category")
                        .bold()
                    if isLoadingCategories {
                        Text("Loading categories...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    
                   // (perform: loadCategories)
                    loadCategories()
                       
              /*  socketService.connect(
                        playerName: username,
                        avatar: selectedAvatar
                    )*/
                    
                    
                }
                
                // MARK: - Character Picker
                VStack(alignment: .leading) {
                    Text("Select Character")
                        .bold()
                    if isLoadingCharacters {
                        Text("Loading characters...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Character", selection: $selectedCharacter) {
                            ForEach(characters, id: \.self) { character in
                                Text(character).tag(character)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .padding(.horizontal)
                .onChange(of: selectedCategory){ _ in
                    loadCharacters()
                }
                
                // MARK: - Start Game Button
                Button(action: startGame) {
                    Text("Start Game")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedCategory.isEmpty || selectedCharacter.isEmpty || username.isEmpty
                            ? Color.gray : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedCategory.isEmpty || selectedCharacter.isEmpty || username.isEmpty)
                .padding(.horizontal)
                
                
                // MARK: - Multiplayer Buttons
                VStack(spacing: 15) {

                    Button(action: {
                        showLobbyView = true
                    }) {
                        Text("Join Multiplayer Lobby")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        showQRJoinView = true
                    }) {
                        Text("Join via QR Code")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                }
                .padding(.horizontal)

                
                
                
                
                Spacer()
            }
            
            .overlay {
                if isLoadingGame {
                    ZStack {
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()

                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)

                            Text("Loading questions...")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .padding(30)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(12)
                    }
                }
            }
            
            
            .navigationTitle("Snake & Ladder")
            .fullScreenCover(isPresented: $showGameView) {
                GameView(viewModel: viewModel)
            }
            
            
            .sheet(isPresented: $showLobbyView) {
                LobbyView(player: viewModel.currentPlayer)
            }

            .sheet(isPresented: $showQRJoinView) {
                QRJoinView(player: viewModel.currentPlayer)
            }
            
            
            
            
            
        }
    }
    
    // MARK: - Network
    private func loadCategories() {
        isLoadingCategories = true

        guard let url = URL(string: "\(baseURL)/categories") else { return }

        // ✅ Longer timeout for Render cold start
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 90
        config.timeoutIntervalForResource = 90

        let session = URLSession(configuration: config)

        session.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoadingCategories = false
            }

            if let error = error {
                print("Category load error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(CategoriesResponse.self, from: data)

                DispatchQueue.main.async {
                    print("Fetched categories:", decoded.categories)
                    self.categories = decoded.categories.sorted()

                    if self.selectedCategory.isEmpty {
                        self.selectedCategory = self.categories.first ?? ""
                    }

                    loadCharacters()
                }
            } catch {
                print("Category decode error:", error.localizedDescription)
            }
        }.resume()
    }
    
    
    /*  private func loadCharacters() {
     guard !selectedCategory.isEmpty else { return }
     isLoadingCharacters = true
     
     guard let url = URL(string: "\(baseURL)/characters?category=\(selectedCategory)") else { return }
     URLSession.shared.dataTask(with: url) { data, _, error in
     defer { isLoadingCharacters = false }
     if let error = error {
     print("Character load error:", error.localizedDescription)
     return
     }
     
     guard let data = data else { return }
     do {
     let decoded = try JSONDecoder().decode([String].self, from: data)
     DispatchQueue.main.async {
     self.characters = decoded.sorted()
     if self.selectedCharacter.isEmpty { self.selectedCharacter = self.characters.first ?? "" }
     }
     } catch {
     print("Character decode error:", error.localizedDescription)
     }
     }.resume()
     }
     
     
     
     */
    
    private func loadCharacters() {
        guard !selectedCategory.isEmpty else { return }
        
        isLoadingCharacters = true
        
        guard let encodedCategory = selectedCategory.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/characters?category=\(encodedCategory)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoadingCharacters = false
            }
            
            if let error = error {
                print("Character load error:", error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(CharactersResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.characters = decoded.characters.sorted()
                    
                    if !self.characters.contains(self.selectedCharacter) {
                        self.selectedCharacter = self.characters.first ?? ""
                    }
                }
            } catch {
                print("Character decode error:", error.localizedDescription)
            }
        }.resume()
    }
    
    
    // MARK: - Start Game
    // MARK: - Start Game
    private func startGame() {
        isLoadingGame = true

        UserDefaults.standard.set(username, forKey: "playerName")
        UserDefaults.standard.set(selectedAvatar, forKey: "playerAvatar")

        viewModel.currentPlayer.name = username
        viewModel.currentPlayer.avatar = selectedAvatar

        viewModel.loadQuestions(category: selectedCategory, character: selectedCharacter) {
            DispatchQueue.main.async {
                self.isLoadingGame = false

                // ✅ START universal timer BEFORE opening GameView
                self.viewModel.startUniversalTimer()

                // ✅ then open game screen
                self.showGameView = true
            }
        }
    }
}
