//
//  HistoryEntry.swift
//  Nyndro
//
//  Practice session history entry model
//

import Foundation
import SwiftData

@Model
final class HistoryEntry {
    // MARK: - Properties
    
    @Attribute(.unique) var id: UUID
    var practice: Practice?
    var progressSnapshot: Int
    var repetitionAdded: Int
    var practiceDate: Date
    var note: String?
    var sessionDuration: TimeInterval?
    
    // MARK: - Computed Properties
    
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: practiceDate)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: practiceDate)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: practiceDate)
    }
    
    var formattedDate: String {
        practiceDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    var formattedDateTime: String {
        practiceDate.formatted(date: .abbreviated, time: .shortened)
    }
    
    var formattedDuration: String? {
        guard let duration = sessionDuration else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration)
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        practice: Practice? = nil,
        progressSnapshot: Int,
        repetitionAdded: Int,
        practiceDate: Date = Date(),
        note: String? = nil,
        sessionDuration: TimeInterval? = nil
    ) {
        self.id = id
        self.practice = practice
        self.progressSnapshot = progressSnapshot
        self.repetitionAdded = repetitionAdded
        self.practiceDate = practiceDate
        self.note = note
        self.sessionDuration = sessionDuration
    }
}

// MARK: - Comparable

extension HistoryEntry: Comparable {
    static func < (lhs: HistoryEntry, rhs: HistoryEntry) -> Bool {
        lhs.practiceDate < rhs.practiceDate
    }
}
