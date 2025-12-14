//
//  PracticeColors.swift
//  Nyndro
//
//  Colors for different Buddhist practices with light/dark mode support
//

import SwiftUI

// MARK: - Practice Color

struct PracticeColor {
    let light: Color
    let dark: Color
    
    init(lightHex: String, darkHex: String) {
        self.light = Color(hex: lightHex)
        self.dark = Color(hex: darkHex)
    }
    
    func color(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? dark : light
    }
    
    /// Adaptive color that automatically responds to color scheme
    var adaptive: Color {
        Color(light: light, dark: dark)
    }
}

// MARK: - Practice Colors

struct PracticeColors {
    
    // MARK: - All Practice Colors
    
    /// Refuge (Schronienie) - Calm Blue - protection, safety
    static let refuge = PracticeColor(
        lightHex: "#5B8FB9",
        darkHex: "#7BA3C9"
    )
    
    /// Bodhicitta - Warm Rose - love, compassion
    static let bodhicitta = PracticeColor(
        lightHex: "#E85D75",
        darkHex: "#F07D91"
    )
    
    /// Vajrasattva (Wadżrasattwa) - Purple - purification, transformation
    static let vajrasattva = PracticeColor(
        lightHex: "#9B72CF",
        darkHex: "#B08DE0"
    )
    
    /// Amitabha - Sunset Orange - infinite light
    static let amitabha = PracticeColor(
        lightHex: "#FF6B35",
        darkHex: "#FF8555"
    )
    
    /// Mandala - Gold - offering, abundance
    static let mandala = PracticeColor(
        lightHex: "#D4AF37",
        darkHex: "#E5C454"
    )
    
    /// Guru Yoga - Saffron - tradition, blessings
    static let guruYoga = PracticeColor(
        lightHex: "#FF9933",
        darkHex: "#FFB366"
    )
    
    /// Chenrezig (Czenrezig) - Teal - compassion, peace
    static let chenrezig = PracticeColor(
        lightHex: "#4ECDC4",
        darkHex: "#6FE0D8"
    )
    
    /// Custom practice - Neutral Gray
    static let custom = PracticeColor(
        lightHex: "#6B7280",
        darkHex: "#9CA3AF"
    )
    
    // MARK: - Color by ID
    
    /// Get practice color by colorId string
    static func color(for colorId: String) -> PracticeColor {
        switch colorId {
        case "refuge":
            return refuge
        case "bodhicitta":
            return bodhicitta
        case "vajrasattva":
            return vajrasattva
        case "amitabha":
            return amitabha
        case "mandala":
            return mandala
        case "guru_yoga":
            return guruYoga
        case "chenrezig":
            return chenrezig
        case "custom":
            return custom
        default:
            return custom
        }
    }
    
    /// Get adaptive color by colorId
    static func adaptiveColor(for colorId: String) -> Color {
        color(for: colorId).adaptive
    }
    
    // MARK: - All Colors List
    
    static let allColorIds: [String] = [
        "refuge",
        "bodhicitta",
        "vajrasattva",
        "amitabha",
        "mandala",
        "guru_yoga",
        "chenrezig",
        "custom"
    ]
    
    static let allColors: [(id: String, color: PracticeColor)] = [
        ("refuge", refuge),
        ("bodhicitta", bodhicitta),
        ("vajrasattva", vajrasattva),
        ("amitabha", amitabha),
        ("mandala", mandala),
        ("guru_yoga", guruYoga),
        ("chenrezig", chenrezig),
        ("custom", custom)
    ]
}

// MARK: - Practice Extension for Color

extension Practice {
    /// Get the adaptive color for this practice
    var color: Color {
        PracticeColors.adaptiveColor(for: colorId)
    }
    
    /// Get the practice color struct for this practice
    var practiceColor: PracticeColor {
        PracticeColors.color(for: colorId)
    }
}
