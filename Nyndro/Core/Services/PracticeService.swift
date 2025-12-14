//
//  PracticeService.swift
//  Nyndro
//
//  Service for managing practices with SwiftData
//

import Foundation
import SwiftData

/// Service responsible for CRUD operations on practices
@MainActor
final class PracticeService: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all practices sorted by order
    func fetchAllPractices() throws -> [Practice] {
        let descriptor = FetchDescriptor<Practice>(
            sortBy: [SortDescriptor(\.order), SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch only active practices
    func fetchActivePractices() throws -> [Practice] {
        let descriptor = FetchDescriptor<Practice>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.order), SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch practice by ID
    func fetchPractice(by id: UUID) throws -> Practice? {
        let descriptor = FetchDescriptor<Practice>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    /// Create a new practice from predefined template
    func createPractice(from template: PredefinedPractice) throws -> Practice {
        let existingPractices = try fetchAllPractices()
        let nextOrder = (existingPractices.map(\.order).max() ?? -1) + 1
        
        let practice = Practice.fromPredefined(template, order: nextOrder)
        modelContext.insert(practice)
        try modelContext.save()
        
        return practice
    }
    
    /// Create a custom practice
    func createCustomPractice(
        name: String,
        description: String = "",
        imageName: String = "plus.circle.fill",
        colorId: String = "custom",
        maxRepetition: Int = Constants.defaultMaxRepetition,
        defaultRepetition: Int = Constants.defaultRepetition
    ) throws -> Practice {
        let existingPractices = try fetchAllPractices()
        let nextOrder = (existingPractices.map(\.order).max() ?? -1) + 1
        
        let practice = Practice(
            name: name,
            descriptionText: description,
            imageName: imageName,
            colorId: colorId,
            maxRepetition: maxRepetition,
            defaultRepetition: defaultRepetition,
            isPredefined: false,
            order: nextOrder
        )
        
        modelContext.insert(practice)
        try modelContext.save()
        
        return practice
    }
    
    /// Update practice details
    func updatePractice(
        _ practice: Practice,
        name: String? = nil,
        description: String? = nil,
        imageName: String? = nil,
        colorId: String? = nil,
        maxRepetition: Int? = nil,
        defaultRepetition: Int? = nil,
        isActive: Bool? = nil
    ) throws {
        if let name = name { practice.name = name }
        if let description = description { practice.descriptionText = description }
        if let imageName = imageName { practice.imageName = imageName }
        if let colorId = colorId { practice.colorId = colorId }
        if let maxRepetition = maxRepetition { practice.maxRepetition = maxRepetition }
        if let defaultRepetition = defaultRepetition { practice.defaultRepetition = defaultRepetition }
        if let isActive = isActive { practice.isActive = isActive }
        
        try modelContext.save()
    }
    
    /// Delete a practice
    func deletePractice(_ practice: Practice) throws {
        modelContext.delete(practice)
        try modelContext.save()
    }
    
    /// Reorder practices
    func reorderPractices(_ practices: [Practice]) throws {
        for (index, practice) in practices.enumerated() {
            practice.order = index
        }
        try modelContext.save()
    }
    
    // MARK: - Progress Operations
    
    /// Add repetitions to a practice
    @discardableResult
    func addRepetitions(
        to practice: Practice,
        count: Int,
        note: String? = nil,
        sessionDuration: TimeInterval? = nil
    ) throws -> HistoryEntry {
        let entry = practice.addRepetitions(count, note: note, sessionDuration: sessionDuration)
        try modelContext.save()
        return entry
    }
    
    /// Subtract repetitions from a practice (correction)
    func subtractRepetitions(from practice: Practice, count: Int) throws {
        practice.subtractRepetitions(count)
        try modelContext.save()
    }
    
    /// Reset practice progress
    func resetProgress(for practice: Practice, keepHistory: Bool = false) throws {
        practice.progress = 0
        
        if !keepHistory {
            for entry in practice.history {
                modelContext.delete(entry)
            }
        }
        
        try modelContext.save()
    }
    
    // MARK: - History Operations
    
    /// Fetch history entries for a practice
    func fetchHistory(for practice: Practice, limit: Int? = nil) throws -> [HistoryEntry] {
        let practiceId = practice.id
        var descriptor = FetchDescriptor<HistoryEntry>(
            sortBy: [SortDescriptor(\.practiceDate, order: .reverse)]
        )
        
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
        
        let allEntries = try modelContext.fetch(descriptor)
        return allEntries.filter { $0.practice?.id == practiceId }
    }
    
    /// Fetch all history entries
    func fetchAllHistory(limit: Int? = nil) throws -> [HistoryEntry] {
        var descriptor = FetchDescriptor<HistoryEntry>(
            sortBy: [SortDescriptor(\.practiceDate, order: .reverse)]
        )
        
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Delete a history entry and update practice progress
    func deleteHistoryEntry(_ entry: HistoryEntry) throws {
        if let practice = entry.practice {
            practice.progress = max(0, practice.progress - entry.repetitionAdded)
        }
        
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    /// Update a history entry
    func updateHistoryEntry(
        _ entry: HistoryEntry,
        repetitionAdded: Int? = nil,
        note: String? = nil,
        practiceDate: Date? = nil
    ) throws {
        // If changing repetition count, adjust practice progress
        if let newCount = repetitionAdded, let practice = entry.practice {
            let difference = newCount - entry.repetitionAdded
            practice.progress = max(0, practice.progress + difference)
            entry.repetitionAdded = newCount
            entry.progressSnapshot = practice.progress
        }
        
        if let note = note { entry.note = note }
        if let date = practiceDate { entry.practiceDate = date }
        
        try modelContext.save()
    }
    
    // MARK: - Query Helpers
    
    /// Get practices practiced today
    func practicesPracticedToday() throws -> [Practice] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<HistoryEntry>(
            predicate: #Predicate { 
                $0.practiceDate >= startOfDay && $0.practiceDate < endOfDay 
            }
        )
        
        let todaysEntries = try modelContext.fetch(descriptor)
        let practiceIds = Set(todaysEntries.compactMap { $0.practice?.id })
        
        return try fetchActivePractices().filter { practiceIds.contains($0.id) }
    }
    
    /// Get total repetitions added today for a practice
    func repetitionsToday(for practice: Practice) throws -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let practiceId = practice.id
        
        let descriptor = FetchDescriptor<HistoryEntry>(
            predicate: #Predicate { 
                $0.practiceDate >= startOfDay && 
                $0.practiceDate < endOfDay 
            }
        )
        
        let entries = try modelContext.fetch(descriptor)
        return entries.filter { $0.practice?.id == practiceId }.reduce(0) { $0 + $1.repetitionAdded }
    }
    
    /// Check if any practices exist
    func hasPractices() throws -> Bool {
        let descriptor = FetchDescriptor<Practice>()
        return try modelContext.fetchCount(descriptor) > 0
    }
}

// MARK: - Settings Operations

extension PracticeService {
    
    /// Fetch user settings (creates default if none exist)
    func fetchSettings() throws -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        
        if let settings = try modelContext.fetch(descriptor).first {
            return settings
        }
        
        // Create default settings
        let settings = UserSettings.default
        modelContext.insert(settings)
        try modelContext.save()
        
        return settings
    }
    
    /// Update user settings
    func updateSettings(_ settings: UserSettings) throws {
        try modelContext.save()
    }
    
    /// Mark onboarding as completed
    func completeOnboarding() throws {
        let settings = try fetchSettings()
        settings.hasCompletedOnboarding = true
        try modelContext.save()
    }
    
    /// Check if onboarding is completed
    func isOnboardingCompleted() throws -> Bool {
        try fetchSettings().hasCompletedOnboarding
    }
}
