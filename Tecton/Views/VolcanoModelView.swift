import SwiftUI
import SceneKit
import QuickLook
import ARKit

struct VolcanoModelView: View {
    @Environment(\.presentationMode) var presentationMode
    let volcanoName: String
    @State private var showingARView = false
    
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
                    .padding(.bottom)
                
                // View in AR button
                Button(action: {
                    showingARView = true
                }) {
                    HStack {
                        Image(systemName: "arkit")
                        Text("View in AR")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color(hex: "#F4A261"))
                    )
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingARView) {
            VolcanoARView(modelName: getModelName(), volcanoName: volcanoName)
        }
    }
}

struct VolcanoARView: UIViewRepresentable {
    let modelName: String
    let volcanoName: String
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        
        // Set scene background
        arView.scene = SCNScene()
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        
        // Set a simple environment without AR tracking for reliability
        arView.debugOptions = []
        
        // Load the model immediately in a fixed position
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
            let referenceNode = SCNReferenceNode(url: modelURL)
            referenceNode?.load()
            
            if let node = referenceNode {
                // Position in front of camera
                node.position = SCNVector3(0, -0.5, -2)
                
                // Add rotation so model faces camera
                node.eulerAngles = SCNVector3(0, 0, 0)
                
                // Scale appropriately
                let scale: Float = 0.2
                node.scale = SCNVector3(scale, scale, scale)
                
                // Add to scene
                arView.scene.rootNode.addChildNode(node)
                context.coordinator.modelNode = node
                
                // Add rotation animation
                let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 30.0)
                let repeatAction = SCNAction.repeatForever(rotateAction)
                node.runAction(repeatAction)
            }
        }
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.7)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(context.coordinator, action: #selector(Coordinator.close), for: .touchUpInside)
        
        arView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: arView.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: arView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Create instructions container view with padding
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.7)
        containerView.layer.cornerRadius = 10
        
        // Add instructions label inside container
        let instructionsLabel = UILabel()
        instructionsLabel.text = "Drag to rotate the \(volcanoName) model"
        instructionsLabel.textAlignment = .center
        instructionsLabel.textColor = .white
        instructionsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionsLabel.numberOfLines = 0
        
        // Add label to container with padding
        containerView.addSubview(instructionsLabel)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            instructionsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            instructionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
        
        // Add container to AR view
        arView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: arView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            containerView.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualTo: arView.widthAnchor, constant: -40)
        ])
        
        // Add pan gesture to rotate model
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        let parent: VolcanoARView
        var modelNode: SCNNode?
        var initialRotation: SCNVector3?
        
        init(_ parent: VolcanoARView) {
            self.parent = parent
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let modelNode = self.modelNode else { return }
            guard let arView = gesture.view as? ARSCNView else { return }
            
            if gesture.state == .began {
                initialRotation = modelNode.eulerAngles
            }
            
            let translation = gesture.translation(in: arView)
            
            if let initialRotation = initialRotation {
                // Convert pan to rotation - pan left/right to rotate around y-axis
                let sensitivity: Float = 0.01
                let yRotation = Float(translation.x) * sensitivity
                let xRotation = Float(translation.y) * sensitivity
                
                modelNode.eulerAngles = SCNVector3(
                    initialRotation.x - xRotation,
                    initialRotation.y - yRotation,
                    initialRotation.z
                )
            }
        }
        
        @objc func close() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Helper class for QuickLook AR preview
class VolcanoQLPreviewController: NSObject, QLPreviewControllerDataSource {
    static let shared = VolcanoQLPreviewController()
    var items: [VolcanoQLPreviewItem] = []
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return items[index]
    }
}

// Model for QuickLook preview item
class VolcanoQLPreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    var previewItemTitle: String?
    
    init(url: URL, title: String?) {
        self.previewItemURL = url
        self.previewItemTitle = title
        super.init()
    }
}

// Preview for SwiftUI canvas
struct VolcanoModelView_Previews: PreviewProvider {
    static var previews: some View {
        VolcanoModelView(volcanoName: "Mount Vesuvius")
    }
} 