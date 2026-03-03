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
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: ResultAlertPresenter?
    
    private let borderWidth: CGFloat = 8
    private let cornerRadius: CGFloat = 20
    private let buttonCornerRadius: CGFloat = 15
    private let answerDelay: Double = 1.0
    
    private enum UIConstants {
        static let greenColor = "YPGreen"
        static let redColor = "YPRed"
        static let networkErrorTitle = "Что-то пошло не так("
        static let retryButtonText = "Попробовать ещё раз"
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        alertPresenter = ResultAlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
        questionIndexLabel.accessibilityIdentifier = "Index"
        yesButton.accessibilityIdentifier = "Yes"
        noButton.accessibilityIdentifier = "No"
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        presenter.noButtonTapped()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        posterImageView.layer.cornerRadius = cornerRadius
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
        
        for button in [noButton, yesButton] {
            button?.layer.cornerRadius = buttonCornerRadius
            button?.clipsToBounds = true
        }
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}

// MARK: - MovieQuizViewControllerProtocol

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    
    func show(quiz step: QuizStepViewModel) {
        posterImageView.image = UIImage(data: step.image)
        questionLabel.text = step.question
        questionIndexLabel.text = step.questionNumber
        questionTitleLabel.text = "Вопрос:"
        posterImageView.layer.borderWidth = 0
        posterImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.presenter.restartGame()
        }
        alertPresenter?.show(model: model)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        setButtonsEnabled(false)
        posterImageView.layer.borderWidth = borderWidth
        posterImageView.layer.borderColor = isCorrectAnswer
            ? UIColor(named: UIConstants.greenColor)?.cgColor
            : UIColor(named: UIConstants.redColor)?.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + answerDelay) { [weak self] in
            guard let self else { return }
            self.setButtonsEnabled(true)
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: UIConstants.networkErrorTitle,
            message: message,
            buttonText: UIConstants.retryButtonText
        ) { [weak self] in
            self?.presenter.restartGame()
        }
        alertPresenter?.show(model: model)
    }
}
