import SwiftUI
// Try different import approaches for Lottie
import Lottie
// import LottieSwiftUI
// import LottieAnimation

// Define navigation destinations
enum NavigationDestination: Hashable {
    case quiz(String)
    case match(String)
    case puzzle(String)
    case volcanoBuilder(String)
    case achievements
}

struct DashboardView: View {
    
    // Navigation state
    @State private var navigationPath = NavigationPath()
    @State private var selectedDestination: NavigationDestination?
    
    // Use the shared ProgressManager to track volcano progress
    @ObservedObject private var progressManager = ProgressManager.shared
    
    // Alternative SwiftUI animation approach
    struct SwiftUIVolcanoAnimation: View {
        @State private var isAnimating = false
        var volcanoName: String = "Mount Vesuvius" // Default to Vesuvius
        
        var body: some View {
            ZStack {
                // Orange circle animation background
                Circle()
                    .fill(Color.orange)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.easeInOut(duration: 3)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                // Choose the appropriate volcano image based on the name
                if volcanoName == "Mount Vesuvius" {
                    Image("visit Mount Vesuvius")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .opacity(isAnimating ? 0.9 : 1.0)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                } else if volcanoName == "Mount St. Helens" {
                    Image("St Helens")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .opacity(isAnimating ? 0.9 : 1.0)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                } else if volcanoName == "Mount Fuji" {
                    Image("Mount fuji pic")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .opacity(isAnimating ? 0.9 : 1.0)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                } else {
                    // Fallback to system icon for any other volcano
                    Image(systemName: "mountain.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .opacity(isAnimating ? 0.9 : 1.0)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
    
    // Volcano Lottie view wrapper
    struct VolcanoLottieView: View {
        var volcanoName: String = "Mount Vesuvius"
        
        var body: some View {
            ZStack {
                // Debug outline to help see the view boundaries
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.red, lineWidth: 1)
                    .frame(width: 110, height: 110)
                
                // Use our SwiftUI animation instead
                SwiftUIVolcanoAnimation(volcanoName: volcanoName)
                    .frame(width: 110, height: 110)
            }
            .frame(width: 110, height: 110)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $navigationPath) {
                ZStack {
                    // Background image - positioned as the bottom layer
                    Image("Background river")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geometry.size.width, height: geometry.size.height)
            
                    VStack{
                        // Fixed achievements button (on top)
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    navigationPath.append(NavigationDestination.achievements)
                                }) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(Color.orange)
                                        .padding(12)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        )
                                }
                                .padding(.trailing, 20)
                            }
                            
                        }
                        
