//
//  L10n.swift
//  Nyndro
//
//  Type-safe localization access with safe fallbacks
//  Uses String+Localization extension for crash-proof localization
//

import Foundation

// MARK: - L10n

enum L10n {
    
    // MARK: - App
    
    enum App {
        static let name = "app.name".localized(default: "Nyndro")
    }
    
    // MARK: - Tab
    
    enum Tab {
        static let practices = "tab.practices".localized(default: "Practices")
        static let statistics = "tab.statistics".localized(default: "Statistics")
        static let history = "tab.history".localized(default: "History")
        static let settings = "tab.settings".localized(default: "Settings")
    }
    
    // MARK: - About
    
    enum About {
        static let description = "about.description".localized(default: "A mindful practice tracking app for Buddhist practitioners following the Ngöndro path.")
        static let madeWithLove = "about.made_with_love".localized(default: "Made with mindfulness")
        static let dedication = "about.dedication".localized(default: "May this app benefit all sentient beings")
    }
    
    // MARK: - Onboarding
    
    enum Onboarding {
        enum Welcome {
            static let title = "onboarding.welcome.title".localized(default: "Welcome to Nyndro")
            static let subtitle = "onboarding.welcome.subtitle".localized(default: "Your mindful companion for Ngöndro practice")
        }
        
        enum Progress {
            static let title = "onboarding.progress.title".localized(default: "Track Your Progress")
            static let subtitle = "onboarding.progress.subtitle".localized(default: "Track your progress toward your traditional practice goals")
        }
        
        enum Counter {
            static let title = "onboarding.counter.title".localized(default: "Simple Counting")
            static let subtitle = "onboarding.counter.subtitle".localized(default: "Simply tap the screen to count your repetitions")
        }
        
        enum Prediction {
            static let title = "onboarding.prediction.title".localized(default: "Smart Predictions")
            static let subtitle = "onboarding.prediction.subtitle".localized(default: "Get insights on when you'll complete your goals based on your practice patterns")
        }
        
        enum Reminders {
            static let title = "onboarding.reminders.title".localized(default: "Mindful Reminders")
            static let subtitle = "onboarding.reminders.subtitle".localized(default: "Set gentle reminders to maintain your daily practice")
        }
        
        static let next = "onboarding.next".localized(default: "Next")
        static let getStarted = "onboarding.get_started".localized(default: "Get Started")
        static let skip = "onboarding.skip".localized(default: "Skip")
    }
    
    // MARK: - Practice
    
    enum Practice {
        static let add = "practice.add".localized(default: "Add Practice")
        static let edit = "practice.edit".localized(default: "Edit Practice")
        static let progress = "practice.progress".localized(default: "%@ of %@")
        static let completed = "practice.completed".localized(default: "Completed")
        static let lastSession = "practice.last_session".localized(default: "Last session")
        static let startSession = "practice.start_session".localized(default: "Start Session")
        static let addManual = "practice.add_manual".localized(default: "Add Manual Entry")
        static let recentHistory = "practice.recent_history".localized(default: "Recent History")
        static let noHistory = "practice.no_history".localized(default: "No practice history yet")
        
        enum Add {
            static let predefined = "practice.add.predefined".localized(default: "Predefined Practices")
            static let custom = "practice.add.custom".localized(default: "Custom Practice")
            static let allAdded = "practice.add.all_added".localized(default: "All predefined practices added")
            static let tryCustom = "practice.add.try_custom".localized(default: "Try adding a custom practice")
        }
        
        enum Name {
            static let placeholder = "practice.name.placeholder".localized(default: "Practice name")
        }
        
        enum Description {
            static let placeholder = "practice.description.placeholder".localized(default: "Description (optional)")
        }
        
        enum Section {
            static let details = "practice.section.details".localized(default: "Details")
            static let goal = "practice.section.goal".localized(default: "Goal")
            static let color = "practice.section.color".localized(default: "Color")
        }
        
        enum Goal {
            static let title = "practice.goal".localized(default: "Goal")
            static let format = "practice.goal.format".localized(default: "%@ repetitions")
            static let common = "practice.goal.common".localized(default: "Common Goals")
            static let custom = "practice.goal.custom".localized(default: "Custom Goal")
            static let customSection = "practice.goal.custom.section".localized(default: "Custom")
            static let select = "practice.goal.select".localized(default: "Select Goal")
        }
        
        enum DefaultRepetitions {
            static let title = "practice.default_repetitions".localized(default: "Default per session")
            static let footer = "practice.default_reps.footer".localized(default: "How many repetitions to count per tap (e.g., 108 for one mala)")
        }
    }
    
    // MARK: - Counter
    
