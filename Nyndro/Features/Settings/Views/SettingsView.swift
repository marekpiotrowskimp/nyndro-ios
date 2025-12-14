//
//  SettingsView.swift
//  Nyndro
//
//  App settings view
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    
    @State private var showingExportOptions = false
    @State private var showingImportPicker = false
    @State private var showingResetConfirmation = false
    
    private var userSettings: UserSettings {
        settings.first ?? UserSettings.default
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                settingsContent
            }
            .navigationTitle(L10n.Tab.settings)
        }
    }
    
    // MARK: - Settings Content
    
    private var settingsContent: some View {
        List {
            // Appearance Section
            Section {
                progressStylePicker
                
                Toggle(L10n.Settings.keepScreenAwake, isOn: Binding(
                    get: { userSettings.keepScreenAwake },
                    set: { newValue in
                        userSettings.keepScreenAwake = newValue
                        try? modelContext.save()
                    }
                ))
            } header: {
                Text(L10n.Settings.Section.appearance)
            }
            
            // Counter Section
            Section {
                soundPicker
                hapticPicker
            } header: {
                Text(L10n.Settings.Section.counter)
            }
            
            // Data Section
            Section {
                Button(action: { showingExportOptions = true }) {
                    Label(L10n.Settings.exportData, systemImage: "square.and.arrow.up")
                }
                
                Button(action: { showingImportPicker = true }) {
                    Label(L10n.Settings.importData, systemImage: "square.and.arrow.down")
                }
            } header: {
                Text(L10n.Settings.Section.data)
            }
            
            // About Section
            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    Label(L10n.Settings.about, systemImage: "info.circle")
                }
            } header: {
                Text(L10n.Settings.Section.about)
            }
            
            // Danger Zone
            Section {
                Button(role: .destructive, action: { showingResetConfirmation = true }) {
                    Label(L10n.Settings.resetAllData, systemImage: "trash")
                }
            } header: {
                Text(L10n.Settings.Section.danger)
            } footer: {
                Text(L10n.Settings.resetWarning)
            }
            
            // App Version
            Section {
                HStack {
                    Text(L10n.Settings.version)
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .confirmationDialog(
            L10n.Settings.exportTitle,
            isPresented: $showingExportOptions,
            titleVisibility: .visible
        ) {
            Button(L10n.Settings.exportJson) {
                exportData(format: .json)
            }
            Button(L10n.Settings.exportCsv) {
                exportData(format: .csv)
            }
            Button(L10n.Common.cancel, role: .cancel) { }
        }
        .alert(L10n.Settings.resetConfirmationTitle, isPresented: $showingResetConfirmation) {
            Button(L10n.Common.cancel, role: .cancel) { }
            Button(L10n.Settings.resetConfirm, role: .destructive) {
                resetAllData()
            }
        } message: {
            Text(L10n.Settings.resetConfirmationMessage)
        }
    }
    
    // MARK: - Progress Style Picker
    
    private var progressStylePicker: some View {
        Picker(L10n.Settings.progressStyle, selection: Binding(
            get: { userSettings.progressBarStyle },
            set: { newValue in
                userSettings.progressBarStyle = newValue
                try? modelContext.save()
            }
        )) {
            ForEach(ProgressBarStyle.allCases, id: \.self) { style in
                HStack {
                    if style.isSystemIcon {
                        Image(systemName: style.icon)
                    } else {
                        Image(style.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                    Text(style.displayName)
                }
                .tag(style)
            }
        }
        .pickerStyle(.menu)
    }
    
    // MARK: - Sound Picker
    
    private var soundPicker: some View {
        Picker(L10n.Settings.counterSound, selection: Binding(
            get: { userSettings.counterSound },
            set: { newValue in
                userSettings.counterSound = newValue
                try? modelContext.save()
                // Play preview sound
                playPreviewSound(newValue)
            }
        )) {
            ForEach(CounterSound.allCases, id: \.self) { sound in
                HStack {
                    Image(systemName: sound.icon)
                    Text(sound.displayName)
                }
                .tag(sound)
            }
        }
    }
    
    // MARK: - Haptic Picker
    
    private var hapticPicker: some View {
        Picker(L10n.Settings.hapticFeedback, selection: Binding(
            get: { userSettings.hapticStyle },
            set: { newValue in
                userSettings.hapticStyle = newValue
                try? modelContext.save()
                // Trigger preview haptic
                triggerPreviewHaptic(newValue)
            }
        )) {
            ForEach(HapticStyle.allCases, id: \.self) { style in
                HStack {
                    Image(systemName: style.icon)
                    Text(style.displayName)
                }
                .tag(style)
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    // MARK: - Actions
    
    private func exportData(format: ExportFormat) {
        // TODO: Implement export functionality
        print("Exporting data as \(format)")
    }
    
    private func resetAllData() {
        // Delete all practices (cascades to history and reminders)
        let practiceDescriptor = FetchDescriptor<Practice>()
        if let practices = try? modelContext.fetch(practiceDescriptor) {
            for practice in practices {
                modelContext.delete(practice)
            }
        }
        
        // Reset settings
        if let currentSettings = settings.first {
            currentSettings.hasCompletedOnboarding = false
            currentSettings.progressBarStyle = .lotus
            currentSettings.counterSound = .none
            currentSettings.hapticStyle = .medium
            currentSettings.keepScreenAwake = true
        }
        
        try? modelContext.save()
    }
    
    private func playPreviewSound(_ sound: CounterSound) {
        SoundService.shared.play(sound: sound)
    }
    
    private func triggerPreviewHaptic(_ style: HapticStyle) {
        switch style {
        case .none:
            break
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}

// MARK: - Export Format

enum ExportFormat {
    case json
    case csv
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // App Icon
                Image("mala_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(.top, Spacing.xl)
                
                // App Name
                Text("Nyndro")
                    .font(Typography.largeTitle)
                    .foregroundColor(Color.theme.textPrimary)
                
                // Description
                Text(L10n.About.description)
                    .font(Typography.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                
                Divider()
                    .padding(.horizontal, Spacing.xl)
                
                // Credits
                VStack(spacing: Spacing.sm) {
                    Text(L10n.About.madeWithLove)
                        .font(Typography.subheadline)
                        .foregroundColor(Color.theme.textSecondary)
                    
                    Text(L10n.About.dedication)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textTertiary)
                        .italic()
                }
                .padding(.bottom, Spacing.xl)
                
                Spacer()
            }
        }
        .background(Color.theme.background)
        .navigationTitle(L10n.Settings.about)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(for: [Practice.self, UserSettings.self], inMemory: true)
}
