//
//  PracticeDetailView.swift
//  Nyndro
//
//  Detailed view for a single practice with counter and history
//

import SwiftUI
import SwiftData

struct PracticeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]
    
    @Bindable var practice: Practice
    
    @State private var showingCounter = false
    @State private var showingEditSheet = false
    @State private var showingAddManual = false
    @State private var manualCount: String = ""
    @State private var manualNote: String = ""
    
    private var userSettings: UserSettings {
        settings.first ?? UserSettings.default
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Progress Card
                progressCard
                
                // Quick Actions
                quickActions
                
                // Recent History
                recentHistory
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.theme.background)
        .navigationTitle(practice.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label(L10n.Common.edit, systemImage: "pencil")
                    }
                    
                    Button(action: { showingAddManual = true }) {
                        Label(L10n.Practice.addManual, systemImage: "plus.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .fullScreenCover(isPresented: $showingCounter) {
            CounterView(practice: practice)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPracticeSheet(practice: practice)
        }
        .alert(L10n.Practice.addManual, isPresented: $showingAddManual) {
            TextField(L10n.Practice.count, text: $manualCount)
                .keyboardType(.numberPad)
            TextField(L10n.Practice.note, text: $manualNote)
            
            Button(L10n.Common.cancel, role: .cancel) {
                manualCount = ""
                manualNote = ""
            }
            
            Button(L10n.Common.add) {
                if let count = Int(manualCount), count > 0 {
                    _ = practice.addRepetitions(count, note: manualNote.isEmpty ? nil : manualNote)
                    try? modelContext.save()
                }
                manualCount = ""
                manualNote = ""
            }
        } message: {
            Text(L10n.Practice.AddManual.message)
        }
    }
    
    // MARK: - Progress Card
    
    private var progressCard: some View {
        VStack(spacing: Spacing.lg) {
            // Progress visualization based on user settings
            progressVisualization
            
            // Stats row
            HStack {
                StatItem(
                    value: practice.progress.formatted(),
                    label: L10n.Statistics.completed
                )
                
                Spacer()
                
                StatItem(
                    value: practice.remaining.formatted(),
                    label: L10n.Statistics.remaining
                )
                
                Spacer()
                
                StatItem(
                    value: "\(practice.progressPercentageInt)%",
                    label: L10n.Statistics.progress
                )
            }
            
            // Start Practice Button
            Button(action: { showingCounter = true }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text(L10n.Practice.startSession)
                }
                .font(Typography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(practice.color)
                .cornerRadius(Spacing.buttonRadius)
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cardRadius)
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Progress Visualization
    
    @ViewBuilder
    private var progressVisualization: some View {
        switch userSettings.progressBarStyle {
        case .lotus:
            LotusProgressView(
                progress: practice.progressPercentage,
                color: practice.color
            )
            .frame(height: 200)
            
        case .mala:
            MalaProgressView(
                progress: practice.progressPercentage,
                color: practice.color
            )
            .frame(height: 200)
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        HStack(spacing: Spacing.md) {
            QuickActionButton(
                title: "+\(practice.defaultRepetition)",
                icon: "plus",
                color: practice.color
            ) {
                addQuickRepetitions(practice.defaultRepetition)
            }
            
            QuickActionButton(
                title: "+1",
                icon: "hand.tap",
                color: Color.theme.accentSecondary
            ) {
                addQuickRepetitions(1)
            }
            
            QuickActionButton(
                title: L10n.Practice.custom,
                icon: "number",
                color: Color.theme.info
            ) {
                showingAddManual = true
            }
        }
    }
    
    // MARK: - Recent History
    
    private var recentHistory: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(L10n.Practice.recentHistory)
                    .font(Typography.headline)
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: PracticeHistoryView(practice: practice)) {
                    Text(L10n.Common.seeAll)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.accent)
                }
            }
            
            if practice.history.isEmpty {
                Text(L10n.Practice.noHistory)
                    .font(Typography.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.lg)
            } else {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(practice.history.sorted(by: >).prefix(5)) { entry in
                        RecentHistoryRow(entry: entry)
                    }
                }
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cardRadius)
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Actions
    
    private func addQuickRepetitions(_ count: Int) {
        _ = practice.addRepetitions(count)
        try? modelContext.save()
        
        // Haptic feedback
        triggerHaptic()
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
}

// MARK: - Supporting Views

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Text(value)
                .font(Typography.title2)
                .foregroundColor(Color.theme.textPrimary)
            
            Text(label)
                .font(Typography.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(Typography.caption)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(color.opacity(0.1))
            .cornerRadius(Spacing.cardRadius)
        }
    }
}

