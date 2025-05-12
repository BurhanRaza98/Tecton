import SwiftUI

struct PuzzleView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var puzzle: VolcanoPuzzle
    @State private var selectedMode: PuzzleMode = .jigsaw // Default to jigsaw mode
    @State private var draggingItem: Int? = nil
    @State private var dragOffset = CGSize.zero
    @State private var dragLocation = CGPoint.zero // Track the absolute drag position
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var isCorrectPlacement = false
    @State private var showResults = false
    @State private var showHint = false
    @State private var animatingPiece: Int? = nil
    
    init(volcano: String = "Mount Vesuvius", initialMode: PuzzleMode = .jigsaw) {
        // Default to Vesuvius if another volcano is specified but assets aren't ready
        let volcanoToUse = volcano == "Mount Vesuvius" ? volcano : "Mount Vesuvius"
        
        // Only use jigsaw mode
        _puzzle = State(initialValue: VolcanoPuzzle.getPuzzle(for: volcanoToUse, mode: .jigsaw))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F5F5DC").edgesIgnoringSafeArea(.all)
            
            if showResults {
                PuzzleResultView(puzzle: puzzle, onDismiss: {
                    presentationMode.wrappedValue.dismiss()
                })
            } else {
                VStack(spacing: 0) {
                    // Top bar with controls
                    PuzzleTopBar(
                        volcanoName: puzzle.volcanoName,
                        progress: puzzle.progress,
                        placedCount: puzzle.pieces.filter { $0.isPlaced }.count,
                        totalCount: puzzle.pieces.count,
                        onClose: {
                            presentationMode.wrappedValue.dismiss()
                        },
                        onHint: {
                            withAnimation {
                                showHint.toggle()
                            }
                        },
                        onReset: {
                            resetPuzzle()
                        }
                    )
                    
                    // Mode selector replaced with static title
                    Text("Assemble the Image")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#2A9D8F"))
                        .padding(.vertical, 10)
                    
                    // Main content based on mode
                    GeometryReader { geometry in
                        ZStack {
                            ScrollView {
                                VStack(spacing: 20) {
                                    // Game instructions
                                    Text(PuzzleMode.jigsaw.description)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "#1D3557"))
                                        .padding(.vertical, 10)
                                        .multilineTextAlignment(.center)
                                    
                                    // Jigsaw puzzle view
                                    JigsawPuzzleView(
                                        puzzle: puzzle,
                                        draggingItem: $draggingItem,
                                        animatingPiece: $animatingPiece,
                                        showHint: showHint,
                                        onPiecePlaced: { pieceIndex, targetIndex in
                                            handlePiecePlacement(pieceIndex: pieceIndex, targetIndex: targetIndex)
                                        }
                                    )
                                    .padding(.horizontal)
                                    
                                    // Draggable pieces at the bottom
                                    PuzzlePiecesView(
                                        puzzle: puzzle,
                                        draggingItem: $draggingItem,
                                        onDragStarted: { index in
                                            startDragging(index: index)
                                        },
                                        onPieceTapped: { index in
                                            if showHint {
                                                highlightCorrectPosition(for: index)
                                            }
                                        }
                                    )
                                    .padding(.vertical, 20)
                                    .padding(.horizontal)
                                    
                                    Spacer(minLength: 40)
                                }
                                .padding()
                            }
                            .disabled(draggingItem != nil) // Disable ScrollView when dragging
                            
                            // Invisible overlay to capture drag movements when a piece is being dragged
                            if draggingItem != nil {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                handleDragChange(location: value.location)
                                            }
                                            .onEnded { _ in
                                                // Reset if released outside a valid drop zone
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    if draggingItem != nil {
                                                        draggingItem = nil
                                                        // Provide feedback
                                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                                        generator.impactOccurred()
                                                    }
                                                }
                                            }
                                    )
                                    .zIndex(100) // Ensure it's on top to capture all touch events
                            }
                            
                            // Dragged piece overlay - follows finger during drag
                            if let draggingItemIndex = draggingItem {
                                DraggedPieceView(piece: puzzle.pieces[draggingItemIndex])
                                    .position(dragPosition(in: geometry))
                                    .animation(.interactiveSpring(), value: dragPosition(in: geometry))
                            }
                        }
                    }
                }
                
                // Feedback overlay
                if showFeedback {
                    FeedbackOverlay(
                        isCorrect: isCorrectPlacement,
                        message: feedbackText,
                        onDismiss: {
                            withAnimation {
                                showFeedback = false
                            }
                            
                            // Check if all pieces are placed correctly
                            if puzzle.isCompleted && !showResults {
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
        .navigationBarHidden(true)
    }
    
    // MARK: - Game Logic Functions
    
    // Position for the dragged piece
    private func dragPosition(in geometry: GeometryProxy) -> CGPoint {
        // Use the tracked position when available, otherwise default to center
        return dragLocation.x != 0 ? dragLocation : CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
    
    // Start dragging a piece
    private func startDragging(index: Int) {
        if !puzzle.pieces[index].isPlaced {
            draggingItem = index
            
            // Hide any showing feedback while dragging
            if showFeedback {
                showFeedback = false
            }
        }
    }
    
    // Handle drag movement
    private func handleDragChange(location: CGPoint) {
        dragLocation = location
    }
    
    // Handle piece placement
    private func handlePiecePlacement(pieceIndex: Int, targetIndex: Int) {
        // Check if the position is already occupied
        if puzzle.pieces.contains(where: { $0.isPlaced && $0.currentIndex == targetIndex }) {
            // Already occupied - show feedback
            feedbackText = "This position is already filled with another piece."
            isCorrectPlacement = false
            withAnimation {
                showFeedback = true
            }
            return
        }
        
        // Place the piece regardless of correctness - this is free-form assembly
        var updatedPuzzle = puzzle
        updatedPuzzle.placePiece(pieceIndex: pieceIndex, at: targetIndex)
        
        // Force UI update with animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            puzzle = updatedPuzzle
        }
        
        // Animate the placed piece
        animatingPiece = pieceIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animatingPiece = nil
        }
        
        // Reset dragging state
        draggingItem = nil
        
        // Add haptic feedback for successful placement
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Check if all pieces are placed (regardless of correctness)
        if puzzle.pieces.allSatisfy({ $0.isPlaced }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showResults = true
                }
            }
        }
    }
    
    // Reset the puzzle
    private func resetPuzzle() {
        withAnimation {
            var updatedPuzzle = puzzle
            updatedPuzzle.reset()
            puzzle = updatedPuzzle
            showHint = false
            
            if showFeedback {
                showFeedback = false
            }
        }
    }
    
    // Highlight the correct position for a piece (hint)
    private func highlightCorrectPosition(for pieceIndex: Int) {
        if !puzzle.pieces[pieceIndex].isPlaced {
            // Show hint animation for the correct position
            animatingPiece = pieceIndex
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                animatingPiece = nil
            }
        }
    }
}

