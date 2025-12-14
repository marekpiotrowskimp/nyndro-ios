//
//  PredictionService.swift
//  Nyndro
//
//  Service for predicting practice completion dates
//

import Foundation
import SwiftData

// MARK: - Confidence Level

/// Confidence level for predictions based on data availability
enum ConfidenceLevel: String, Codable {
    case insufficient = "insufficient"  // < 7 days of data
    case low = "low"                    // 7-14 days
    case medium = "medium"              // 15-30 days
    case high = "high"                  // > 30 days + regular practice
    
    var displayName: String {
        switch self {
        case .insufficient:
            return "statistics.confidence.insufficient".localized(default: "Insufficient data")
        case .low:
            return "statistics.confidence.low".localized(default: "Low confidence")
        case .medium:
            return "statistics.confidence.medium".localized(default: "Medium confidence")
        case .high:
            return "statistics.confidence.high".localized(default: "High confidence")
        }
    }
    
    var icon: String {
        switch self {
        case .insufficient: return "questionmark.circle"
        case .low: return "chart.bar.fill"
        case .medium: return "chart.bar.fill"
        case .high: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Prediction Result

/// Result of a completion date prediction
struct PredictionResult {
    /// Most likely completion date (weighted average)
    let mostLikelyDate: Date
    
    /// Days until most likely completion
    let mostLikelyDays: Int
    
    /// Optimistic completion date (top 25% tempo)
    let optimisticDate: Date
    
    /// Pessimistic completion date (accounting for breaks)
    let pessimisticDate: Date
    
    /// Confidence level of the prediction
    let confidence: ConfidenceLevel
    
    /// Number of days of data used for prediction
    let basedOnDays: Int
    
    /// Daily average used for calculation
    let dailyAverage: Double
    
    /// Is the practice already completed?
    let isCompleted: Bool
}

// MARK: - Prediction Service

/// Service responsible for predicting practice completion dates
@MainActor
final class PredictionService: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    private let statisticsService: StatisticsService
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.statisticsService = StatisticsService(modelContext: modelContext)
    }
    
    // MARK: - Main Prediction Method
    
    /// Calculate prediction for a practice
    func predict(for practice: Practice) -> PredictionResult {
        // Check if already completed
        if practice.isCompleted {
            return PredictionResult(
                mostLikelyDate: Date(),
                mostLikelyDays: 0,
                optimisticDate: Date(),
                pessimisticDate: Date(),
                confidence: .high,
                basedOnDays: 0,
                dailyAverage: 0,
                isCompleted: true
            )
        }
        
        // Get practice days data
        let practiceData = getPracticeData(for: practice)
        let daysOfData = practiceData.count
        
        // Check for insufficient data
        if daysOfData < Constants.minimumDaysForPrediction {
            return createInsufficientDataResult(for: practice, daysOfData: daysOfData)
        }
        
        // Check for long gap that should reset statistics
        if statisticsService.shouldResetStatistics(for: practice) {
            // Use only recent data after the gap
            let recentData = getRecentDataAfterGap(for: practice)
            if recentData.count < Constants.minimumDaysForPrediction {
                return createInsufficientDataResult(for: practice, daysOfData: recentData.count)
            }
            return calculatePrediction(for: practice, using: recentData)
        }
        
        return calculatePrediction(for: practice, using: practiceData)
    }
    
    // MARK: - Private Calculation Methods
    
    /// Get daily repetition data for a practice
    private func getPracticeData(for practice: Practice) -> [(date: Date, repetitions: Int)] {
        let calendar = Calendar.current
        
        // Group history entries by day
        var dailyTotals: [Date: Int] = [:]
        
        for entry in practice.history where entry.repetitionAdded > 0 {
            let day = calendar.startOfDay(for: entry.practiceDate)
            dailyTotals[day, default: 0] += entry.repetitionAdded
        }
        
        // Sort by date
        return dailyTotals.sorted { $0.key < $1.key }.map { (date: $0.key, repetitions: $0.value) }
    }
    
    /// Get data after the most recent long gap
    private func getRecentDataAfterGap(for practice: Practice) -> [(date: Date, repetitions: Int)] {
        let allData = getPracticeData(for: practice)
        guard allData.count > 1 else { return allData }
        
        let calendar = Calendar.current
        let thresholdDays = Constants.statisticsResetThresholdDays
        
        // Find the last gap that exceeds threshold
        var lastGapIndex = 0
        
        for i in 1..<allData.count {
            let gap = calendar.dateComponents([.day], from: allData[i - 1].date, to: allData[i].date).day ?? 0
            if gap > thresholdDays {
                lastGapIndex = i
            }
        }
        
        // Return data after the gap
        return Array(allData[lastGapIndex...])
    }
    
    /// Calculate weighted daily average
    private func calculateWeightedAverage(from data: [(date: Date, repetitions: Int)]) -> Double {
        guard !data.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var totalWeightedReps: Double = 0
        var totalWeight: Double = 0
        
        for item in data {
            let daysAgo = calendar.dateComponents([.day], from: item.date, to: today).day ?? 0
            
            // Weight formula: weight = 1 / (1 + daysAgo / 30)
            let weight = 1.0 / (1.0 + Double(daysAgo) / 30.0)
            
            totalWeightedReps += Double(item.repetitions) * weight
            totalWeight += weight
        }
        
        return totalWeight > 0 ? totalWeightedReps / totalWeight : 0
    }
    
    /// Calculate optimistic estimate (top 25% performance)
    private func calculateOptimisticAverage(from data: [(date: Date, repetitions: Int)]) -> Double {
        guard !data.isEmpty else { return 0 }
        
        // Get all daily totals sorted descending
        let sortedReps = data.map { $0.repetitions }.sorted(by: >)
        
        // Take top 25%
        let topCount = max(1, sortedReps.count / 4)
        let topReps = sortedReps.prefix(topCount)
        
        return Double(topReps.reduce(0, +)) / Double(topCount)
    }
    
    /// Calculate pessimistic estimate (accounting for zero days)
    private func calculatePessimisticAverage(from data: [(date: Date, repetitions: Int)], practice: Practice) -> Double {
        guard !data.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        
        // Get the date range
        guard let firstDate = data.first?.date,
              let lastDate = data.last?.date else { return 0 }
        
        // Calculate total days in range (including zero days)
        let totalDays = max(1, (calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0) + 1)
        
        // Calculate total repetitions
        let totalReps = data.reduce(0) { $0 + $1.repetitions }
        
        // Pessimistic average includes all days (including zeros)
        let avgWithZeros = Double(totalReps) / Double(totalDays)
        
        // Apply a further reduction factor based on consistency
        let activeDays = data.count
        let consistency = Double(activeDays) / Double(totalDays)
        
        // Lower consistency = more pessimistic prediction
        return avgWithZeros * (0.7 + 0.3 * consistency)
    }
    
    /// Calculate prediction with given data
    private func calculatePrediction(
        for practice: Practice,
        using data: [(date: Date, repetitions: Int)]
    ) -> PredictionResult {
        let remaining = practice.remaining
        let daysOfData = data.count
        
        // Calculate averages
        let weightedAvg = calculateWeightedAverage(from: data)
        let optimisticAvg = calculateOptimisticAverage(from: data)
        let pessimisticAvg = calculatePessimisticAverage(from: data, practice: practice)
        
        // Calculate days to completion
        let mostLikelyDays = weightedAvg > 0 ? Int(ceil(Double(remaining) / weightedAvg)) : Int.max
        let optimisticDays = optimisticAvg > 0 ? Int(ceil(Double(remaining) / optimisticAvg)) : Int.max
        let pessimisticDays = pessimisticAvg > 0 ? Int(ceil(Double(remaining) / pessimisticAvg)) : Int.max
        
        // Calculate dates
        let calendar = Calendar.current
        let mostLikelyDate = calendar.date(byAdding: .day, value: mostLikelyDays, to: Date()) ?? Date.distantFuture
        let optimisticDate = calendar.date(byAdding: .day, value: optimisticDays, to: Date()) ?? Date.distantFuture
        let pessimisticDate = calendar.date(byAdding: .day, value: pessimisticDays, to: Date()) ?? Date.distantFuture
        
        // Determine confidence level
        let confidence = calculateConfidence(daysOfData: daysOfData, practice: practice)
        
        return PredictionResult(
            mostLikelyDate: mostLikelyDate,
            mostLikelyDays: mostLikelyDays,
            optimisticDate: optimisticDate,
            pessimisticDate: pessimisticDate,
            confidence: confidence,
            basedOnDays: daysOfData,
            dailyAverage: weightedAvg,
            isCompleted: false
        )
    }
    
    /// Create result for insufficient data
    private func createInsufficientDataResult(for practice: Practice, daysOfData: Int) -> PredictionResult {
        // Use default repetition as fallback estimate
        let defaultDaily = Double(practice.defaultRepetition)
        let remaining = practice.remaining
        let estimatedDays = defaultDaily > 0 ? Int(ceil(Double(remaining) / defaultDaily)) : 1000
        
        let calendar = Calendar.current
        let estimatedDate = calendar.date(byAdding: .day, value: estimatedDays, to: Date()) ?? Date.distantFuture
        
        return PredictionResult(
            mostLikelyDate: estimatedDate,
            mostLikelyDays: estimatedDays,
            optimisticDate: estimatedDate,
            pessimisticDate: estimatedDate,
            confidence: .insufficient,
            basedOnDays: daysOfData,
            dailyAverage: defaultDaily,
            isCompleted: false
        )
    }
    
    /// Calculate confidence level based on data availability and consistency
    private func calculateConfidence(daysOfData: Int, practice: Practice) -> ConfidenceLevel {
        if daysOfData < 7 {
            return .insufficient
        } else if daysOfData < 15 {
            return .low
        } else if daysOfData < 31 {
            return .medium
        } else {
            // Check for regular practice (consistency > 50%)
            let consistency = statisticsService.consistency(for: practice, inLast: 30)
            return consistency > 0.5 ? .high : .medium
        }
    }
}

// MARK: - Formatted Strings

extension PredictionResult {
    
    /// Formatted most likely date
    var formattedMostLikelyDate: String {
        if isCompleted {
            return String(localized: "statistics.completed", defaultValue: "Completed!")
        }
        return mostLikelyDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    /// Formatted date range
    var formattedDateRange: String {
        if isCompleted {
            return String(localized: "statistics.completed", defaultValue: "Completed!")
        }
        
        let optimistic = optimisticDate.formatted(date: .abbreviated, time: .omitted)
        let pessimistic = pessimisticDate.formatted(date: .abbreviated, time: .omitted)
        
        return "\(optimistic) – \(pessimistic)"
    }
    
    /// Formatted days remaining
    var formattedDaysRemaining: String {
        if isCompleted {
            return "0"
        }
        
        if mostLikelyDays > 365 {
            let years = mostLikelyDays / 365
            return L10n.Statistics.yearsRemaining(years)
        }
        
        return L10n.Statistics.daysRemaining(mostLikelyDays)
    }
    
    /// Formatted daily average
    var formattedDailyAverage: String {
        if dailyAverage < 1 {
            return "< 1"
        }
        return String(format: "%.0f", dailyAverage)
    }
}
