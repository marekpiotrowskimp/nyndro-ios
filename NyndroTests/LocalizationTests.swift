//
//  LocalizationTests.swift
//  NyndroTests
//
//  Unit tests to verify all localization keys exist across all supported languages.
//  These tests ensure the app won't crash due to missing translations.
//

import XCTest
@testable import Nyndro

final class LocalizationTests: XCTestCase {
    
    // MARK: - All Localization Keys
    // This list must be kept in sync with L10n.swift
    
    static let allLocalizationKeys: [String] = [
        // App
        "app.name",
        
        // Tabs
        "tab.practices",
        "tab.statistics",
        "tab.history",
        "tab.settings",
        
        // About
        "about.description",
        "about.made_with_love",
        "about.dedication",
        
        // Onboarding - Welcome
        "onboarding.welcome.title",
        "onboarding.welcome.subtitle",
        
        // Onboarding - Progress
        "onboarding.progress.title",
        "onboarding.progress.subtitle",
        
        // Onboarding - Counter
        "onboarding.counter.title",
        "onboarding.counter.subtitle",
        
        // Onboarding - Prediction
        "onboarding.prediction.title",
        "onboarding.prediction.subtitle",
        
        // Onboarding - Reminders
        "onboarding.reminders.title",
        "onboarding.reminders.subtitle",
        
        // Onboarding - Actions
        "onboarding.next",
        "onboarding.get_started",
        "onboarding.skip",
        
        // Practice - General
        "practice.add",
        "practice.edit",
        "practice.progress",
        "practice.completed",
        "practice.last_session",
        "practice.start_session",
        "practice.add_manual",
        "practice.recent_history",
        "practice.no_history",
        
        // Practice - Add
        "practice.add.predefined",
        "practice.add.custom",
        "practice.add.all_added",
        "practice.add.try_custom",
        
        // Practice - Form
        "practice.name.placeholder",
        "practice.description.placeholder",
        "practice.section.details",
        "practice.section.goal",
        "practice.section.color",
        
        // Practice - Goal
        "practice.goal",
        "practice.goal.format",
        "practice.goal.common",
        "practice.goal.custom",
        "practice.goal.custom.section",
        "practice.goal.select",
        "practice.default_repetitions",
        "practice.default_reps.footer",
        
        // Counter
        "counter.tap_to_count",
        "counter.tap_anywhere",
        "counter.end_session",
        "counter.this_session",
        "counter.session_count",
        "counter.per_tap",
        "counter.tap_value",
        "counter.common_values",
        "counter.custom_value",
        "counter.custom",
        "counter.default",
        "counter.save_exit",
        "counter.discard",
        "counter.milestone",
        "counter.repetitions",
        "counter.exit.title",
        "counter.exit.message",
        
        // Statistics - Overview
        "statistics.overview",
        "statistics.estimated_completion",
        "statistics.prediction",
        "statistics.most_likely",
        "statistics.optimistic",
        "statistics.pessimistic",
        
        // Statistics - Confidence
        "statistics.confidence",
        "statistics.insufficient_data",
        "statistics.need_more_days",
        "statistics.confidence.insufficient",
        "statistics.confidence.low",
        "statistics.confidence.medium",
        "statistics.confidence.high",
        
        // Statistics - Averages
        "statistics.daily_average",
        "statistics.weekly_average",
        "statistics.monthly_average",
        
        // Statistics - Days
        "statistics.practice_days",
        "statistics.per_day",
        "statistics.streak",
        "statistics.days",
        "statistics.current_streak",
        "statistics.best_streak",
        
        // Statistics - Progress
        "statistics.completed",
        "statistics.remaining",
        "statistics.progress",
        
        // Settings - General
        "settings.progress_style",
        "settings.keep_screen_awake",
        "settings.counter_sound",
        "settings.haptic_feedback",
        "settings.export_data",
        "settings.import_data",
        "settings.about",
        "settings.reset_all_data",
        "settings.reset_warning",
        "settings.reset_confirmation_title",
        "settings.reset_confirmation_message",
        "settings.reset_confirm",
        "settings.export_title",
        "settings.export_json",
        "settings.export_csv",
        "settings.version",
        
        // Settings - Sections
        "settings.section.appearance",
        "settings.section.counter",
        "settings.section.data",
        "settings.section.about",
        "settings.section.danger",
        
        // Settings - Sound Options
        "settings.sound.none",
        "settings.sound.click",
        "settings.sound.bell",
        "settings.sound.singing_bowl",
        "settings.sound.gong",
        
        // Settings - Haptic Options
        "settings.haptic.none",
        "settings.haptic.light",
        "settings.haptic.medium",
        "settings.haptic.heavy",
        
        // Settings - Progress Style
        "settings.progress_style.lotus",
        "settings.progress_style.mala",
        
        // Reminder
        "reminder.repeat.none",
        "reminder.repeat.daily",
        "reminder.repeat.weekly",
        "reminder.repeat.monthly",
        
        // Milestone
        "milestone.personal_best.title",
        
        // Date
        "date.today",
        "date.yesterday",
        
        // Empty States
        "empty.practices.title",
        "empty.practices.message",
        "empty.history.title",
        "empty.history.message",
        "empty.statistics.title",
        "empty.statistics.message",
        
        // Common
        "common.cancel",
        "common.save",
        "common.delete",
        "common.edit",
        "common.done",
        "common.add",
        "common.continue",
        "common.see_all",
        "common.set"
    ]
    
