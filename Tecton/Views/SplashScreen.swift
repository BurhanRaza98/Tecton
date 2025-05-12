import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // Background image
                Image("Splash Screen")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Logo and app name
                VStack(spacing: 15) {
                    Spacer()
                    
                    // Logo
                    Image("Tecton Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    // App name
                    Text("Tecton")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.vertical, 100)
                .opacity(opacity)
            }
            .onAppear {
                // Animate the logo appearance
                withAnimation(.easeIn(duration: 1.5)) {
                    self.opacity = 1.0
                }
                
                // Navigate to main screen after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
} 