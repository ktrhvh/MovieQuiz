import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    var totalAccuracy: Double { get }
    func store(correct: Int, total: Int)
}

struct GameRecord {
    let correct: Int
    let total: Int
    let date: Date
}
