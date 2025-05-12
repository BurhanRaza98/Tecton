import SwiftUI

// Implementation of the "Build the Layers" puzzle mode
struct LayersPuzzleView: View {
    let puzzle: VolcanoPuzzle
    @Binding var draggingItem: Int?
    @Binding var animatingPiece: Int?
    let showHint: Bool
    let onPiecePlaced: (Int, Int) -> Void
    
    // Local state
    @State private var dropZones: [DropZone] = []
    @State private var dragPosition: CGPoint = .zero
    @State private var activeDropZone: Int? = nil
    
    // Initialize drop zones
    private func createDropZones(in geometry: GeometryProxy) -> [DropZone] {
        // Create zones from bottom to top
        let zoneHeight = geometry.size.height / CGFloat(puzzle.pieces.count)
        var zones: [DropZone] = []
        
        for i in 0..<puzzle.pieces.count {
            let y = geometry.size.height - (CGFloat(i) + 0.5) * zoneHeight
            zones.append(
                DropZone(
                    index: i,
                    rect: CGRect(
                        x: geometry.size.width / 2 - 100,
                        y: y - 40,
                        width: 200,
                        height: zoneHeight
                    )
                )
            )
        }
        return zones
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Instruction text
            Text("Stack the volcano layers from bottom to top")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#1D3557"))
                .padding(.vertical, 5)
            
            // Volcano diagram container with drop zones
            GeometryReader { geometry in
                ZStack {
                    // Volcano outline/background
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            // Volcano silhouette
                            Image(puzzle.backgroundImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(20)
                                .opacity(0.6)
                        )
                    
                    // Drop zones
                    ForEach(0..<puzzle.pieces.count, id: \.self) { i in
                        ZStack {
                            // Drop zone highlight
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(dropZoneColor(for: i), 
                                        style: StrokeStyle(lineWidth: 3, dash: [5]))
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(dropZoneColor(for: i).opacity(0.2))
                                )
                                .opacity(0.8)
                            
                            if showHint {
                                let hintPiece = getHintPiece(for: i)
                                if let hintPiece = hintPiece {
                                    Text(hintPiece.name)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color(hex: "#1D3557").opacity(0.8))
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.7))
                                        )
                                }
                            }
                        }
                        .frame(width: dropZones.isEmpty ? 0 : dropZones[i].rect.width, 
                               height: dropZones.isEmpty ? 0 : dropZones[i].rect.height)
                        .position(
                            x: dropZones.isEmpty ? 0 : dropZones[i].rect.midX,
                            y: dropZones.isEmpty ? 0 : dropZones[i].rect.midY
                        )
                    }
                    
                    // Placed layers
                    ForEach(puzzle.pieces.indices, id: \.self) { index in
                        if let currentIndex = puzzle.pieces[index].currentIndex, puzzle.pieces[index].isPlaced {
                            PlacedLayerView(
                                piece: puzzle.pieces[index],
                                isAnimating: animatingPiece == index,
                                dropZone: dropZones.isEmpty ? .zero : 
                                    CGRect(
                                        x: dropZones[currentIndex].rect.midX - 100,
                                        y: dropZones[currentIndex].rect.midY - 40,
                                        width: 200,
                                        height: 80
                                    )
                            )
                        }
                    }
                    
                    // Drop zone detection overlay (invisible)
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if draggingItem != nil {
                                        // Update drag position for drop zone detection
                                        dragPosition = value.location
                                        
                                        // Check which drop zone we're hovering over
                                        let newActiveZone = dropZones.firstIndex { zone in
                                            zone.rect.contains(value.location)
                                        }
                                        
                                        if activeDropZone != newActiveZone {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                activeDropZone = newActiveZone
                                            }
                                            
                                            // Add haptic feedback when hovering over a zone
                                            if newActiveZone != nil {
                                                let impactLight = UIImpactFeedbackGenerator(style: .light)
                                                impactLight.impactOccurred()
                                            }
                                        }
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
                    // Create drop zones based on geometry
                    dropZones = createDropZones(in: geometry)
                }
                .onChange(of: geometry.size) { oldValue, newValue in
                    // Update drop zones if size changes
                    dropZones = createDropZones(in: geometry)
                }
            }
            .frame(height: 250) // Reduced height
            
            Spacer(minLength: 10)
            
            // Draggable pieces section
            VStack {
                Text("Available Pieces")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(.bottom, 5)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(puzzle.pieces.indices, id: \.self) { index in
                        if !puzzle.pieces[index].isPlaced {
                            DraggablePieceView(
                                piece: puzzle.pieces[index],
                                isDragging: draggingItem == index,
                                onDragStarted: {
                                    if draggingItem == nil {
                                        draggingItem = index
                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                        impactMed.impactOccurred()
                                    }
                                }
                            )
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
    
    // Get appropriate color for drop zone based on state
    private func dropZoneColor(for index: Int) -> Color {
        if activeDropZone == index {
            return Color(hex: "#1D3557").opacity(0.9) // Highlight when hovering over any zone
        } else if puzzle.pieces.contains(where: { $0.isPlaced && $0.currentIndex == index }) {
            return Color(hex: "#1D3557").opacity(0.4) // Lighter highlight for filled zones
        } else {
            return Color(hex: "#1D3557").opacity(0.6) // Default color
        }
    }
    
    // Determine if a drop zone should be fully visible
    private func isDropZoneVisible(_ index: Int) -> Bool {
        return activeDropZone == index || showHint || 
               puzzle.pieces.contains(where: { $0.isPlaced && $0.currentIndex == index })
    }
    
    // Get the piece that belongs in this zone for hints
    private func getHintPiece(for zoneIndex: Int) -> PuzzlePiece? {
        return puzzle.pieces.first { piece in
            piece.correctIndex == zoneIndex && !piece.isPlaced
        }
    }
}

// Helper struct for drop zones
struct DropZone {
    let index: Int
    let rect: CGRect
}

// View for a placed layer in the puzzle
struct PlacedLayerView: View {
    let piece: PuzzlePiece
    let isAnimating: Bool
    let dropZone: CGRect
    
    var body: some View {
        VStack(spacing: 5) {
            // If there's an image, show it
            if let imageName = piece.image, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
            } else {
                // Otherwise just show the text
                Text(piece.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#2A9D8F"))
                    )
            }
        }
        .frame(width: dropZone.width, height: dropZone.height)
        .position(x: dropZone.midX, y: dropZone.midY)
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .animation(
            isAnimating ? 
                Animation.spring(response: 0.3, dampingFraction: 0.6).repeatCount(1) : 
                .default,
            value: isAnimating
        )
    }
}

// Draggable piece view specifically for the layers puzzle
struct DraggablePieceView: View {
    let piece: PuzzlePiece
    let isDragging: Bool
    let onDragStarted: () -> Void
    
    var body: some View {
        ZStack {
            // If there's an image, show it
            if let imageName = piece.image, !imageName.isEmpty {
                ZStack(alignment: .topTrailing) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .cornerRadius(8)
                        .padding(5)
                    
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
            color: Color.black.opacity(isDragging ? 0.3 : 0.1),
            radius: isDragging ? 10 : 5,
            x: 0,
            y: isDragging ? 5 : 2
        )
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { _ in
                    if !isDragging {
                        onDragStarted()
                    }
                }
        )
        .padding(.horizontal, 5)
    }
} 