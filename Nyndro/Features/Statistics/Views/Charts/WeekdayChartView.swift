//
//  WeekdayChartView.swift
//  Nyndro
//
//  Chart showing practice activity by day of week
//

import SwiftUI
import Charts

struct WeekdayChartView: View {
    let practice: Practice
    
    // Calculate data for each weekday
    private var weekdayData: [WeekdayStats] {
        let calendar = Calendar.current
        
        // Initialize weekday totals
        var totals: [Int: Int] = [:]
        var counts: [Int: Int] = [:]
        
        for weekday in 1...7 {
            totals[weekday] = 0
            counts[weekday] = 0
        }
        
        // Aggregate history by weekday
        for entry in practice.history {
            let weekday = calendar.component(.weekday, from: entry.practiceDate)
            totals[weekday, default: 0] += entry.repetitionAdded
            counts[weekday, default: 0] += 1
        }
        
        // Create stats array
        return (1...7).map { weekday in
            let count = counts[weekday, default: 0]
            let total = totals[weekday, default: 0]
            let average = count > 0 ? Double(total) / Double(count) : 0
            
            return WeekdayStats(
                weekday: weekday,
                total: total,
                average: average,
                sessionCount: count
            )
        }
    }
    
    private var maxTotal: Int {
        weekdayData.map(\.total).max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(L10n.Statistics.weekdayActivity)
                .font(Typography.headline)
                .foregroundColor(Color.theme.textPrimary)
            
            if practice.history.isEmpty {
                emptyState
            } else {
                chartView
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color.theme.cardBackground)
        .cornerRadius(Spacing.cardRadius)
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart(weekdayData) { data in
            BarMark(
                x: .value("Day", data.shortName),
                y: .value("Repetitions", data.total)
            )
            .foregroundStyle(
                data.total == maxTotal
                    ? practice.color
                    : practice.color.opacity(0.6)
            )
            .cornerRadius(4)
            .annotation(position: .top, alignment: .center) {
                if data.total > 0 {
                    Text(formatNumber(data.total))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel()
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
        .frame(height: 180)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundColor(Color.theme.textTertiary)
            
            Text(L10n.Statistics.noDataYet)
                .font(Typography.body)
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }
    
    // MARK: - Helpers
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return "\(number / 1000)k"
        }
        return "\(number)"
    }
}

// MARK: - Weekday Stats

struct WeekdayStats: Identifiable {
    let weekday: Int // 1 = Sunday, 2 = Monday, etc.
    let total: Int
    let average: Double
    let sessionCount: Int
    
    var id: Int { weekday }
    
    var shortName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        // weekdaySymbols is 0-indexed (Sunday = 0), but Calendar weekday is 1-indexed
        let symbols = formatter.shortWeekdaySymbols ?? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return symbols[(weekday - 1) % 7]
    }
    
    var fullName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.weekdaySymbols ?? ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return symbols[(weekday - 1) % 7]
    }
}

// MARK: - Preview

#Preview {
    VStack {
        WeekdayChartView(practice: Practice(
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
