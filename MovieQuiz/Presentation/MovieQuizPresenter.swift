import Foundation

final class MovieQuizPresenter {
    
    // MARK: - Properties
    
    let questionsAmount = 10
    private var currentQuestionIndex = 0
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    
    private var questionFactory: QuestionFactory?
    private let statisticService: StatisticServiceProtocol
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private let dateFormat = "dd.MM.yyyy HH:mm"
    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = dateFormat
        return f
    }()
    
    // MARK: - Init
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - Public Methods
    
    func yesButtonTapped() {
        checkAnswer(true)
    }
    
    func noButtonTapped() {
        checkAnswer(false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestDate = dateFormatter.string(from: statisticService.bestGame.date)
            let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestDate))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: result)
        } else {
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAnswer(_ answer: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect { correctAnswers += 1 }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}
