//
//  HistoryListView.swift
//  Nyndro
//
//  Practice history list view
//

import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HistoryEntry.practiceDate, order: .reverse)
    private var allHistory: [HistoryEntry]
    
    @Query(filter: #Predicate<Practice> { $0.isActive }, sort: \Practice.order)
    private var practices: [Practice]
    
    @State private var selectedPractice: Practice?
    @State private var showingDeleteConfirmation = false
    @State private var entryToDelete: HistoryEntry?
    
    @AppStorage("hasSeenHistorySwipeHint") private var hasSeenSwipeHint = false
    
    private var filteredHistory: [HistoryEntry] {
        if let practice = selectedPractice {
            return allHistory.filter { $0.practice?.id == practice.id }
        }
        return allHistory
    }
    
    private var groupedHistory: [(String, [HistoryEntry])] {
        let grouped = Dictionary(grouping: filteredHistory) { entry in
            entry.practiceDate.formatted(date: .abbreviated, time: .omitted)
        }
        return grouped.sorted { $0.value.first?.practiceDate ?? Date() > $1.value.first?.practiceDate ?? Date() }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                if allHistory.isEmpty {
                    emptyState
                } else {
                    historyContent
                }
            }
            .navigationTitle(L10n.Tab.history)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { selectedPractice = nil }) {
                            HStack {
                                Text(Filter.all)
                                Spacer()
                                if selectedPractice == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Divider()
                        
                        ForEach(practices) { practice in
                            Button(action: { selectedPractice = practice }) {
                                HStack {
                                    Text(practice.name)
                                    Spacer()
                                    if selectedPractice?.id == practice.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .alert(L10n.Common.delete, isPresented: $showingDeleteConfirmation) {
                Button(L10n.Common.cancel, role: .cancel) { }
                Button(L10n.Common.delete, role: .destructive) {
                    if let entry = entryToDelete {
                        deleteEntry(entry)
                    }
                }
            } message: {
                Text(History.deleteConfirmation)
            }
        }
    }
    
    // MARK: - History Content
    
    private var historyContent: some View {
        VStack(spacing: 0) {
            // Filter chips
            if practices.count > 1 {
                filterChips
                    .padding(.vertical, Spacing.sm)
            }
            
            // Swipe hint banner (shown once)
            if !hasSeenSwipeHint && !filteredHistory.isEmpty {
                SwipeHintBanner {
                    withAnimation {
                        hasSeenSwipeHint = true
                    }
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, Spacing.sm)
            }
            
            // History list with swipe actions
            List {
                ForEach(groupedHistory, id: \.0) { dateString, entries in
                    Section {
                        ForEach(entries) { entry in
                            HistoryRowView(entry: entry)
                                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.screenHorizontal, bottom: Spacing.xs, trailing: Spacing.screenHorizontal))
                                .listRowBackground(Color.theme.cardBackground)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        entryToDelete = entry
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label(L10n.Common.delete, systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        HStack {
                            Text(dateString)
                                .font(Typography.subheadline)
                                .foregroundColor(Color.theme.textSecondary)
                            
                            Spacer()
                            
                            Text(History.totalCount(entries.reduce(0) { $0 + $1.repetitionAdded }))
                                .font(Typography.caption)
                                .foregroundColor(Color.theme.textTertiary)
                        }
                        .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)
        }
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FilterChip(
                    title: Filter.all,
                    isSelected: selectedPractice == nil
                ) {
                    withAnimation { selectedPractice = nil }
                }
                
                ForEach(practices) { practice in
                    FilterChip(
                        title: practice.name,
                        isSelected: selectedPractice?.id == practice.id,
                        color: practice.color
                    ) {
                        withAnimation { selectedPractice = practice }
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        EmptyStateView.history
    }
    
    // MARK: - Actions
    
    private func deleteEntry(_ entry: HistoryEntry) {
        // Update practice progress
        if let practice = entry.practice {
            practice.subtractRepetitions(entry.repetitionAdded)
        }
        
        // Delete entry
        modelContext.delete(entry)
        try? modelContext.save()
    }
}

// MARK: - Swipe Hint Banner

struct SwipeHintBanner: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "hand.point.left.fill")
                .foregroundColor(Color.theme.info)
            
            Text(History.swipeHint)
                .font(Typography.caption)
                .foregroundColor(Color.theme.textSecondary)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.theme.textTertiary)
            }
        }
        .padding(Spacing.sm)
        .background(Color.theme.info.opacity(0.1))
        .cornerRadius(Spacing.cardRadius)
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = Color.theme.accent
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.caption)
                .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? color : Color.theme.secondaryBackground)
                .cornerRadius(Spacing.buttonRadius)
        }
    }
}

struct HistoryRowView: View {
    let entry: HistoryEntry
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Practice color indicator
            if let practice = entry.practice {
                Circle()
                    .fill(practice.color)
                    .frame(width: 12, height: 12)
            }
            
            // Practice name and time
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(entry.practice?.name ?? L10n.Practice.unknown)
                    .font(Typography.body)
                    .foregroundColor(Color.theme.textPrimary)
                
                HStack(spacing: Spacing.sm) {
                    Text(entry.practiceDate.formatted(date: .omitted, time: .shortened))
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textSecondary)
                    
                    if let duration = entry.formattedDuration {
                        Text("•")
                            .foregroundColor(Color.theme.textTertiary)
                        
                        Text(duration)
                            .font(Typography.caption)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    if entry.note != nil {
                        Image(systemName: "note.text")
                            .font(.system(size: 10))
                            .foregroundColor(Color.theme.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            // Repetitions added
            Text("+\(entry.repetitionAdded)")
                .font(Typography.headline)
                .foregroundColor(entry.practice?.color ?? Color.theme.accent)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    HistoryListView()
        .modelContainer(for: [Practice.self, HistoryEntry.self], inMemory: true)
}
