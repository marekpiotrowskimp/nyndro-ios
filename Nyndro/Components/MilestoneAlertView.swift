//
//  MilestoneAlertView.swift
//  Nyndro
//
//  Alert view shown when user achieves a milestone
//

import SwiftUI

/// Alert view shown when user achieves a milestone
struct MilestoneAlertView: View {
    let achievement: MilestoneAchievement
    let onDismiss: () -> Void
    
    @State private var animateConfetti = false
    @State private var animateScale = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Content card
            VStack(spacing: Spacing.lg) {
                // Celebration icon
                celebrationIcon
                
                // Title
                Text(achievement.type.displayName)
                    .font(Typography.largeTitle)
                    .foregroundColor(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Value if applicable
                if let displayValue = achievement.displayValue {
                    Text(displayValue)
                        .font(Typography.headline)
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                // Practice name
                Text(achievement.practice.name)
                    .font(Typography.title3)
                    .foregroundColor(achievement.practice.color)
                
                // Dismiss button
                Button(action: onDismiss) {
                    Text(L10n.Common.done)
                        .font(Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(milestoneColor)
                        .cornerRadius(Spacing.buttonRadius)
                }
                .padding(.top, Spacing.md)
            }
            .padding(Spacing.xl)
            .background(Color.theme.cardBackground)
            .cornerRadius(Spacing.cardRadius)
            .shadow(color: Color.theme.shadow, radius: 20, x: 0, y: 10)
            .padding(.horizontal, Spacing.xl)
            .scaleEffect(animateScale ? 1.0 : 0.8)
            .opacity(animateScale ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateScale = true
            }
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                animateConfetti = true
            }
        }
    }
    
    // MARK: - Milestone Color
    
    private var milestoneColor: Color {
        switch achievement.type {
        case .personalBest:
            return Color.theme.accentSecondary
        case .streak7, .streak21, .streak30, .streak100, .streak365:
            return Color.theme.warning
        case .progress50, .completed:
            return Color.theme.success
        case .progress25, .progress75, .progress90:
            return Color.theme.info
        }
    }
    
    // MARK: - Celebration Icon
    
    @ViewBuilder
    private var celebrationIcon: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            milestoneColor.opacity(0.3),
                            milestoneColor.opacity(0)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(animateConfetti ? 1.2 : 1.0)
            
            // Icon circle
            Circle()
                .fill(milestoneColor.opacity(0.15))
                .frame(width: 80, height: 80)
            
            // Icon
            Image(systemName: achievement.type.icon)
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(milestoneColor)
        }
    }
}

// MARK: - Preview

#Preview("Personal Best") {
    MilestoneAlertView(
        achievement: MilestoneAchievement(
            type: .personalBest,
            practice: Practice(
                name: "Refuge",
                descriptionText: "Test",
                colorId: "refuge",
                progress: 5000,
                maxRepetition: 111111
            ),
            achievedAt: Date(),
            value: 432
        ),
        onDismiss: {}
    )
}

#Preview("Streak 30") {
    MilestoneAlertView(
        achievement: MilestoneAchievement(
            type: .streak30,
            practice: Practice(
                name: "Mandala",
                descriptionText: "Test",
                colorId: "mandala",
                progress: 10000,
                maxRepetition: 111111
            ),
            achievedAt: Date(),
            value: 30
        ),
        onDismiss: {}
    )
}

#Preview("50% Complete") {
    MilestoneAlertView(
        achievement: MilestoneAchievement(
            type: .progress50,
            practice: Practice(
                name: "Vajrasattva",
                descriptionText: "Test",
                colorId: "vajrasattva",
                progress: 55555,
                maxRepetition: 111111
            ),
            achievedAt: Date(),
            value: 50
        ),
        onDismiss: {}
    )
}

#Preview("Completed") {
    MilestoneAlertView(
        achievement: MilestoneAchievement(
            type: .completed,
            practice: Practice(
                name: "Guru Yoga",
                descriptionText: "Test",
                colorId: "guru_yoga",
                progress: 111111,
                maxRepetition: 111111
            ),
            achievedAt: Date(),
            value: 100
        ),
        onDismiss: {}
    )
}
