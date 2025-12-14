//
//  Practice.swift
//  Nyndro
//
//  Buddhist practice tracking model
//

import Foundation
import SwiftData

@Model
final class Practice {
    // MARK: - Properties
    
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionText: String
    var imageName: String
    var colorId: String
    var progress: Int
    var maxRepetition: Int
    var defaultRepetition: Int
    var isActive: Bool
    var isPredefined: Bool
    var createdAt: Date
    var order: Int
    
    // MARK: - Relationships
    
    @Relationship(deleteRule: .cascade, inverse: \HistoryEntry.practice)
    var history: [HistoryEntry] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Reminder.practice)
    var reminders: [Reminder] = []
    
    // MARK: - Computed Properties
    
    var progressPercentage: Double {
        guard maxRepetition > 0 else { return 0 }
        return min(Double(progress) / Double(maxRepetition), 1.0)
    }
    
    var progressPercentageInt: Int {
        Int(progressPercentage * 100)
    }
    
    var lastPracticeDate: Date? {
        history
            .filter { $0.repetitionAdded > 0 }
            .max(by: { $0.practiceDate < $1.practiceDate })?
            .practiceDate
    }
    
    var isCompleted: Bool {
        progress >= maxRepetition
    }
    
    var remaining: Int {
        max(0, maxRepetition - progress)
    }
    
    var formattedProgress: String {
        "\(progress.formatted()) / \(maxRepetition.formatted())"
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        descriptionText: String = "",
        imageName: String = "plus.circle.fill",
        colorId: String = "custom",
        progress: Int = 0,
        maxRepetition: Int = 111111,
        defaultRepetition: Int = 108,
        isActive: Bool = true,
        isPredefined: Bool = false,
        createdAt: Date = Date(),
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.imageName = imageName
        self.colorId = colorId
        self.progress = progress
        self.maxRepetition = maxRepetition
        self.defaultRepetition = defaultRepetition
        self.isActive = isActive
        self.isPredefined = isPredefined
        self.createdAt = createdAt
        self.order = order
    }
    
    // MARK: - Methods
    
    /// Add repetitions and create history entry
    func addRepetitions(_ count: Int, note: String? = nil, sessionDuration: TimeInterval? = nil) -> HistoryEntry {
        progress += count
        
        let entry = HistoryEntry(
            practice: self,
            progressSnapshot: progress,
            repetitionAdded: count,
            practiceDate: Date(),
            note: note,
            sessionDuration: sessionDuration
        )
        
        history.append(entry)
        return entry
    }
    
    /// Subtract repetitions (for corrections)
    func subtractRepetitions(_ count: Int) {
        progress = max(0, progress - count)
    }
}

// MARK: - Predefined Practice Helper

extension Practice {
    /// Create practice from predefined template
    static func fromPredefined(_ template: PredefinedPractice, order: Int) -> Practice {
        Practice(
            name: template.localizedName,
            descriptionText: template.localizedDescription,
            imageName: template.imageName,
            colorId: template.colorId,
            progress: 0,
            maxRepetition: template.maxRepetition,
            defaultRepetition: template.defaultRepetition,
            isActive: true,
            isPredefined: true,
            createdAt: Date(),
            order: order
        )
    }
}
