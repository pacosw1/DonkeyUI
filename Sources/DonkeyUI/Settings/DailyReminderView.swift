//
//  SwiftUIView.swift
//
//
//  Created by Paco Sainz on 4/16/23.
//

import SwiftUI
import UserNotifications

public struct DailyReminderView: View {
    @AppStorage("dailyReminder") var dailyReminderOn = true

    
    public init() {
    }
    
    public var body: some View {
        DailyReminderPickerView()
            .editToggle(isOn: $dailyReminderOn, systemImage: "calendar.badge.clock", label: "Daily Reminder", iconColor: .purple)
    }
}

struct DailyReminderView_Previews: PreviewProvider {
    static var previews: some View {
        DailyReminderView()
    }
}

public struct DailyReminderPickerView: View {
    @State private var date: Date = Date.now.startOfDay
    @State private var text: String = ""
    
    @AppStorage("dailyReminderHour") var dailyReminderHour  = 9
    @AppStorage("dailyReminderMinute") var dailyReminderMinute = 0
    @AppStorage("dailyReminderLabel") var dailyReminderLabel = "Time to schedule your day"


    let calendar = Calendar.current
    
    public var body: some View {
        HStack(alignment: .center) {

                TextField("Time to schedule your day", text: $text)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: false)
            Spacer()
                DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
            

        }
        .padding(.vertical)
        .onChange(of: date) {
            dailyReminderHour =  calendar.component(.hour, from: date)
            dailyReminderMinute =  calendar.component(.minute, from: date)
            
            var component = DateComponents()
            component.hour = dailyReminderHour
            component.minute = dailyReminderMinute
            
            print(dailyReminderHour)
            print(dailyReminderMinute)
            
            scheduleDailyNotification(title: text, body: "", dateComponents: component)
        }
        .onChange(of: text) {
            dailyReminderLabel = text
        }
        .task {
            let calendar = Calendar.current
            let now = Date.now

            // Set the time to 3:30 PM
            var dateComponents = DateComponents()
            dateComponents.hour = dailyReminderHour
            dateComponents.minute = dailyReminderMinute

            var newDate = calendar.date(bySetting: .hour, value: dateComponents.hour ?? 0, of: now)!
            newDate = calendar.date(bySetting: .minute, value: dateComponents.minute ?? 0, of: newDate)!
            
            date = newDate
        }
    }
    
    func scheduleDailyNotification(title: String, body: String, dateComponents: DateComponents) {
        
        // Delete the previously schedule notification and create an updated one
        let notificationCenter =  UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailyNotification"])

        notificationCenter.createDailyNotification(id: "dailyNotification", title: title, content: "", hour: dateComponents.hour!, minute: dateComponents.minute!)
    }
}

//https://apps.apple.com/app/id6443977467?action=write-review
