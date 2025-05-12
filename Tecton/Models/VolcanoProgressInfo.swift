import SwiftUI

struct VolcanoProgressInfo: Identifiable, Codable {
    let id: UUID
    let name: String
    var isUnlocked: Bool
    let order: Int // To maintain a specific sequence on the dashboard
    var games: [GameInfo] // Games associated with this volcano
    
    init(id: UUID = UUID(), name: String, isUnlocked: Bool, order: Int, games: [GameInfo]) {
        self.id = id
        self.name = name
        self.isUnlocked = isUnlocked
        self.order = order
        self.games = games
    }
}

struct GameInfo: Identifiable, Codable {
    let id: UUID
    let name: String
    var isCompleted: Bool
    let gameType: GameType
    
    init(id: UUID = UUID(), name: String, isCompleted: Bool, gameType: GameType) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.gameType = gameType
    }
}

enum GameType: String, Codable {
    case quiz
    case wordMatch
    case puzzle
    case volcanoBuilder
} 