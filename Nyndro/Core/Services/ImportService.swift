//
//  ImportService.swift
//  Nyndro
//
//  Service for importing practice data from JSON backups
//

import Foundation
import SwiftData

// MARK: - Import Mode

enum ImportMode: String, CaseIterable {
    case replace = "replace"
    case merge = "merge"
    
    var displayName: String {
        switch self {
        case .replace:
            return String(localized: "import.mode.replace", defaultValue: "Replace all data")
        case .merge:
            return String(localized: "import.mode.merge", defaultValue: "Merge with existing")
        }
    }
    
    var description: String {
        switch self {
        case .replace:
            return String(localized: "import.mode.replace.description", defaultValue: "Delete all existing data and import from backup")
        case .merge:
            return String(localized: "import.mode.merge.description", defaultValue: "Keep existing data and add new items from backup")
        }
    }
}

// MARK: - Import Result

struct ImportResult {
    let practicesImported: Int
    let historyEntriesImported: Int
    let remindersImported: Int
    let settingsImported: Bool
    let errors: [ImportError]
    
    var isSuccess: Bool {
        errors.isEmpty
    }
    
    var summary: String {
        var parts: [String] = []
        if practicesImported > 0 {
            parts.append("\(practicesImported) practices")
        }
        if historyEntriesImported > 0 {
            parts.append("\(historyEntriesImported) history entries")
        }
        if remindersImported > 0 {
            parts.append("\(remindersImported) reminders")
        }
        if settingsImported {
            parts.append("settings")
        }
        return parts.isEmpty ? "No data imported" : "Imported: " + parts.joined(separator: ", ")
    }
}

// MARK: - Import Service

