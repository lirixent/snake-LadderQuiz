import Foundation

struct Question: Codable, Identifiable {
    var id: String { _id } // this lets SwiftUI use the MongoDB _id
    let _id: String
    let no: Int
    let category: String
    let character: String
    let questionText: String
    let options: [String: String]
    let answer: String
    let point: Int
    let agPoint: Int
    let time: Int
    let createdAt: String
    let updatedAt: String
}

struct QuestionsResponse: Codable {
    let success: Bool
    let total: Int
    let questions: [Question]
}
