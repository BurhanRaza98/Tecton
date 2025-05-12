import Foundation
import SwiftUI
import Combine

class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    @Published var volcanoLevels: [VolcanoProgressInfo] = [
        VolcanoProgressInfo(
            name: "Mount Vesuvius", 
            isUnlocked: true, // First volcano is always unlocked
            order: 1,
            games: [
                GameInfo(name: "Volcano Quiz", isCompleted: false, gameType: .quiz),
                GameInfo(name: "Lava Match", isCompleted: false, gameType: .wordMatch),
                GameInfo(name: "Volcano Builder", isCompleted: false, gameType: .volcanoBuilder)
            ]
        ),
        VolcanoProgressInfo(
            name: "Mount St. Helens", 
            isUnlocked: false, // Initially locked
            order: 2,
            games: [
                GameInfo(name: "Volcano Quiz", isCompleted: false, gameType: .quiz),
                GameInfo(name: "Ash Match", isCompleted: false, gameType: .wordMatch),
                GameInfo(name: "Volcano Builder", isCompleted: false, gameType: .volcanoBuilder)
            ]
        ),
        VolcanoProgressInfo(
            name: "Mount Fuji", 
            isUnlocked: false, // Initially locked
            order: 3,
            games: [
                GameInfo(name: "Volcano Quiz", isCompleted: false, gameType: .quiz),
                GameInfo(name: "Symbol Match", isCompleted: false, gameType: .wordMatch),
                GameInfo(name: "Volcano Builder", isCompleted: false, gameType: .volcanoBuilder)
            ]
        )
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadProgress()
        
        // Set up auto-save when data changes
        $volcanoLevels
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveProgress()
            }
            .store(in: &cancellables)
    }
    
    // Mark a specific game as completed for a volcano
    func markGameCompleted(volcanoName: String, gameType: GameType) {
        guard let volcanoIndex = volcanoLevels.firstIndex(where: { $0.name == volcanoName }) else { return }
        
        // Find the game index
        if let gameIndex = volcanoLevels[volcanoIndex].games.firstIndex(where: { $0.gameType == gameType }) {
            // Only mark as completed if it wasn't already
            if !volcanoLevels[volcanoIndex].games[gameIndex].isCompleted {
                // Mark this game as completed
                volcanoLevels[volcanoIndex].games[gameIndex].isCompleted = true
                
                // Check if we should unlock the next volcano
                checkAndUnlockNextVolcano(currentVolcanoIndex: volcanoIndex)
                
                // Check for new achievements
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    AchievementManager.shared.checkForNewAchievements()
                }
            }
        }
    }
    
    // Check if all games for a volcano are completed and unlock the next volcano if needed
    private func checkAndUnlockNextVolcano(currentVolcanoIndex: Int) {
        // Skip if this is the last volcano
        guard currentVolcanoIndex < volcanoLevels.count - 1 else { return }
        
        // Check if all games for the current volcano are completed
        let allGamesCompleted = volcanoLevels[currentVolcanoIndex].games.allSatisfy { $0.isCompleted }
        
        if allGamesCompleted {
            // All games are completed, unlock the next volcano
            volcanoLevels[currentVolcanoIndex + 1].isUnlocked = true
        }
    }
    
    // Save progress to UserDefaults
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(volcanoLevels) {
            UserDefaults.standard.set(encoded, forKey: "volcanoProgress")
        }
    }
    
    // Load progress from UserDefaults
    private func loadProgress() {
        if let savedData = UserDefaults.standard.data(forKey: "volcanoProgress"),
           let decoded = try? JSONDecoder().decode([VolcanoProgressInfo].self, from: savedData) {
            volcanoLevels = decoded
        }
    }
    
    // Reset all progress (mainly for testing)
    func resetAllProgress() {
        // Reset completion status for all volcanoes
        for i in 0..<volcanoLevels.count {
            // First volcano is always unlocked
            volcanoLevels[i].isUnlocked = (i == 0)
            
            // Reset all games to not completed
            for j in 0..<volcanoLevels[i].games.count {
                volcanoLevels[i].games[j].isCompleted = false
            }
        }
    }
} 