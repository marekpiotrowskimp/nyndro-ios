//
//  Date+Extensions.swift
//  Nyndro
//
//  Date utility extensions
//

import Foundation

extension Date {
    
    // MARK: - Start/End of Day
    
    /// Get start of the day (00:00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Get end of the day (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    // MARK: - Components
    
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var weekOfYear: Int {
        Calendar.current.component(.weekOfYear, from: self)
    }
    
    // MARK: - Comparisons
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Check if date is in the current week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Check if date is in the current month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Check if date is in the current year
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    /// Check if two dates are on the same day
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    // MARK: - Date Math
    
    /// Days between two dates
    func days(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date.startOfDay, to: self.startOfDay)
        return components.day ?? 0
    }
    
    /// Days ago from now
    var daysAgo: Int {
        Date().days(from: self)
    }
    
    /// Add days to date
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Add months to date
    func addingMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    // MARK: - Formatting
    
    /// Relative date string (Today, Yesterday, or formatted)
    var relativeString: String {
        if isToday {
            return String(localized: "date.today", defaultValue: "Today")
        } else if isYesterday {
            return String(localized: "date.yesterday", defaultValue: "Yesterday")
        } else if isThisWeek {
            return formatted(.dateTime.weekday(.wide))
        } else if isThisYear {
            return formatted(.dateTime.month(.abbreviated).day())
        } else {
            return formatted(.dateTime.year().month(.abbreviated).day())
        }
    }
    
    /// Short date string
    var shortString: String {
        formatted(date: .abbreviated, time: .omitted)
    }
    
    /// Time only string
    var timeString: String {
        formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - Date Intervals

extension Date {
    /// Get all dates in range
    static func dates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate.startOfDay
        let endDay = endDate.startOfDay
        
        while currentDate <= endDay {
            dates.append(currentDate)
            currentDate = currentDate.addingDays(1)
        }
        
        return dates
    }
}