/// Service responsible for importing data from JSON backups
@MainActor
final class ImportService: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Import Methods
    
    /// Validate and preview import data
    func validateImportData(_ data: Data) throws -> ExportData {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let exportData = try decoder.decode(ExportData.self, from: data)
            return exportData
        } catch {
            throw ImportError.invalidFormat(error.localizedDescription)
        }
    }
    
    /// Import data from JSON
    func importFromJSON(_ data: Data, mode: ImportMode) throws -> ImportResult {
        let exportData = try validateImportData(data)
        
        var errors: [ImportError] = []
        var practicesImported = 0
        var historyEntriesImported = 0
        var remindersImported = 0
        var settingsImported = false
        
        // If replace mode, delete all existing data first
        if mode == .replace {
            try deleteAllData()
        }
        
        // Create a mapping from old practice IDs to new practices
        var practiceMapping: [String: Practice] = [:]
        
        // Import practices
        for exportablePractice in exportData.practices {
            do {
                let practice = try importPractice(exportablePractice, mode: mode)
                if let practice = practice {
                    practiceMapping[exportablePractice.id] = practice
                    practicesImported += 1
                }
            } catch let error as ImportError {
                errors.append(error)
            }
        }
        
        // Import history entries
        for exportableEntry in exportData.history {
            do {
                if try importHistoryEntry(exportableEntry, practiceMapping: practiceMapping, mode: mode) {
                    historyEntriesImported += 1
                }
            } catch let error as ImportError {
                errors.append(error)
            }
        }
        
        // Import reminders
        for exportableReminder in exportData.reminders {
            do {
                if try importReminder(exportableReminder, practiceMapping: practiceMapping, mode: mode) {
                    remindersImported += 1
                }
            } catch let error as ImportError {
                errors.append(error)
            }
        }
        
        // Import settings (always replace)
        do {
            try importSettings(exportData.settings)
            settingsImported = true
        } catch let error as ImportError {
            errors.append(error)
        }
        
        // Save all changes
        try modelContext.save()
        
        return ImportResult(
            practicesImported: practicesImported,
            historyEntriesImported: historyEntriesImported,
            remindersImported: remindersImported,
            settingsImported: settingsImported,
            errors: errors
        )
    }
    
    /// Import from file URL
    func importFromFile(_ url: URL, mode: ImportMode) throws -> ImportResult {
        let data = try Data(contentsOf: url)
        return try importFromJSON(data, mode: mode)
    }
    
    // MARK: - Private Methods
    
    private func deleteAllData() throws {
        // Delete all practices (cascades to history and reminders)
        let practiceDescriptor = FetchDescriptor<Practice>()
        let practices = try modelContext.fetch(practiceDescriptor)
        for practice in practices {
            modelContext.delete(practice)
        }
        
        // Delete orphaned history entries
        let historyDescriptor = FetchDescriptor<HistoryEntry>()
        let historyEntries = try modelContext.fetch(historyDescriptor)
        for entry in historyEntries {
            modelContext.delete(entry)
        }
        
        // Delete orphaned reminders
        let reminderDescriptor = FetchDescriptor<Reminder>()
        let reminders = try modelContext.fetch(reminderDescriptor)
        for reminder in reminders {
            modelContext.delete(reminder)
        }
    }
    
    private func importPractice(_ exportable: ExportablePractice, mode: ImportMode) throws -> Practice? {
        // Check if practice with same name already exists (for merge mode)
        if mode == .merge {
            let descriptor = FetchDescriptor<Practice>()
            let existingPractices = try modelContext.fetch(descriptor)
            if existingPractices.contains(where: { $0.name == exportable.name }) {
                // Skip existing practice in merge mode
                return nil
            }
        }
        
        let practice = Practice(
            id: UUID(uuidString: exportable.id) ?? UUID(),
            name: exportable.name,
            descriptionText: exportable.descriptionText,
            imageName: exportable.imageName,
            colorId: exportable.colorId,
            progress: exportable.progress,
            maxRepetition: exportable.maxRepetition,
            defaultRepetition: exportable.defaultRepetition,
            isActive: exportable.isActive,
            isPredefined: exportable.isPredefined,
            createdAt: exportable.createdAt,
            order: exportable.order
        )
        
        modelContext.insert(practice)
        return practice
    }
    
    private func importHistoryEntry(
        _ exportable: ExportableHistoryEntry,
        practiceMapping: [String: Practice],
        mode: ImportMode
    ) throws -> Bool {
        guard let practice = practiceMapping[exportable.practiceId] else {
            // Practice not found, skip this entry
            return false
        }
        
        // In merge mode, check if entry already exists
        if mode == .merge {
            let entryId = UUID(uuidString: exportable.id)
            if let id = entryId {
                let descriptor = FetchDescriptor<HistoryEntry>()
                let existingEntries = try modelContext.fetch(descriptor)
                if existingEntries.contains(where: { $0.id == id }) {
                    return false
                }
            }
        }
        
        let entry = HistoryEntry(
            id: UUID(uuidString: exportable.id) ?? UUID(),
            practice: practice,
            progressSnapshot: exportable.progressSnapshot,
            repetitionAdded: exportable.repetitionAdded,
            practiceDate: exportable.practiceDate,
            note: exportable.note,
            sessionDuration: exportable.sessionDuration
        )
        
        modelContext.insert(entry)
        practice.history.append(entry)
        
        return true
    }
    
    private func importReminder(
        _ exportable: ExportableReminder,
        practiceMapping: [String: Practice],
        mode: ImportMode
    ) throws -> Bool {
        guard let practice = practiceMapping[exportable.practiceId] else {
            return false
        }
        
        guard let repeatType = RepeatType(rawValue: exportable.repeatType) else {
            return false
        }
        
        let reminder = Reminder(
            id: UUID(uuidString: exportable.id) ?? UUID(),
            practice: practice,
            scheduledDate: exportable.scheduledDate,
            repeatType: repeatType,
            isActive: exportable.isActive
        )
        
        modelContext.insert(reminder)
        practice.reminders.append(reminder)
        
        return true
    }
    
    private func importSettings(_ exportable: ExportableSettings) throws {
        let descriptor = FetchDescriptor<UserSettings>()
        let existingSettings = try modelContext.fetch(descriptor)
        
        let settings: UserSettings
        if let existing = existingSettings.first {
            settings = existing
        } else {
            settings = UserSettings()
            modelContext.insert(settings)
        }
        
        settings.progressBarStyleRaw = exportable.progressBarStyle
        settings.counterSoundRaw = exportable.counterSound
        settings.hapticStyleRaw = exportable.hapticStyle
        settings.keepScreenAwake = exportable.keepScreenAwake
    }
}

// MARK: - Import Errors

enum ImportError: LocalizedError, Identifiable {
    case invalidFormat(String)
    case practiceImportFailed(String)
    case historyImportFailed(String)
    case reminderImportFailed(String)
    case settingsImportFailed(String)
    case fileReadFailed(String)
    
    var id: String {
        errorDescription ?? UUID().uuidString
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat(let details):
            return "Invalid file format: \(details)"
        case .practiceImportFailed(let details):
            return "Failed to import practice: \(details)"
        case .historyImportFailed(let details):
            return "Failed to import history: \(details)"
        case .reminderImportFailed(let details):
            return "Failed to import reminder: \(details)"
        case .settingsImportFailed(let details):
            return "Failed to import settings: \(details)"
        case .fileReadFailed(let details):
            return "Failed to read file: \(details)"
        }
    }
}
