//
//  Spacing.swift
//  Nyndro
//
//  Spacing system for consistent padding and margins
//

import SwiftUI

// MARK: - Spacing

struct Spacing {
    
    // MARK: - Base Unit (4pt)
    
    /// 4pt
    static let xxs: CGFloat = 4
    
    /// 8pt
    static let xs: CGFloat = 8
    
    /// 12pt
    static let sm: CGFloat = 12
    
    /// 16pt
    static let md: CGFloat = 16
    
    /// 20pt
    static let lg: CGFloat = 20
    
    /// 24pt
    static let xl: CGFloat = 24
    
    /// 32pt
    static let xxl: CGFloat = 32
    
    /// 40pt
    static let xxxl: CGFloat = 40
    
    /// 48pt
    static let huge: CGFloat = 48
    
    // MARK: - Semantic Spacing
    
    /// Screen horizontal padding
    static let screenHorizontal: CGFloat = 16
    
    /// Screen vertical padding
    static let screenVertical: CGFloat = 16
    
    /// Card internal padding
    static let cardPadding: CGFloat = 16
    
    /// Card corner radius
    static let cardRadius: CGFloat = 16
    
    /// Button corner radius
    static let buttonRadius: CGFloat = 12
    
    /// Small corner radius
    static let smallRadius: CGFloat = 8
    
    /// List item spacing
    static let listSpacing: CGFloat = 12
    
    /// Section spacing
    static let sectionSpacing: CGFloat = 24
    
    /// Icon size small
    static let iconSmall: CGFloat = 16
    
    /// Icon size medium
    static let iconMedium: CGFloat = 24
    
    /// Icon size large
    static let iconLarge: CGFloat = 32
    
    /// Icon size extra large
    static let iconXLarge: CGFloat = 48
    
    /// Progress bar height
    static let progressBarHeight: CGFloat = 8
    
    /// Progress bar height large
    static let progressBarHeightLarge: CGFloat = 12
}

// MARK: - EdgeInsets Helpers

extension EdgeInsets {
    /// Standard screen insets
    static let screen = EdgeInsets(
        top: Spacing.screenVertical,
        leading: Spacing.screenHorizontal,
        bottom: Spacing.screenVertical,
        trailing: Spacing.screenHorizontal
    )
    
    /// Card padding insets
    static let card = EdgeInsets(
        top: Spacing.cardPadding,
        leading: Spacing.cardPadding,
        bottom: Spacing.cardPadding,
        trailing: Spacing.cardPadding
    )
    
    /// Horizontal only insets
    static func horizontal(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value)
    }
    
    /// Vertical only insets
    static func vertical(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0)
    }
    
    /// All sides equal
    static func all(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
}
