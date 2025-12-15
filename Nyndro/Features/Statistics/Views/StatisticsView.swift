//
//  StatisticsView.swift
//  Nyndro
//
//  Statistics and predictions view
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Practice> { $0.isActive }, sort: \Practice.order)
    private var practices: [Practice]
    
    @State private var selectedPractice: Practice?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                if practices.isEmpty {
                    emptyState
                } else {
                    statisticsContent
                }
            }
            .navigationTitle(L10n.Tab.statistics)
        }
        .onAppear {
            if selectedPractice == nil {
                selectedPractice = practices.first
            }
        }
    }
    
    // MARK: - Statistics Content
    
    private var statisticsContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Practice Picker
                practicePicker
                
                if let practice = selectedPractice {
                    // Overview Card
                    overviewCard(for: practice)
                    
                    // Monthly Activity Chart
                    MonthlyChartView(practice: practice)
                    
                    // Weekday Activity Chart
                    WeekdayChartView(practice: practice)
                    
                    // Prediction Card
                    predictionCard(for: practice)
                    
                    // Daily Average Card
                    dailyAverageCard(for: practice)
                    
                    // Streak Card
                    streakCard(for: practice)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.md)
        }
    }
    
    // MARK: - Practice Picker
    
    private var practicePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(practices) { practice in
                    PracticeChip(
                        practice: practice,
                        isSelected: selectedPractice?.id == practice.id
                    ) {
                        withAnimation(.easeInOut(duration: Constants.Animation.fast)) {
                            selectedPractice = practice
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.xs)
        }
    }
    
    // MARK: - Overview Card
    
    private func overviewCard(for practice: Practice) -> some View {
        StatCard(title: L10n.Statistics.overview) {
            VStack(spacing: Spacing.md) {
                HStack {
                    StatValue(
                        title: L10n.Statistics.completed,
                        value: practice.progress.formatted()
                    )
                    Spacer()
                    StatValue(
                        title: L10n.Statistics.remaining,
                        value: practice.remaining.formatted()
                    )
                    Spacer()
                    StatValue(
                        title: L10n.Statistics.progress,
                        value: "\(practice.progressPercentageInt)%"
                    )
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.theme.progressEmpty)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(practice.color)
                            .frame(width: geometry.size.width * practice.progressPercentage)
                    }
                }
                .frame(height: 8)
            }
        }
    }
    
    // MARK: - Prediction Card
    
    private func predictionCard(for practice: Practice) -> some View {
        StatCard(title: L10n.Statistics.prediction) {
            VStack(spacing: Spacing.md) {
                if practice.history.count >= Constants.minimumDaysForPrediction {
                    // Calculate predictions
                    let stats = calculateStatistics(for: practice)
                    
                    VStack(spacing: Spacing.sm) {
                        PredictionRow(
                            icon: "hare.fill",
                            label: L10n.Statistics.optimistic,
                            date: stats.optimisticDate,
                            color: .theme.success
                        )
                        
                        PredictionRow(
                            icon: "tortoise.fill",
                            label: L10n.Statistics.mostLikely,
                            date: stats.mostLikelyDate,
                            color: .theme.accent
                        )
                        
                        PredictionRow(
                            icon: "clock.fill",
                            label: L10n.Statistics.pessimistic,
                            date: stats.pessimisticDate,
                            color: .theme.warning
                        )
                    }
                    
                    // Confidence indicator
                    HStack {
                        Text(L10n.Statistics.confidence)
                            .font(Typography.caption)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Spacer()
                        
                        ConfidenceBadge(level: stats.confidence)
                    }
                    .padding(.top, Spacing.xs)
                } else {
                    // Insufficient data
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 32))
                            .foregroundColor(Color.theme.textTertiary)
                        
                        Text(L10n.Statistics.insufficientData)
                            .font(Typography.body)
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text(String(format: L10n.Statistics.needMoreDays, "\(Constants.minimumDaysForPrediction)"))
                            .font(Typography.caption)
                            .foregroundColor(Color.theme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                }
            }
        }
    }
    
    // MARK: - Daily Average Card
    
    private func dailyAverageCard(for practice: Practice) -> some View {
        StatCard(title: L10n.Statistics.dailyAverage) {
            let average = calculateDailyAverage(for: practice)
            
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(average.formatted())
                        .font(Typography.largeTitle)
                        .foregroundColor(practice.color)
                    
                    Text(L10n.Statistics.perDay)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                // Weekly trend indicator
                if let trend = calculateWeeklyTrend(for: practice) {
                    TrendIndicator(trend: trend)
                }
            }
        }
    }
    
    // MARK: - Streak Card
    
    private func streakCard(for practice: Practice) -> some View {
        StatCard(title: L10n.Statistics.streak) {
            let streak = calculateStreak(for: practice)
            
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text("\(streak.current)")
                            .font(Typography.largeTitle)
                            .foregroundColor(streak.current > 0 ? .theme.success : .theme.textTertiary)
                        
                        Text(L10n.Statistics.days)
                            .font(Typography.body)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    Text(L10n.Statistics.currentStreak)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text("\(streak.best)")
                            .font(Typography.title2)
                            .foregroundColor(Color.theme.accentSecondary)
                        
                        Text(L10n.Statistics.days)
                            .font(Typography.caption)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    Text(L10n.Statistics.bestStreak)
                        .font(Typography.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        EmptyStateView.statistics
    }
    
    // MARK: - Calculation Methods
    
    private func calculateStatistics(for practice: Practice) -> PredictionStats {
        // TODO: Implement proper weighted average calculation
        // This is a placeholder implementation
        let dailyAverage = calculateDailyAverage(for: practice)
        let remaining = Double(practice.remaining)
        
        guard dailyAverage > 0 else {
            return PredictionStats(
                optimisticDate: nil,
                mostLikelyDate: nil,
                pessimisticDate: nil,
                confidence: .insufficient
            )
        }
        
        let optimisticDays = remaining / (dailyAverage * 1.25)
        let mostLikelyDays = remaining / dailyAverage
        let pessimisticDays = remaining / (dailyAverage * 0.75)
        
        return PredictionStats(
            optimisticDate: Calendar.current.date(byAdding: .day, value: Int(optimisticDays), to: Date()),
            mostLikelyDate: Calendar.current.date(byAdding: .day, value: Int(mostLikelyDays), to: Date()),
            pessimisticDate: Calendar.current.date(byAdding: .day, value: Int(pessimisticDays), to: Date()),
            confidence: determineConfidence(historyCount: practice.history.count)
        )
    }
    
    private func calculateDailyAverage(for practice: Practice) -> Double {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let recentHistory = practice.history.filter { $0.practiceDate >= thirtyDaysAgo }
        
        guard !recentHistory.isEmpty else { return 0 }
        
        let totalReps = recentHistory.reduce(0) { $0 + $1.repetitionAdded }
        let daysPracticed = Set(recentHistory.map { calendar.startOfDay(for: $0.practiceDate) }).count
        
        return daysPracticed > 0 ? Double(totalReps) / Double(daysPracticed) : 0
    }
    
    private func calculateWeeklyTrend(for practice: Practice) -> Double? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now),
              let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) else {
            return nil
        }
        
        let thisWeek = practice.history.filter { $0.practiceDate >= oneWeekAgo }
        let lastWeek = practice.history.filter { $0.practiceDate >= twoWeeksAgo && $0.practiceDate < oneWeekAgo }
        
        let thisWeekTotal = thisWeek.reduce(0) { $0 + $1.repetitionAdded }
        let lastWeekTotal = lastWeek.reduce(0) { $0 + $1.repetitionAdded }
        
        guard lastWeekTotal > 0 else { return nil }
        
        return Double(thisWeekTotal - lastWeekTotal) / Double(lastWeekTotal) * 100
    }
    
    private func calculateStreak(for practice: Practice) -> (current: Int, best: Int) {
        let calendar = Calendar.current
        var currentStreak = 0
        var bestStreak = 0
        var tempStreak = 0
        
        let sortedDates = Set(practice.history
            .filter { $0.repetitionAdded > 0 }
            .map { calendar.startOfDay(for: $0.practiceDate) })
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return (0, 0) }
        
        // Check current streak
        var checkDate = calendar.startOfDay(for: Date())
        for date in sortedDates {
            if date == checkDate {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if date < checkDate {
                break
            }
        }
        
        // Calculate best streak
        var previousDate: Date?
        for date in sortedDates.reversed() {
            if let prev = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                if daysDiff == 1 {
                    tempStreak += 1
                } else {
                    bestStreak = max(bestStreak, tempStreak)
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            previousDate = date
        }
        bestStreak = max(bestStreak, tempStreak)
        
        return (currentStreak, bestStreak)
    }
    
    private func determineConfidence(historyCount: Int) -> ConfidenceLevel {
        switch historyCount {
        case 0..<7: return .insufficient
        case 7..<14: return .low
        case 14..<30: return .medium
        default: return .high
        }
    }
}