    enum Counter {
        static let tapToCount = "counter.tap_to_count".localized(default: "Tap to count")
        static let tapAnywhere = "counter.tap_anywhere".localized(default: "Tap anywhere to count")
        static let endSession = "counter.end_session".localized(default: "End Session")
        static let thisSession = "counter.this_session".localized(default: "This session")
        static let sessionCount = "counter.session_count".localized(default: "Session Count")
        static let perTap = "counter.per_tap".localized(default: "per tap")
        static let tapValue = "counter.tap_value".localized(default: "Count per tap")
        static let commonValues = "counter.common_values".localized(default: "Common Values")
        static let customValue = "counter.custom_value".localized(default: "Custom Value")
        static let custom = "counter.custom".localized(default: "Custom")
        static let `default` = "counter.default".localized(default: "Default")
        static let saveExit = "counter.save_exit".localized(default: "Save & Exit")
        static let discard = "counter.discard".localized(default: "Discard")
        static let milestone = "counter.milestone".localized(default: "Milestone")
        static let repetitions = "counter.repetitions".localized(default: "repetitions")
        
        enum Exit {
            static let title = "counter.exit.title".localized(default: "End Session?")
            static let message = "counter.exit.message".localized(default: "You have %@ repetitions in this session. Would you like to save them?")
        }
    }
    
    // MARK: - Statistics
    
    enum Statistics {
        static let overview = "statistics.overview".localized(default: "Overview")
        static let estimatedCompletion = "statistics.estimated_completion".localized(default: "Estimated Completion")
        static let prediction = "statistics.prediction".localized(default: "Prediction")
        static let mostLikely = "statistics.most_likely".localized(default: "Most likely")
        static let optimistic = "statistics.optimistic".localized(default: "Optimistic")
        static let pessimistic = "statistics.pessimistic".localized(default: "Pessimistic")
        static let confidence = "statistics.confidence".localized(default: "Confidence")
        static let insufficientData = "statistics.insufficient_data".localized(default: "Insufficient data")
        static let needMoreDays = "statistics.need_more_days".localized(default: "Practice for at least %@ days for predictions")
        static let dailyAverage = "statistics.daily_average".localized(default: "Daily average")
        static let weeklyAverage = "statistics.weekly_average".localized(default: "Weekly average")
        static let monthlyAverage = "statistics.monthly_average".localized(default: "Monthly average")
        static let practiceDays = "statistics.practice_days".localized(default: "Practice days")
        static let perDay = "statistics.per_day".localized(default: "per day")
        static let streak = "statistics.streak".localized(default: "Streak")
        static let days = "statistics.days".localized(default: "days")
        static let currentStreak = "statistics.current_streak".localized(default: "Current streak")
        static let bestStreak = "statistics.best_streak".localized(default: "Best streak")
        static let completed = "statistics.completed".localized(default: "Completed")
        static let remaining = "statistics.remaining".localized(default: "Remaining")
        static let progress = "statistics.progress".localized(default: "Progress")
        
        enum Confidence {
            static let insufficient = "statistics.confidence.insufficient".localized(default: "Insufficient data")
            static let low = "statistics.confidence.low".localized(default: "Low confidence")
            static let medium = "statistics.confidence.medium".localized(default: "Medium confidence")
            static let high = "statistics.confidence.high".localized(default: "High confidence")
        }
    }
    
    // MARK: - Settings
    
    enum Settings {
        static let progressStyle = "settings.progress_style".localized(default: "Progress Style")
        static let keepScreenAwake = "settings.keep_screen_awake".localized(default: "Keep Screen Awake")
        static let counterSound = "settings.counter_sound".localized(default: "Counter Sound")
        static let hapticFeedback = "settings.haptic_feedback".localized(default: "Haptic Feedback")
        static let exportData = "settings.export_data".localized(default: "Export Data")
        static let importData = "settings.import_data".localized(default: "Import Data")
        static let about = "settings.about".localized(default: "About")
        static let resetAllData = "settings.reset_all_data".localized(default: "Reset All Data")
        static let resetWarning = "settings.reset_warning".localized(default: "This will permanently delete all your practices, history, and settings.")
        static let resetConfirmationTitle = "settings.reset_confirmation_title".localized(default: "Reset All Data?")
        static let resetConfirmationMessage = "settings.reset_confirmation_message".localized(default: "This action cannot be undone.")
        static let resetConfirm = "settings.reset_confirm".localized(default: "Reset")
        static let exportTitle = "settings.export_title".localized(default: "Export Data")
        static let exportJson = "settings.export_json".localized(default: "Export as JSON")
        static let exportCsv = "settings.export_csv".localized(default: "Export as CSV")
        static let version = "settings.version".localized(default: "Version")
        
