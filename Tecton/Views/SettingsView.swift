import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    @State private var showResetConfirmation = false
    @ObservedObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color that adapts to dark/light mode
                Color(colorScheme == .dark ? .black : Color(hex: "#F5F5DC"))
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 30) {
                    // GENERAL section
                    sectionHeader("GENERAL")
                    
                    VStack(spacing: 0) {
                        Toggle(isOn: $notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(hex: "#F4A261"))
                                    .font(.system(size: 18))
                                    .frame(width: 24, height: 24)
                                
                                Text("Enable Notifications")
                                    .font(.system(size: 17))
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : .white)
                        .cornerRadius(10)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            // Save to UserDefaults
                            UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                            
                            // Update achievement manager
                            if !newValue {
                                // If notifications are disabled, clear any pending notifications
                                achievementManager.newlyEarnedAchievement = nil
                                
                                // Remove all pending notifications
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            } else {
                                // If notifications are enabled, request permissions
                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    appDelegate.requestNotificationPermissions()
                                }
                            }
                        }
                    }
                    
                    // LEGAL section
                    sectionHeader("LEGAL")
                    
                    VStack(spacing: 1) {
                        navigationLink(icon: "doc.text.fill", iconColor: "#2A9D8F", title: "Terms & Conditions")
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        navigationLink(icon: "shield.fill", iconColor: "#2A9D8F", title: "Privacy Policy")
                    }
                    .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : .white)
                    .cornerRadius(10)
                    
                    // DEVELOPERS section
                    sectionHeader("DEVELOPERS")
                    
                    NavigationLink(destination: DevelopersCreditsView()) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(Color(hex: "#E76F51"))
                                .font(.system(size: 18))
                                .frame(width: 24, height: 24)
                                .padding(.leading, 16)
                            
                            Text("Meet the Team")
                                .font(.system(size: 17))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#1D3557"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                .padding(.trailing, 16)
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : .white)
                    .cornerRadius(10)
                    
                    // REFRESH section
                    sectionHeader("REFRESH")
                    
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Text("Reset All Progress")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : .white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Settings", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#1D3557"))
            })
            .alert(isPresented: $showResetConfirmation) {
                Alert(
                    title: Text("Reset Progress"),
                    message: Text("Are you sure you want to reset all your progress? This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        // Reset all progress
                        ProgressManager.shared.resetAllProgress()
                        
                        // Reset notifications setting
                        UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                        notificationsEnabled = true
                        
                        // Clear all UserDefaults (except the notifications setting we just set)
                        let keys = UserDefaults.standard.dictionaryRepresentation().keys
                        keys.forEach { key in
                            if key != "notificationsEnabled" {
                                UserDefaults.standard.removeObject(forKey: key)
                            }
                        }
                        
                        // Remove all pending notifications
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        
                        // Reset achievement manager
                        achievementManager.newlyEarnedAchievement = nil
                        
                        // Dismiss settings view and navigate to Dashboard
                        dismiss()
                        
                        // Post notification to switch to Dashboard tab
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToDashboardTab"), object: nil)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                // Set default value if not already set
                if !UserDefaults.standard.contains(key: "notificationsEnabled") {
                    UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                    notificationsEnabled = true
                }
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.leading, 16)
            .padding(.bottom, -5)
    }
    
    private func navigationLink(icon: String, iconColor: String, title: String) -> some View {
        NavigationLink(destination: {
            if title == "Privacy Policy" {
                AnyView(PrivacyPolicyView())
            } else if title == "Terms & Conditions" {
                AnyView(TermsAndConditionsView())
            } else {
                AnyView(Text("Content for \(title)"))
            }
        }()) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: iconColor))
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                    .padding(.leading, 16)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#1D3557"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Extension to check if a key exists in UserDefaults
extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
                .preferredColorScheme(.light)
            
            SettingsView()
                .preferredColorScheme(.dark)
        }
    }
}

// Add this new view for Privacy Policy
struct PrivacyPolicyView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last Updated: 09/June/2025")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Thank you for using Tecton! Your privacy is incredibly important to us. This Privacy Policy explains what information we collect, how we use it, and the choices you have about your information. Our goal is to be transparent and straightforward.")
                
                divider()
                
                sectionTitle("1. Information We Collect")
                
                Text("We designed Tecton to be a fun and private learning experience. We collect very limited information, and we do not collect any personally identifiable information (PII).")
                    .padding(.bottom, 5)
                
                subsectionTitle("Information You Provide to Us")
                Text("None. You are not required to create an account, and we do not ask for personal details like your name, email address, or location.")
                
                subsectionTitle("Information Collected Automatically")
                Text("Game Progress Data: We anonymously track which mini-games you complete and which achievements you unlock.")
                Text("How it's Stored: This information is stored only on your local device using standard iOS features (UserDefaults). It is not transmitted to us or any third party. This data is essential for the app to function, allowing you to save your progress and unlock new content.")
                
                // Additional sections...
                divider()
                
                sectionTitle("2. How We Use Your Information")
                Text("The non-personal information we collect is used solely to provide and improve your app experience. We use it to:")
                bulletPoint("Save your progress so you can pick up where you left off.")
                bulletPoint("Unlock new volcanoes and achievements as you complete challenges.")
                bulletPoint("Understand which features are most popular to help us make the app better.")
                
                // Continue with remaining sections...
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color(hex: "#F5F5DC"))
        .navigationBarTitle("Privacy Policy", displayMode: .inline)
        // Removed the custom dismiss button only from this view
    }
    
    private func divider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.gray.opacity(0.3))
            .padding(.vertical, 10)
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .padding(.bottom, 5)
    }
    
    private func subsectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .padding(.bottom, 2)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.system(size: 16))
            Text(text)
                .font(.system(size: 16))
        }
        .padding(.leading, 5)
    }
}

