//
//  UserSettings.swift
//  Nyndro
//
//  User preferences and settings model
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    // MARK: - Properties
    
    @Attribute(.unique) var id: UUID
    var progressBarStyleRaw: String
    var counterSoundRaw: String
    var hapticStyleRaw: String
    var keepScreenAwake: Bool
    var hasCompletedOnboarding: Bool
    
    // MARK: - Computed Properties
    
    var progressBarStyle: ProgressBarStyle {
        get { ProgressBarStyle(rawValue: progressBarStyleRaw) ?? .lotus }
        set { progressBarStyleRaw = newValue.rawValue }
    }
    
    var counterSound: CounterSound {
        get { CounterSound(rawValue: counterSoundRaw) ?? .none }
        set { counterSoundRaw = newValue.rawValue }
    }
    
    var hapticStyle: HapticStyle {
        get { HapticStyle(rawValue: hapticStyleRaw) ?? .medium }
        set { hapticStyleRaw = newValue.rawValue }
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        progressBarStyle: ProgressBarStyle = .lotus,
        counterSound: CounterSound = .none,
        hapticStyle: HapticStyle = .medium,
        keepScreenAwake: Bool = true,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = id
        self.progressBarStyleRaw = progressBarStyle.rawValue
        self.counterSoundRaw = counterSound.rawValue
        self.hapticStyleRaw = hapticStyle.rawValue
        self.keepScreenAwake = keepScreenAwake
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
    
    // MARK: - Default Settings
    
    static var `default`: UserSettings {
        UserSettings()
    }
}

// MARK: - ProgressBarStyle

enum ProgressBarStyle: String, Codable, CaseIterable {
    case lotus = "lotus"
    case mala = "mala"
    
    var displayName: String {
        switch self {
        case .lotus:
            return String(localized: "settings.progress_style.lotus", defaultValue: "Lotus")
        case .mala:
            return String(localized: "settings.progress_style.mala", defaultValue: "Mala")
        }
    }
    
    var icon: String {
        switch self {
        case .lotus: return "leaf.fill"
        case .mala: return "mala_icon"
        }
    }
    
    /// Returns true if the icon is an SF Symbol (contains "."), false for asset images
    var isSystemIcon: Bool {
        icon.contains(".")
    }
    
    var description: String {
        switch self {
        case .lotus:
            return String(localized: "settings.progress_style.lotus.description", defaultValue: "Blooming lotus flower")
        case .mala:
            return String(localized: "settings.progress_style.mala.description", defaultValue: "Traditional prayer beads")
        }
    }
}

// MARK: - CounterSound

enum CounterSound: String, Codable, CaseIterable {
    case none = "none"
    case click = "click"
    case bell = "bell"
    case singingBowl = "singing_bowl"
    case gong = "gong"
    
    var displayName: String {
        switch self {
        case .none:
            return String(localized: "settings.sound.none", defaultValue: "None")
        case .click:
            return String(localized: "settings.sound.click", defaultValue: "Click")
        case .bell:
            return String(localized: "settings.sound.bell", defaultValue: "Bell")
        case .singingBowl:
            return String(localized: "settings.sound.singing_bowl", defaultValue: "Singing Bowl")
        case .gong:
            return String(localized: "settings.sound.gong", defaultValue: "Gong")
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "speaker.slash"
        case .click: return "hand.tap"
        case .bell: return "bell"
        case .singingBowl: return "waveform.circle"
        case .gong: return "circle.circle"
        }
    }
    
    var fileName: String? {
        switch self {
        case .none: return nil
        default: return rawValue
        }
    }
}

// MARK: - HapticStyle

enum HapticStyle: String, Codable, CaseIterable {
    case none = "none"
    case light = "light"
    case medium = "medium"
    case heavy = "heavy"
    
    var displayName: String {
        switch self {
        case .none:
            return String(localized: "settings.haptic.none", defaultValue: "None")
        case .light:
            return String(localized: "settings.haptic.light", defaultValue: "Light")
        case .medium:
            return String(localized: "settings.haptic.medium", defaultValue: "Medium")
        case .heavy:
            return String(localized: "settings.haptic.heavy", defaultValue: "Strong")
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "iphone.slash"
        case .light: return "iphone.gen1.radiowaves.left.and.right"
        case .medium: return "iphone.gen2.radiowaves.left.and.right"
        case .heavy: return "iphone.gen3.radiowaves.left.and.right"
        }
    }
}