struct RecentHistoryRow: View {
    let entry: HistoryEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(entry.formattedDateTime)
                    .font(Typography.body)
                    .foregroundColor(Color.theme.textPrimary)
                
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("+\(entry.repetitionAdded)")
                .font(Typography.headline)
                .foregroundColor(Color.theme.accent)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Lotus Progress View (Placeholder)

struct LotusProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(Color.theme.lotusWater)
            
            // Progress circle as placeholder for lotus
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(20)
            
            // Center content
            VStack(spacing: Spacing.xs) {
                Image("mala_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text("\(Int(progress * 100))%")
                    .font(Typography.largeTitle)
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - Mala Progress View (Placeholder)

struct MalaProgressView: View {
    let progress: Double
    let color: Color
    
    private let beadCount = 108
    
    var body: some View {
        ZStack {
            // Beads circle
            ForEach(0..<beadCount, id: \.self) { index in
                let angle = Double(index) / Double(beadCount) * 360
                let isFilled = Double(index) / Double(beadCount) <= progress
                
                Circle()
                    .fill(isFilled ? color : Color.theme.malaBeadEmpty)
                    .frame(width: 6, height: 6)
                    .offset(y: -80)
                    .rotationEffect(.degrees(angle))
            }
            
            // Center content
            VStack(spacing: Spacing.xs) {
                Text("\(Int(progress * Double(beadCount)))")
                    .font(Typography.largeTitle)
                    .foregroundColor(color)
                
                Text("/ \(beadCount)")
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
    }
}

// MARK: - Edit Practice Sheet

struct EditPracticeSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var practice: Practice
    
    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var maxRepetition: Int = 111111
    @State private var defaultRepetition: Int = 108
    @State private var selectedColorId: String = "custom"
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L10n.Practice.Name.placeholder, text: $name)
                    
                    TextField(L10n.Practice.Description.placeholder, text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Stepper(value: $maxRepetition, in: 1...10000000, step: 1000) {
                        HStack {
                            Text(L10n.Practice.Goal.title)
                            Spacer()
                            Text(maxRepetition.formatted())
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                    
                    Stepper(value: $defaultRepetition, in: 1...1000, step: 1) {
                        HStack {
                            Text(L10n.Practice.DefaultRepetitions.title)
                            Spacer()
                            Text("\(defaultRepetition)")
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
                
                if !practice.isPredefined {
                    Section {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: Spacing.md) {
                            ForEach(PracticeColors.allColorIds, id: \.self) { colorId in
                                Button(action: { selectedColorId = colorId }) {
                                    ZStack {
                                        Circle()
                                            .fill(PracticeColors.adaptiveColor(for: colorId))
                                            .frame(width: 36, height: 36)
                                        
                                        if selectedColorId == colorId {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, Spacing.sm)
                    } header: {
                        Text(L10n.Practice.Section.color)
                    }
                }
            }
            .navigationTitle(L10n.Practice.edit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) {
                        savePractice()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                name = practice.name
                descriptionText = practice.descriptionText
                maxRepetition = practice.maxRepetition
                defaultRepetition = practice.defaultRepetition
                selectedColorId = practice.colorId
            }
        }
    }
    
    private func savePractice() {
        practice.name = name.trimmingCharacters(in: .whitespaces)
        practice.descriptionText = descriptionText.trimmingCharacters(in: .whitespaces)
        practice.maxRepetition = maxRepetition
        practice.defaultRepetition = defaultRepetition
        
        if !practice.isPredefined {
            practice.colorId = selectedColorId
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Practice History View

struct PracticeHistoryView: View {
    let practice: Practice
    
    var sortedHistory: [HistoryEntry] {
        practice.history.sorted(by: >)
    }
    
    var body: some View {
        List {
            ForEach(sortedHistory) { entry in
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(entry.formattedDateTime)
                            .font(Typography.body)
                        
                        if let note = entry.note, !note.isEmpty {
                            Text(note)
                                .font(Typography.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        
                        if let duration = entry.formattedDuration {
                            Text(L10n.Practice.duration(duration))
                                .font(Typography.caption)
                                .foregroundColor(Color.theme.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("+\(entry.repetitionAdded)")
                        .font(Typography.headline)
                        .foregroundColor(practice.color)
                }
            }
        }
        .navigationTitle(L10n.Tab.history)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PracticeDetailView(practice: Practice(
            name: "Refuge",
            descriptionText: "Taking refuge in Buddha, Dharma, Sangha",
            colorId: "refuge",
            progress: 5000,
            maxRepetition: 111111
        ))
    }
    .modelContainer(for: [Practice.self, HistoryEntry.self, UserSettings.self], inMemory: true)
}