// Add this new view for Terms and Conditions
struct TermsAndConditionsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Tecton!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                
                Text("These terms and conditions outline the rules and regulations for the use of Tecton's Application, located at the App Store:")
                
                // App Store Link
                Link("Tecton's App Store Link", destination: URL(string: "https://apps.apple.com/mx/app/tecton/id6745767567")!)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#2A9D8F"))
                    .padding(.vertical, 5)
                
                Text("By accessing this app we assume you accept these terms and conditions. Do not continue to use Tecton if you do not agree to take all of the terms and conditions stated on this page.")
                
                divider()
                
                sectionTitle("License")
                Text("Unless otherwise stated, Tecton and/or its licensors own the intellectual property rights for all material on Tecton. All intellectual property rights are reserved.")
                
                Text("You must not:")
                    .font(.system(size: 16, weight: .medium))
                    .padding(.top, 5)
                
                bulletPoint("Republish material from Tecton")
                bulletPoint("Sell, rent or sub-license material from Tecton")
                bulletPoint("Reproduce, duplicate or copy material from Tecton")
                bulletPoint("Redistribute content from Tecton")
                
                Text("This Agreement shall begin on the date hereof.")
                    .padding(.top, 5)
                
                divider()
                
                sectionTitle("User Content")
                Text("Our App may allow you to post, link, store, share and otherwise make available certain information, text, graphics, videos, or other material (\"Content\"). You are responsible for the Content that you post on or through the Service, including its legality, reliability, and appropriateness.")
                
                Text("We reserve the right to terminate your access to the app for any reason, without notice.")
                    .padding(.top, 5)
                
                divider()
                
                sectionTitle("Disclaimer")
                Text("The materials on Tecton's app are provided on an 'as is' basis. Tecton makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.")
                
                divider()
                
                // Support Center Section
                supportCenterSection()
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color(hex: "#F5F5DC"))
        .navigationBarTitle("Terms & Conditions", displayMode: .inline)
    }
    
    private func divider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.gray.opacity(0.3))
            .padding(.vertical, 10)
    }
    
    private func supportCenterSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tecton Support Center 🌋")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#1D3557"))
            
            Text("Welcome to the official support page for Tecton! We're here to help you get the most out of your geology adventure. If you have a question or are running into an issue, you've come to the right place.")
                .font(.body)
            
            divider()
            
            Group {
                Text("❓ Frequently Asked Questions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(.bottom, 5)
                
                Text("How do I unlock new volcanoes?")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 5)
                
                Text("New volcanoes are unlocked by completing all the mini-games for the previous volcano. For example, to unlock Mount St. Helens, you must successfully complete the Quiz, Match, and Builder mini-games for Mount Vesuvius.")
                    .font(.body)
                
                Text("I've completed a mini-game, but it's not marked as complete. What should I do?")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 5)
                
                Text("Game completion is registered the moment the \"Completion\" screen appears. If you believe a game was completed but isn't being marked correctly, please try the following:")
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 5) {
                    numberedPoint(1, "Ensure you have a stable internet connection.")
                    numberedPoint(2, "Close and restart the Tecton app.")
                    numberedPoint(3, "If the issue persists, please use the contact information below to let us know.")
                }
                .padding(.leading)
            }
            
            Group {
                Text("How do I view the 3D models of the volcanoes?")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 5)
                
                Text("The interactive 3D model for each volcano is a special reward! You can unlock it by earning the \"Master\" achievement for that volcano. Once you've completed all three mini-games and unlocked the achievement, follow these steps:")
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("1. Go to the Achievements tab from the main dashboard.")
                        .font(.body)
                    Text("2. Tap on the \"Master\" badge for the volcano you've completed.")
                        .font(.body)
                    Text("3. The detailed 3D model will appear, ready for you to explore!")
                        .font(.body)
                }
                .padding(.leading)
                
                Text("How do I manage notifications?")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 5)
                
                Text("You can manage your notification preferences at any time by going to the Settings screen, which is accessible from the Achievements tab. There, you can enable or disable all notifications for Tecton. If you have previously denied permission, you may need to go to your device's Settings > Notifications > Tecton to enable them.")
                    .font(.body)
            }
            
            divider()
            
            Group {
                Text("📖 How-To Guides")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(.bottom, 5)
                
                Text("How to Play the Mini-Games")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    bulletPointWithBoldTitle("Learning Cards:", "Before each game, you'll be shown a series of illustrated cards. Swipe left or right through these cards to learn the key facts you'll need to succeed.")
                    bulletPointWithBoldTitle("Quiz:", "Read the question carefully and select the multiple-choice answer you believe is correct.")
                    bulletPointWithBoldTitle("Match:", "First, tap a label from the list at the bottom. Then, tap the corresponding location on the volcano diagram to create a match.")
                    bulletPointWithBoldTitle("Builder:", "Answer the multiple-choice question correctly to add the next layer to your volcano.")
                }
                .padding(.leading, 5)
                
                Text("How to Reset My Progress")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 5)
                
                Text("If you'd like to start your adventure over from the beginning, you can do so from the Settings screen.")
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("1. Navigate to the Achievements tab, then tap the \"Settings\" icon.")
                        .font(.body)
                    Text("2. Tap the \"Reset All Progress\" button.")
                        .font(.body)
                    Text("3. Please be aware that this action is permanent and will erase all your completed games and unlocked achievements.")
                        .font(.body)
                }
                .padding(.leading)
            }
            
            divider()
            
            Group {
                Text("📬 Contact Us")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(.bottom, 5)
                
                Text("Still have questions or need to report a bug? We're here to help!")
                    .font(.body)
                
                Text("Please send us an email at support@tectonapp.com with a detailed description of your issue. If you are reporting a bug, please include the following information if possible:")
                    .font(.body)
                
                bulletPoint("The device you are using (e.g., iPhone 14 Pro).")
                bulletPoint("The iOS version you are running (e.g., iOS 17.2).")
                bulletPoint("A screenshot or screen recording of the issue.")
                
                Text("We'll get back to you as soon as we can. Thank you for playing Tecton!")
                    .font(.body)
                    .padding(.top, 5)
            }
        }
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(hex: "#1D3557"))
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.system(size: 16))
            Text(text)
                .font(.system(size: 16))
        }
        .padding(.leading, 5)
    }
    
    private func bulletPointWithBoldTitle(_ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.system(size: 16))
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(text)
                    .font(.system(size: 16))
            }
        }
        .padding(.leading, 5)
    }
    
    private func numberedPoint(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number).")
                .font(.system(size: 16, weight: .bold))
                .frame(width: 20, alignment: .leading)
            Text(text)
                .font(.system(size: 16))
        }
    }
}