// MARK: - Supporting Views

// Top bar with controls
struct PuzzleTopBar: View {
    let volcanoName: String
    let progress: Double
    let placedCount: Int
    let totalCount: Int
    let onClose: () -> Void
    let onHint: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Close button
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
                
                // Title
                Text("\(volcanoName) Puzzle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                
                Spacer()
                
                // Hint button
                Button(action: onHint) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#F4A261"))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.6))
                        )
                }
                
                // Reset button
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#E76F51"))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.6))
                        )
                }
            }
            .padding(.horizontal)
            
            // Progress bar
            HStack {
                Text("\(placedCount)/\(totalCount) Placed")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#1D3557"))
                
                Spacer()
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        Capsule()
                            .fill(Color(hex: "#2A9D8F"))
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal)
        }
        .padding(.top, 15)
        .padding(.bottom, 10)
        .background(Color.white.opacity(0.1))
    }
}

// Jigsaw mode view
struct JigsawPuzzleView: View {
    let puzzle: VolcanoPuzzle
    @Binding var draggingItem: Int?
    @Binding var animatingPiece: Int?
    let showHint: Bool
    let onPiecePlaced: (Int, Int) -> Void
    
    // Local state
    @State private var dropZones: [JigsawDropZone] = []
    @State private var dragPosition: CGPoint = .zero
    @State private var activeDropZone: Int? = nil
    
