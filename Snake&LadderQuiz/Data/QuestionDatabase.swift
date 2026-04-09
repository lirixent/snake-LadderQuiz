import Foundation
import SQLite

class QuestionDatabase {
    
    static let shared = QuestionDatabase()
    
    private var db: Connection!
    
    private let questionsTable = Table("questions")
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let options = Expression<String>("options") // JSON encoded array
    private let correctAnswer = Expression<String>("correctAnswer")
    private let category = Expression<String>("category")
    private let character = Expression<String>("character")
    private let no = Expression<Int>("no")
    
    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/questions.sqlite3")
            try createTable()
        } catch {
            print("SQLite initialization error: \(error)")
        }
    }
    
    private func createTable() throws {
        try db.run(questionsTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(text)
            t.column(options)
            t.column(correctAnswer)
            t.column(category)
            t.column(character)
            t.column(no)
        })
    }
    
    func save(question: Question) {
        do {
            let optionsData = try JSONEncoder().encode(question.options)
            let optionsString = String(data: optionsData, encoding: .utf8)!
            
            let insert = questionsTable.insert(
               
                id <- question.id,
                
                text <- question.questionText,
                options <- optionsString,
                correctAnswer <- question.answer,
                category <- question.category,
                character <- question.character,
                no <- question.no
            )
            try db.run(insert)
        } catch {
            print("Error saving question: \(error)")
        }
    }
    
    func loadQuestions(category selectedCategory: String, character selectedCharacter: String) -> [Question] {
        var result: [Question] = []
        do {
            let query = questionsTable.filter(self.category == selectedCategory && self.character == selectedCharacter)
            for row in try db.prepare(query) {
                if let optionsData = row[options].data(using: .utf8),
                   
                    
                    let optionsDictionary = try? JSONDecoder().decode([String: String].self, from: optionsData) {

                    
                    let question = Question(
                                _id: row[id],
                                no: row[no],
                                category: row[category],
                                character: row[character],
                                questionText: row[text],
                                options: optionsDictionary,
                                answer: row[correctAnswer],
                                point: 5,
                                agPoint: 2,
                                time: 30,
                                createdAt: "",
                                updatedAt: ""
                                           
                    )
                    
                    result.append(question)
                }
            }
        } catch {
            print("Error loading questions: \(error)")
        }
        return result
    }
    
    func questionCount(category selectedCategory: String, character selectedCharacter: String) -> Int {
        do {
            let query = questionsTable.filter(self.category == selectedCategory && self.character == selectedCharacter)
            return try db.scalar(query.count)
        } catch {
            return 0
        }
    }
}
