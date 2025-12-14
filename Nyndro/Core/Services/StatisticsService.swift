//
//  StatisticsService.swift
//  Nyndro
//
//  Service for calculating practice statistics
//

import Foundation
import SwiftData

/// Service responsible for calculating practice statistics
@MainActor
final class StatisticsService: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Daily Statistics
    
    /// Get total repetitions for a practice on a specific date
    func repetitions(for practice: Practice, on date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return practice.history
            .filter { $0.practiceDate >= startOfDay && $0.practiceDate < endOfDay }
            .reduce(0) { $0 + $1.repetitionAdded }
    }
    
    /// Get total repetitions for all practices on a specific date
    func totalRepetitions(on date: Date) throws -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<HistoryEntry>(
            predicate: #Predicate {
                $0.practiceDate >= startOfDay && $0.practiceDate < endOfDay
            }
        )
        
        let entries = try modelContext.fetch(descriptor)
        return entries.reduce(0) { $0 + $1.repetitionAdded }
    }
    
    // MARK: - Average Calculations
    
    /// Calculate daily average for a practice over a period
    func dailyAverage(for practice: Practice, days: Int = 30) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return 0
        }
        
        let relevantEntries = practice.history.filter {
            $0.practiceDate >= startDate && $0.practiceDate <= endDate
        }
        
        guard !relevantEntries.isEmpty else { return 0 }
        
        let totalRepetitions = relevantEntries.reduce(0) { $0 + $1.repetitionAdded }
        return Double(totalRepetitions) / Double(days)
    }
    
    /// Calculate weighted daily average (recent data weighted more heavily)
    func weightedDailyAverage(for practice: Practice, days: Int = 30) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var totalWeightedReps: Double = 0
        var totalWeight: Double = 0
        
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            
            let reps = repetitions(for: practice, on: date)
            
            // Weight formula: more recent days have higher weight
            // weight = 1 / (1 + daysAgo / 30)
            let weight = 1.0 / (1.0 + Double(dayOffset) / 30.0)
            
            totalWeightedReps += Double(reps) * weight
            totalWeight += weight
        }
        
        return totalWeight > 0 ? totalWeightedReps / totalWeight : 0
    }
    
    /// Calculate weekly average for a practice
    func weeklyAverage(for practice: Practice, weeks: Int = 4) -> Double {
        return dailyAverage(for: practice, days: weeks * 7) * 7
    }
    
    /// Calculate monthly average for a practice
    func monthlyAverage(for practice: Practice, months: Int = 3) -> Double {
        return dailyAverage(for: practice, days: months * 30) * 30
    }
    
    // MARK: - Streak Calculations
    
    /// Calculate current practice streak (consecutive days)
    func currentStreak(for practice: Practice) -> Int {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streak = 0
        
        // Check if practiced today
        if repetitions(for: practice, on: currentDate) > 0 {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        // Count consecutive previous days
        while true {
            if repetitions(for: practice, on: currentDate) > 0 {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    /// Calculate best (longest) streak for a practice
    func bestStreak(for practice: Practice) -> Int {
        guard !practice.history.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        
        // Get all unique practice dates
        let practiceDates = Set(practice.history
            .filter { $0.repetitionAdded > 0 }
            .map { calendar.startOfDay(for: $0.practiceDate) }
        ).sorted()
        
        guard !practiceDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<practiceDates.count {
            let dayDifference = calendar.dateComponents(
                [.day],
                from: practiceDates[i - 1],
                to: practiceDates[i]
            ).day ?? 0
            
            if dayDifference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    // MARK: - Weekly Trend
    
    /// Calculate week-over-week trend (positive = improving)
    func weeklyTrend(for practice: Practice) -> Double {
        let thisWeekAvg = dailyAverage(for: practice, days: 7)
        let lastWeekAvg = dailyAverageForPeriod(for: practice, daysAgo: 14, duration: 7)
        
        guard lastWeekAvg > 0 else {
            return thisWeekAvg > 0 ? 1.0 : 0
        }
        
        return (thisWeekAvg - lastWeekAvg) / lastWeekAvg
    }
    
    /// Calculate daily average for a specific past period
    private func dailyAverageForPeriod(for practice: Practice, daysAgo: Int, duration: Int) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -daysAgo, to: today),
              let endDate = calendar.date(byAdding: .day, value: duration, to: startDate) else {
            return 0
        }
        
        let relevantEntries = practice.history.filter {
            $0.practiceDate >= startDate && $0.practiceDate < endDate
        }
        
        let totalRepetitions = relevantEntries.reduce(0) { $0 + $1.repetitionAdded }
        return Double(totalRepetitions) / Double(duration)
    }
    
    // MARK: - Day of Week Statistics
    
    /// Get repetitions grouped by day of week (1 = Sunday, 7 = Saturday)
    func repetitionsByDayOfWeek(for practice: Practice, weeks: Int = 4) -> [Int: Int] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -(weeks * 7), to: Date()) else {
            return [:]
        }
        
        var dayTotals: [Int: Int] = [:]
        for weekday in 1...7 {
            dayTotals[weekday] = 0
        }
        
        for entry in practice.history where entry.practiceDate >= startDate {
            let weekday = calendar.component(.weekday, from: entry.practiceDate)
            dayTotals[weekday, default: 0] += entry.repetitionAdded
        }
        
        return dayTotals
    }
    
    /// Get the most productive day of week
    func mostProductiveDay(for practice: Practice) -> Int? {
        let dayStats = repetitionsByDayOfWeek(for: practice)
        return dayStats.max(by: { $0.value < $1.value })?.key
    }
    
    // MARK: - Monthly Statistics
    
    /// Get repetitions grouped by month
    func repetitionsByMonth(for practice: Practice, months: Int = 6) -> [(month: Date, total: Int)] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .month, value: -months, to: Date()) else {
            return []
        }
        
        var monthTotals: [Date: Int] = [:]
        
        for entry in practice.history where entry.practiceDate >= startDate {
            let components = calendar.dateComponents([.year, .month], from: entry.practiceDate)
            if let monthStart = calendar.date(from: components) {
                monthTotals[monthStart, default: 0] += entry.repetitionAdded
            }
        }
        
        return monthTotals.sorted { $0.key < $1.key }.map { (month: $0.key, total: $0.value) }
    }
    
    // MARK: - Personal Records
    
    /// Get the best single day total for a practice
    func bestDayTotal(for practice: Practice) -> (date: Date, total: Int)? {
        let calendar = Calendar.current
        
        var dayTotals: [Date: Int] = [:]
        
        for entry in practice.history {
            let day = calendar.startOfDay(for: entry.practiceDate)
            dayTotals[day, default: 0] += entry.repetitionAdded
        }
        
        if let best = dayTotals.max(by: { $0.value < $1.value }) {
            return (date: best.key, total: best.value)
        }
        
        return nil
    }
    
    /// Check if today's total is a new personal record
    func isTodayPersonalRecord(for practice: Practice) -> Bool {
        let todayTotal = repetitions(for: practice, on: Date())
        
        guard todayTotal > 0,
              let best = bestDayTotal(for: practice) else {
            return false
        }
        
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(best.date)
        
        return isToday && todayTotal >= best.total
    }
    
    // MARK: - Practice Activity
    
    /// Get number of days practiced in the last N days
    func activeDays(for practice: Practice, inLast days: Int) -> Int {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return 0
        }
        
        let uniqueDays = Set(
            practice.history
                .filter { $0.practiceDate >= startDate && $0.repetitionAdded > 0 }
                .map { calendar.startOfDay(for: $0.practiceDate) }
        )
        
        return uniqueDays.count
    }
    
    /// Calculate practice consistency (percentage of days practiced)
    func consistency(for practice: Practice, inLast days: Int) -> Double {
        let active = activeDays(for: practice, inLast: days)
        return Double(active) / Double(days)
    }
    
    // MARK: - Gap Detection
    
    /// Get the longest gap without practice
    func longestGap(for practice: Practice) -> Int? {
        guard !practice.history.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let practiceDates = practice.history
            .filter { $0.repetitionAdded > 0 }
            .map { calendar.startOfDay(for: $0.practiceDate) }
            .sorted()
        
        guard practiceDates.count > 1 else { return nil }
        
        var maxGap = 0
        
        for i in 1..<practiceDates.count {
            let gap = calendar.dateComponents([.day], from: practiceDates[i - 1], to: practiceDates[i]).day ?? 0
            maxGap = max(maxGap, gap)
        }
        
        return maxGap
    }
    
    /// Check if there's a gap that should trigger statistics reset
    func shouldResetStatistics(for practice: Practice) -> Bool {
        guard let gap = longestGap(for: practice) else { return false }
        return gap > Constants.statisticsResetThresholdDays
    }
    
    /// Get days since last practice
    func daysSinceLastPractice(for practice: Practice) -> Int? {
        guard let lastDate = practice.lastPracticeDate else { return nil }
        
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: lastDate, to: Date()).day
    }
}

// MARK: - Statistics Summary

struct PracticeStatistics {
    let practice: Practice
    let dailyAverage: Double
    let weeklyAverage: Double
    let currentStreak: Int
    let bestStreak: Int
    let weeklyTrend: Double
    let consistency: Double
    let bestDay: (date: Date, total: Int)?
    let daysSinceLastPractice: Int?
}

extension StatisticsService {
    
    /// Get comprehensive statistics for a practice
    func getStatistics(for practice: Practice) -> PracticeStatistics {
        PracticeStatistics(
            practice: practice,
            dailyAverage: dailyAverage(for: practice),
            weeklyAverage: weeklyAverage(for: practice),
            currentStreak: currentStreak(for: practice),
            bestStreak: bestStreak(for: practice),
            weeklyTrend: weeklyTrend(for: practice),
            consistency: consistency(for: practice, inLast: 30),
            bestDay: bestDayTotal(for: practice),
            daysSinceLastPractice: daysSinceLastPractice(for: practice)
        )
    }
}