    var body: some View {
        VStack {
            // Jigsaw puzzle board
            GeometryReader { geometry in
                ZStack {
                    // Background grid
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Grid of drop zones
                    VStack(spacing: 2) {
                        ForEach(0..<2) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<3) { column in
                                    let index = row * 3 + column
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(dropZoneColor(for: index), 
                                                    style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(dropZoneColor(for: index).opacity(0.1))
                                            )
                                            .padding(4)
                                        
                                        // Show piece if placed
                                        if let placedPiece = getPlacedPiece(at: index) {
                                            Image(placedPiece.image ?? "PZV1")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(8)
                                                .scaleEffect(animatingPiece == getPlacedPieceIndex(at: index) ? 1.1 : 1.0)
                                                .animation(
                                                    animatingPiece == getPlacedPieceIndex(at: index) ? 
                                                        Animation.spring(response: 0.3, dampingFraction: 0.6).repeatCount(1) : 
                                                        .default,
                                                    value: animatingPiece == getPlacedPieceIndex(at: index)
                                                )
                                        }
                                        
                                        // Show hint if enabled
                                        if showHint && getPlacedPiece(at: index) == nil {
                                            let correctPiece = getCorrectPiece(for: index)
                                            if let correctPiece = correctPiece {
                                                Image(correctPiece.image ?? "PZV1")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .padding(8)
                                                    .opacity(0.3)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    
                    // Invisible overlay for drag detection
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if draggingItem != nil {
                                        // Update drag position
                                        dragPosition = value.location
                                        
                                        // Check which drop zone we're hovering over
                                        for (i, zone) in getDropZones(in: geometry).enumerated() {
                                            if zone.rect.contains(value.location) {
                                                if activeDropZone != i {
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        activeDropZone = i
                                                    }
                                                    
                                                    // Haptic feedback
                                                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                                                    impactLight.impactOccurred()
                                                }
                                                return
                                            }
                                        }
                                        activeDropZone = nil
                                    }
                                }
                                .onEnded { value in
                                    if let currentDraggingItem = draggingItem, let currentActiveZone = activeDropZone {
                                        // When released over a drop zone, attempt placement
                                        onPiecePlaced(currentDraggingItem, currentActiveZone)
                                        
                                        // Add success haptic feedback
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                    }
                                    
                                    // Reset active zone
                                    activeDropZone = nil
                                }
                        )
                }
                .onAppear {
                    // Initialize drop zones
                    dropZones = getDropZones(in: geometry)
                }
                .onChange(of: geometry.size) { _, _ in
                    // Update drop zones if size changes
                    dropZones = getDropZones(in: geometry)
                }
            }
            .aspectRatio(1.5, contentMode: .fit)
        }
    }
    
    // Create drop zones based on geometry
    private func getDropZones(in geometry: GeometryProxy) -> [JigsawDropZone] {
        let width = (geometry.size.width - 40) / 3
        let height = (geometry.size.height - 40) / 2
        
        var zones: [JigsawDropZone] = []
        
        for row in 0..<2 {
            for col in 0..<3 {
                let index = row * 3 + col
                let x = 20 + width * CGFloat(col) + width/2
                let y = 20 + height * CGFloat(row) + height/2
                
                zones.append(
                    JigsawDropZone(
                        index: index,
                        rect: CGRect(
                            x: x - width/2,
                            y: y - height/2,
                            width: width,
                            height: height
                        )
                    )
                )
            }
        }
        
        return zones
    }
    
    // Get appropriate color for drop zone based on state
    private func dropZoneColor(for index: Int) -> Color {
        if activeDropZone == index {
            return Color(hex: "#1D3557").opacity(0.9) // Highlight when hovering
        } else if getPlacedPiece(at: index) != nil {
            return Color(hex: "#1D3557").opacity(0.4) // Lighter highlight for filled zones
        } else {
            return Color(hex: "#1D3557").opacity(0.6) // Default color
        }
    }
    
    // Get the piece placed at a specific position
    private func getPlacedPiece(at index: Int) -> PuzzlePiece? {
        return puzzle.pieces.first { $0.isPlaced && $0.currentIndex == index }
    }
    
    // Get the index of a placed piece
    private func getPlacedPieceIndex(at index: Int) -> Int? {
        return puzzle.pieces.firstIndex { $0.isPlaced && $0.currentIndex == index }
    }
    
    // Get the piece that should be in this position (for hints)
    private func getCorrectPiece(for index: Int) -> PuzzlePiece? {
        return puzzle.pieces.first { $0.correctIndex == index && !$0.isPlaced }
    }
}

// Helper struct for jigsaw drop zones
struct JigsawDropZone {
    let index: Int
    let rect: CGRect
}

