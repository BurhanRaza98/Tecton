import SwiftUI

struct MatchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var match: VolcanoMatch = VolcanoMatch.vesuviusSample
    @State private var selectedItem: Int? = nil
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var isCorrectMatch = false
    @State private var showResults = false
    @State private var highlightedZone: Int? = nil
    
    // Animation states
    @State private var bounceAnimation = false
    
    init(volcano: String) {
        // Load the appropriate match game based on the volcano name
        let initialMatch = VolcanoMatch.getMatch(for: volcano)
        _match = State(initialValue: initialMatch)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F5F5DC").edgesIgnoringSafeArea(.all)
            
            if showResults {
                MatchResultView(match: match, onDismiss: {
                    presentationMode.wrappedValue.dismiss()
                })
            } else {
                GeometryReader { geometry in
                    // Main game content
                    ScrollView {
                        VStack(spacing: 20) {
                            // Top bar with progress and close button
                            MatchTopBar(
                                progress: match.progress,
                                matchedCount: match.zones.filter { $0.isMatched }.count,
                                totalCount: match.zones.count,
                                onClose: {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                            .padding(.top, 10)
                            
                            // Game title
                            Text("Volcano Parts - \(match.volcanoName)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "#1D3557"))
                                .padding(.vertical, 10)
                            
                            // Instructions
                            Text(selectedItem == nil ? 
                                 "First, select a label below" : 
                                 "Now, tap on the correct location on the volcano")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#1D3557"))
                                .padding(.bottom, 5)
                            
                            // Volcano diagram with clickable zones
                            VolcanoDiagramView(
                                match: match,
                                highlightedZone: highlightedZone,
                                onZoneTapped: { zoneIndex in
                                    if let itemIndex = selectedItem {
                                        handleMatchAttempt(itemIndex: itemIndex, zoneIndex: zoneIndex)
                                    }
                                }
                            )
                            .frame(height: 300)
                            .padding(.horizontal)
                            
                            // Clickable labels at the bottom
                            VStack(spacing: 15) {
                                // Grid of clickable labels
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(match.items.indices, id: \.self) { index in
                                        if !match.items[index].isMatched {
                                            ClickableLabelView(
                                                item: match.items[index],
                                                isSelected: selectedItem == index,
                                                onTap: {
                                                    selectItem(index)
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.8))
                            )
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    
                    // Feedback overlay (shown when match is made)
                    if showFeedback {
                        MatchFeedbackView(
                            isCorrect: isCorrectMatch,
                            message: feedbackText,
                            onDismiss: {
                                withAnimation {
                                    showFeedback = false
                                }
                                
                                // Check if the game is completed after a correct match
                                if match.isCompleted && !showResults {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation {
                                            showResults = true
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // Select an item
    private func selectItem(_ index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            // Toggle selection
            if selectedItem == index {
                selectedItem = nil
                highlightedZone = nil
            } else {
                selectedItem = index
                
                // No longer automatically highlight the correct zone
                // Just set highlightedZone to nil
                highlightedZone = nil
            }
            
            // Hide any showing feedback
            if showFeedback {
                showFeedback = false
            }
        }
    }
    
    // Handle match attempt
    private func handleMatchAttempt(itemIndex: Int, zoneIndex: Int) {
        // Check if the zone is already matched
        if match.zones[zoneIndex].isMatched {
            // Already matched - show feedback
            feedbackText = "This location already has a label."
            isCorrectMatch = false
            withAnimation {
                showFeedback = true
            }
            return
        }
        
        // Check if the labels match
        let itemLabel = match.items[itemIndex].label
        let zoneLabel = match.zones[zoneIndex].label
        
        if itemLabel == zoneLabel {
            // Correct match
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    var updatedMatch = match
                    updatedMatch.setMatched(itemIndex: itemIndex, zoneIndex: zoneIndex)
                    match = updatedMatch
                    
                    // Show feedback for correct match
                    feedbackText = match.zones[zoneIndex].fact
                    isCorrectMatch = true
                    showFeedback = true
                    
                    // Reset selection
                    selectedItem = nil
                    highlightedZone = nil
                }
            }
        } else {
            // Incorrect match
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bounceAnimation = true
            }
            
            // Show feedback for incorrect match
            feedbackText = "Try again! Select the correct location for this label."
            isCorrectMatch = false
            showFeedback = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                bounceAnimation = false
            }
        }
    }
}

// MARK: - Supporting Views

// Top bar with progress tracking
struct MatchTopBar: View {
    let progress: Double
    let matchedCount: Int
    let totalCount: Int
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
            
            Text("\(matchedCount)/\(totalCount) Matched")
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

// Volcano diagram with target zones
struct VolcanoDiagramView: View {
    let match: VolcanoMatch
    let highlightedZone: Int?
    let onZoneTapped: (Int) -> Void
    
    // Helper to get image from various locations
    private func getMatchImage() -> UIImage? {
        // Check different possible locations
        if let image = UIImage(named: match.backgroundImage) {
            return image
        }
        
        // Try app bundle
        if let path = Bundle.main.path(forResource: match.backgroundImage, ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        
        // Try Views folder
        if let path = Bundle.main.path(forResource: "Views/\(match.backgroundImage)", ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        
        return nil
    }
    
    @ViewBuilder
    private func zoneView(for zone: MatchZone, at position: CGPoint, isHighlighted: Bool) -> some View {
        if zone.isMatched {
            Text(zone.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#4A6D7C"))
                )
                .position(position)
        } else {
            Circle()
                .strokeBorder(isHighlighted ? Color(hex: "#E76F51") : Color(hex: "#1D3557").opacity(0.6), lineWidth: isHighlighted ? 3 : 2)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.white.opacity(0.3)).frame(width: 34, height: 34))
                .position(position)
                .onTapGesture {
                    onZoneTapped(match.zones.firstIndex(where: { $0.id == zone.id }) ?? 0)
                }
        }
    }
    
    var body: some View {
        ZStack {
            // Background and zones container
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .overlay(
                    // Try to load the image from various locations
                    GeometryReader { geometry in
                        if let matchImage = getMatchImage() {
                            Image(uiImage: matchImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.9)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        } else {
                            // Fallback to a placeholder volcano
                            Image(systemName: "mountain.2.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color(hex: "#B57F50").opacity(0.8))
                                .frame(width: geometry.size.width * 0.5)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                    }
                )
            
            // Target zones - using GeometryReader to better position the zones
            GeometryReader { geometry in
                // Scale factor to adapt zone positions based on view size
                let width = geometry.size.width
                let height = geometry.size.height
                let scale = min(width / 400, height / 400) // Normalize to base design size
                
                // Calculate image bounds
                let imageWidth = width * 0.8
                let imageHeight = height * 0.9
                let imageBounds = CGRect(
                    x: (width - imageWidth) / 2,
                    y: (height - imageHeight) / 2,
                    width: imageWidth,
                    height: imageHeight
                )
                
                ForEach(match.zones.indices, id: \.self) { index in
                    let zone = match.zones[index]
                    
                    // Calculate raw position
                    let scaledPosition = calculateScaledPosition(for: zone, scale: scale, bounds: imageBounds)
                    
                    self.zoneView(
                        for: zone, 
                        at: scaledPosition, 
                        isHighlighted: highlightedZone == index
                    )
                }
            }
        }
    }
    
    // Helper function to calculate scaled position with bounds checking
    private func calculateScaledPosition(for zone: MatchZone, scale: CGFloat, bounds: CGRect) -> CGPoint {
        // Calculate position based on the center of the image
        let centerX = bounds.midX
        let centerY = bounds.midY
        
        // Calculate position relative to the center, then scale
        var position = CGPoint(
            x: centerX + (zone.coordinates.x - 200) * scale, // 200 is the center X in the original design
            y: centerY + (zone.coordinates.y - 200) * scale  // 200 is the center Y in the original design
        )
        
        // Clamp position to stay within image bounds
        position.x = max(bounds.minX + 20, min(position.x, bounds.maxX - 20))
        position.y = max(bounds.minY + 20, min(position.y, bounds.maxY - 20))
        
        return position
    }
}

// Clickable label component
struct ClickableLabelView: View {
    let item: MatchItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(item.label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(backgroundColor)
                )
                .shadow(color: Color.black.opacity(isSelected ? 0.3 : 0.1),
                        radius: isSelected ? 10 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2)
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    // Background color logic
    private var backgroundColor: Color {
        if isSelected {
            return Color(hex: "#E76F51") // Orange-red when selected
        } else {
            return Color(hex: "#2A9D8F") // Teal for default state
        }
    }
}

// Feedback shown after a match attempt
struct MatchFeedbackView: View {
    let isCorrect: Bool
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isCorrect ? Color(hex: "#8FBC8F") : Color(hex: "#F4A261"))
                
                Text(isCorrect ? "Correct!" : "Try Again")
                    .font(.headline)
                    .foregroundColor(isCorrect ? Color(hex: "#8FBC8F") : Color(hex: "#F4A261"))
                
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#1D3557"))
                    .fixedSize(horizontal: false, vertical: true) // Allow text to expand vertically
                    .padding(.horizontal)
                
                Button(action: onDismiss) {
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
            .padding(.bottom, 40)
        }
        .transition(.opacity)
        .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
        .onTapGesture {
            onDismiss()
        }
    }
}

// Results view shown after completing the match game
struct MatchResultView: View {
    let match: VolcanoMatch
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Match Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                
                // Achievement image
                ZStack {
                    Circle()
                        .fill(Color(hex: "#2A9D8F"))
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "puzzlepiece.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 20)
                
                Text("You've completed the \(match.volcanoName) Match!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#1D3557"))
                
                // Facts learned
                VStack(alignment: .leading, spacing: 15) {
                    Text("Facts Learned:")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    ForEach(match.zones.filter { $0.isMatched }, id: \.id) { zone in
                        HStack(alignment: .top, spacing: 10) {
                            Text("•")
                                .foregroundColor(Color(hex: "#2A9D8F"))
                                .font(.system(size: 16, weight: .bold))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(zone.label)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#1D3557"))
                                
                                Text(zone.fact)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#1D3557"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.vertical, 5)
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
                .padding(.bottom, 40)
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
            // Mark the word match game as completed
            ProgressManager.shared.markGameCompleted(volcanoName: match.volcanoName, gameType: .wordMatch)
        }
    }
}

// Preview
struct MatchView_Previews: PreviewProvider {
    static var previews: some View {
        MatchView(volcano: "Mount Vesuvius")
    }
} 
