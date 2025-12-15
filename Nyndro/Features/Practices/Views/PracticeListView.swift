//
//  PracticeListView.swift
//  Nyndro
//
//  Main practice list view
//

import SwiftUI
import SwiftData

struct PracticeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Practice> { $0.isActive }, sort: \Practice.order)
    private var practices: [Practice]
    
    @State private var showingAddPractice = false
    @State private var practiceToDelete: Practice?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                if practices.isEmpty {
                    emptyState
                } else {
                    practiceList
                }
            }
            .navigationTitle(L10n.Tab.practices)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPractice = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPractice) {
                AddPracticeView()
            }
            .alert(L10n.Common.delete, isPresented: $showingDeleteConfirmation) {
                Button(L10n.Common.cancel, role: .cancel) { }
                Button(L10n.Common.delete, role: .destructive) {
                    if let practice = practiceToDelete {
                        deletePractice(practice)
                    }
                }
            } message: {
                Text(L10n.Practice.deleteConfirmation)
            }
        }
    }
    
    // MARK: - Practice List
    
    private var practiceList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.listSpacing) {
                ForEach(practices) { practice in
                    NavigationLink(destination: PracticeDetailView(practice: practice)) {
                        PracticeCardView(practice: practice)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(action: {
                            // Edit action
                        }) {
                            Label(L10n.Common.edit, systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            practiceToDelete = practice
                            showingDeleteConfirmation = true
                        }) {
                            Label(L10n.Common.delete, systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.md)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        EmptyStateView.practices {
            showingAddPractice = true
        }
    }
    
    // MARK: - Actions
    
    private func deletePractice(_ practice: Practice) {
        practice.isActive = false
        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    PracticeListView()
        .modelContainer(for: Practice.self, inMemory: true)
}
