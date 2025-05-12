import SwiftUI

struct QuizView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var quiz: VolcanoQuiz
    @State private var selectedAnswerIndex: Int? = nil
    @State private var isAnswerCorrect: Bool? = nil
    @State private var showingFeedback = false
    @State private var cardRotation: Double = 0
    @State private var showResults = false
    
    init(volcano: String) {
        // Load the appropriate quiz based on the volcano name
        _quiz = State(initialValue: VolcanoQuiz.getQuiz(for: volcano))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F5F5DC").edgesIgnoringSafeArea(.all)
            
            if showResults {
                QuizResultView(quiz: quiz, onDismiss: {
                    presentationMode.wrappedValue.dismiss()
                })
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Top bar with progress and close button
                        QuizTopBar(
                            progress: quiz.progress,
                            currentQuestion: quiz.currentQuestionIndex + 1,
                            totalQuestions: quiz.questions.count,
                            onClose: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 20)
                        
                        // Question card with 3D flip effect
                        FlashcardView(
                            question: quiz.currentQuestion?.question ?? "",
                            rotation: cardRotation
                        )
                        
                        Spacer().frame(height: 20)
                        
                        // Answer options
                        if let currentQuestion = quiz.currentQuestion {
                            VStack(spacing: 12) {
                                ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                                    AnswerButton(
                                        text: currentQuestion.options[index],
                                        isSelected: selectedAnswerIndex == index,
                                        isCorrect: isAnswerCorrect == true && selectedAnswerIndex == index,
                                        isIncorrect: isAnswerCorrect == false && selectedAnswerIndex == index,
                                        disabled: showingFeedback,
                                        action: {
                                            selectAnswer(index)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        // Feedback area (shows after answering)
                        if showingFeedback {
                            FeedbackView(
                                isCorrect: isAnswerCorrect ?? false,
                                message: feedbackMessage,
                                onContinue: {
                                    moveToNext()
                                }
                            )
                            .padding(.vertical, 10)
                        }
                        
                        Spacer().frame(height: 10)
                        
                        // Progress dots
                        ProgressDotsView(
                            currentIndex: quiz.currentQuestionIndex,
                            totalCount: quiz.questions.count
                        )
                        .padding(.bottom)
                        
                        Spacer().frame(height: 60) // Extra space at bottom for comfortable scrolling
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var feedbackMessage: String {
        guard let currentQuestion = quiz.currentQuestion else { return "" }
        return isAnswerCorrect == true ? currentQuestion.funFact : currentQuestion.hint
    }
    
    private func selectAnswer(_ index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            selectedAnswerIndex = index
            isAnswerCorrect = quiz.answerQuestion(withIndex: index)
            showingFeedback = true
        }
    }
    
    private func moveToNext() {
        // Animate card flip
        withAnimation(.easeInOut(duration: 0.5)) {
            cardRotation += 360
            showingFeedback = false
            selectedAnswerIndex = nil
            isAnswerCorrect = nil
        }
        
        // After animation, move to next question or show results
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            quiz.moveToNextQuestion()
            if quiz.isFinished {
                withAnimation {
                    showResults = true
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct QuizTopBar: View {
    let progress: Double
    let currentQuestion: Int
    let totalQuestions: Int
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.6))
                    )
            }
            
            Spacer()
            
            Text("\(currentQuestion)/\(totalQuestions)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#1D3557"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.6))
                )
        }
        .padding(.horizontal)
        .overlay(
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color(hex: "#F4A261"))
                    .frame(width: geometry.size.width * progress, height: 4)
                    .position(x: geometry.size.width * progress / 2, y: geometry.size.height)
            }
        )
    }
}

struct FlashcardView: View {
    let question: String
    let rotation: Double
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Question text
            Text(question)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#1D3557"))
                .multilineTextAlignment(.center)
                .padding(30)
        }
        .frame(height: 200)
        .padding(.horizontal)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(buttonTextColor)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(buttonColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            )
        }
        .disabled(disabled)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        // Shake animation when wrong
        .modifier(ShakeEffect(animatableData: isIncorrect ? 1 : 0))
    }
    
    private var buttonColor: Color {
        if isCorrect {
            return Color(hex: "#8FBC8F").opacity(0.9) // Green for correct
        } else if isIncorrect {
            return Color(hex: "#CD5C5C").opacity(0.9) // Red for incorrect
        } else if isSelected {
            return Color(hex: "#E9C46A").opacity(0.9) // Yellow for selected
        } else {
            return Color.white.opacity(0.9) // Default white
        }
    }
    
    private var buttonTextColor: Color {
        if isCorrect || isIncorrect || isSelected {
            return .white
        } else {
            return Color(hex: "#1D3557")
        }
    }
}

struct FeedbackView: View {
    let isCorrect: Bool
    let message: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(isCorrect ? Color(hex: "#8FBC8F") : Color(hex: "#F4A261"))
            
            Text(isCorrect ? "Correct!" : "Try Again!")
                .font(.headline)
                .foregroundColor(isCorrect ? Color(hex: "#8FBC8F") : Color(hex: "#F4A261"))
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#1D3557"))
                .fixedSize(horizontal: false, vertical: true) // Allow text to expand vertically
                .padding(.horizontal)
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#F4A261"))
                    )
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .transition(.opacity)
    }
}

struct ProgressDotsView: View {
    let currentIndex: Int
    let totalCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalCount, id: \.self) { index in
                Circle()
                    .fill(index <= currentIndex ? Color(hex: "#F4A261") : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
    }
}

struct QuizResultView: View {
    let quiz: VolcanoQuiz
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Quiz Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                
                // Score and badge
                VStack(spacing: 15) {
                    Text("Your Score")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    Text("\(quiz.score)/\(quiz.questions.count)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    // Badge
                    ZStack {
                        Circle()
                            .fill(badgeColor)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    Text("\(quiz.badgeLevel.rawValue) Badge")
                        .font(.title3)
                        .foregroundColor(badgeColor)
                        .padding(.top, 5)
                }
                .padding(.vertical, 20)
                
                // Unlocked facts
                VStack(alignment: .leading, spacing: 15) {
                    Text("You've unlocked:")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    ForEach(unlockedFacts, id: \.self) { fact in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#8FBC8F"))
                            
                            Text(fact)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#1D3557"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.8))
                )
                
                // Continue button
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#F4A261"))
                        )
                }
                .padding(.top, 20)
                .padding(.bottom, 40) // Add extra padding at bottom
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#F5F5DC").opacity(0.95))
        )
        .padding()
        .onAppear {
            // Mark the quiz game as completed
            ProgressManager.shared.markGameCompleted(volcanoName: quiz.volcanoName, gameType: .quiz)
        }
    }
    
    private var badgeColor: Color {
        switch quiz.badgeLevel {
        case .gold:
            return Color(hex: "#FFD700")
        case .silver:
            return Color(hex: "#C0C0C0")
        case .bronze:
            return Color(hex: "#CD7F32")
        }
    }
    
    // Show unlocked facts based on performance
    private var unlockedFacts: [String] {
        let factsToShow: Int
        switch quiz.badgeLevel {
        case .gold:
            factsToShow = quiz.unlockableFacts.count
        case .silver:
            factsToShow = min(2, quiz.unlockableFacts.count)
        case .bronze:
            factsToShow = min(1, quiz.unlockableFacts.count)
        }
        
        return Array(quiz.unlockableFacts.prefix(factsToShow))
    }
}

// MARK: - Effects

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            10 * sin(animatableData * .pi * 4), y: 0))
    }
}

// MARK: - Preview

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(volcano: "Mount Vesuvius")
    }
} 