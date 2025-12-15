//
//  ThemeColors.swift
//  Nyndro
//
//  Main UI color palette with light/dark mode support
//

import SwiftUI

// MARK: - Theme Colors

struct ThemeColors {
    
    // MARK: - Backgrounds
    
    /// Main app background
    static let background = Color(
        lightHex: "#FAFAFA",
        darkHex: "#121212"
    )
    
    /// Card and elevated surface background
    static let cardBackground = Color(
        lightHex: "#FFFFFF",
        darkHex: "#1E1E1E"
    )
    
    /// Secondary background for groupings
    static let secondaryBackground = Color(
        lightHex: "#F5F5F5",
        darkHex: "#2D2D2D"
    )
    
    /// Tertiary background
    static let tertiaryBackground = Color(
        lightHex: "#EBEBEB",
        darkHex: "#3D3D3D"
    )
    
    // MARK: - Text
    
    /// Primary text color
    static let textPrimary = Color(
        lightHex: "#1A1A1A",
        darkHex: "#FAFAFA"
    )
    
    /// Secondary text color
    static let textSecondary = Color(
        lightHex: "#666666",
        darkHex: "#A0A0A0"
    )
    
    /// Tertiary/placeholder text color
    static let textTertiary = Color(
        lightHex: "#999999",
        darkHex: "#707070"
    )
    
    // MARK: - Accent Colors
    
    /// Main accent color (Saffron)
    static let accent = Color(
        lightHex: "#FF9933",
        darkHex: "#FFB366"
    )
    
    /// Secondary accent
    static let accentSecondary = Color(
        lightHex: "#D4AF37",
        darkHex: "#E5C454"
    )
    
    // MARK: - Semantic Colors
    
    /// Success state
    static let success = Color(
        lightHex: "#4CAF50",
        darkHex: "#66BB6A"
    )
    
    /// Warning state
    static let warning = Color(
        lightHex: "#FF9800",
        darkHex: "#FFB74D"
    )
    
    /// Error state
    static let error = Color(
        lightHex: "#F44336",
        darkHex: "#EF5350"
    )
    
    /// Info state
    static let info = Color(
        lightHex: "#2196F3",
        darkHex: "#64B5F6"
    )
    
    // MARK: - Progress Bar Specific
    
    /// Empty progress track
    static let progressEmpty = Color(
        lightHex: "#E0E0E0",
        darkHex: "#3D3D3D"
    )
    
    /// Lotus water background
    static let lotusWater = Color(
        lightHex: "#E3F2FD",
        darkHex: "#0D1B2A"
    )
    
    /// Lotus stem color
    static let lotusStem = Color(
        lightHex: "#2E7D32",
        darkHex: "#4CAF50"
    )
    
    /// Lotus leaf color
    static let lotusLeaf = Color(
        lightHex: "#388E3C",
        darkHex: "#66BB6A"
    )
    
    // MARK: - Mala Specific
    
    /// Mala bead empty
    static let malaBeadEmpty = Color(
        lightHex: "#D0D0D0",
        darkHex: "#404040"
    )
    
    /// Mala guru bead color
    static let malaGuruBead = Color(
        lightHex: "#8B4513",
        darkHex: "#A0522D"
    )
    
    /// Mala string color
    static let malaString = Color(
        lightHex: "#8B4513",
        darkHex: "#A0522D"
    )
    
    // MARK: - Dividers & Borders
    
    /// Divider line
    static let divider = Color(
        lightHex: "#E0E0E0",
        darkHex: "#333333"
    )
    
    /// Border color
    static let border = Color(
        lightHex: "#D0D0D0",
        darkHex: "#404040"
    )
    
    // MARK: - Shadows
    
    /// Card shadow color
    static let shadow = Color.black.opacity(0.1)
}

// MARK: - Color Extension for Theme Access

extension Color {
    static let theme = ThemeColors.self
}
