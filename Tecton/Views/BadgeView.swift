import SwiftUI

struct BadgeView: View {
    let achievement: Achievement
    let size: BadgeSize
    let isEarned: Bool
    
    var body: some View {
        ZStack {
            // Badge background circle
            Circle()
                .fill(isEarned ? achievement.badgeColor : Color.gray.opacity(0.3))
                .frame(width: size.dimension, height: size.dimension)
                .shadow(color: isEarned ? achievement.badgeColor.opacity(0.6) : Color.clear, radius: 4)
            
            // Badge icon or custom image
            if let customImage = achievement.customBadgeImage, isEarned {
                // Use custom badge image if available and earned
                Image(customImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.dimension, height: size.dimension)
            } else {
                // Fallback to system icon
                Image(systemName: achievement.badgeIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isEarned ? .white : .gray)
                    .padding(size.dimension * 0.25)
                    .frame(width: size.dimension, height: size.dimension)
            }
            
            // Locked icon overlay for unearned badges
            if !isEarned {
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: size.dimension * 0.3, height: size.dimension * 0.3)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: size.dimension * 0.35, height: size.dimension * 0.35)
                    )
                    .offset(x: size.dimension * 0.25, y: size.dimension * 0.25)
            }
        }
    }
}

struct DetailedBadgeView: View {
    let achievement: Achievement
    let isEarned: Bool
    @State private var showingModelView = false
    
    // Check if this achievement is for a volcano that has completed all minigames
    private var isVolcanoMaster: Bool {
        return isEarned && 
               achievement.volcanoName != "All Volcanoes" && 
               achievement.title.contains("Master")
    }
    
    var body: some View {
        Button(action: {
            // Only activate when it's earned and is a Master achievement
            if isVolcanoMaster {
                showingModelView = true
            }
        }) {
            HStack(spacing: 16) {
                // Badge
                BadgeView(achievement: achievement, size: .medium, isEarned: isEarned)
                
                // Achievement details
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(isEarned ? Color(hex: "#1D3557") : .gray)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(isEarned ? Color(hex: "#2A9D8F") : .gray.opacity(0.8))
                    
                    // Progress indicator for volcano-specific achievements
                    if achievement.volcanoName != "All Volcanoes" {
                        let progress = AchievementManager.shared.getAchievementProgress(for: achievement.volcanoName)
                        let requiredGames = achievement.requiredGames
                        
                        HStack(spacing: 2) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(i < progress ? Color(hex: "#2A9D8F") : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                            
                            Text("\(progress)/\(3) completed")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                    }
                }
                
                Spacer()
                
                // Completion indicator
                if isEarned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#2A9D8F"))
                        .font(.title3)
                }
                
                // View 3D model indicator for volcano masters
                if isVolcanoMaster {
                    Image(systemName: "cube.fill")
                        .foregroundColor(Color(hex: "#F4A261"))
                        .font(.title3)
                        .padding(.leading, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Prevent default button styling
        .sheet(isPresented: $showingModelView) {
            VolcanoModelView(volcanoName: achievement.volcanoName)
        }
    }
}

struct ProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 120, height: 120)
                
                // Progress indicator
                Circle()
                    .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#F4A261"), Color(hex: "#2A9D8F")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: progress)
                
                // Percentage text
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#2A9D8F"))
                }
            }
            
            Text("Achievement Progress")
                .font(.headline)
                .foregroundColor(Color(hex: "#1D3557"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            let mockAchievement = Achievement(
                title: "Vesuvius Explorer",
                description: "Complete 2 mini-games for Mount Vesuvius",
                volcanoName: "Mount Vesuvius",
                badgeIcon: "mountain.2.fill",
                badgeColor: AchievementLevel.silver.color,
                requiredGames: 2,
                customBadgeImage: "Vesuvius Explorer"
            )
            
            let defaultAchievement = Achievement(
                title: "Volcano Expert",
                description: "Complete all mini-games for all volcanoes",
                volcanoName: "All Volcanoes",
                badgeIcon: "star.fill",
                badgeColor: AchievementLevel.gold.color,
                requiredGames: 9,
                customBadgeImage: nil
            )
            
            Text("Custom Badge Images").font(.headline)
            HStack {
                BadgeView(achievement: mockAchievement, size: .large, isEarned: true)
                BadgeView(achievement: mockAchievement, size: .medium, isEarned: false)
            }
            
            Text("Default System Icons").font(.headline)
            HStack {
                BadgeView(achievement: defaultAchievement, size: .large, isEarned: true)
                BadgeView(achievement: defaultAchievement, size: .medium, isEarned: false)
            }
            
            DetailedBadgeView(achievement: mockAchievement, isEarned: true)
            DetailedBadgeView(achievement: mockAchievement, isEarned: false)
            
            ProgressView(progress: 0.66)
        }
        .padding()
        .background(Color(hex: "#F5F5DC"))
    }
} 