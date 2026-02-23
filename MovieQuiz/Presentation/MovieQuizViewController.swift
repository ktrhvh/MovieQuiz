import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var questionIndexLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Properties
    
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
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
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showCurrentQuestion()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        checkAnswer(false)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        posterImageView.layer.cornerRadius = 20
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
        
        for button in [noButton, yesButton] {
            button?.layer.cornerRadius = 15
            button?.clipsToBounds = true
        }
    }
    
    private func showCurrentQuestion() {
        let question = questions[currentQuestionIndex]
        posterImageView.image = UIImage(named: question.image)
        questionLabel.text = question.text
        questionTitleLabel.text = "Вопрос:"
        questionIndexLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        posterImageView.layer.borderWidth = 0
        posterImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func checkAnswer(_ answer: Bool) {
        let isCorrect = answer == questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect)
    }
    
    private func showAnswerResult(_ isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        
        view.isUserInteractionEnabled = false
        
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrect
            ? UIColor(named: "YPGreen")?.cgColor
            : UIColor(named: "YPRed")?.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.view.isUserInteractionEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }
    
    private func showResults() {
        let alert = UIAlertController(
            title: "Раунд окончен!",
            message: "Ваш результат: \(correctAnswers)/\(questions.count)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Сыграть ещё раз", style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showCurrentQuestion()
        })
        present(alert, animated: true)
    }
}
