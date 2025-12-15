//
//  ExportService.swift
//  Nyndro
//
//  Service for exporting practice data to JSON/CSV formats
//

import Foundation
import SwiftData

// MARK: - Export Data Models

/// Codable wrapper for practice export
struct ExportablePractice: Codable {
    let id: String
    let name: String
    let descriptionText: String
    let imageName: String
    let colorId: String
    let progress: Int
    let maxRepetition: Int
    let defaultRepetition: Int
    let isActive: Bool
    let isPredefined: Bool
    let createdAt: Date
    let order: Int
}

/// Codable wrapper for history entry export
struct ExportableHistoryEntry: Codable {
    let id: String
    let practiceId: String
    let progressSnapshot: Int
    let repetitionAdded: Int
    let practiceDate: Date
    let note: String?
    let sessionDuration: Double?
}

/// Codable wrapper for reminder export
struct ExportableReminder: Codable {
    let id: String
    let practiceId: String
    let scheduledDate: Date
    let repeatType: Int
    let isActive: Bool
}

/// Codable wrapper for user settings export
struct ExportableSettings: Codable {
    let progressBarStyle: String
    let counterSound: String
    let hapticStyle: String
    let keepScreenAwake: Bool
}

/// Complete export data structure
struct ExportData: Codable {
    let version: String
    let exportDate: Date
    let appVersion: String
    let practices: [ExportablePractice]
    let history: [ExportableHistoryEntry]
    let reminders: [ExportableReminder]
    let settings: ExportableSettings
}

// MARK: - Export Service

