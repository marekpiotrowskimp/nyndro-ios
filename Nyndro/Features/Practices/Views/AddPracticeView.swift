//
//  AddPracticeView.swift
//  Nyndro
//
//  View for adding a new practice (predefined or custom)
//

import SwiftUI
import SwiftData

struct AddPracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Practice> { $0.isActive }, sort: \Practice.order)
    private var existingPractices: [Practice]
    
    @State private var selectedTab: AddPracticeTab = .predefined
    @State private var customName: String = ""
    @State private var customDescription: String = ""
    @State private var customGoal: Int = Constants.defaultMaxRepetition
    @State private var customDefaultReps: Int = Constants.defaultRepetition
    @State private var selectedColorId: String = "custom"
    @State private var showingGoalPicker = false
    
    private let predefinedPractices = PredefinedPracticesLoader.load()
    
    enum AddPracticeTab: String, CaseIterable {
        case predefined
        case custom
        
        var title: String {
            switch self {
            case .predefined:
                return L10n.Practice.Add.predefined
            case .custom:
                return L10n.Practice.Add.custom
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("", selection: $selectedTab) {
                    ForEach(AddPracticeTab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.md)
                
                // Content
                switch selectedTab {
                case .predefined:
                    predefinedContent
                case .custom:
                    customContent
                }
            }
            .background(Color.theme.background)
            .navigationTitle(L10n.Practice.add)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
                
                if selectedTab == .custom {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(L10n.Common.save) {
                            saveCustomPractice()
                        }
                        .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }
    
    // MARK: - Predefined Content
    
    private var predefinedContent: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(predefinedPractices.filter { !isPracticeAlreadyAdded($0) }) { practice in
                    PredefinedPracticeCard(practice: practice) {
                        addPredefinedPractice(practice)
                    }
                }
                
                // Show message if all predefined practices are added
                if predefinedPractices.allSatisfy({ isPracticeAlreadyAdded($0) }) {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(Color.theme.success)
                        
                        Text(L10n.Practice.Add.allAdded)
                            .font(Typography.body)
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text(L10n.Practice.Add.tryCustom)
                            .font(Typography.caption)
                            .foregroundColor(Color.theme.textTertiary)
                    }
                    .padding(.vertical, Spacing.xl)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.md)
        }
    }
    
    // MARK: - Custom Content
    
    private var customContent: some View {
        Form {
            // Name Section
            Section {
                TextField(L10n.Practice.Name.placeholder, text: $customName)
                
                TextField(L10n.Practice.Description.placeholder, text: $customDescription, axis: .vertical)
                    .lineLimit(3...6)
            } header: {
                Text(L10n.Practice.Section.details)
            }
            
            // Goal Section
            Section {
                Button(action: { showingGoalPicker = true }) {
                    HStack {
                        Text(L10n.Practice.Goal.title)
                        Spacer()
                        Text(customGoal.formatted())
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                
                Stepper(value: $customDefaultReps, in: 1...1000, step: 1) {
                    HStack {
                        Text(L10n.Practice.DefaultRepetitions.title)
                        Spacer()
                        Text("\(customDefaultReps)")
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
            } header: {
                Text(L10n.Practice.Section.goal)
            } footer: {
                Text(L10n.Practice.DefaultRepetitions.footer)
            }
            
            // Color Section
            Section {
                colorPicker
            } header: {
                Text(L10n.Practice.Section.color)
            }
        }
        .sheet(isPresented: $showingGoalPicker) {
            GoalPickerSheet(selectedGoal: $customGoal)
        }
    }
    
    // MARK: - Color Picker
    
    private var colorPicker: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: Spacing.md) {
            ForEach(PracticeColors.allColorIds, id: \.self) { colorId in
                Button(action: { selectedColorId = colorId }) {
                    ZStack {
                        Circle()
                            .fill(PracticeColors.adaptiveColor(for: colorId))
                            .frame(width: 40, height: 40)
                        
                        if selectedColorId == colorId {
                            Circle()
                                .strokeBorder(.white, lineWidth: 2)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding(.vertical, Spacing.sm)
    }
    
    // MARK: - Helper Methods
    
    private func isPracticeAlreadyAdded(_ predefined: PredefinedPractice) -> Bool {
        // Check if a practice with the same ID or name already exists
        existingPractices.contains { practice in
            practice.colorId == predefined.colorId && practice.isPredefined
        }
    }
    
    private func addPredefinedPractice(_ predefined: PredefinedPractice) {
        let newOrder = existingPractices.count
        let practice = Practice.fromPredefined(predefined, order: newOrder)
        
        modelContext.insert(practice)
        try? modelContext.save()
        dismiss()
    }
    
    private func saveCustomPractice() {
        let trimmedName = customName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let practice = Practice(
            name: trimmedName,
            descriptionText: customDescription.trimmingCharacters(in: .whitespaces),
            imageName: "plus.circle.fill",
            colorId: selectedColorId,
            progress: 0,
            maxRepetition: customGoal,
            defaultRepetition: customDefaultReps,
            isActive: true,
            isPredefined: false,
            createdAt: Date(),
            order: existingPractices.count
        )
        
        modelContext.insert(practice)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Predefined Practice Card

struct PredefinedPracticeCard: View {
    let practice: PredefinedPractice
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Color indicator
            Circle()
                .fill(PracticeColors.adaptiveColor(for: practice.colorId))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: practice.imageName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(practice.localizedName)
                    .font(Typography.headline)
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(practice.localizedDescription)
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(2)
                
                Text(String(format: L10n.Practice.Goal.format, practice.maxRepetition.formatted()))
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textTertiary)
            }
            
            Spacer()
            
            // Add button
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(PracticeColors.adaptiveColor(for: practice.colorId))
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cardRadius)
        .shadow(color: Color.theme.shadow, radius: 2, x: 0, y: 1)
    }
}

// MARK: - Goal Picker Sheet

struct GoalPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedGoal: Int
    @State private var customGoalText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Constants.alternativeGoals, id: \.self) { goal in
                        Button(action: {
                            selectedGoal = goal
                            dismiss()
                        }) {
                            HStack {
                                Text(goal.formatted())
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Spacer()
                                
                                if selectedGoal == goal {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.theme.accent)
                                }
                            }
                        }
                    }
                } header: {
                    Text(L10n.Practice.Goal.common)
                }
                
                Section {
                    HStack {
                        TextField(L10n.Practice.Goal.custom, text: $customGoalText)
                            .keyboardType(.numberPad)
                        
                        if !customGoalText.isEmpty, let value = Int(customGoalText) {
                            Button(L10n.Common.set) {
                                selectedGoal = value
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } header: {
                    Text(L10n.Practice.Goal.customSection)
                }
            }
            .navigationTitle(L10n.Practice.Goal.select)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
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
    AddPracticeView()
        .modelContainer(for: Practice.self, inMemory: true)
}