        enum Section {
            static let appearance = "settings.section.appearance".localized(default: "Appearance")
            static let counter = "settings.section.counter".localized(default: "Counter")
            static let data = "settings.section.data".localized(default: "Data")
            static let about = "settings.section.about".localized(default: "About")
            static let danger = "settings.section.danger".localized(default: "Danger Zone")
        }
        
        enum Sound {
            static let none = "settings.sound.none".localized(default: "None")
            static let click = "settings.sound.click".localized(default: "Click")
            static let bell = "settings.sound.bell".localized(default: "Bell")
            static let singingBowl = "settings.sound.singing_bowl".localized(default: "Singing Bowl")
            static let gong = "settings.sound.gong".localized(default: "Gong")
        }
        
        enum Haptic {
            static let none = "settings.haptic.none".localized(default: "None")
            static let light = "settings.haptic.light".localized(default: "Light")
            static let medium = "settings.haptic.medium".localized(default: "Medium")
            static let heavy = "settings.haptic.heavy".localized(default: "Strong")
        }
        
        enum ProgressStyle {
            static let lotus = "settings.progress_style.lotus".localized(default: "Lotus")
            static let mala = "settings.progress_style.mala".localized(default: "Mala")
        }
    }
    
    // MARK: - Reminder
    
    enum Reminder {
        enum Repeat {
            static let none = "reminder.repeat.none".localized(default: "Once")
            static let daily = "reminder.repeat.daily".localized(default: "Daily")
            static let weekly = "reminder.repeat.weekly".localized(default: "Weekly")
            static let monthly = "reminder.repeat.monthly".localized(default: "Monthly")
        }
    }
    
    // MARK: - Milestone
    
    enum Milestone {
        enum PersonalBest {
            static let title = "milestone.personal_best.title".localized(default: "Personal Best!")
        }
    }
    
    // MARK: - Date
    
    enum Date {
        static let today = "date.today".localized(default: "Today")
        static let yesterday = "date.yesterday".localized(default: "Yesterday")
    }
    
    // MARK: - Empty States
    
    enum Empty {
        enum Practices {
            static let title = "empty.practices.title".localized(default: "No Practices")
            static let message = "empty.practices.message".localized(default: "Add your first practice to get started")
        }
        
        enum History {
            static let title = "empty.history.title".localized(default: "No History")
            static let message = "empty.history.message".localized(default: "Your practice history will appear here")
        }
        
        enum Statistics {
            static let title = "empty.statistics.title".localized(default: "No Statistics")
            static let message = "empty.statistics.message".localized(default: "Start practicing to see your statistics")
        }
    }
    
    // MARK: - Common
    
    enum Common {
        static let cancel = "common.cancel".localized(default: "Cancel")
        static let save = "common.save".localized(default: "Save")
        static let delete = "common.delete".localized(default: "Delete")
        static let edit = "common.edit".localized(default: "Edit")
        static let done = "common.done".localized(default: "Done")
        static let add = "common.add".localized(default: "Add")
        static let `continue` = "common.continue".localized(default: "Continue")
        static let seeAll = "common.see_all".localized(default: "See All")
        static let set = "common.set".localized(default: "Set")
    }
}

// MARK: - Filter

enum Filter {
    static let all = "filter.all".localized(default: "All")
}

// MARK: - History

enum History {
    static let deleteConfirmation = "history.delete.confirmation".localized(default: "Are you sure you want to delete this entry?")
    
    static func totalCount(_ count: Int) -> String {
        String(format: "history.total_count".localized(default: "Total: %d"), count)
    }
}

// MARK: - Additional Practice Keys

extension L10n.Practice {
    static let unknown = "practice.unknown".localized(default: "Unknown Practice")
    static let count = "practice.count".localized(default: "Count")
    static let note = "practice.note".localized(default: "Note (optional)")
    static let custom = "practice.custom".localized(default: "Custom")
    static let deleteConfirmation = "practice.delete.confirmation".localized(default: "Are you sure you want to delete this practice?")
    
    static func duration(_ duration: String) -> String {
        String(format: "practice.duration".localized(default: "Duration: %@"), duration)
    }
    
    enum AddManual {
        static let message = "practice.add_manual.message".localized(default: "Enter the number of repetitions to add manually")
    }
}

// MARK: - Additional Statistics Keys

extension L10n.Statistics {
    static func yearsRemaining(_ years: Int) -> String {
        String(format: "statistics.years_remaining".localized(default: "%d+ years"), years)
    }
    
    static func daysRemaining(_ days: Int) -> String {
        String(format: "statistics.days_remaining".localized(default: "%d days"), days)
    }
}
