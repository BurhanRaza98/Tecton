import SwiftUI
import SceneKit

struct VolcanoModelView: View {
    @Environment(\.presentationMode) var presentationMode
    let volcanoName: String
    
    // Function to determine which 3D model to use
    private func getModelName() -> String {
        switch volcanoName {
        case "Mount Vesuvius":
            return "vesuvius"
        case "Mount St. Helens":
            return "Mount Etna" // Using Etna model for St. Helens as specified
        case "Mount Fuji":
            return "Fiji" // Using the Fiji model for Fuji
        default:
            return "vesuvius" // Default fallback
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F5F5DC").edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top bar with title and close button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
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
                    
                    Text("\(volcanoName) 3D Model")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1D3557"))
                    
                    Spacer()
                    
                    // Empty view for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 36, height: 36)
                }
                .padding()
                
                // 3D Model View
                SceneView(
                    scene: {
                        let scene = SCNScene()
                        
                        // Try to load the USD model
                        if let modelURL = Bundle.main.url(forResource: getModelName(), withExtension: "usdz") {
                            let modelNode = SCNReferenceNode(url: modelURL)
                            modelNode?.load()
                            
                            // Position the model in the center
                            if let modelNode = modelNode {
                                // Center model
                                let (min, max) = modelNode.boundingBox
                                let modelHeight = max.y - min.y
                                modelNode.position = SCNVector3(0, -modelHeight/2, 0)
                                
                                // Add to scene
                                scene.rootNode.addChildNode(modelNode)
                            }
                        }
                        
                        // Add ambient light
                        let ambientLight = SCNNode()
                        ambientLight.light = SCNLight()
                        ambientLight.light?.type = .ambient
                        ambientLight.light?.color = UIColor(white: 0.5, alpha: 1.0)
                        scene.rootNode.addChildNode(ambientLight)
                        
                        // Add directional light
                        let directionalLight = SCNNode()
                        directionalLight.light = SCNLight()
                        directionalLight.light?.type = .directional
                        directionalLight.light?.color = UIColor(white: 0.8, alpha: 1.0)
                        directionalLight.eulerAngles = SCNVector3(x: -.pi / 3, y: .pi / 4, z: 0)
                        scene.rootNode.addChildNode(directionalLight)
                        
                        return scene
                    }(),
                    options: [
                        .allowsCameraControl,
                        .autoenablesDefaultLighting,
                        .temporalAntialiasingEnabled
                    ]
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Instructions for interaction
                Text("Pinch to zoom, drag to rotate")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }
}

// Preview for SwiftUI canvas
struct VolcanoModelView_Previews: PreviewProvider {
    static var previews: some View {
        VolcanoModelView(volcanoName: "Mount Vesuvius")
    }
} 