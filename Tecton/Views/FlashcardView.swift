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
                    // Vista de finalización centrada
                    VStack(spacing: 0) {
                        Spacer().frame(height: geometry.size.height * 0.15)
                        
                        // Mensaje de finalización
                        VStack(spacing: 16) {
                            Text("You're ready!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("You can now play the mini-games.")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Tap here to continue")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.top, 8)
                        }
                        .padding(.vertical, 30)
                        .padding(.horizontal, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "#E76F51").opacity(0.9))
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                } else {
                    // Contenido principal
                    ZStack {
                        // Botón para cerrar la modal (posicionado absolutamente)
                        VStack {
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
                            
                            Spacer()
                        }
                        .zIndex(2)
                        
                        // Contenedor centrado en la tarjeta
                        VStack(spacing: 0) {
                            // Espacio superior ajustable
                            Spacer()
                                .frame(height: geometry.size.height * 0.1)
                            
                            // Flecha animada (igual de gruesa pero menos abierta)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .shadow(radius: 2)
                                .offset(y: offset.height / 10)
                                .animation(
                                    Animation.easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true),
                                    value: UUID()
                                )
                                .padding(.bottom, 20)
                                .padding(.trailing, 5) // Compensación sutil de 5 puntos
                            
                            // Tarjeta actual (centrada y más grande)
                            ZStack {
                                // Mostrar la siguiente tarjeta parcialmente detrás de la actual
                                if currentIndex < deck.cards.count - 1 {
                                    cardView(for: deck.cards[currentIndex + 1])
                                        .zIndex(0)
                                        .padding(.trailing, 5) // Compensación sutil de 5 puntos
                                }
                                
                                // Tarjeta actual
                                cardView(for: deck.cards[currentIndex])
                                    .offset(offset)
                                    .rotationEffect(.degrees(Double(offset.width / 20)))
                                    .zIndex(1)
                                    .padding(.trailing, 5) // Compensación sutil de 5 puntos
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                offset = gesture.translation
                                            }
                                            .onEnded { gesture in
                                                if abs(gesture.translation.width) > 100 {
                                                    // Deslizamiento suficiente para cambiar de tarjeta
                                                    withAnimation(.easeOut(duration: 0.3)) {
                                                        offset = CGSize(
                                                            width: gesture.translation.width > 0 ? 500 : -500,
                                                            height: 0
                                                        )
                                                    }
                                                    
                                                    // Cambiar a la siguiente tarjeta después de la animación
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        // Preparar la siguiente tarjeta sin animación
                                                        offset = .zero
                                                        if currentIndex < deck.cards.count - 1 {
                                                            currentIndex += 1
                                                        } else {
                                                            showCompletion = true
                                                        }
                                                    }
                                                } else {
                                                    // No deslizó lo suficiente, volver a la posición original
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        offset = .zero
                                                    }
                                                }
                                            }
                                    )
                            }
                            .frame(height: geometry.size.height * 0.7)
                            .padding(.trailing, 5) // Compensación sutil de 5 puntos para el ZStack completo
                            
                            // Espacio flexible para empujar los indicadores hacia abajo
                            Spacer()
                            
                            // Indicadores de progreso (anclados abajo)
                            HStack(spacing: 10) {
                                ForEach(0..<deck.cards.count, id: \.self) { index in
                                    Circle()
                                        .fill(index <= currentIndex ? Color.green : Color.white.opacity(0.5))
                                        .frame(width: 10, height: 10)
                                }
                            }
                            .padding(.trailing, 5) // Compensación sutil de 5 puntos
                            .padding(.bottom, 320)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }
                        .frame(width: geometry.size.width)
                        .padding(.trailing, 5) // Compensación sutil de 5 puntos para todo el contenedor
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
            .padding(.horizontal, 5) // Padding mínimo para maximizar tamaño
    }
    
    // Vista de finalización
    private var completionView: some View {
        VStack(spacing: 16) {
            Text("You're ready!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("You can now play the mini-games.")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Tap here to continue")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 8)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#E76F51").opacity(0.9))
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10)
        .padding(30)
        .frame(maxWidth: .infinity, alignment: .center) // Asegura centrado horizontal
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
