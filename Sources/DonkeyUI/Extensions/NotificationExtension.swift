//
//  NotificationExtension.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/21/22.
//

import Foundation
import UserNotifications

public extension UNUserNotificationCenter {
    
    
//    func updateNotification(coreDataNotification: [TaskNotification], rollover: Bool = false) {
//        let identifiers = coreDataNotification.map { notif in
//            return notif.id!.uuidString
//        }
//
//        self.removeDeliveredNotifications(withIdentifiers: identifiers)
//        self.removePendingNotificationRequests(withIdentifiers: identifiers)
//
//        //TODO fix date offset for tasks
//
//        for notification in coreDataNotification {
//
//            let reminderTimeComponent = notification.dueAt!.timeComponents
//            let updatedReminderDate = Calendar.current.date(byAdding: reminderTimeComponent, to: notification.task!.date!.startOfDay)!
//            // TODO update label
//            self.createNotification(id: notification.id!.uuidString, title: notificationHeader(minutes: Int(notification.minutes), time: notification.dueAt!.timeString), content: notification.task!.title!, date: updatedReminderDate)
//        }
//
//    }
    
    func notificationHeader(minutes: Int, time: String) -> String {
        if minutes == 0 {
            return "Starting now!"
        } else if minutes == 1440 {
            return "Starting in one day (\(time))"
        }
        return minutes == 60 ? "Starting in one hour (\(time))" : "Starting in \(minutes) minutes"
    }
    
    
//    func createNotifications(list: [TaskNotification]) {
//        for notif in list {
//            self.createNotification(id: notif.id!.uuidString, title: notificationHeader(minutes: Int(notif.minutes), time: notif.dueAt!.timeString), content: notif.task!.title!, date: notif.dueAt!)
//        }
//    }
    
    
    func createDailyNotification(id: String, title: String, content: String, hour: Int, minute: Int) {
        let notification = UNMutableNotificationContent()
        notification.title = title
        notification.sound = .default
        notification.body = content
        notification.badge = 1
        notification.interruptionLevel = .timeSensitive
        
                
        var component = DateComponents()
        component.hour = hour
        component.minute = minute
        component.timeZone = TimeZone.current
        component.calendar = Calendar.current
        
                        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notification, trigger: trigger)
        
        self.add(request) { error in
            if let error = error {
                print("could not create notification")
                print(error)
            }
        }
    }
    
    func createNotification(id: String, title: String, content: String, date: Date, badge: Int = 1) {
        
        let notification = UNMutableNotificationContent()
        notification.title = title
        notification.sound = .default
        notification.body = content
        notification.badge = 1
        notification.interruptionLevel = .timeSensitive
        
//        print("creating notification at \(date.dateString) \(date.timeString)")

        let dueDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dueDate, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: notification, trigger: trigger)
        
        self.add(request) { error in
            if let error = error {
                print("could not create notification")
                print(error)
            }
        }
    }
}

