//
//  Constants.swift
//  Nyndro
//
//  App-wide constants
//

import Foundation

// MARK: - App Constants

enum Constants {
    
    // MARK: - Practice Defaults
    
    /// Default repetition count (traditional mala count)
    static let defaultRepetition: Int = 108
    
    /// Default practice goal
    static let defaultMaxRepetition: Int = 111_111
    
    /// Alternative goals
    static let alternativeGoals: [Int] = [
        11_000,
        100_000,
        111_111,
        1_000_000
    ]
    
    // MARK: - Statistics
    
    /// Days without practice before reset (6 months)
    static let statisticsResetThresholdDays: Int = 180
    
    /// Minimum days for reliable prediction
    static let minimumDaysForPrediction: Int = 7
    
    /// Days for weighted average calculation
    static let weightedAverageDays: Int = 30
    
    // MARK: - Milestones
    
    /// Streak day milestones
    static let streakMilestones: [Int] = [7, 21, 30, 100, 365]
    
    /// Progress percentage milestones
    static let progressMilestones: [Int] = [25, 50, 75, 90, 100]
    
    // MARK: - Notifications
    
    /// Default reminder check interval (seconds)
    static let reminderCheckInterval: TimeInterval = 60
    
    /// Notification category identifier
    static let notificationCategoryId = "NYNDRO_REMINDER"
    
    // MARK: - UI
    
    /// Maximum practices to show on home screen
    static let maxPracticesOnHome: Int = 10
    
    /// Animation durations
    enum Animation {
        static let fast: Double = 0.2
        static let normal: Double = 0.3
        static let slow: Double = 0.5
        static let celebration: Double = 1.0
    }
    
    // MARK: - Export/Import
    
    /// Export file version
    static let exportVersion = "1.0"
    
    /// Export file extension
    static let jsonExtension = "json"
    static let csvExtension = "csv"
    
    /// Export UTI types
    static let jsonUTI = "public.json"
    static let csvUTI = "public.comma-separated-values-text"
    
    // MARK: - Storage Keys
    
    enum StorageKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastSyncDate = "lastSyncDate"
        static let appVersion = "appVersion"
    }
    
}

// MARK: - Predefined Practice Data

struct PredefinedPractice: Codable, Identifiable {
    let id: String
    let colorId: String
    let imageName: String
    let maxRepetition: Int
    let defaultRepetition: Int
    let name: LocalizedString
    let description: LocalizedString
    
    struct LocalizedString: Codable {
        let en: String
        let pl: String
        let de: String
        
        /// Get localized string for current locale
        var localized: String {
            let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
            switch languageCode {
            case "pl": return pl
            case "de": return de
            default: return en
            }
        }
    }
    
    var localizedName: String { name.localized }
    var localizedDescription: String { description.localized }
}

// MARK: - Predefined Practices Loader

enum PredefinedPracticesLoader {
    static func load() -> [PredefinedPractice] {
        guard let url = Bundle.main.url(forResource: "PredefinedPractices", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let practices = try? JSONDecoder().decode([PredefinedPractice].self, from: data) else {
            return defaultPractices
        }
        return practices
    }
    
    /// Fallback default practices if JSON fails to load
    static let defaultPractices: [PredefinedPractice] = [
        PredefinedPractice(
            id: "refuge",
            colorId: "refuge",
            imageName: "shield.fill",
            maxRepetition: 11000,
            defaultRepetition: 108,
            name: .init(en: "Refuge", pl: "Schronienie", de: "Zuflucht"),
            description: .init(
                en: "Taking refuge in Buddha, Dharma, Sangha",
                pl: "Przyjmowanie schronienia w Buddzie, Dharmie, Sandze",
                de: "Zuflucht zu Buddha, Dharma, Sangha nehmen"
            )
        ),
        PredefinedPractice(
            id: "bodhicitta",
            colorId: "bodhicitta",
            imageName: "heart.circle.fill",
            maxRepetition: 111111,
            defaultRepetition: 108,
            name: .init(en: "Refuge & Bodhicitta", pl: "Schronienie i Bodhicitta", de: "Zuflucht & Bodhicitta"),
            description: .init(
                en: "Refuge with enlightened attitude for all beings",
                pl: "Schronienie z postawą oświeconą dla wszystkich istot",
                de: "Zuflucht mit erleuchteter Haltung für alle Wesen"
            )
        ),
        PredefinedPractice(
            id: "vajrasattva",
            colorId: "vajrasattva",
            imageName: "drop.fill",
            maxRepetition: 111111,
            defaultRepetition: 108,
            name: .init(en: "Vajrasattva", pl: "Wadżrasattwa", de: "Vajrasattva"),
            description: .init(
                en: "Purification practice with 100-syllable mantra",
                pl: "Praktyka oczyszczania z mantrą 100 sylab",
                de: "Reinigungspraxis mit 100-Silben-Mantra"
            )
        ),
        PredefinedPractice(
            id: "custom",
            colorId: "custom",
            imageName: "plus.circle.fill",
            maxRepetition: 111111,
            defaultRepetition: 108,
            name: .init(en: "Custom Practice", pl: "Własna praktyka", de: "Eigene Praxis"),
            description: .init(
                en: "Add your own practice",
                pl: "Dodaj własną praktykę",
                de: "Füge deine eigene Praxis hinzu"
            )
        )
    ]
}
