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
                        navigationLink(icon: "doc.text.fill", iconColor: "#2A9D8F", title: "Terms and Conditions")
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        navigationLink(icon: "shield.fill", iconColor: "#2A9D8F", title: "Privacy Policy")
                    }
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
                        // Add reset functionality here
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
        NavigationLink(destination: Text("Content for \(title)")) {
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
