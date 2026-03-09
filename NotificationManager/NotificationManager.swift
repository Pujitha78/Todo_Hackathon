import UserNotifications
import UIKit
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleTaskNotification(taskId: String, taskTitle: String, dueDate: Date) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = taskTitle
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        // Add custom data
        content.userInfo = ["taskId": taskId]
        
        // Calculate time interval
        let timeInterval = dueDate.timeIntervalSinceNow
        
        // Only schedule if due time is in the future
        if timeInterval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: min(timeInterval, 86400), repeats: false)
            let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Notification scheduled for: \(taskTitle)")
                }
            }
        }
    }
    
    func scheduleEndOfDayNotification() {
        let content = UNMutableNotificationContent()
        content.title = "End of Day"
        content.body = "Don't forget to review your tasks for today!"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.userInfo = ["type": "endOfDay"]
        
        // Schedule for 9 PM (21:00)
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 21
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "endOfDay", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling end of day notification: \(error)")
            }
        }
    }
    
    func cancelNotification(taskId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
}
