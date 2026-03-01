import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var questionIndexLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var alertPresenter: ResultAlertPresenter?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    
    private let borderWidth: CGFloat = 8
    private let cornerRadius: CGFloat = 20
    private let answerDelay: Double = 1.0
    private let dateFormat = "dd.MM.yyyy HH:mm"
    private let questionTitle = "Вопрос:"
    private let alertTitle = "Этот раунд окончен!"
    private let alertButtonText = "Сыграть ещё раз"
    private let questionsAmount = 10
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = cornerRadius
        alertPresenter = ResultAlertPresenter(viewController: self)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        checkAnswer(false)
    }
    
    // MARK: - Private Methods
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showCurrentQuestion(_ question: QuizQuestion) {
        currentQuestion = question
        posterImageView.image = UIImage(data: question.image)
        questionLabel.text = question.text
        questionTitleLabel.text = questionTitle
        questionIndexLabel.text = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        posterImageView.layer.borderWidth = 0
        posterImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func checkAnswer(_ answer: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = answer == currentQuestion.correctAnswer
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
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let bestDate = formatter.string(from: statisticService.bestGame.date)
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
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
            self.showLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(model: model)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.show(model: model)
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        hideLoadingIndicator()
        showCurrentQuestion(question)
    }
}
