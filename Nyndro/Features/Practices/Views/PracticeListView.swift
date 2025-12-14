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
        VStack(spacing: Spacing.lg) {
            Image("mala_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.theme.textTertiary)
            
            Text(L10n.Empty.Practices.title)
                .font(Typography.title2)
                .foregroundColor(Color.theme.textPrimary)
            
            Text(L10n.Empty.Practices.message)
                .font(Typography.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddPractice = true }) {
                Label(L10n.Practice.add, systemImage: "plus")
                    .font(Typography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.theme.accent)
                    .cornerRadius(Spacing.buttonRadius)
            }
            .padding(.top, Spacing.md)
        }
        .padding(Spacing.screenHorizontal)
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
