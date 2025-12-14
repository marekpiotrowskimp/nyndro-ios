//
//  Reminder.swift
//  Nyndro
//
//  Practice reminder/notification model
//

import Foundation
import SwiftData

@Model
final class Reminder {
    // MARK: - Properties
    
    @Attribute(.unique) var id: UUID
    var practice: Practice?
    var scheduledDate: Date
    var repeatType: RepeatType
    var isActive: Bool
    var notificationId: String
    
    // MARK: - Computed Properties
    
    var formattedTime: String {
        scheduledDate.formatted(date: .omitted, time: .shortened)
    }
    
    var formattedDate: String {
        scheduledDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    var formattedDateTime: String {
        scheduledDate.formatted(date: .abbreviated, time: .shortened)
    }
    
    var nextOccurrence: Date {
        let now = Date()
        var date = scheduledDate
        
        // If date is in the past, calculate next occurrence
        while date < now {
            switch repeatType {
            case .none:
                return date
            case .daily:
                date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
            case .weekly:
                date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
            case .monthly:
                date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
            }
        }
        
        return date
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        practice: Practice? = nil,
        scheduledDate: Date,
        repeatType: RepeatType = .none,
        isActive: Bool = true
    ) {
        self.id = id
        self.practice = practice
        self.scheduledDate = scheduledDate
        self.repeatType = repeatType
        self.isActive = isActive
        self.notificationId = id.uuidString
    }
}

// MARK: - RepeatType

enum RepeatType: Int, Codable, CaseIterable {
    case none = 0
    case daily = 1
    case weekly = 2
    case monthly = 3
    
    var displayName: String {
        switch self {
        case .none:
            return String(localized: "reminder.repeat.none", defaultValue: "Once")
        case .daily:
            return String(localized: "reminder.repeat.daily", defaultValue: "Daily")
        case .weekly:
            return String(localized: "reminder.repeat.weekly", defaultValue: "Weekly")
        case .monthly:
            return String(localized: "reminder.repeat.monthly", defaultValue: "Monthly")
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "1.circle"
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        }
    }
}
