//
//  RemindersListView.swift
//  Nyndro
//
//  List of reminders for a practice
//

import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var practice: Practice
    
    @State private var showingAddReminder = false
    @State private var reminderToEdit: Reminder?
    
    var body: some View {
        List {
            if practice.reminders.isEmpty {
                emptyState
            } else {
                ForEach(practice.reminders.sorted(by: { $0.scheduledDate < $1.scheduledDate })) { reminder in
                    ReminderRow(reminder: reminder)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            reminderToEdit = reminder
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteReminder(reminder)
                            } label: {
                                Label(L10n.Common.delete, systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleReminder(reminder)
                            } label: {
                                Label(
                                    reminder.isActive ? "Disable" : "Enable",
                                    systemImage: reminder.isActive ? "bell.slash" : "bell"
                                )
                            }
                            .tint(reminder.isActive ? .orange : .green)
                        }
                }
            }
        }
        .navigationTitle(L10n.Reminder.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddReminder = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(practice: practice)
        }
        .sheet(item: $reminderToEdit) { reminder in
            EditReminderView(reminder: reminder)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundColor(Color.theme.textTertiary)
            
            Text(L10n.Reminder.Empty.title)
                .font(Typography.headline)
                .foregroundColor(Color.theme.textPrimary)
            
            Text(L10n.Reminder.Empty.message)
                .font(Typography.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddReminder = true }) {
                Label(L10n.Reminder.add, systemImage: "plus")
                    .foregroundColor(.white)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.theme.accent)
            .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Actions
    
    private func deleteReminder(_ reminder: Reminder) {
        Task {
            await NotificationService.shared.cancelReminder(reminder)
        }
        modelContext.delete(reminder)
        try? modelContext.save()
    }
    
    private func toggleReminder(_ reminder: Reminder) {
        reminder.isActive.toggle()
        try? modelContext.save()
        
        Task {
            if reminder.isActive {
                try? await NotificationService.shared.scheduleReminder(reminder)
            } else {
                await NotificationService.shared.cancelReminder(reminder)
            }
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    @Bindable var reminder: Reminder
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Status indicator
            Image(systemName: reminder.isActive ? "bell.fill" : "bell.slash")
                .foregroundColor(reminder.isActive ? Color.theme.accent : Color.theme.textTertiary)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                // Time
                Text(reminder.formattedTime)
                    .font(Typography.headline)
                    .foregroundColor(reminder.isActive ? Color.theme.textPrimary : Color.theme.textSecondary)
                
                // Repeat type
                HStack(spacing: Spacing.xs) {
                    Image(systemName: reminder.repeatType.icon)
                        .font(.system(size: 12))
                    Text(reminder.repeatType.displayName)
                        .font(Typography.caption)
                }
                .foregroundColor(Color.theme.textSecondary)
            }
            
            Spacer()
            
            // Next occurrence
            if reminder.isActive {
                VStack(alignment: .trailing, spacing: Spacing.xxs) {
                    Text(L10n.Reminder.next)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textTertiary)
                    
                    Text(reminder.nextOccurrence.formatted(date: .abbreviated, time: .omitted))
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
        .opacity(reminder.isActive ? 1 : 0.6)
    }
}

