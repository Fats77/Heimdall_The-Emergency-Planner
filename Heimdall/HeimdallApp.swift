//
//  HeimdallApp.swift
//  Heimdall
//
//  Created by Fatima Zeb on 23/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging // Import Firebase Messaging
import UserNotifications // Import User Notifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        // --- 1. Set Delegates ---
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // --- 2. Handle APNs Token ---
    // This is called when Apple successfully registers the device
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Give the token to Firebase
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    // --- 3. Handle Failed Registration ---
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate (Handling notifications when app is open)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Show the notification even if the app is in the foreground
        completionHandler([.banner, .sound, .list])
    }
    
    // This handles a tap on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped with userInfo: \(userInfo)")
        
        // TODO: Handle the notification tap
        // e.g., Read the 'type', 'buildingId', etc., from userInfo
        // and navigate the user to the correct screen.
        
        completionHandler()
    }
}

// MARK: - MessagingDelegate (Getting the FCM Token)
extension AppDelegate: MessagingDelegate {
    
    // This function is called when Firebase provides or refreshes the FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("Firebase FCM Token: \(token)")
        
        // --- THIS IS THE CRITICAL STEP ---
        // Save the token to Firestore
        NotificationService.shared.saveFCMTokenToFirestore(token: token)
    }
}


@main
struct HeimdallApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            if authService.currentUser != nil {
                HomeView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