// Extension to allow combining Text views with different styles
extension Text {
    static func + (lhs: Text, rhs: Text) -> Text {
        return lhs + rhs // Usar el operador + que ya está definido para Text
    }
}

// Extension to allow starting with a number and text
// extension HStack {
//     static func + (lhs: HStack<TupleView<(Text, Text)>>, rhs: Text) -> Text {
//         return Text("") // This is a placeholder that will be replaced by the actual implementation
//     }
// }

// // Helper function to create numbered points with styled text
// private func styledNumberedPoint(_ number: Int, _ text: Text) -> some View {
//     HStack(alignment: .top, spacing: 10) {
//         Text("\(number).")
//             .font(.system(size: 16, weight: .bold))
//             .frame(width: 20, alignment: .leading)
//         text
//     }
// }

// Add this new view for Developers Credits
struct DevelopersCreditsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Meet the Team")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#1D3557"))
                    .padding(.top, 20)
                
                Text("Tecton was created with passion by a diverse team of developers from around the world.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 25) {
                    developerCard(
                        name: "Syed Burhan Raza Gillani",
                        nameInNative: "سید برھان رضا گیلانی",
                        role: "Software Engineering"
                    )
                    
                    developerCard(
                        name: "Seyed Aryan Rozati",
                        nameInNative: "سید آرین روضاتی",
                        role: "Design and Illustration"
                    )
                    
                    developerCard(
                        name: "Otabek Eshpo'latov",
                        role: "Software Engineering"
                    )
                    
                    developerCard(
                        name: "Juan Daniel Rodríguez Oropeza",
                        role: "Software Engineering"
                    )
                    
                    developerCard(
                        name: "Muhammad Hamza Khalil",
                        nameInNative: "محمد حمزہ خلیل",
                        role: "Business and Marketing"
                    )
                }
                .padding(.horizontal)
                
                Text("© 2025 Tecton Team. All rights reserved.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color(hex: "#F5F5DC"))
        .navigationBarTitle("Developers", displayMode: .inline)
    }
    
    private func developerCard(name: String, nameInNative: String? = nil, role: String) -> some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#1D3557"))
                .multilineTextAlignment(.center)
            
            if let nativeName = nameInNative {
                Text(nativeName)
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "#457B9D"))
                    .multilineTextAlignment(.center)
            }
            
            Text(role)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : .white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
