//
//  TectonApp.swift
//  Tecton
//
//  Created by Burhan Raza on 08/05/25.
//

import SwiftUI
import SwiftData
import UIKit
import UserNotifications

// Add this to configure the app icon at startup
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Request notification permissions
        requestNotificationPermissions()
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // Register for push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // In a real app, you would send this token to your server
        // saveDeviceTokenToServer(token)
    }
    
    // Handle registration errors
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithDeviceToken error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // Request permission to send notifications
    func requestNotificationPermissions() {
        // Check if notifications are enabled in app settings
        if UserDefaults.standard.bool(forKey: "notificationsEnabled") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                
                if let error = error {
                    print("Error requesting notification permissions: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification banner even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Get the notification data
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification tap based on content
        if let achievementId = userInfo["achievementId"] as? String {
            // Post notification to navigate to achievements view
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToAchievementsTab"), object: nil)
        }
        
        completionHandler()
    }
}

@main
struct TectonApp: App {
    // Register the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
        .modelContainer(sharedModelContainer)
    }
}
