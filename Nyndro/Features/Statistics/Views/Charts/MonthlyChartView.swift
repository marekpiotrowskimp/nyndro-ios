//
//  MonthlyChartView.swift
//  Nyndro
//
//  Chart showing practice activity over the last 30 days
//

import SwiftUI
import Charts

struct MonthlyChartView: View {
    let practice: Practice
    
    // Calculate daily data for the last 30 days
    private var dailyData: [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create date range for last 30 days
        var data: [DailyStats] = []
        for dayOffset in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            
            // Sum repetitions for this day
            let dayEntries = practice.history.filter {
                calendar.isDate($0.practiceDate, inSameDayAs: date)
            }
            let total = dayEntries.reduce(0) { $0 + $1.repetitionAdded }
            
            data.append(DailyStats(date: date, total: total))
        }
        
        return data
    }
    
    private var maxTotal: Int {
        max(dailyData.map(\.total).max() ?? 1, 1)
    }
    
    private var totalInPeriod: Int {
        dailyData.reduce(0) { $0 + $1.total }
    }
    
    private var activeDays: Int {
        dailyData.filter { $0.total > 0 }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                Text(L10n.Statistics.monthlyActivity)
                    .font(Typography.headline)
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                Text(L10n.Statistics.last30Days)
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
            
            if practice.history.isEmpty {
                emptyState
            } else {
                chartView
                
                // Summary row
                summaryRow
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cardRadius)
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart(dailyData) { data in
            BarMark(
                x: .value("Date", data.date, unit: .day),
                y: .value("Repetitions", data.total)
            )
            .foregroundStyle(
                data.total > 0
                    ? practice.color.gradient
                    : Color.theme.progressEmpty.gradient
            )
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisGridLine()
                    .foregroundStyle(Color.theme.divider)
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .font(Typography.caption)
                    .foregroundStyle(Color.theme.textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color.theme.divider)
                AxisValueLabel()
                    .font(Typography.caption)
                    .foregroundStyle(Color.theme.textTertiary)
            }
        }
        .frame(height: 150)
    }
    
    // MARK: - Summary Row
    
    private var summaryRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(totalInPeriod.formatted())
                    .font(Typography.title3)
                    .foregroundColor(practice.color)
                Text(L10n.Statistics.completed)
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text("\(activeDays)")
                    .font(Typography.title3)
                    .foregroundColor(Color.theme.textPrimary)
                Text(L10n.Statistics.practiceDays)
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .padding(.top, Spacing.sm)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32))
                .foregroundColor(Color.theme.textTertiary)
            
            Text(L10n.Statistics.noDataYet)
                .font(Typography.body)
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }
}

// MARK: - Daily Stats

struct DailyStats: Identifiable {
    let date: Date
    let total: Int
    
    var id: Date { date }
}

// MARK: - Preview

#Preview {
    VStack {
        MonthlyChartView(practice: Practice(
            name: "Test",
            descriptionText: "Test practice",
            colorId: "refuge",
            progress: 1000,
            maxRepetition: 111111
        ))
    }
    .padding()
    .modelContainer(for: [Practice.self, HistoryEntry.self], inMemory: true)
}
