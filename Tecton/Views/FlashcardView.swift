import SwiftUI

struct VolcanoInfoCardView: View {
    let volcanoName: String
    @State private var deck: VolcanoFlashcardDeck
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showCompletion = false
    @Environment(\.presentationMode) var presentationMode
    
    // Inicializador que carga el deck correcto según el volcán
    init(volcanoName: String) {
        self.volcanoName = volcanoName
        _deck = State(initialValue: VolcanoFlashcardDeck.getDeck(for: volcanoName))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo similar al dashboard (gradiente naranja-rojo)
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#C9AB39"), Color(hex: "#E76F51")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Imagen de fondo
                Image("New_Background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.8)
                
                if showCompletion {
                    // Vista de finalización
                    completionView
                } else {
                    // Contenido principal
                    VStack(spacing: 0) {
                        // Botón para cerrar la modal (posicionado absolutamente)
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                    )
                            }
                            .padding(.leading, 20)
                            .padding(.top, 10)
                            
                            Spacer()
                        }
                        .zIndex(1)
                        
                        // Contenedor principal centrado
                        VStack(spacing: 20) {
                            // Flecha animada
                            Image(systemName: "chevron.down")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .shadow(radius: 2)
                                .offset(y: offset.height / 10)
                                .animation(
                                    Animation.easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true),
                                    value: UUID()
                                )
                            
                            // Tarjeta actual (centrada)
                            ZStack {
                                ForEach(0..<deck.cards.count, id: \.self) { index in
                                    if index == currentIndex {
                                        cardView(for: deck.cards[index])
                                            .offset(offset)
                                            .rotationEffect(.degrees(Double(offset.width / 20)))
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { gesture in
                                                        offset = gesture.translation
                                                    }
                                                    .onEnded { gesture in
                                                        if abs(gesture.translation.width) > 100 {
                                                            // Deslizamiento suficiente para cambiar de tarjeta
                                                            withAnimation {
                                                                offset = CGSize(
                                                                    width: gesture.translation.width > 0 ? 500 : -500,
                                                                    height: 0
                                                                )
                                                            }
                                                            
                                                            // Cambiar a la siguiente tarjeta después de la animación
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                offset = .zero
                                                                if currentIndex < deck.cards.count - 1 {
                                                                    currentIndex += 1
                                                                } else {
                                                                    showCompletion = true
                                                                }
                                                            }
                                                        } else {
                                                            // No deslizó lo suficiente, volver a la posición original
                                                            withAnimation {
                                                                offset = .zero
                                                            }
                                                        }
                                                    }
                                            )
                                    }
                                }
                            }
                            .frame(height: geometry.size.height * 0.5)
                            
                            // Indicadores de progreso
                            HStack(spacing: 10) {
                                ForEach(0..<deck.cards.count, id: \.self) { index in
                                    Circle()
                                        .fill(index <= currentIndex ? Color.green : Color.white.opacity(0.5))
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                        .padding(.top, -300) // Ajuste moderado hacia arriba
                        .frame(maxHeight: .infinity, alignment: .center) // Centrar verticalmente
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // Vista para una tarjeta individual
    private func cardView(for card: VolcanoFlashcard) -> some View {
        Image(card.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(20)
            .padding(.horizontal)
    }
    
    // Vista de finalización
    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("¡Listo para jugar!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Ahora conoces los datos básicos sobre \(volcanoName). ¡Es hora de poner a prueba tus conocimientos en los mini-juegos!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text("Toca en cualquier lugar para continuar")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 40)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 10)
        )
        .padding(30)
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct VolcanoInfoCardView_Previews: PreviewProvider {
    static var previews: some View {
        VolcanoInfoCardView(volcanoName: "Mount Vesuvius")
    }
}
