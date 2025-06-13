import Foundation
import SwiftUI
import UserNotifications

// Achievement badge model
struct Achievement: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let volcanoName: String
    let badgeIcon: String
    let badgeColor: Color
    let requiredGames: Int
    let customBadgeImage: String?
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}

// Achievement level for a volcano
enum AchievementLevel: Int, CaseIterable {
    case bronze = 1
    case silver = 2
    case gold = 3
    
    var name: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        }
    }
    
    var icon: String {
        switch self {
        case .bronze: return "medal.fill"
        case .silver: return "medal.fill"
        case .gold: return "medal.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bronze: return Color(hex: "#CD7F32")
        case .silver: return Color(hex: "#C0C0C0")
        case .gold: return Color(hex: "#FFD700")
        }
    }
}

// Badge image size
enum BadgeSize {
    case small
    case medium
    case large
    
    var dimension: CGFloat {
        switch self {
        case .small: return 30
        case .medium: return 60
        case .large: return 90
        }
    }
}

// Achievement manager
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = []
    @Published var newlyEarnedAchievement: Achievement? = nil
    
    // Track which achievements have been shown in notifications
    private var notifiedAchievements: Set<UUID> = []
    
    // Achievement definitions
    let vesuviusAchievements = [
        Achievement(
            title: "Vesuvius Novice",
            description: "Complete 1 mini-game for Mount Vesuvius",
            volcanoName: "Mount Vesuvius",
            badgeIcon: "mountain.2.fill",
            badgeColor: AchievementLevel.bronze.color,
            requiredGames: 1,
            customBadgeImage: "Vesuvius Novice"
        ),
        Achievement(
            title: "Vesuvius Explorer",
            description: "Complete 2 mini-games for Mount Vesuvius",
            volcanoName: "Mount Vesuvius",
            badgeIcon: "mountain.2.fill",
            badgeColor: AchievementLevel.silver.color,
            requiredGames: 2,
            customBadgeImage: "Vesuvius Explorer"
        ),
        Achievement(
            title: "Vesuvius Master",
            description: "Complete all mini-games for Mount Vesuvius",
            volcanoName: "Mount Vesuvius",
            badgeIcon: "mountain.2.fill",
            badgeColor: AchievementLevel.gold.color,
            requiredGames: 3,
            customBadgeImage: "Vesuvius Master"
        )
    ]
    
    let stHelensAchievements = [
        Achievement(
            title: "St. Helens Novice",
            description: "Complete 1 mini-game for Mount St. Helens",
            volcanoName: "Mount St. Helens",
            badgeIcon: "flame.fill",
            badgeColor: AchievementLevel.bronze.color,
            requiredGames: 1,
            customBadgeImage: "St Helens Novice"
        ),
        Achievement(
            title: "St. Helens Explorer",
            description: "Complete 2 mini-games for Mount St. Helens",
            volcanoName: "Mount St. Helens",
            badgeIcon: "flame.fill",
            badgeColor: AchievementLevel.silver.color,
            requiredGames: 2,
            customBadgeImage: "St Helens Explorer"
        ),
        Achievement(
            title: "St. Helens Master",
            description: "Complete all mini-games for Mount St. Helens",
            volcanoName: "Mount St. Helens",
            badgeIcon: "flame.fill",
            badgeColor: AchievementLevel.gold.color,
            requiredGames: 3,
            customBadgeImage: "St Helens Master"
        )
    ]
    
    let fujiAchievements = [
        Achievement(
            title: "Fuji Novice",
            description: "Complete 1 mini-game for Mount Fuji",
            volcanoName: "Mount Fuji",
            badgeIcon: "snowflake",
            badgeColor: AchievementLevel.bronze.color,
            requiredGames: 1,
            customBadgeImage: "Fuji Novice"
        ),
        Achievement(
            title: "Fuji Explorer",
            description: "Complete 2 mini-games for Mount Fuji",
            volcanoName: "Mount Fuji",
            badgeIcon: "snowflake",
            badgeColor: AchievementLevel.silver.color,
            requiredGames: 2,
            customBadgeImage: "Fuji Explorer"
        ),
        Achievement(
            title: "Fuji Master",
            description: "Complete all mini-games for Mount Fuji",
            volcanoName: "Mount Fuji",
            badgeIcon: "snowflake",
            badgeColor: AchievementLevel.gold.color,
            requiredGames: 3,
            customBadgeImage: "Fuji Master"
        )
    ]
    
    // Special achievements
    let specialAchievements = [
        Achievement(
            title: "Volcano Expert",
            description: "Complete all mini-games for all volcanoes",
            volcanoName: "All Volcanoes",
            badgeIcon: "star.fill",
            badgeColor: Color(hex: "#FFD700"),
            requiredGames: 9,
            customBadgeImage: nil
        )
    ]
    
    private init() {
        // Combine all achievement definitions
        achievements = vesuviusAchievements + stHelensAchievements + fujiAchievements + specialAchievements
    }
    
    // Get earned achievements based on current progress
    func getEarnedAchievements() -> [Achievement] {
        var earned: [Achievement] = []
        
        // Count completed games for each volcano
        let vesuviusCompleted = countCompletedGames(for: "Mount Vesuvius")
        let stHelensCompleted = countCompletedGames(for: "Mount St. Helens")
        let fujiCompleted = countCompletedGames(for: "Mount Fuji")
        
        // Check Vesuvius achievements
        for achievement in vesuviusAchievements {
            if vesuviusCompleted >= achievement.requiredGames {
                earned.append(achievement)
            }
        }
        
        // Check St. Helens achievements
        for achievement in stHelensAchievements {
            if stHelensCompleted >= achievement.requiredGames {
                earned.append(achievement)
            }
        }
        
        // Check Fuji achievements
        for achievement in fujiAchievements {
            if fujiCompleted >= achievement.requiredGames {
                earned.append(achievement)
            }
        }
        
        // Check special achievements
        let totalCompleted = vesuviusCompleted + stHelensCompleted + fujiCompleted
        for achievement in specialAchievements {
            if totalCompleted >= achievement.requiredGames {
                earned.append(achievement)
            }
        }
        
        return earned
    }
    
    // Count completed games for a specific volcano
    private func countCompletedGames(for volcanoName: String) -> Int {
        let progressManager = ProgressManager.shared
        
        if let volcano = progressManager.volcanoLevels.first(where: { $0.name == volcanoName }) {
            return volcano.games.filter { $0.isCompleted }.count
        }
        
        return 0
    }
    
    // Check if a specific achievement is earned
    func isAchievementEarned(_ achievement: Achievement) -> Bool {
        return getEarnedAchievements().contains(where: { $0.id == achievement.id })
    }
    
    // Get achievement progress for a specific volcano (0-3 games completed)
    func getAchievementProgress(for volcanoName: String) -> Int {
        return countCompletedGames(for: volcanoName)
    }
    
    // Get the total achievement progress percentage across all volcanoes
    func getTotalProgressPercentage() -> Double {
        let progressManager = ProgressManager.shared
        let totalGames = progressManager.volcanoLevels.reduce(0) { $0 + $1.games.count }
        let completedGames = progressManager.volcanoLevels.reduce(0) { $0 + $1.games.filter { $0.isCompleted }.count }
        
        guard totalGames > 0 else { return 0 }
        return Double(completedGames) / Double(totalGames)
    }
    
    // Check for newly earned achievements
    func checkForNewAchievements() {
        // Check if notifications are enabled
        let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        if !notificationsEnabled {
            return // Skip checking if notifications are disabled
        }
        
        // Check each achievement
        for achievement in achievements {
            let isEarned = isAchievementEarned(achievement)
            
            // If this is newly earned and not yet notified
            if isEarned && !notifiedAchievements.contains(achievement.id) {
                // Mark as notified
                notifiedAchievements.insert(achievement.id)
                
                // Update UI with newly earned achievement
                DispatchQueue.main.async {
                    self.newlyEarnedAchievement = achievement
                }
                
                // Save notification status to UserDefaults
                let notifiedStrings = notifiedAchievements.map { $0.uuidString }
                UserDefaults.standard.set(notifiedStrings, forKey: "notifiedAchievements")
                
                // Send push notification
                sendAchievementNotification(achievement)
                
                // Only notify about one achievement at a time
                break
            }
        }
    }
    
    // Send a push notification for an achievement
    private func sendAchievementNotification(_ achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.body = achievement.title
        content.sound = UNNotificationSound.default
        
        // Add achievement ID to user info
        content.userInfo = ["achievementId": achievement.id.uuidString]
        
        // Create a trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: achievement.id.uuidString, content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
} 
