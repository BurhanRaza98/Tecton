import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        print("=== LOTTIE DEBUG START ===")
        print("Attempting to load animation: \(name)")
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        // Create animation view
        let animationView = LottieAnimationView()
        
        // List all files in the bundle to verify what's available
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("Files in app bundle: \(files)")
                
                // Filter for animation files
                let animationFiles = files.filter { $0.contains("json") || $0.contains("lottie") }
                print("Animation files: \(animationFiles)")
            } catch {
                print("Error listing files in bundle: \(error)")
            }
        }
        
        // Try to load animation by name (JSON file)
        print("Attempting to load animation by name: \(name)")
        if let animation = LottieAnimation.named(name) {
            print("SUCCESS! Loaded animation: \(name) by name")
            setupAnimationView(animationView, animation, view)
            print("=== LOTTIE DEBUG END ===")
            return view
        } else {
            print("Failed to load animation by name")
        }
        
        // Try explicit JSON file path
        print("Attempting to load from JSON file path")
        if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
            print("Found JSON file at path: \(filePath)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                print("Loaded \(data.count) bytes of JSON data")
                
                do {
                    let animation = try LottieAnimation.from(data: data)
                    print("SUCCESS! Parsed JSON animation data")
                    setupAnimationView(animationView, animation, view)
                    print("=== LOTTIE DEBUG END ===")
                    return view
                } catch {
                    print("Error parsing JSON animation data: \(error)")
                }
            } catch {
                print("Error loading JSON file: \(error)")
            }
        } else {
            print("No JSON file found with name: \(name)")
        }
        
        // Try loading just any JSON animation file
        print("Attempting to load TectonAnimation.json directly")
        if let filePath = Bundle.main.path(forResource: "TectonAnimation", ofType: "json") {
            print("Found TectonAnimation.json file at path: \(filePath)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                print("Loaded \(data.count) bytes of TectonAnimation.json data")
                
                do {
                    let animation = try LottieAnimation.from(data: data)
                    print("SUCCESS! Parsed TectonAnimation.json data")
                    setupAnimationView(animationView, animation, view)
                    print("=== LOTTIE DEBUG END ===")
                    return view
                } catch {
                    print("Error parsing TectonAnimation.json data: \(error)")
                }
            } catch {
                print("Error loading TectonAnimation.json file: \(error)")
            }
        } else {
            print("TectonAnimation.json file not found in bundle")
        }
        
        // Fallback for lottie files
        print("Attempting to load .lottie file")
        if let filePath = Bundle.main.path(forResource: name, ofType: "lottie") {
            print("Found .lottie file at path: \(filePath)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                print("Loaded \(data.count) bytes of .lottie data")
                
                do {
                    let animation = try LottieAnimation.from(data: data)
                    print("SUCCESS! Parsed .lottie data")
                    setupAnimationView(animationView, animation, view)
                    print("=== LOTTIE DEBUG END ===")
                    return view
                } catch {
                    print("Error parsing .lottie data: \(error)")
                }
            } catch {
                print("Error loading .lottie file: \(error)")
            }
        } else {
            print("No .lottie file found with name: \(name)")
        }
        
        // Use fallback
        print("All animation loading methods failed, using fallback")
        createFallbackView(view)
        print("=== LOTTIE DEBUG END ===")
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        // Nothing to update
    }
    
    private func setupAnimationView(_ animationView: LottieAnimationView, _ animation: LottieAnimation, _ containerView: UIView) {
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.play()
        
        containerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func createFallbackView(_ view: UIView) {
        // Create a fallback view - orange pulsing circle with mountain icon
        let fallbackView = UIView()
        fallbackView.backgroundColor = UIColor.orange
        fallbackView.layer.cornerRadius = 50
        view.addSubview(fallbackView)
        fallbackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fallbackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fallbackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            fallbackView.widthAnchor.constraint(equalToConstant: 100),
            fallbackView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Add a mountain icon
        let imageView = UIImageView(image: UIImage(systemName: "mountain.2.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        fallbackView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: fallbackView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: fallbackView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Animate the fallback view
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            fallbackView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            fallbackView.alpha = 0.8
        })
    }
} 