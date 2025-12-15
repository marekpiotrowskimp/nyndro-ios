//
//  EmptyStateView.swift
//  Nyndro
//
//  Reusable empty state view component
//

import SwiftUI

/// A reusable empty state view that displays an icon, title, message, and optional action button
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(Color.theme.textTertiary)
            
            // Title
            Text(title)
                .font(Typography.title2)
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(Typography.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            // Optional action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Typography.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.md)
                        .background(Color.theme.accent)
                        .cornerRadius(Spacing.buttonRadius)
                }
                .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Convenience initializers

extension EmptyStateView {
    /// Empty state for practices list
    static func practices(addAction: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "leaf.circle",
            title: L10n.Empty.Practices.title,
            message: L10n.Empty.Practices.message,
            actionTitle: L10n.Practice.add,
            action: addAction
        )
    }
    
    /// Empty state for history list
    static var history: EmptyStateView {
        EmptyStateView(
            icon: "clock.arrow.circlepath",
            title: L10n.Empty.History.title,
            message: L10n.Empty.History.message
        )
    }
    
    /// Empty state for statistics
    static var statistics: EmptyStateView {
        EmptyStateView(
            icon: "chart.bar",
            title: L10n.Empty.Statistics.title,
            message: L10n.Empty.Statistics.message
        )
    }
}

// MARK: - Preview

#Preview("Empty State - Practices") {
    EmptyStateView.practices {
        print("Add practice")
    }
}

#Preview("Empty State - History") {
    EmptyStateView.history
}

#Preview("Empty State - Statistics") {
    EmptyStateView.statistics
}
