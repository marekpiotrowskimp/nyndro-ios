//
//  PracticeIconView.swift
//  Nyndro
//
//  Reusable practice icon component with consistent styling
//

import SwiftUI

/// A reusable view for displaying practice icons with consistent styling
struct PracticeIconView: View {
    let imageName: String
    let color: Color
    let size: IconSize
    
    enum IconSize {
        case small      // 24pt - for lists
        case medium     // 36pt - for cards
        case large      // 48pt - for details
        case extraLarge // 64pt - for empty states
        
        var dimension: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 36
            case .large: return 48
            case .extraLarge: return 64
            }
        }
        
        var backgroundSize: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 52
            case .large: return 72
            case .extraLarge: return 96
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            case .extraLarge: return 20
            }
        }
    }
    
    init(_ imageName: String, color: Color, size: IconSize = .medium) {
        self.imageName = imageName
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(color.opacity(0.15))
                .frame(width: size.backgroundSize, height: size.backgroundSize)
            
            // Icon
            Image(systemName: imageName)
                .font(.system(size: size.dimension * 0.6, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - Convenience initializers for Practice

extension PracticeIconView {
    init(practice: Practice, size: IconSize = .medium) {
        self.imageName = practice.imageName
        self.color = practice.color
        self.size = size
    }
}

// MARK: - Preview

#Preview("Icon Sizes") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            PracticeIconView("shield.fill", color: .blue, size: .small)
            Text("Small")
        }
        
        HStack(spacing: 20) {
            PracticeIconView("heart.circle.fill", color: .pink, size: .medium)
            Text("Medium")
        }
        
        HStack(spacing: 20) {
            PracticeIconView("drop.fill", color: .purple, size: .large)
            Text("Large")
        }
        
        HStack(spacing: 20) {
            PracticeIconView("sun.horizon.fill", color: .orange, size: .extraLarge)
            Text("Extra Large")
        }
    }
    .padding()
}

#Preview("Practice Icons") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            PracticeIconView("shield.fill", color: PracticeColors.refuge.adaptive, size: .medium)
            Text("Refuge")
        }
        HStack(spacing: 12) {
            PracticeIconView("heart.circle.fill", color: PracticeColors.bodhicitta.adaptive, size: .medium)
            Text("Bodhicitta")
        }
        HStack(spacing: 12) {
            PracticeIconView("drop.fill", color: PracticeColors.vajrasattva.adaptive, size: .medium)
            Text("Vajrasattva")
        }
        HStack(spacing: 12) {
            PracticeIconView("circle.hexagongrid.fill", color: PracticeColors.mandala.adaptive, size: .medium)
            Text("Mandala")
        }
        HStack(spacing: 12) {
            PracticeIconView("sun.horizon.fill", color: PracticeColors.guruYoga.adaptive, size: .medium)
            Text("Guru Yoga")
        }
    }
    .padding()
}
