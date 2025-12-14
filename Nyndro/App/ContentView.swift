//
//  ContentView.swift
//  Nyndro
//
//  Main content view with tab navigation
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    
    @State private var selectedTab: Tab = .practices
    
    // MARK: - Tabs
    
    enum Tab: String, CaseIterable {
        case practices
        case statistics
        case history
        case settings
        
        var title: String {
            switch self {
            case .practices:
                return L10n.Tab.practices
            case .statistics:
                return L10n.Tab.statistics
            case .history:
                return L10n.Tab.history
            case .settings:
                return L10n.Tab.settings
            }
        }
        
        var icon: String {
            switch self {
            case .practices:
                return "mala"
            case .statistics:
                return "chart.bar.fill"
            case .history:
                return "clock.fill"
            case .settings:
                return "gearshape.fill"
            }
        }
        
        var isSystemImage: Bool {
            switch self {
            case .practices:
                return false
            default:
                return true
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView()
            } else {
                mainTabView
            }
        }
        .onAppear {
            ensureSettingsExist()
        }
    }
    
    // MARK: - Main Tab View
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            PracticeListView()
                .tabItem {
                    Label(Tab.practices.title, image: Tab.practices.icon)
                }
                .tag(Tab.practices)
            
            StatisticsView()
                .tabItem {
                    Label(Tab.statistics.title, systemImage: Tab.statistics.icon)
                }
                .tag(Tab.statistics)
            
            HistoryListView()
                .tabItem {
                    Label(Tab.history.title, systemImage: Tab.history.icon)
                }
                .tag(Tab.history)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.theme.accent)
    }
    
    // MARK: - Helpers
    
    private var shouldShowOnboarding: Bool {
        guard let userSettings = settings.first else { return true }
        return !userSettings.hasCompletedOnboarding
    }
    
    private func ensureSettingsExist() {
        if settings.isEmpty {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Practice.self, HistoryEntry.self, Reminder.self, UserSettings.self], inMemory: true)
}
