import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    // MARK: - Properties
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount) }
    }
    
    var bestGame: GameRecord {
        get {
            let correct = userDefaults.integer(forKey: Keys.bestCorrect)
            let total = userDefaults.integer(forKey: Keys.bestTotal)
            let date = userDefaults.object(forKey: Keys.bestDate) as? Date ?? Date()
            return GameRecord(correct: correct, total: total, date: date)
        }
        set {
            userDefaults.set(newValue.correct, forKey: Keys.bestCorrect)
            userDefaults.set(newValue.total, forKey: Keys.bestTotal)
            userDefaults.set(newValue.date, forKey: Keys.bestDate)
        }
    }
    
    var totalAccuracy: Double {
        let correct = userDefaults.integer(forKey: Keys.totalCorrect)
        let total = userDefaults.integer(forKey: Keys.totalQuestions)
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * percentMultiplier
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let percentMultiplier: Double = 100
    
    private enum Keys {
        static let gamesCount = "gamesCount"
        static let bestCorrect = "bestCorrect"
        static let bestTotal = "bestTotal"
        static let bestDate = "bestDate"
        static let totalCorrect = "totalCorrect"
        static let totalQuestions = "totalQuestions"
    }
    
    // MARK: - Methods
    
    func store(correct: Int, total: Int) {
        gamesCount += 1
        
        let totalCorrect = userDefaults.integer(forKey: Keys.totalCorrect) + correct
        let totalQuestions = userDefaults.integer(forKey: Keys.totalQuestions) + total
        userDefaults.set(totalCorrect, forKey: Keys.totalCorrect)
        userDefaults.set(totalQuestions, forKey: Keys.totalQuestions)
        
        if correct > bestGame.correct {
            bestGame = GameRecord(correct: correct, total: total, date: Date())
        }
    }
}
