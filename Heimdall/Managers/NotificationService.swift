//
//  NotificationService.swift
//  Heimdall
//
//  Created by Kemas Deanova on 17/11/25.
//


import Foundation
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class NotificationService {
    
    static let shared = NotificationService()
    private var db = Firestore.firestore()
    
    /// 1. Asks the user for notification permissions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
                // Register with Apple Push Notification service
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    /// 2. Saves the FCM token to the user's document
    func saveFCMTokenToFirestore(token: String) {
        // Only save the token if a user is logged in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Not saving token, user is not logged in.")
            return
        }
        
        let userRef = db.collection("users").document(userID)
        
        // Set/update the 'fcmToken' field
        userRef.updateData(["fcmToken": token]) { error in
            if let error = error {
                print("Error saving FCM token to Firestore: \(error.localizedDescription)")
            } else {
                print("Successfully saved FCM token!")
            }
        }
    }
}