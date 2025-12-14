//
//  CounterView.swift
//  Nyndro
//
//  Full-screen counter mode for practice
//

import SwiftUI
import SwiftData

struct CounterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]
    
    @Bindable var practice: Practice
    
    @State private var sessionCount: Int = 0
    @State private var sessionStartTime: Date = Date()
    @State private var showingExitConfirmation = false
    @State private var tapIncrement: Int = 1
    @State private var showingIncrementPicker = false
    @State private var showingCelebration = false
    
    private var userSettings: UserSettings {
        settings.first ?? UserSettings.default
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - tappable area
                practice.color
                    .ignoresSafeArea()
                    .onTapGesture {
                        incrementCounter()
                    }
                
                VStack {
                    // Header
                    header
                    
                    Spacer()
                    
                    // Main counter display
                    counterDisplay
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControls
                }
                .padding(Spacing.screenHorizontal)
                
                // Celebration overlay
                if showingCelebration {
                    celebrationOverlay
                }
            }
        }
        .statusBar(hidden: true)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            applyScreenSettings()
            tapIncrement = practice.defaultRepetition
        }
        .onDisappear {
            resetScreenSettings()
        }
        .confirmationDialog(
            L10n.Counter.Exit.title,
            isPresented: $showingExitConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.Counter.saveExit) {
                saveAndExit()
            }
            
            Button(L10n.Counter.discard, role: .destructive) {
                dismiss()
            }
            
            Button(L10n.Common.cancel, role: .cancel) { }
        } message: {
            Text(String(format: L10n.Counter.Exit.message, "\(sessionCount)"))
        }
        .sheet(isPresented: $showingIncrementPicker) {
            IncrementPickerSheet(
                selectedIncrement: $tapIncrement,
                defaultValue: practice.defaultRepetition
            )
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            // Close button
            Button(action: { handleExit() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Practice name
            VStack(spacing: Spacing.xxs) {
                Text(practice.name)
                    .font(Typography.headline)
                    .foregroundColor(.white)
                
                Text(String(format: L10n.Counter.sessionCount, "\(sessionCount)"))
                    .font(Typography.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Settings button
            Button(action: { showingIncrementPicker = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Counter Display
    
    private var counterDisplay: some View {
        VStack(spacing: Spacing.lg) {
            // Total progress
            Text(practice.progress.formatted())
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: practice.progress)
            
            // Progress indicator
            Text(practice.formattedProgress)
                .font(Typography.title3)
                .foregroundColor(.white.opacity(0.8))
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: geometry.size.width * practice.progressPercentage)
                        .animation(.spring(response: 0.3), value: practice.progressPercentage)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, Spacing.xl)
            
            // Tap instruction
            Text(L10n.Counter.tapAnywhere)
                .font(Typography.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, Spacing.md)
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        HStack(spacing: Spacing.xl) {
            // Subtract button
            CounterControlButton(
                icon: "minus",
                label: "-\(tapIncrement)"
            ) {
                decrementCounter()
            }
            
            // Center - shows current increment
            VStack(spacing: Spacing.xxs) {
                Text("+\(tapIncrement)")
                    .font(Typography.largeTitle)
                    .foregroundColor(.white)
                
                Text(L10n.Counter.perTap)
                    .font(Typography.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(minWidth: 100)
            
            // Quick increment buttons
            CounterControlButton(
                icon: "plus",
                label: "+\(tapIncrement)"
            ) {
                incrementCounter()
            }
        }
        .padding(.bottom, Spacing.lg)
    }
    
    // MARK: - Celebration Overlay
    
    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                Image(systemName: "star.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.yellow)
                
                Text(L10n.Counter.milestone)
                    .font(Typography.title1)
                    .foregroundColor(.white)
                
                Text("\(practice.progress.formatted()) " + L10n.Counter.repetitions)
                    .font(Typography.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                Button(action: { showingCelebration = false }) {
                    Text(L10n.Common.continue)
                        .font(Typography.headline)
                        .foregroundColor(practice.color)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.md)
                        .background(.white)
                        .cornerRadius(Spacing.buttonRadius)
                }
                .padding(.top, Spacing.md)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Actions
    
    private func incrementCounter() {
        let previousProgress = practice.progress
        sessionCount += tapIncrement
        practice.progress += tapIncrement
        
        // Check for milestones
        checkMilestone(previousProgress: previousProgress)
        
        // Feedback
        playSound()
        triggerHaptic()
    }
    
    private func decrementCounter() {
        guard sessionCount >= tapIncrement else { return }
        sessionCount -= tapIncrement
        practice.subtractRepetitions(tapIncrement)
        triggerHaptic()
    }
    
    private func handleExit() {
        if sessionCount > 0 {
            showingExitConfirmation = true
        } else {
            dismiss()
        }
    }
    
    private func saveAndExit() {
        // Create history entry for the session
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        
        let entry = HistoryEntry(
            practice: practice,
            progressSnapshot: practice.progress,
            repetitionAdded: sessionCount,
            practiceDate: Date(),
            note: nil,
            sessionDuration: sessionDuration
        )
        
        practice.history.append(entry)
        try? modelContext.save()
        
        dismiss()
    }
    
    private func checkMilestone(previousProgress: Int) {
        let newProgress = practice.progress
        
        // Check percentage milestones
        for milestone in Constants.progressMilestones {
            let threshold = Int(Double(practice.maxRepetition) * Double(milestone) / 100.0)
            if previousProgress < threshold && newProgress >= threshold {
                withAnimation {
                    showingCelebration = true
                }
                break
            }
        }
    }
    
    // MARK: - Audio & Haptics
    
    private func playSound() {
        SoundService.shared.play(sound: userSettings.counterSound)
    }
    
    private func triggerHaptic() {
        switch userSettings.hapticStyle {
        case .none: break
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
    
    private func applyScreenSettings() {
        if userSettings.keepScreenAwake {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    private func resetScreenSettings() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

// MARK: - Counter Control Button

struct CounterControlButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                
                Text(label)
                    .font(Typography.caption)
            }
            .foregroundColor(.white)
            .frame(width: 70, height: 70)
            .background(.white.opacity(0.2))
            .cornerRadius(Spacing.cardRadius)
        }
    }
}

// MARK: - Increment Picker Sheet

struct IncrementPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIncrement: Int
    let defaultValue: Int
    
    @State private var customValue: String = ""
    
    private let commonIncrements = [1, 21, 27, 54, 108, 216]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(commonIncrements, id: \.self) { value in
                        Button(action: {
                            selectedIncrement = value
                            dismiss()
                        }) {
                            HStack {
                                Text("+\(value)")
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                if value == defaultValue {
                                    Text(L10n.Counter.default)
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                
                                Spacer()
                                
                                if selectedIncrement == value {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.theme.accent)
                                }
                            }
                        }
                    }
                } header: {
                    Text(L10n.Counter.commonValues)
                }
                
                Section {
                    HStack {
                        TextField(L10n.Counter.customValue, text: $customValue)
                            .keyboardType(.numberPad)
                        
                        if !customValue.isEmpty, let value = Int(customValue), value > 0 {
                            Button(L10n.Common.set) {
                                selectedIncrement = value
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } header: {
                    Text(L10n.Counter.custom)
                }
            }
            .navigationTitle(L10n.Counter.tapValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    CounterView(practice: Practice(
        name: "Refuge",
        descriptionText: "Taking refuge",
        colorId: "refuge",
        progress: 5000,
        maxRepetition: 111111
    ))
    .modelContainer(for: [Practice.self, HistoryEntry.self, UserSettings.self], inMemory: true)
}
