//
//  TimestampExtension.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/24/22.
//

import Foundation
import SwiftUI

public extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var time: String {
        var hour = ""
        var minute = ""
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: self)
        if components.hour != nil {
            hour = "\(components.hour!)"
        } else {
            hour = "00"
        }
        
        if components.minute  != nil {
            minute = "\(components.hour!)"
        } else {
            minute = "00"
        }
            
        return "\(hour):\(minute)"
        
    }
    
    func getDate(dayDifference: Int) -> Date {
        var components = DateComponents()
        components.day = dayDifference
        return Calendar.current.date(byAdding: components, to:startOfDay)!
    }
    
    
    func inRange(start: Date, end: Date) -> Bool {
        return self.startOfDay >= start.startOfDay && self.endOfDay <= end.endOfDay
    }
    
    func addMinutes(minuteDifference: Int) -> Date {
        var components = DateComponents()
        components.minute = minuteDifference
        return Calendar.current.date(byAdding: components, to:self)!
    }
    
    func addSeconds(secondDifference: Int) -> Date {
        var components = DateComponents()
        components.second = secondDifference
        return Calendar.current.date(byAdding: components, to:self)!
    }
    
    var startOfMonth: Date {

            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month], from: self)

            return  calendar.date(from: components)!
    }
    
    var timeComponents: DateComponents {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute, .second], from: self)

        return components
    }
    
    var endOfMonth: Date {
           var components = DateComponents()
           components.month = 1
           components.second = -1
           return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var monthString: String {
        
        let year = Calendar.current.component(.year, from: self.startOfDay)
        let now = Calendar.current.component(.year, from: Date.now)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = year == now ? "MMMM" : "MMMM yyyy"
        return dateFormatter.string(from: self.startOfDay)
    }
    
    
    
    func distanceInText(date: Date) -> String {
        
        let curr = date.startOfDay
        
        if curr == self.startOfDay {
            return "Today"
        } else if curr == self.yesterday.startOfDay {
            return "Yesterday"
        } else if curr == self.tomorrow.startOfDay {
            return "Tomorrow"
        }
        
        //        comp.day = direction == 1 ? curr.dayOfWeek : -curr.dayOfWeek
        //        curr = Calendar.current.date(byAdding: comp, to: date.startOfDay) ?? date
        //
        
        //        let years = components.year ?? 0
        //        let months = components.month ?? 0
        //        let weeks = components.weekOfYear ?? 0
        
        
        let days = Calendar.current.dateComponents([ .day], from: self.startOfDay, to: date.startOfDay).day ?? 0

        var offset: Double = abs(Double(days)) + Double(self.dayOfWeek)
        var neg: Bool = false
        
        if days < 0 {
            neg = true
            offset = abs(offset)
        }
        
        
        
        if offset <= 7 {
            return "\(neg ? "Last" : "This") \(curr.dayOfWeekString)"
        } else if offset > 7 && offset <= 14 {
            return "\(neg ? "Last" : "Next") \(curr.dayOfWeekString)"
            // days: \(days + self.dayOfWeek)
        } else {
//            let weeks = floor((offset - 1) / 7.0)
            
//            var comp = DateComponents()
//            comp.day = -self.dayOfWeek
//            curr = Calendar.current.date(byAdding: comp, to: date.startOfDay) ?? date
//            comp.day = 0
//            comp.month = self.month
//            let months = Calendar.current.dateComponents([ .month], from: self.startOfDay, to: date.startOfDay).month ?? 0
            
            
            
            if curr.year == self.year {
                
                
                if curr.month == self.month {
                    return neg ? "\(Int((offset - 1) / 7)) weeks ago" : "In \(Int((offset - 1) / 7)) weeks"
                } else {
                    
                    
                    var months = curr.month - self.month
                    
                    neg = months < 0
                    
                    months = abs(months)
                    
                    if months == 1 {
                        return neg ? "Last Month": "Next Month"
                    } else {
                        return neg ? "\(months) Months Ago" : "In \(months) Months"
                    }
                }
            } else {
                var years = curr.year - self.year
                
                neg = years < 0
                years = abs(years)
                
                if years == 1 {
                    return "\(neg ? "Last" : "Next") Year"
                } else {
                    return neg ? "\(years) Years Ago" : "In \(years) Years"
                }
            }
        }
        
        
        
    }
        
    
//        if years != 0 {
//            if years == 1 {
//                return "Next Year"
//            } else {
//                if years < 0 {
//                    if years == -1 {
//                        return "Last Year"
//                    } else {
//                        return "\(years) years Ago"
//                    }
//                } else {
//                    return "In \(years) years"
//                }
//            }
//        } else if months != 0 {
//            if months > 0 {
//                if months == 1 {
//                    return "Next Month"
//                } else {
//                    return "In \(months) months"
//                }
//            } else {
//                return "\(months) Months Ago"
//            }
//        } else if weeks != 0 {
//            //check weeks here
//            if weeks > 0 {
//                if weeks == 1 {
//                    return "Next \(curr.dayOfWeekString)"
//                } else {
//                    return "In \(weeks) weeks"
//                }
//            } else {
//                if weeks == -1 {
//                    return "Last Week"
//                } else {
//                    return "\(weeks) Weeks Ago"
//                }
//            }
//        } else   {
//            return "This \(curr.dayOfWeekString)"
//        }
        
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MMMM, dd, YYYY"
        return dateFormatter.string(from: self.startOfDay)
    }
    
    var timeString: String {
        let dateFormatter = DateFormatter()
        
        if Locale.is24Hour {
            dateFormatter.dateFormat =  "HH:mm"
        } else {
            dateFormatter.dateFormat =  "hh:mm a"
        }
        return dateFormatter.string(from: self)
    }
    
    var dayOfWeekString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "EEEE"
        return dateFormatter.string(from: self.startOfDay)
    }
    
    var dayOfWeek: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    func timestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    
}



extension ForEach where Data.Element: Hashable, ID == Data.Element, Content: View {
    init(values: Data, content: @escaping (Data.Element) -> Content) {
        self.init(values, id: \.self, content: content)
    }
}
