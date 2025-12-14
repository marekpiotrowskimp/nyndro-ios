//
//  String+Localization.swift
//  Nyndro
//
//  Safe localization extension - NEVER crashes on missing keys
//  If a key is missing, returns the key itself (or default value)
//  Logs warnings in DEBUG mode for missing translations
//

import Foundation
import os.log

// MARK: - Safe Localization Extension

extension String {
    
    /// Safely localize a string key
    /// Returns the key itself if translation not found (NEVER crashes)
    ///
    /// Usage:
    /// ```
    /// let text = "tab.practices".localized
    /// ```
    var localized: String {
        let bundle = Bundle.main
        let value = bundle.localizedString(forKey: self, value: nil, table: nil)
        
        #if DEBUG
        if value == self && !self.isEmpty {
            Logger.localization.warning("⚠️ Missing translation for key: '\(self)'")
        }
        #endif
        
        return value
    }
    
    /// Safely localize with format arguments
    /// Returns the key with arguments if translation not found
    ///
    /// Usage:
    /// ```
    /// let text = "counter.exit.message".localized(with: 108)
    /// ```
    func localized(with args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
    
    /// Safely localize with explicit default value (RECOMMENDED)
    /// If the key is not found, returns the default value
    /// This is the safest option - guarantees meaningful text even if .strings is missing
    ///
    /// Usage:
    /// ```
    /// let text = "tab.practices".localized(default: "Practices")
    /// ```
    func localized(default defaultValue: String) -> String {
        let bundle = Bundle.main
        
        // First check if key exists
        let checkValue = bundle.localizedString(forKey: self, value: "🔑NOT_FOUND🔑", table: nil)
        
        if checkValue == "🔑NOT_FOUND🔑" {
            // Key not found - use default and log warning
            #if DEBUG
            if !self.isEmpty {
                Logger.localization.warning("⚠️ Missing translation for key: '\(self)' - using default: '\(defaultValue)'")
            }
            #endif
            return defaultValue
        }
        
        return checkValue
    }
    
    /// Safely localize with format arguments and default value
    ///
    /// Usage:
    /// ```
    /// let text = "practice.progress".localized(default: "%@ of %@", with: "1000", "111111")
    /// ```
    func localized(default defaultValue: String, with args: CVarArg...) -> String {
        String(format: self.localized(default: defaultValue), arguments: args)
    }
}

// MARK: - Localization Logger

extension Logger {
    /// Logger for localization-related warnings and errors
    static let localization = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.marek.piotrowski.nyndro",
        category: "Localization"
    )
}

// MARK: - Debug Helpers

#if DEBUG
extension String {
    /// Check if a localization key exists (DEBUG only)
    /// Useful for testing and validation
    var localizationKeyExists: Bool {
        let bundle = Bundle.main
        let value = bundle.localizedString(forKey: self, value: "🔑NOT_FOUND🔑", table: nil)
        return value != "🔑NOT_FOUND🔑"
    }
}
#endif
