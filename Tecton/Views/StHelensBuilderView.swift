import SwiftUI
import AVFoundation

struct StHelensBuilderView: View {
    @StateObject var manager: StHelensQuizManager
    @State private var synthesizer = AVSpeechSynthesizer()
    @Environment(\.colorScheme) var colorScheme
    
    init(manager: StHelensQuizManager = StHelensQuizManager()) {
        // Use explicit StateObject initializer to avoid ambiguity
        self._manager = StateObject<StHelensQuizManager>(wrappedValue: manager)
        
        // If using a fresh manager, load the quiz immediately
        if manager.quiz == nil {
            manager.loadQuiz()
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(colorScheme == .dark ? .black : .systemBackground)
                .edgesIgnoringSafeArea(.all)
                
            ScrollView {
                VStack(spacing: 20) {
                    Text("Build Mount St. Helens")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Volcano building section
                    ZStack {
                        // Base background - light blue tint
                        Color(hex: "#E6F0F8")
                            .frame(height: 400)
                            .cornerRadius(12)
                        
                        // Display a placeholder outline
                        Image("PZH4") // Use the top layer as a ghost outline
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 400)
                            .opacity(0.1)
                        
                        // Volcano layers that have been answered correctly
                        ForEach(manager.answeredCorrectly, id: \.self) { asset in
                            Image(asset)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 400)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: manager.answeredCorrectly)
                    .padding(.horizontal)
                    
                    // Fact popup
                    if manager.showingFact {
                        factView
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.horizontal)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: manager.showingFact)
                    }
                    
                    // Quiz question or completion message
                    if let current = manager.quiz?.layers[safe: manager.currentIndex] {
                        questionView(for: current)
                            .transition(.opacity)
                            .animation(.easeInOut, value: manager.currentIndex)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    } else {
                        completionView
                            .transition(.scale)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: manager.currentIndex)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                    
                    // Add extra space at the bottom for better scrolling
                    Spacer().frame(height: 50)
                }
            }
        }
        .onAppear {
            // Show the base layer as soon as the view appears
            if manager.answeredCorrectly.isEmpty {
                // Preload PZH1 as the base if no image is shown
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if manager.answeredCorrectly.isEmpty {
                        withAnimation {
                            manager.answeredCorrectly = ["PZH1"]
                            manager.currentIndex = 1 // Move to next question
                        }
                    }
                }
            }
        }
    }
    
    // Fact popup view
    private var factView: some View {
        VStack(spacing: 8) {
            Text("Did You Know?")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(manager.currentFact)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.2))
                )
                .onAppear {
                    speakFact(manager.currentFact)
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
                .shadow(radius: 5)
        )
    }
    
    // Question and answer options view
    private func questionView(for layer: StHelensLayer) -> some View {
        VStack(spacing: 16) {
            Text(layer.question)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ForEach(layer.options.indices, id: \.self) { i in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        manager.submitAnswer(i)
                    }
                }) {
                    Text(layer.options[i])
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.8))
                        )
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
        )
    }
    
    // Completion view shown when all layers are completed
    private var completionView: some View {
        VStack(spacing: 20) {
            Text("Volcano Complete! 🌋")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You've successfully built Mount St. Helens!")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            // Achievement unlock message with custom badge image
            HStack {
                Image("St Helens Master")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("St. Helens Master Achievement Unlocked!")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1D3557"))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.6))
            )
            
            // Instructions to view 3D model
            Text("Go to the Achievements tab and tap on the St. Helens Master badge to view a 3D model of the volcano!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#2A9D8F"))
                .padding(.horizontal)
            
            // Achievements tab button
            Button(action: {
                // Mark this game as completed
                ProgressManager.shared.markGameCompleted(volcanoName: "Mount St. Helens", gameType: .volcanoBuilder)
                
                // Switch to Achievements tab
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToAchievementsTab"), object: nil)
                
                // Dismiss this view
                withAnimation {
                    manager.resetQuiz()
                }
            }) {
                HStack {
                    Image(systemName: "trophy")
                    Text("Go to Achievements")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#F4A261"))
                )
                .foregroundColor(.white)
                .shadow(radius: 3)
            }
            .padding(.top)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
                .shadow(radius: 5)
        )
        .onAppear {
            // Mark this game as completed when view appears
            ProgressManager.shared.markGameCompleted(volcanoName: "Mount St. Helens", gameType: .volcanoBuilder)
        }
    }
    
    // Function to read facts aloud
    private func speakFact(_ fact: String) {
        let utterance = AVSpeechUtterance(string: fact)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }
}

#Preview {
    StHelensBuilderView(manager: {
        let previewManager = StHelensQuizManager()
        previewManager.loadQuiz()
        previewManager.answeredCorrectly = ["PZH1", "PZH2"]
        return previewManager
    }())
} 