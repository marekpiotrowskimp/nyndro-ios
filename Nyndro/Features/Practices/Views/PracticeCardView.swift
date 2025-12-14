//
//  PracticeCardView.swift
//  Nyndro
//
//  Card view for practice in list
//

import SwiftUI

struct PracticeCardView: View {
    let practice: Practice
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack(spacing: Spacing.sm) {
                // Icon
                Image(systemName: practice.imageName)
                    .font(.system(size: 24))
                    .foregroundColor(practice.color)
                    .frame(width: 40, height: 40)
                    .background(practice.color.opacity(0.15))
                    .cornerRadius(Spacing.smallRadius)
                
                // Title and progress
                VStack(alignment: .leading, spacing: 2) {
                    Text(practice.name)
                        .font(Typography.headline)
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(1)
                    
                    Text(practice.formattedProgress)
                        .font(Typography.caption1)
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                // Quick add button
                Button(action: quickAdd) {
                    Text("+\(practice.defaultRepetition)")
                        .font(Typography.subheadline)
                        .foregroundColor(practice.color)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(practice.color.opacity(0.15))
                        .cornerRadius(Spacing.smallRadius)
                }
                .buttonStyle(.plain)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: Spacing.progressBarHeight / 2)
                        .fill(Color.theme.progressEmpty)
                        .frame(height: Spacing.progressBarHeight)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: Spacing.progressBarHeight / 2)
                        .fill(practice.color)
                        .frame(
                            width: geometry.size.width * practice.progressPercentage,
                            height: Spacing.progressBarHeight
                        )
                }
            }
            .frame(height: Spacing.progressBarHeight)
            
            // Footer
            HStack {
                // Percentage
                Text("\(practice.progressPercentageInt)%")
                    .font(Typography.caption1)
                    .foregroundColor(practice.color)
                
                Spacer()
                
                // Last practice date
                if let lastDate = practice.lastPracticeDate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(lastDate.relativeString)
                            .font(Typography.caption2)
                    }
                    .foregroundColor(Color.theme.textTertiary)
                }
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cardRadius)
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Actions
    
    private func quickAdd() {
        _ = practice.addRepetitions(practice.defaultRepetition)
        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    let practice = Practice(
        name: "Vajrasattva",
        descriptionText: "Purification practice",
        imageName: "drop.fill",
        colorId: "vajrasattva",
        progress: 38900,
        maxRepetition: 111111
    )
    
    return PracticeCardView(practice: practice)
        .padding()
        .background(Color.theme.background)
}
