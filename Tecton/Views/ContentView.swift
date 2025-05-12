//
//  ContentView.swift
//  Tecton
//
//  Created by Burhan Raza on 08/05/25.
//

import SwiftUI
// SwiftData might not be needed here anymore if Item.swift is moved or not used by ContentView directly.
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @ObservedObject private var achievementManager = AchievementManager.shared
    
    init() {
        // Customize TabView appearance
        let appearance = UITabBarAppearance()
        
        // Set background color for the tab bar
        appearance.backgroundColor = UIColor(Color(hex: "#FFFFE0")) // Light Yellow
        
        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()
        
        // Add padding to move icons down
        itemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        itemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        
        // Set icon colors
        itemAppearance.normal.iconColor = UIColor(Color(hex: "#F4A261").opacity(0.6)) // Lighter orange when not selected
        itemAppearance.selected.iconColor = UIColor(Color(hex: "#F4A261")) // Full orange when selected
        
        // Make text black and bold for both normal and selected states
        let boldFont = UIFont.boldSystemFont(ofSize: 10) // Using system font with bold weight
        let blackColor = UIColor.black
        
        // Apply text attributes
        itemAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.font: boldFont,
            NSAttributedString.Key.foregroundColor: blackColor
        ]
        itemAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.font: boldFont,
            NSAttributedString.Key.foregroundColor: blackColor
        ]
        
        // Apply item appearance to all tab bar items
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        // Apply the appearance to the tab bar
        UITabBar.appearance().standardAppearance = appearance
        
        // For iOS 15 and later, also set scrollEdgeAppearance if you want consistency
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Image("Dashboard")
                            .renderingMode(.template) // Makes the image use the accent color
                        Text("Dashboard")
                    }
                    .tag(0)
                
                AchievementsView()
                    .tabItem {
                        Image("Achievements")
                            // Removed template rendering to use the original icon
                        Text("Achievements")
                    }
                    .tag(1)
            }
            // Remove the accent color since we're now setting colors explicitly in UIAppearance
            // .accentColor(Color(hex: "#F4A261"))
            .onAppear {
                // Set up notification observer to switch to the Achievements tab
                NotificationCenter.default.addObserver(forName: NSNotification.Name("SwitchToAchievementsTab"), object: nil, queue: .main) { _ in
                    withAnimation {
                        selectedTab = 1 // Switch to Achievements tab
                    }
                }
            }
            
            // Achievement popup notification
            if achievementManager.newlyEarnedAchievement != nil {
                AchievementNotificationView(
                    achievement: achievementManager.newlyEarnedAchievement!,
                    isShowing: Binding<Bool>(
                        get: { achievementManager.newlyEarnedAchievement != nil },
                        set: { if !$0 { achievementManager.newlyEarnedAchievement = nil } }
                    )
                )
            }
        }
    }
}

// Achievement notification popup
struct AchievementNotificationView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = 400
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Achievement Unlocked!")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    dismissNotification()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(hex: "#2A9D8F"))
            
            // Content
            HStack(spacing: 20) {
                // Badge with custom image
                if let customImage = achievement.customBadgeImage {
                    Image(customImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                } else {
                    // Fallback to regular badge
                    BadgeView(achievement: achievement, size: .large, isEarned: true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(achievement.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    // Show 3D model hint for master achievements
                    if achievement.title.contains("Master") && achievement.volcanoName != "All Volcanoes" {
                        Text("Tap the achievement badge to view a 3D model!")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#F4A261"))
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .frame(width: min(UIScreen.main.bounds.width - 40, 400))
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 0
            }
            
            // Auto dismiss after 30 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                dismissNotification()
            }
        }
    }
    
    private func dismissNotification() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            offset = 400
        }
        
        // Remove from state after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShowing = false
        }
    }
}

// DashboardView struct has been moved to Tecton/Views/DashboardView.swift
// AchievementsView struct has been moved to Tecton/Views/AchievementsView.swift

// Helper to use hex colors
// extension Color {
//     init(hex: String) {
//         let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//         var int: UInt64 = 0
//         Scanner(string: hex).scanHexInt64(&int)
//         let a, r, g, b: UInt64
//         switch hex.count {
//         case 3: // RGB (12-bit)
//             (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//         case 6: // RGB (24-bit)
//             (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//         case 8: // ARGB (32-bit)
//             (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//         default:
//             (a, r, g, b) = (255, 0, 0, 0)
//         }
//         self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
//     }
// }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
