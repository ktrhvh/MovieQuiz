import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

struct QuizQuestion {
    let image: Data
    let text: String
    let correctAnswer: Bool
}

final class QuestionFactory {
    
    // MARK: - Properties
    
    weak var delegate: QuestionFactoryDelegate?
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    private enum Constants {
        static let questionsCount = 10
        static let ratingThreshold = 7.0
    }
    
    // MARK: - Init
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let threshold = Float(Int.random(in: 6...8))
            let isMoreThan = Bool.random()
            
            let text = isMoreThan
            ? "Рейтинг этого фильма больше чем \(Int(threshold))?"
            : "Рейтинг этого фильма меньше чем \(Int(threshold))?"
            
            let correctAnswer = isMoreThan
            ? rating > threshold
            : rating < threshold
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