// Draggable puzzle pieces view
struct PuzzlePiecesView: View {
    let puzzle: VolcanoPuzzle
    @Binding var draggingItem: Int?
    let onDragStarted: (Int) -> Void
    let onPieceTapped: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Available Pieces")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#1D3557"))
                
                Image(systemName: "arrow.up")
                    .foregroundColor(Color(hex: "#E76F51"))
                    .font(.system(size: 14, weight: .bold))
                
                Text("Drag to place")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#E76F51"))
            }
            .padding(.bottom, 5)
            
            // Grid of pieces
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(puzzle.pieces.indices, id: \.self) { index in
                    if !puzzle.pieces[index].isPlaced {
                        PuzzlePieceView(
                            piece: puzzle.pieces[index],
                            isDragging: draggingItem == index,
                            onTap: {
                                onPieceTapped(index)
                            },
                            onDragStarted: {
                                onDragStarted(index)
                            }
                        )
                        .transition(.scale)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// Individual puzzle piece
struct PuzzlePieceView: View {
    let piece: PuzzlePiece
    let isDragging: Bool
    let onTap: () -> Void
    let onDragStarted: () -> Void
    @State private var dragAmount = CGSize.zero
    @GestureState private var isDetectingLongPress = false
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                // If there's an image, show it
                if let imageName = piece.image, !imageName.isEmpty {
                    ZStack(alignment: .topTrailing) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            .cornerRadius(8)
                            .padding(5)
                        
                        // Drag icon indicator
                        Image(systemName: "hand.draw")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Circle().fill(Color(hex: "#E76F51")))
                            .offset(x: -5, y: 5)
                    }
                } else {
                    // Otherwise just show the text
                    ZStack(alignment: .topTrailing) {
                        Text(piece.name)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 10)
                            .frame(height: 70)
                        
                        // Drag icon indicator
                        Image(systemName: "hand.draw")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Circle().fill(Color(hex: "#E76F51")))
                            .offset(x: -5, y: 5)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#2A9D8F"))
            )
            .shadow(
                color: Color.black.opacity(isDragging || isDetectingLongPress ? 0.3 : 0.1),
                radius: isDragging || isDetectingLongPress ? 10 : 5,
                x: 0,
                y: isDragging || isDetectingLongPress ? 5 : 2
            )
            .scaleEffect(isDragging || isDetectingLongPress ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging || isDetectingLongPress)
        }
        .highPriorityGesture(
            DragGesture(minimumDistance: 5)
                .updating($isDetectingLongPress) { currentState, gestureState, _ in
                    gestureState = true
                }
                .onChanged { _ in
                    if !isDragging {
                        onDragStarted()
                        // Add haptic feedback
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }
                }
        )
        .allowsHitTesting(!isDragging)
    }
}

// Feedback overlay
struct FeedbackOverlay: View {
    let isCorrect: Bool
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 15) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isCorrect ? Color(hex: "#2A9D8F") : Color(hex: "#E76F51"))
                    .padding(.bottom, 5)
                
                Text(isCorrect ? "Correct!" : "Try Again")
                    .font(.headline)
                    .foregroundColor(isCorrect ? Color(hex: "#2A9D8F") : Color(hex: "#E76F51"))
                
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(.horizontal)
                
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(
                            Capsule()
                                .fill(isCorrect ? Color(hex: "#2A9D8F") : Color(hex: "#E76F51"))
                        )
                }
                .padding(.top, 10)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
        .transition(.opacity)
    }
}

// Results view shown after completing the puzzle
struct PuzzleResultView: View {
    let puzzle: VolcanoPuzzle
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Puzzle Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                
                // Achievement icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#2A9D8F"))
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 20)
                
                Text("You've completed the \(puzzle.volcanoName) \(puzzle.mode.rawValue) puzzle!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#1D3557"))
                
                // Facts learned section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Facts Learned:")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    ForEach(puzzle.pieces.filter { !$0.description.isEmpty }, id: \.id) { piece in
                        HStack(alignment: .top, spacing: 10) {
                            Text("•")
                                .foregroundColor(Color(hex: "#2A9D8F"))
                                .font(.system(size: 16, weight: .bold))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(piece.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#1D3557"))
                                
                                Text(piece.description)
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
    }
}

// View for the piece being actively dragged
struct DraggedPieceView: View {
    let piece: PuzzlePiece
    
    var body: some View {
        if let imageName = piece.image, !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100) // Larger size while dragging
                .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 10)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .blur(radius: 8)
                )
        } else {
            Text(piece.name)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#2A9D8F"))
                )
                .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 10)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .blur(radius: 8)
                )
        }
    }
}

// Preview
struct PuzzleView_Previews: PreviewProvider {
    static var previews: some View {
        PuzzleView(volcano: "Mount Vesuvius")
    }
} 