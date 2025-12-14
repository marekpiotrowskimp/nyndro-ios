//
//  OnboardingView.swift
//  Nyndro
//
//  Onboarding screens for new users
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Nyndro",
            titleLocalized: L10n.Onboarding.Welcome.title,
            subtitle: L10n.Onboarding.Welcome.subtitle,
            imageName: "mala_icon",
            color: Color(hex: "#FF9933")
        ),
        OnboardingPage(
            title: "Track Your Progress",
            titleLocalized: L10n.Onboarding.Progress.title,
            subtitle: L10n.Onboarding.Progress.subtitle,
            imageName: "chart.line.uptrend.xyaxis",
            color: Color(hex: "#4ECDC4")
        ),
        OnboardingPage(
            title: "Easy Counting",
            titleLocalized: L10n.Onboarding.Counter.title,
            subtitle: L10n.Onboarding.Counter.subtitle,
            imageName: "hand.tap.fill",
            color: Color(hex: "#9B72CF")
        ),
        OnboardingPage(
            title: "Smart Predictions",
            titleLocalized: L10n.Onboarding.Prediction.title,
            subtitle: L10n.Onboarding.Prediction.subtitle,
            imageName: "calendar.badge.clock",
            color: Color(hex: "#D4AF37")
        ),
        OnboardingPage(
            title: "Stay on Track",
            titleLocalized: L10n.Onboarding.Reminders.title,
            subtitle: L10n.Onboarding.Reminders.subtitle,
            imageName: "bell.fill",
            color: Color(hex: "#E85D75")
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Bottom section
            VStack(spacing: Spacing.lg) {
                // Page indicators
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? pages[currentPage].color : Color.theme.progressEmpty)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                
                // Button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage < pages.count - 1 
                         ? L10n.Onboarding.next
                         : L10n.Onboarding.getStarted)
                        .font(Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(pages[currentPage].color)
                        .cornerRadius(Spacing.buttonRadius)
                }
                
                // Skip button (except on last page)
                if currentPage < pages.count - 1 {
                    Button(action: completeOnboarding) {
                        Text(L10n.Onboarding.skip)
                            .font(Typography.subheadline)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.theme.background)
    }
    
    private func completeOnboarding() {
        if let userSettings = settings.first {
            userSettings.hasCompletedOnboarding = true
            try? modelContext.save()
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let title: String
    let titleLocalized: String
    let subtitle: String
    let imageName: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 160, height: 160)
                
                // SF Symbols contain ".", asset images don't
                if page.imageName.contains(".") {
                    Image(systemName: page.imageName)
                        .font(.system(size: 64))
                        .foregroundColor(page.color)
                } else {
                    Image(page.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
            }
            
            // Text
            VStack(spacing: Spacing.md) {
                Text(page.titleLocalized)
                    .font(Typography.title1)
                    .foregroundColor(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(Typography.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, Spacing.screenHorizontal)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .modelContainer(for: UserSettings.self, inMemory: true)
}
