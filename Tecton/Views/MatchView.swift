import SwiftUI

struct MatchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var match: VolcanoMatch = VolcanoMatch.vesuviusSample
    @State private var draggingItem: Int? = nil
    @State private var dragOffset = CGSize.zero
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var isCorrectMatch = false
    @State private var showResults = false
    @State private var dragItemPosition = CGPoint.zero
    @State private var isHoveringOverMatch = false
    
    // Animation states
    @State private var bounceAnimation = false
    @State private var showBounceHint = false
    
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
                            
                            // Volcano diagram with drop zones
                            VolcanoDiagramView(
                                match: match,
                                draggedItemPosition: draggingItem != nil ? dragItemPosition : nil
                            )
                            .frame(height: 300)
                            .padding(.horizontal)
                            
                            // Draggable labels at the bottom
                            VStack(spacing: 15) {
                                Text("Drag labels to the correct location")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#1D3557"))
                                    .padding(.bottom, 5)
                                
                                // Grid of draggable labels
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(match.items.indices, id: \.self) { index in
                                        DraggableLabelView(
                                            item: match.items[index],
                                            isDragging: draggingItem == index,
                                            isHoveringOverMatch: draggingItem == index && isHoveringOverMatch,
                                            dragOffset: draggingItem == index ? dragOffset : .zero,
                                            onDragChanged: { offset in
                                                handleDrag(index: index, offset: offset, in: geometry)
                                            },
                                            onDragEnded: { offset in
                                                handleDragEnd(index: index, offset: offset, in: geometry)
                                            }
                                        )
                                        .opacity(match.items[index].isMatched ? 0 : 1)
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
    
    // Update the position of the dragged item
    private func handleDrag(index: Int, offset: CGSize, in geometry: GeometryProxy) {
        // Calculate position for collision detection
        let item = match.items[index]
        let basePosition = item.originalPosition
        let absolutePosition = CGPoint(
            x: basePosition.x + offset.width,
            y: basePosition.y + offset.height
        )
        
        dragItemPosition = absolutePosition
        draggingItem = index
        dragOffset = offset
        
        // Scale factor for coordinates
        let scale = min(geometry.size.width / 400, geometry.size.height / 400)
        
        // Check if hovering over matching zone
        let scaledPosition = CGPoint(
            x: (basePosition.x + offset.width) / scale,
            y: (basePosition.y + offset.height) / scale
        )
        
        // Use the match model to check if we're hovering over the correct zone
        let isHovering = match.checkMatch(itemIndex: index, dragPosition: scaledPosition) != nil
        withAnimation(.easeInOut(duration: 0.2)) {
            isHoveringOverMatch = isHovering
        }
        
        // Hide any showing feedback while dragging
        if showFeedback {
            showFeedback = false
        }
    }
    
    // Handle when the user stops dragging an item
    private func handleDragEnd(index: Int, offset: CGSize, in geometry: GeometryProxy) {
        // Calculate final position
        let item = match.items[index]
        let basePosition = item.originalPosition
        
        // Scale factor for adapted coordinates (similarly to what we do in VolcanoDiagramView)
        let scale = min(geometry.size.width / 400, geometry.size.height / 400)
        
        // Adjust the drop position using the scale factor
        let finalPosition = CGPoint(
            x: (basePosition.x + offset.width) / scale,
            y: (basePosition.y + offset.height) / scale
        )
        
        // Reset hover state
        isHoveringOverMatch = false
        
        // Check if the position matches a target zone
        if let matchedZoneIndex = match.checkMatch(itemIndex: index, dragPosition: finalPosition) {
            // Correct match - add a small delay to show the green color
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    var updatedMatch = match
                    updatedMatch.setMatched(itemIndex: index, zoneIndex: matchedZoneIndex)
                    match = updatedMatch
                    
                    // Show feedback for correct match
                    feedbackText = match.zones[matchedZoneIndex].fact
                    isCorrectMatch = true
                    showFeedback = true
                }
            }
        } else {
            // Incorrect match or no zone found - bounce back
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bounceAnimation = true
                showBounceHint = true
            }
            
            // Reset position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                    dragOffset = .zero
                }
                
                // Show feedback for incorrect match
                feedbackText = "Try again! Drag the label to the correct location on the volcano."
                isCorrectMatch = false
                showFeedback = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    bounceAnimation = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showBounceHint = false
                    }
                }
            }
        }
        
        // Reset dragging state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            draggingItem = nil
            dragOffset = .zero
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
    let draggedItemPosition: CGPoint?
    
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
    private func zoneView(for zone: MatchZone, at position: CGPoint) -> some View {
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
                .strokeBorder(Color(hex: "#1D3557").opacity(0.6), lineWidth: 2)
                .frame(width: 36, height: 36)
                .position(position)
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

                    self.zoneView(for: zone, at: scaledPosition)
                }
            }
        }
    }
    
    // Helper function to calculate scaled position with bounds checking
    private func calculateScaledPosition(for zone: MatchZone, scale: CGFloat, bounds: CGRect) -> CGPoint {
        // Calculate raw position
        var position = CGPoint(
            x: zone.coordinates.x * scale,
            y: zone.coordinates.y * scale
        )
        
        // Clamp position to stay within image bounds
        position.x = max(bounds.minX + 20, min(position.x, bounds.maxX - 20))
        position.y = max(bounds.minY + 20, min(position.y, bounds.maxY - 20))
        
        return position
    }
}

// Draggable label component
struct DraggableLabelView: View {
    let item: MatchItem
    let isDragging: Bool
    let isHoveringOverMatch: Bool
    let dragOffset: CGSize
    let onDragChanged: (CGSize) -> Void
    let onDragEnded: (CGSize) -> Void
    
    // Animation states
    @State private var pulseEffect: Bool = false
    
    var body: some View {
        Text(item.label)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
            .shadow(color: Color.black.opacity(isDragging ? 0.3 : 0.1),
                    radius: isDragging ? 10 : 4,
                    x: 0,
                    y: isDragging ? 4 : 2)
            .scaleEffect(scaleValue)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !item.isMatched {
                            onDragChanged(value.translation)
                        }
                    }
                    .onEnded { value in
                        if !item.isMatched {
                            onDragEnded(value.translation)
                        }
                    }
            )
            .onChange(of: isHoveringOverMatch) { oldValue, newValue in
                if newValue {
                    // Start pulse animation when hovering over match
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        pulseEffect = true
                    }
                } else {
                    // Stop pulse animation
                    withAnimation {
                        pulseEffect = false
                    }
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
            .animation(.easeInOut(duration: 0.2), value: isHoveringOverMatch)
    }
    
    // Scale value with pulse effect
    private var scaleValue: CGFloat {
        if isHoveringOverMatch {
            return isDragging ? (pulseEffect ? 1.15 : 1.1) : 1.0
        } else {
            return isDragging ? 1.1 : 1.0
        }
    }
    
    // Background color logic
    private var backgroundColor: Color {
        if isHoveringOverMatch {
            return Color(hex: "#4CAF50") // Green for correct hover
        } else if isDragging {
            return Color(hex: "#E76F51") // Orange-red while dragging
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