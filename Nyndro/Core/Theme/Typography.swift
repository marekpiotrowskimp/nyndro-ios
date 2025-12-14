//
//  Typography.swift
//  Nyndro
//
//  Typography system and text styles
//

import SwiftUI

// MARK: - Typography

struct Typography {
    
    // MARK: - Large Titles
    
    /// Large title for main screens
    static let largeTitle = Font.largeTitle.weight(.bold)
    
    /// Title 1
    static let title1 = Font.title.weight(.bold)
    
    /// Title 2
    static let title2 = Font.title2.weight(.semibold)
    
    /// Title 3
    static let title3 = Font.title3.weight(.semibold)
    
    // MARK: - Headlines
    
    /// Headline
    static let headline = Font.headline.weight(.semibold)
    
    /// Subheadline
    static let subheadline = Font.subheadline.weight(.medium)
    
    // MARK: - Body
    
    /// Body text
    static let body = Font.body
    
    /// Body emphasized
    static let bodyBold = Font.body.weight(.semibold)
    
    /// Callout
    static let callout = Font.callout
    
    // MARK: - Small
    
    /// Footnote
    static let footnote = Font.footnote
    
    /// Caption (alias for caption1)
    static let caption = Font.caption
    
    /// Caption 1
    static let caption1 = Font.caption
    
    /// Caption 2
    static let caption2 = Font.caption2
    
    // MARK: - Counter
    
    /// Large counter number
    static let counterLarge = Font.system(size: 72, weight: .bold, design: .rounded)
    
    /// Medium counter number
    static let counterMedium = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// Small counter number
    static let counterSmall = Font.system(size: 32, weight: .semibold, design: .rounded)
    
    // MARK: - Progress
    
    /// Progress percentage
    static let progressPercentage = Font.system(size: 24, weight: .bold, design: .rounded)
    
    /// Progress numbers
    static let progressNumbers = Font.system(size: 16, weight: .medium, design: .rounded)
    
    // MARK: - Monospaced
    
    /// Monospaced for numbers alignment
    static let monospacedBody = Font.system(.body, design: .monospaced)
    
    /// Monospaced caption
    static let monospacedCaption = Font.system(.caption, design: .monospaced)
}

// MARK: - View Extension for Typography

extension View {
    func typography(_ font: Font) -> some View {
        self.font(font)
    }
}
