//
//  SettingsView.swift
//  Nyndro
//
//  App settings view with export/import functionality
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    
    @State private var showingExportOptions = false
    @State private var showingImportPicker = false
    @State private var showingResetConfirmation = false
    @State private var showingExportShare = false
    @State private var showingImportModeSelection = false
    @State private var exportFileURL: URL?
    @State private var importFileData: Data?
    @State private var selectedImportMode: ImportMode = .merge
    
    // Export/Import state
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportError: String?
    @State private var importError: String?
    @State private var importResult: ImportResult?
    @State private var showingImportResult = false
    @State private var showingExportError = false
    @State private var showingImportError = false
    
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
                    HStack {
                        Label(L10n.Settings.exportData, systemImage: "square.and.arrow.up")
                        Spacer()
                        if isExporting {
                            ProgressView()
                        }
                    }
                }
                .disabled(isExporting)
                
                Button(action: { showingImportPicker = true }) {
                    HStack {
                        Label(L10n.Settings.importData, systemImage: "square.and.arrow.down")
                        Spacer()
                        if isImporting {
                            ProgressView()
                        }
                    }
                }
                .disabled(isImporting)
            } header: {
                Text(L10n.Settings.Section.data)
            } footer: {
                Text(L10n.Settings.dataFooter)
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
        // Export format selection
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
        } message: {
            Text(L10n.Settings.exportMessage)
        }
        // Import file picker
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportFileSelection(result)
        }
        // Import mode selection
        .confirmationDialog(
            L10n.Settings.importTitle,
            isPresented: $showingImportModeSelection,
            titleVisibility: .visible
        ) {
            Button(ImportMode.merge.displayName) {
                selectedImportMode = .merge
                performImport()
            }
            Button(ImportMode.replace.displayName) {
                selectedImportMode = .replace
                performImport()
            }
            Button(L10n.Common.cancel, role: .cancel) {
                importFileData = nil
            }
        } message: {
            Text(L10n.Settings.importModeMessage)
        }
        // Share sheet for export
        .sheet(isPresented: $showingExportShare) {
            if let url = exportFileURL {
                ShareSheet(activityItems: [url])
            }
        }
        // Reset confirmation
        .alert(L10n.Settings.resetConfirmationTitle, isPresented: $showingResetConfirmation) {
            Button(L10n.Common.cancel, role: .cancel) { }
            Button(L10n.Settings.resetConfirm, role: .destructive) {
                resetAllData()
            }
        } message: {
            Text(L10n.Settings.resetConfirmationMessage)
        }
        // Export error
        .alert(L10n.Settings.exportError, isPresented: $showingExportError) {
            Button(L10n.Common.done) { }
        } message: {
            Text(exportError ?? "Unknown error")
        }
        // Import error
        .alert(L10n.Settings.importError, isPresented: $showingImportError) {
            Button(L10n.Common.done) { }
        } message: {
            Text(importError ?? "Unknown error")
        }
        // Import result
        .alert(L10n.Settings.importSuccess, isPresented: $showingImportResult) {
            Button(L10n.Common.done) { }
        } message: {
            Text(importResult?.summary ?? "")
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
                Text(style.displayName)
                    .tag(style)
            }
        }
    }
    
    // MARK: - Sound Picker
    
    private var soundPicker: some View {
        Picker(L10n.Settings.counterSound, selection: Binding(
            get: { userSettings.counterSound },
            set: { newValue in
                userSettings.counterSound = newValue
                try? modelContext.save()
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
    
    // MARK: - Export Actions
    
    private func exportData(format: ExportFormat) {
        isExporting = true
        
        Task {
            do {
                let exportService = ExportService(modelContext: modelContext)
                let fileURL = try exportService.createExportFile(format: format)
                
                await MainActor.run {
                    exportFileURL = fileURL
                    isExporting = false
                    showingExportShare = true
                }
            } catch {
                await MainActor.run {
                    exportError = error.localizedDescription
                    isExporting = false
                    showingExportError = true
                }
            }
        }
    }
    
    // MARK: - Import Actions
    
    private func handleImportFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Read file data
            do {
                // Request access to the file
                guard url.startAccessingSecurityScopedResource() else {
                    importError = "Cannot access file"
                    showingImportError = true
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                importFileData = try Data(contentsOf: url)
                showingImportModeSelection = true
            } catch {
                importError = error.localizedDescription
                showingImportError = true
            }
            
        case .failure(let error):
            importError = error.localizedDescription
            showingImportError = true
        }
    }
    
    private func performImport() {
        guard let data = importFileData else { return }
        
        isImporting = true
        
        Task {
            do {
                let importService = ImportService(modelContext: modelContext)
                let result = try importService.importFromJSON(data, mode: selectedImportMode)
                
                await MainActor.run {
                    importResult = result
                    isImporting = false
                    importFileData = nil
                    showingImportResult = true
                }
            } catch {
                await MainActor.run {
                    importError = error.localizedDescription
                    isImporting = false
                    importFileData = nil
                    showingImportError = true
                }
            }
        }
    }
    
    // MARK: - Reset Actions
    
    private func resetAllData() {
        // Cancel all notifications
        NotificationService.shared.removeAllPendingNotifications()
        
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
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
                Text(L10n.App.name)
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

// MARK: - L10n Extensions for Settings

extension L10n.Settings {
    static let dataFooter = "settings.data_footer".localized(default: "Export your data as a backup or to transfer to another device")
    static let exportMessage = "settings.export_message".localized(default: "Choose a format for export")
    static let importTitle = "settings.import_title".localized(default: "Import Data")
    static let importModeMessage = "settings.import_mode_message".localized(default: "How would you like to import the data?")
    static let exportError = "settings.export_error".localized(default: "Export Failed")
    static let importError = "settings.import_error".localized(default: "Import Failed")
    static let importSuccess = "settings.import_success".localized(default: "Import Successful")
}

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(for: [Practice.self, UserSettings.self], inMemory: true)
}