// MARK: - Add Reminder View

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let practice: Practice
    
    @State private var scheduledDate = Date()
    @State private var repeatType: RepeatType = .daily
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        L10n.Reminder.time,
                        selection: $scheduledDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    
                    if repeatType == .none || repeatType == .weekly {
                        DatePicker(
                            L10n.Reminder.date,
                            selection: $scheduledDate,
                            displayedComponents: [.date]
                        )
                    }
                }
                
                Section {
                    Picker(L10n.Reminder.repeatLabel, selection: $repeatType) {
                        ForEach(RepeatType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                } footer: {
                    Text(repeatTypeDescription)
                }
            }
            .navigationTitle(L10n.Reminder.add)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) {
                        saveReminder()
                    }
                }
            }
            .alert(L10n.Reminder.PermissionRequired.title, isPresented: $showingPermissionAlert) {
                Button(L10n.Common.cancel, role: .cancel) { }
                Button(L10n.Reminder.openSettings) {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            } message: {
                Text(L10n.Reminder.PermissionRequired.message)
            }
        }
    }
    
    private var repeatTypeDescription: String {
        switch repeatType {
        case .none:
            return L10n.Reminder.Repeat.none.description
        case .daily:
            return L10n.Reminder.Repeat.daily.description
        case .weekly:
            return L10n.Reminder.Repeat.weekly.description
        case .monthly:
            return L10n.Reminder.Repeat.monthly.description
        }
    }
    
    private func saveReminder() {
        Task {
            // Check notification permission
            let authorized = await NotificationService.shared.requestAuthorization()
            
            if !authorized {
                showingPermissionAlert = true
                return
            }
            
            // Create reminder
            let reminder = Reminder(
                practice: practice,
                scheduledDate: scheduledDate,
                repeatType: repeatType,
                isActive: true
            )
            
            modelContext.insert(reminder)
            practice.reminders.append(reminder)
            try? modelContext.save()
            
            // Schedule notification
            try? await NotificationService.shared.scheduleReminder(reminder)
            
            dismiss()
        }
    }
}

// MARK: - Edit Reminder View

struct EditReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var reminder: Reminder
    
    @State private var scheduledDate: Date
    @State private var repeatType: RepeatType
    @State private var isActive: Bool
    
    init(reminder: Reminder) {
        self.reminder = reminder
        _scheduledDate = State(initialValue: reminder.scheduledDate)
        _repeatType = State(initialValue: reminder.repeatType)
        _isActive = State(initialValue: reminder.isActive)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        L10n.Reminder.time,
                        selection: $scheduledDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    
                    if repeatType == .none || repeatType == .weekly {
                        DatePicker(
                            L10n.Reminder.date,
                            selection: $scheduledDate,
                            displayedComponents: [.date]
                        )
                    }
                }
                
                Section {
                    Picker(L10n.Reminder.repeatLabel, selection: $repeatType) {
                        ForEach(RepeatType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section {
                    Toggle(L10n.Reminder.active, isOn: $isActive)
                }
            }
            .navigationTitle(L10n.Reminder.edit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        reminder.scheduledDate = scheduledDate
        reminder.repeatType = repeatType
        reminder.isActive = isActive
        
        try? modelContext.save()
        
        Task {
            if isActive {
                try? await NotificationService.shared.scheduleReminder(reminder)
            } else {
                await NotificationService.shared.cancelReminder(reminder)
            }
        }
        
        dismiss()
    }
}

// MARK: - L10n Extensions

extension L10n {
    enum Reminder {
        static let title = "reminder.title".localized(default: "Reminders")
        static let add = "reminder.add".localized(default: "Add Reminder")
        static let edit = "reminder.edit".localized(default: "Edit Reminder")
        static let time = "reminder.time".localized(default: "Time")
        static let date = "reminder.date".localized(default: "Date")
        static let repeatLabel = "reminder.repeat".localized(default: "Repeat")
        static let active = "reminder.active".localized(default: "Active")
        static let next = "reminder.next".localized(default: "Next")
        static let openSettings = "reminder.open_settings".localized(default: "Open Settings")
        
        enum Empty {
            static let title = "reminder.empty.title".localized(default: "No Reminders")
            static let message = "reminder.empty.message".localized(default: "Add a reminder to never miss your practice")
        }
        
        enum PermissionRequired {
            static let title = "reminder.permission.title".localized(default: "Notifications Required")
            static let message = "reminder.permission.message".localized(default: "Please enable notifications in Settings to receive practice reminders")
        }
        
        enum Repeat {
            enum none {
                static let description = "reminder.repeat.none.description".localized(default: "A one-time reminder at the specified date and time")
            }
            enum daily {
                static let description = "reminder.repeat.daily.description".localized(default: "Reminds you every day at the same time")
            }
            enum weekly {
                static let description = "reminder.repeat.weekly.description".localized(default: "Reminds you once a week on the same day")
            }
            enum monthly {
                static let description = "reminder.repeat.monthly.description".localized(default: "Reminds you once a month on the same day")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RemindersListView(practice: Practice(name: "Test Practice"))
    }
    .modelContainer(for: [Practice.self, Reminder.self], inMemory: true)
}
