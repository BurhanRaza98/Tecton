import SwiftUI

struct AchievementsView: View {
    @ObservedObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory: AchievementCategory = .all
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    // Achievement categories
    enum AchievementCategory: String, CaseIterable {
        case all = "All"
        case vesuvius = "Vesuvius"
        case stHelens = "St. Helens"
        case fuji = "Fuji"
        
        var displayName: String {
            self.rawValue
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Image("Background river")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Fixed header with X button
                
                Spacer(minLength: 60)
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#1D3557"))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                            )
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Text("Achievements")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    Spacer()
                    
                    // Empty view to balance the X button
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                        .padding(.trailing, 20)
                    
                }
                .padding(.top, 40)
                .padding(.bottom, 16)
                
                // Make content scrollable
                ScrollView {
                    VStack(spacing: 0) {
                        // Progress circle
                        ProgressView(progress: achievementManager.getTotalProgressPercentage())
                            .padding(.vertical, 20)
                        
                        // Category picker
                        categoryPicker
                            .padding(.horizontal)
                        
                        // Achievements list
                        VStack(spacing: 12) {
                            ForEach(filteredAchievements) { achievement in
                                DetailedBadgeView(
                                    achievement: achievement,
                                    isEarned: achievementManager.isAchievementEarned(achievement)
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // Category picker for filtering achievements
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // Individual category button
    private func categoryButton(for category: AchievementCategory) -> some View {
        Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            Text(category.displayName)
                .fontWeight(selectedCategory == category ? .bold : .medium)
                .foregroundColor(selectedCategory == category ? .white : Color(hex: "#1D3557"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedCategory == category ? Color(hex: "#2A9D8F") : Color.white.opacity(0.8))
                )
        }
    }
    
    // Filtered achievements based on selected category
    private var filteredAchievements: [Achievement] {
        switch selectedCategory {
        case .all:
            return achievementManager.achievements
        case .vesuvius:
            return achievementManager.vesuviusAchievements
        case .stHelens:
            return achievementManager.stHelensAchievements
        case .fuji:
            return achievementManager.fujiAchievements
        }
    }
}

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// It's good practice to have a preview for individual views
struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
    }
} 