                        // Scrollable content
                        ScrollView {

                            GreetingCardView()
                            
                            VStack(spacing: 0) {
                   
                                VStack(spacing: 30) {
                                    ForEach(progressManager.volcanoLevels) { volcano in
                                        VStack(spacing: 15) {
                                            // Volcano header with name
                                            VolcanoHeaderView(volcano: volcano)
                                            
                                            // Display game nodes for each volcano
                                            HStack(spacing: 20) {
                                                ForEach(volcano.games) { game in
                                                    GameNodeView(game: game, isEnabled: volcano.isUnlocked, volcanoName: volcano.name) { destination in
                                                        navigationPath.append(destination)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal)
                                        }
                                        .padding(.vertical, 20)
                                        
                                        // Don't show connector line after the last volcano
                                        if volcano.order < progressManager.volcanoLevels.count {
                                            ConnectorLine()
                                                .frame(height: 60)
                                        }
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 80)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                    }
          
                    
                
                }
                .navigationBarHidden(true)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .quiz(let volcano):
                        QuizView(volcano: volcano)
                    case .match(let volcano):
                        MatchView(volcano: volcano)
                    case .puzzle(let volcano):
                        PuzzleView(volcano: volcano)
                    case .volcanoBuilder(let volcano):
                        if volcano == "Mount Vesuvius" {
                            VolcanoBuilderView()
                        } else if volcano == "Mount St. Helens" {
                            StHelensBuilderView()
                        } else if volcano == "Mount Fuji" {
                            FujiBuilderView()
                        } else {
                            // Default to Vesuvius if volcano not supported
                            VolcanoBuilderView()
                        }
                    case .achievements:
                        AchievementsView()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }
}

struct GreetingCardView: View {
    @ObservedObject private var progressManager = ProgressManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hey Explorer!") // Generic greeting
                .font(.custom("SF Pro Rounded", size: 22).weight(.bold))
                .foregroundColor(Color(hex: "#1D3557"))
            
            // Show different message based on progress
            Text(greetingMessage)
                .font(.custom("SF Pro Text", size: 16))
                .foregroundColor(Color(hex: "#1D3557"))
                .lineLimit(nil) // Allow multiple lines
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
    
    private var greetingMessage: String {
        let vesuvius = progressManager.volcanoLevels[0]
        let stHelens = progressManager.volcanoLevels[1]
        let fuji = progressManager.volcanoLevels[2]
        
        // Check which volcanoes are unlocked and provide appropriate message
        if !stHelens.isUnlocked {
            return "Complete the mini-games for \(vesuvius.name) to unlock Mount St. Helens."
        } else if !fuji.isUnlocked {
            return "Great job on \(vesuvius.name)! Now complete the Mount St. Helens mini-games to unlock Mount Fuji."
        } else if !allGamesCompleted(for: fuji) {
            return "Excellent progress! Complete the remaining Mount Fuji mini-games to master all volcanoes."
        } else {
            return "Congratulations! You've completed all volcano mini-games. You're a volcano expert!"
        }
    }
    
    private func allGamesCompleted(for volcano: VolcanoProgressInfo) -> Bool {
        return volcano.games.allSatisfy { $0.isCompleted }
    }
}

struct VolcanoHeaderView: View {
    let volcano: VolcanoProgressInfo
    
    var body: some View {
        VStack(spacing: 12) {
            // Use a specific image for each volcano
            if volcano.name == "Mount Vesuvius" {
                ZStack {
                    Image("visit Mount Vesuvius")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .frame(width: 100, height: 100)
            }
            else if volcano.name == "Mount St. Helens" {
                ZStack {
                    Image("St Helens")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .frame(width: 100, height: 100)
            }
            else if volcano.name == "Mount Fuji" {
                ZStack {
                    Image("Mount fuji pic")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .frame(width: 100, height: 100)
            }
            // Fallback to the animation as backup
            else {
                DashboardView.VolcanoLottieView(volcanoName: volcano.name)
                    .frame(width: 100, height: 100)
            }
            
            Text(volcano.name)
                .font(.custom("SF Pro Text", size: 18).weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(hex: "#1D3557").opacity(0.7) as Color)
                )
        }
    }
}

struct GameNodeView: View {
    let game: GameInfo
    let isEnabled: Bool
    let volcanoName: String
    let onNavigation: (NavigationDestination) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                if isEnabled {
                    switch game.gameType {
                    case .quiz:
                        onNavigation(.quiz(volcanoName))
                    case .wordMatch:
                        onNavigation(.match(volcanoName))
                    case .puzzle:
                        onNavigation(.puzzle(volcanoName))
                    case .volcanoBuilder:
                        onNavigation(.volcanoBuilder(volcanoName))
                    }
                }
            }) {
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 15)
                        .fill(game.isCompleted ? Color(hex: "#4CAF50").opacity(0.3) as Color : Color.white.opacity(0.3) as Color)
                        .frame(width: 70, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(game.isCompleted ? Color(hex: "#4CAF50") : Color.white, lineWidth: 2)
                        )
                    
                    // Icon based on game type
                    Image(systemName: gameTypeIcon(game.gameType))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(isEnabled ? (game.isCompleted ? Color(hex: "#4CAF50") : .white) : Color.gray.opacity(0.5) as Color)
                    
                    // Completed checkmark
                    if game.isCompleted {
                        Circle()
                            .fill(Color(hex: "#4CAF50"))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 25, y: -25)
                    }
                }
            }
            .disabled(!isEnabled)
            
            Text(gameTypeText(game.gameType))
                .font(.custom("SF Pro Text", size: 11).weight(.medium))
                .foregroundColor(isEnabled ? .white : Color.gray.opacity(0.7) as Color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isEnabled ? (game.isCompleted ? Color(hex: "#4CAF50").opacity(0.7) as Color : Color(hex: "#F4A261").opacity(0.7) as Color) : Color.gray.opacity(0.3) as Color)
                )
        }
    }
    
    // Helper to convert game type to icon
    private func gameTypeIcon(_ type: GameType) -> String {
        switch type {
        case .quiz: return "questionmark.circle"
        case .wordMatch: return "rectangle.grid.2x2"
        case .puzzle: return "puzzlepiece"
        case .volcanoBuilder: return "mountain.2"
        }
    }
    
    // Helper to convert game type to display text
    private func gameTypeText(_ type: GameType) -> String {
        switch type {
        case .quiz: return "Quiz"
        case .wordMatch: return "Match"
        case .puzzle: return "Puzzle"
        case .volcanoBuilder: return "Builder"
        }
    }
}

struct ConnectorLine: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 60))
        }
        .stroke(style: StrokeStyle(lineWidth: 3, dash: [8]))
        .foregroundColor(Color.white.opacity(0.7) as Color)
        .frame(width: 1)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 
