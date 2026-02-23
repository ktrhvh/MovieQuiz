import Foundation

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

final class QuestionFactory {
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 9?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 8?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 8?", correctAnswer: false),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 8?", correctAnswer: false),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 7?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 7?", correctAnswer: false),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма меньше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма меньше чем 5?", correctAnswer: true),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 5?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    func question(at index: Int) -> QuizQuestion? {
        guard index >= 0 && index < questions.count else { return nil }
        return questions[index]
    }
    
    var count: Int { questions.count }
}