// MARK: - Supporting Types

struct PredictionStats {
    let optimisticDate: Date?
    let mostLikelyDate: Date?
    let pessimisticDate: Date?
    let confidence: ConfidenceLevel
}

// MARK: - ConfidenceLevel Color Extension

extension ConfidenceLevel {
    var color: Color {
        switch self {
        case .insufficient: return .theme.textTertiary
        case .low: return .theme.warning
        case .medium: return .theme.info
        case .high: return .theme.success
        }
    }
}

// MARK: - Supporting Views

struct PracticeChip: View {
    let practice: Practice
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(practice.name)
                .font(Typography.subheadline)
                .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    isSelected
                        ? AnyShapeStyle(practice.color)
                        : AnyShapeStyle(Color.theme.secondaryBackground)
                )
                .cornerRadius(Spacing.buttonRadius)
        }
    }
}

struct StatCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(Color.theme.textPrimary)
            
            content
        }
        .padding(Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cardRadius)
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
}

struct StatValue: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(value)
                .font(Typography.title3)
                .foregroundColor(Color.theme.textPrimary)
            
            Text(title)
                .font(Typography.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
    }
}

struct PredictionRow: View {
    let icon: String
    let label: String
    let date: Date?
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(Typography.body)
                .foregroundColor(Color.theme.textSecondary)
            
            Spacer()
            
            if let date = date {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(Typography.body)
                    .foregroundColor(Color.theme.textPrimary)
            } else {
                Text("--")
                    .font(Typography.body)
                    .foregroundColor(Color.theme.textTertiary)
            }
        }
    }
}

struct ConfidenceBadge: View {
    let level: ConfidenceLevel
    
    var body: some View {
        Text(level.displayName)
            .font(Typography.caption)
            .foregroundColor(level.color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(level.color.opacity(0.15))
            .cornerRadius(Spacing.buttonRadius)
    }
}

struct TrendIndicator: View {
    let trend: Double
    
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
            Text("\(abs(Int(trend)))%")
        }
        .font(Typography.caption)
        .foregroundColor(trend >= 0 ? .theme.success : .theme.error)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background((trend >= 0 ? Color.theme.success : Color.theme.error).opacity(0.15))
        .cornerRadius(Spacing.buttonRadius)
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
        .modelContainer(for: [Practice.self, HistoryEntry.self], inMemory: true)
}
