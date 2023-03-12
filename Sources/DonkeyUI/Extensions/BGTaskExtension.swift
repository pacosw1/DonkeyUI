//
//  BGTaskExtension.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/21/22.
//

import Foundation
import BackgroundTasks


extension BGTaskScheduler {
    
    
    func replacePendingBackgroundTask() {
//        BGTaskScheduler.shared.cancelAllTaskRequests()
        self.scheduleAppRefresh()
    }
    func scheduleAppRefresh() {
        let enabled = UserDefaults.standard.bool(forKey: "dailyReminder")
//        print(enabled ? "Daily reminders enabled" : "Daily reminders disabled")
        
        if enabled {
            
//            let interval = UserDefaults.standard.double(forKey: "dailyReminderTime")
//            let setDate = Date(timeIntervalSince1970: interval)
//
//
//            let components = setDate.timeComponents
//            let reminderDate = Date.now.startOfDay
//
//            let final = Calendar.current.date(byAdding: components, to: reminderDate)
//            print("scheduling reminders at \(final!.dateString) \(final!.timeString)")

            
            let request = BGAppRefreshTaskRequest(identifier: "reminderRefresh")
            var time = DateComponents()
            time.hour = 9
            request.earliestBeginDate = Calendar.current.date(byAdding: time, to: Date.now.tomorrow.startOfDay)
            
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print(error.localizedDescription)
            }
            
            
            
        }
    }
}