    // MARK: - Supported Languages
    
    static let supportedLanguages = ["en", "pl", "de"]
    
    // MARK: - Tests
    
    /// Test that all keys exist in all supported languages
    func testAllKeysExistInAllLanguages() {
        for language in Self.supportedLanguages {
            for key in Self.allLocalizationKeys {
                let localizedString = localizedString(for: key, language: language)
                
                // The localized string should NOT be equal to the key itself
                // (unless the key is meant to be displayed as-is, which is rare)
                // This catches cases where NSLocalizedString returns the key because translation is missing
                
                XCTAssertNotEqual(
                    localizedString,
                    key,
                    "Missing translation for key '\(key)' in language '\(language)'"
                )
            }
        }
    }
    
    /// Test that English translations exist for all keys
    func testEnglishTranslationsExist() {
        let language = "en"
        var missingKeys: [String] = []
        
        for key in Self.allLocalizationKeys {
            let localizedString = localizedString(for: key, language: language)
            if localizedString == key {
                missingKeys.append(key)
            }
        }
        
        XCTAssertTrue(
            missingKeys.isEmpty,
            "Missing English translations for keys: \(missingKeys.joined(separator: ", "))"
        )
    }
    
    /// Test that Polish translations exist for all keys
    func testPolishTranslationsExist() {
        let language = "pl"
        var missingKeys: [String] = []
        
        for key in Self.allLocalizationKeys {
            let localizedString = localizedString(for: key, language: language)
            if localizedString == key {
                missingKeys.append(key)
            }
        }
        
        XCTAssertTrue(
            missingKeys.isEmpty,
            "Missing Polish translations for keys: \(missingKeys.joined(separator: ", "))"
        )
    }
    
    /// Test that German translations exist for all keys
    func testGermanTranslationsExist() {
        let language = "de"
        var missingKeys: [String] = []
        
        for key in Self.allLocalizationKeys {
            let localizedString = localizedString(for: key, language: language)
            if localizedString == key {
                missingKeys.append(key)
            }
        }
        
        XCTAssertTrue(
            missingKeys.isEmpty,
            "Missing German translations for keys: \(missingKeys.joined(separator: ", "))"
        )
    }
    
    /// Test that the safe .localized extension doesn't crash on missing keys
    func testSafeLocalizedExtensionDoesNotCrash() {
        // Test with a key that definitely doesn't exist
        let nonExistentKey = "this.key.definitely.does.not.exist.12345"
        
        // This should NOT crash, it should return the key itself
        let result = nonExistentKey.localized
        
        XCTAssertEqual(result, nonExistentKey, "Safe localized extension should return the key when translation is missing")
    }
    
    /// Test that .localized(default:) returns the default value for missing keys
    func testLocalizedWithDefaultReturnsDefault() {
        let nonExistentKey = "this.key.definitely.does.not.exist.67890"
        let defaultValue = "My Default Value"
        
        let result = nonExistentKey.localized(default: defaultValue)
        
        XCTAssertEqual(result, defaultValue, "Safe localized(default:) should return the default value when translation is missing")
    }
    
    /// Test that translations are not empty strings
    func testTranslationsAreNotEmpty() {
        for language in Self.supportedLanguages {
            for key in Self.allLocalizationKeys {
                let localizedString = localizedString(for: key, language: language)
                
                // Skip if the key is not translated (tested elsewhere)
                if localizedString == key {
                    continue
                }
                
                XCTAssertFalse(
                    localizedString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "Translation for key '\(key)' in language '\(language)' should not be empty"
                )
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Get localized string for a specific language
    private func localizedString(for key: String, language: String) -> String {
        guard let bundlePath = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else {
            // If we can't find the bundle, return the key to indicate failure
            return key
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