/// Service responsible for exporting data to various formats
@MainActor
final class ExportService: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    static let exportVersion = "1.0"
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - JSON Export
    
    /// Export all data as JSON
    func exportToJSON() throws -> Data {
        let exportData = try createExportData()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try encoder.encode(exportData)
    }
    
    /// Export all data as JSON string
    func exportToJSONString() throws -> String {
        let data = try exportToJSON()
        guard let string = String(data: data, encoding: .utf8) else {
            throw ExportError.encodingFailed
        }
        return string
    }
    
    // MARK: - CSV Export
    
    /// Export history data as CSV
    func exportHistoryToCSV() throws -> String {
        let practices = try fetchPractices()
        let history = try fetchHistory()
        
        // Create practice name lookup
        let practiceNames = Dictionary(uniqueKeysWithValues: practices.map { ($0.id.uuidString, $0.name) })
        
        var csv = "Date,Time,Practice,Repetitions,Total Progress,Note,Duration (seconds)\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        for entry in history.sorted(by: { $0.practiceDate > $1.practiceDate }) {
            let date = dateFormatter.string(from: entry.practiceDate)
            let time = timeFormatter.string(from: entry.practiceDate)
            let practiceName = entry.practice.map { practiceNames[$0.id.uuidString] ?? "Unknown" } ?? "Unknown"
            let note = entry.note?.replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "\n", with: " ") ?? ""
            let duration = entry.sessionDuration.map { String(format: "%.0f", $0) } ?? ""
            
            csv += "\(date),\(time),\"\(practiceName)\",\(entry.repetitionAdded),\(entry.progressSnapshot),\"\(note)\",\(duration)\n"
        }
        
        return csv
    }
    
    /// Export practices summary as CSV
    func exportPracticesToCSV() throws -> String {
        let practices = try fetchPractices()
        
        var csv = "Name,Progress,Goal,Percentage,Default Repetition,Color,Active,Predefined,Created\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for practice in practices.sorted(by: { $0.order < $1.order }) {
            let date = dateFormatter.string(from: practice.createdAt)
            let percentage = String(format: "%.2f", practice.progressPercentage * 100)
            
            csv += "\"\(practice.name)\",\(practice.progress),\(practice.maxRepetition),\(percentage)%,\(practice.defaultRepetition),\(practice.colorId),\(practice.isActive),\(practice.isPredefined),\(date)\n"
        }
        
        return csv
    }
    
    // MARK: - File Creation
    
    /// Create a temporary file with exported data
    func createExportFile(format: ExportFormat) throws -> URL {
        let data: Data
        let fileName: String
        
        switch format {
        case .json:
            data = try exportToJSON()
            fileName = "nyndro_backup_\(formattedDate()).json"
            
        case .csv:
            let csvString = try exportHistoryToCSV()
            guard let csvData = csvString.data(using: .utf8) else {
                throw ExportError.encodingFailed
            }
            data = csvData
            fileName = "nyndro_history_\(formattedDate()).csv"
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        
        return fileURL
    }
    
    // MARK: - Private Methods
    
    private func createExportData() throws -> ExportData {
        let practices = try fetchPractices()
        let history = try fetchHistory()
        let reminders = try fetchReminders()
        let settings = try fetchSettings()
        
        let exportablePractices = practices.map { practice in
            ExportablePractice(
                id: practice.id.uuidString,
                name: practice.name,
                descriptionText: practice.descriptionText,
                imageName: practice.imageName,
                colorId: practice.colorId,
                progress: practice.progress,
                maxRepetition: practice.maxRepetition,
                defaultRepetition: practice.defaultRepetition,
                isActive: practice.isActive,
                isPredefined: practice.isPredefined,
                createdAt: practice.createdAt,
                order: practice.order
            )
        }
        
        let exportableHistory = history.compactMap { entry -> ExportableHistoryEntry? in
            guard let practiceId = entry.practice?.id.uuidString else { return nil }
            return ExportableHistoryEntry(
                id: entry.id.uuidString,
                practiceId: practiceId,
                progressSnapshot: entry.progressSnapshot,
                repetitionAdded: entry.repetitionAdded,
                practiceDate: entry.practiceDate,
                note: entry.note,
                sessionDuration: entry.sessionDuration
            )
        }
        
        let exportableReminders = reminders.compactMap { reminder -> ExportableReminder? in
            guard let practiceId = reminder.practice?.id.uuidString else { return nil }
            return ExportableReminder(
                id: reminder.id.uuidString,
                practiceId: practiceId,
                scheduledDate: reminder.scheduledDate,
                repeatType: reminder.repeatType.rawValue,
                isActive: reminder.isActive
            )
        }
        
        let exportableSettings = ExportableSettings(
            progressBarStyle: settings.progressBarStyleRaw,
            counterSound: settings.counterSoundRaw,
            hapticStyle: settings.hapticStyleRaw,
            keepScreenAwake: settings.keepScreenAwake
        )
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        return ExportData(
            version: Self.exportVersion,
            exportDate: Date(),
            appVersion: appVersion,
            practices: exportablePractices,
            history: exportableHistory,
            reminders: exportableReminders,
            settings: exportableSettings
        )
    }
    
    private func fetchPractices() throws -> [Practice] {
        let descriptor = FetchDescriptor<Practice>(sortBy: [SortDescriptor(\.order)])
        return try modelContext.fetch(descriptor)
    }
    
    private func fetchHistory() throws -> [HistoryEntry] {
        let descriptor = FetchDescriptor<HistoryEntry>(sortBy: [SortDescriptor(\.practiceDate, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    private func fetchReminders() throws -> [Reminder] {
        let descriptor = FetchDescriptor<Reminder>()
        return try modelContext.fetch(descriptor)
    }
    
    private func fetchSettings() throws -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        if let settings = try modelContext.fetch(descriptor).first {
            return settings
        }
        return UserSettings.default
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}

// MARK: - Export Format

enum ExportFormat: String, CaseIterable {
    case json
    case csv
    
    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV"
        }
    }
    
    var fileExtension: String {
        rawValue
    }
    
    var mimeType: String {
        switch self {
        case .json: return "application/json"
        case .csv: return "text/csv"
        }
    }
}

// MARK: - Export Errors

enum ExportError: LocalizedError {
    case encodingFailed
    case fileCreationFailed
    case noDataToExport
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data"
        case .fileCreationFailed:
            return "Failed to create export file"
        case .noDataToExport:
            return "No data available to export"
        }
    }
}
