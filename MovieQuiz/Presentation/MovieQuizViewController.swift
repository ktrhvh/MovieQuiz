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
    
    private let questionFactory = QuestionFactory()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var alertPresenter: ResultAlertPresenter?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let borderWidth: CGFloat = 8
    private let cornerRadius: CGFloat = 20
    private let answerDelay: Double = 1.0
    private let dateFormat = "dd.MM.yyyy HH:mm"
    private let questionTitle = "Вопрос:"
    private let alertTitle = "Этот раунд окончен!"
    private let alertButtonText = "Сыграть ещё раз"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = cornerRadius
        alertPresenter = ResultAlertPresenter(viewController: self)
        showCurrentQuestion()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped(_ sender: UIButto		n) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        checkAnswer(false)
    }
    
    // MARK: - Private Methods
    
    private func showCurrentQuestion() {
        guard let question = questionFactory.question(at: currentQuestionIndex) else { return }
        posterImageView.image = UIImage(named: question.image)
        questionLabel.text = question.text
        questionTitleLabel.text = questionTitle
        questionIndexLabel.text = "\(currentQuestionIndex + 1)/\(questionFactory.count)"
        posterImageView.layer.borderWidth = 0
        posterImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func checkAnswer(_ answer: Bool) {
        guard let question = questionFactory.question(at: currentQuestionIndex) else { return }
        let isCorrect = answer == question.correctAnswer
        showAnswerResult(isCorrect)
    }
    
    private func showAnswerResult(_ isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        
        view.isUserInteractionEnabled = false
        posterImageView.layer.borderWidth = borderWidth
        posterImageView.layer.borderColor = isCorrect
            ? UIColor(named: "YPGreen")?.cgColor
            : UIColor(named: "YPRed")?.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + answerDelay) { [weak self] in
            guard let self else { return }
            self.view.isUserInteractionEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionFactory.count - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }
    
    private func showResults() {
        statisticService.store(correct: correctAnswers, total: questionFactory.count)
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let bestDate = formatter.string(from: statisticService.bestGame.date)
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionFactory.count)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestDate))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        let model = AlertModel(
            title: alertTitle,
            message: message,
            buttonText: alertButtonText
        ) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showCurrentQuestion()
        }
        
        alertPresenter?.show(model: model)
    }
}
