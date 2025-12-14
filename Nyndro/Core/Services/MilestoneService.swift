//
//  MilestoneService.swift
//  Nyndro
//
//  Service for tracking and celebrating practice milestones
//

import Foundation
import SwiftData

// MARK: - Milestone Type

/// Types of milestones that can be achieved
enum MilestoneType: String, Codable {
    case personalBest = "personal_best"
    case streak7 = "streak_7"
    case streak21 = "streak_21"
    case streak30 = "streak_30"
    case streak100 = "streak_100"
    case streak365 = "streak_365"
    case progress25 = "progress_25"
    case progress50 = "progress_50"
    case progress75 = "progress_75"
    case progress90 = "progress_90"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .personalBest:
            return String(localized: "milestone.personal_best", defaultValue: "Personal Best!")
        case .streak7:
            return String(localized: "milestone.streak_7", defaultValue: "7 Day Streak!")
        case .streak21:
            return String(localized: "milestone.streak_21", defaultValue: "21 Day Streak!")
        case .streak30:
            return String(localized: "milestone.streak_30", defaultValue: "30 Day Streak!")
        case .streak100:
            return String(localized: "milestone.streak_100", defaultValue: "100 Day Streak!")
        case .streak365:
            return String(localized: "milestone.streak_365", defaultValue: "365 Day Streak!")
        case .progress25:
            return String(localized: "milestone.progress_25", defaultValue: "25% Complete!")
        case .progress50:
            return String(localized: "milestone.progress_50", defaultValue: "Halfway There!")
        case .progress75:
            return String(localized: "milestone.progress_75", defaultValue: "75% Complete!")
        case .progress90:
            return String(localized: "milestone.progress_90", defaultValue: "Almost There!")
        case .completed:
            return String(localized: "milestone.completed", defaultValue: "Practice Completed!")
        }
    }
    
    var icon: String {
        switch self {
        case .personalBest: return "star.fill"
        case .streak7, .streak21, .streak30, .streak100, .streak365: return "flame.fill"
        case .progress25, .progress50, .progress75, .progress90: return "chart.bar.fill"
        case .completed: return "checkmark.seal.fill"
        }
    }
    
    /// Celebration level (1 = subtle, 2 = medium, 3 = full)
    var celebrationLevel: Int {
        switch self {
        case .personalBest: return 2
        case .streak7: return 2
        case .streak21: return 2
        case .streak30: return 3
        case .streak100: return 3
        case .streak365: return 3
        case .progress25: return 1
        case .progress50: return 3
        case .progress75: return 1
        case .progress90: return 2
        case .completed: return 3
        }
    }
}

// MARK: - Milestone Achievement

/// Represents an achieved milestone
struct MilestoneAchievement {
    let type: MilestoneType
    let practice: Practice
    let achievedAt: Date
    let value: Int? // e.g., streak count, percentage, etc.
    
    var displayValue: String? {
        guard let value = value else { return nil }
        
        switch type {
        case .personalBest:
            return "\(value) repetitions"
        case .streak7, .streak21, .streak30, .streak100, .streak365:
            return "\(value) days"
        case .progress25, .progress50, .progress75, .progress90, .completed:
            return "\(value)%"
        }
    }
}

// MARK: - Milestone Service

/// Service responsible for detecting and tracking milestones
@MainActor
final class MilestoneService: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    private let statisticsService: StatisticsService
    
    /// Last known streak values for detecting new streaks
    private var lastKnownStreaks: [UUID: Int] = [:]
    
    /// Last known best day totals for detecting personal bests
    private var lastKnownBestDayTotals: [UUID: Int] = [:]
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.statisticsService = StatisticsService(modelContext: modelContext)
    }
    
    // MARK: - Milestone Detection
    
    /// Check for new milestones after adding repetitions
    func checkMilestones(for practice: Practice, previousProgress: Int) -> [MilestoneAchievement] {
        var achievements: [MilestoneAchievement] = []
        
        // Check progress milestones
        if let progressMilestone = checkProgressMilestone(for: practice, previousProgress: previousProgress) {
            achievements.append(progressMilestone)
        }
        
        // Check streak milestones
        if let streakMilestone = checkStreakMilestone(for: practice) {
            achievements.append(streakMilestone)
        }
        
        // Check personal best
        if let personalBest = checkPersonalBest(for: practice) {
            achievements.append(personalBest)
        }
        
        return achievements
    }
    
    // MARK: - Progress Milestones
    
    private func checkProgressMilestone(for practice: Practice, previousProgress: Int) -> MilestoneAchievement? {
        let previousPercentage = Double(previousProgress) / Double(practice.maxRepetition) * 100
        let currentPercentage = practice.progressPercentage * 100
        
        // Check if we crossed any milestone thresholds
        let milestones: [(Int, MilestoneType)] = [
            (25, .progress25),
            (50, .progress50),
            (75, .progress75),
            (90, .progress90),
            (100, .completed)
        ]
        
        for (threshold, type) in milestones {
            if previousPercentage < Double(threshold) && currentPercentage >= Double(threshold) {
                return MilestoneAchievement(
                    type: type,
                    practice: practice,
                    achievedAt: Date(),
                    value: threshold
                )
            }
        }
        
        return nil
    }
    
    // MARK: - Streak Milestones
    
    private func checkStreakMilestone(for practice: Practice) -> MilestoneAchievement? {
        let currentStreak = statisticsService.currentStreak(for: practice)
        let lastKnownStreak = lastKnownStreaks[practice.id] ?? 0
        
        // Update last known streak
        lastKnownStreaks[practice.id] = currentStreak
        
        // Check if we crossed any streak thresholds
        let streakMilestones: [(Int, MilestoneType)] = [
            (7, .streak7),
            (21, .streak21),
            (30, .streak30),
            (100, .streak100),
            (365, .streak365)
        ]
        
        for (threshold, type) in streakMilestones {
            if lastKnownStreak < threshold && currentStreak >= threshold {
                return MilestoneAchievement(
                    type: type,
                    practice: practice,
                    achievedAt: Date(),
                    value: currentStreak
                )
            }
        }
        
        return nil
    }
    
    // MARK: - Personal Best
    
    private func checkPersonalBest(for practice: Practice) -> MilestoneAchievement? {
        guard let bestDay = statisticsService.bestDayTotal(for: practice) else {
            return nil
        }
        
        let calendar = Calendar.current
        guard calendar.isDateInToday(bestDay.date) else {
            return nil
        }
        
        let lastKnownBest = lastKnownBestDayTotals[practice.id] ?? 0
        let todayTotal = statisticsService.repetitions(for: practice, on: Date())
        
        // Only celebrate if this is a new best (not the first day)
        if todayTotal > lastKnownBest && lastKnownBest > 0 {
            lastKnownBestDayTotals[practice.id] = todayTotal
            
            return MilestoneAchievement(
                type: .personalBest,
                practice: practice,
                achievedAt: Date(),
                value: todayTotal
            )
        }
        
        // Update last known best
        lastKnownBestDayTotals[practice.id] = todayTotal
        
        return nil
    }
    
    // MARK: - Celebration
    
    /// Trigger celebration for a milestone
    func celebrate(milestone: MilestoneAchievement) {
        let level = milestone.type.celebrationLevel
        
        // Haptic feedback
        HapticService.shared.milestoneReached(level: level)
        
        // Sound
        SoundService.shared.playMilestoneSound(level: level)
    }
    
    /// Trigger full completion celebration
    func celebrateCompletion(for practice: Practice) {
        HapticService.shared.practiceCompleted()
        SoundService.shared.playCompletionSound()
    }
    
    // MARK: - Summary
    
    /// Get summary of achieved milestones for a practice
    func getMilestoneSummary(for practice: Practice) -> MilestoneSummary {
        let currentStreak = statisticsService.currentStreak(for: practice)
        let bestStreak = statisticsService.bestStreak(for: practice)
        let bestDay = statisticsService.bestDayTotal(for: practice)
        
        return MilestoneSummary(
            practice: practice,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            bestDayTotal: bestDay?.total ?? 0,
            bestDayDate: bestDay?.date,
            progressPercentage: practice.progressPercentageInt,
            isCompleted: practice.isCompleted
        )
    }
}

// MARK: - Milestone Summary

/// Summary of milestone-related stats for a practice
struct MilestoneSummary {
    let practice: Practice
    let currentStreak: Int
    let bestStreak: Int
    let bestDayTotal: Int
    let bestDayDate: Date?
    let progressPercentage: Int
    let isCompleted: Bool
    
    var achievedStreakMilestones: [MilestoneType] {
        var milestones: [MilestoneType] = []
        
        if bestStreak >= 7 { milestones.append(.streak7) }
        if bestStreak >= 21 { milestones.append(.streak21) }
        if bestStreak >= 30 { milestones.append(.streak30) }
        if bestStreak >= 100 { milestones.append(.streak100) }
        if bestStreak >= 365 { milestones.append(.streak365) }
        
        return milestones
    }
    
    var achievedProgressMilestones: [MilestoneType] {
        var milestones: [MilestoneType] = []
        
        if progressPercentage >= 25 { milestones.append(.progress25) }
        if progressPercentage >= 50 { milestones.append(.progress50) }
        if progressPercentage >= 75 { milestones.append(.progress75) }
        if progressPercentage >= 90 { milestones.append(.progress90) }
        if isCompleted { milestones.append(.completed) }
        
        return milestones
    }
    
    var nextStreakMilestone: (days: Int, type: MilestoneType)? {
        let streakMilestones = [7, 21, 30, 100, 365]
        
        for milestone in streakMilestones {
            if currentStreak < milestone {
                let daysUntil = milestone - currentStreak
                let type: MilestoneType
                
                switch milestone {
                case 7: type = .streak7
                case 21: type = .streak21
                case 30: type = .streak30
                case 100: type = .streak100
                default: type = .streak365
                }
                
                return (days: daysUntil, type: type)
            }
        }
        
        return nil
    }
    
    var nextProgressMilestone: (percentage: Int, type: MilestoneType)? {
        let progressMilestones = [25, 50, 75, 90, 100]
        
        for milestone in progressMilestones {
            if progressPercentage < milestone {
                let type: MilestoneType
                
                switch milestone {
                case 25: type = .progress25
                case 50: type = .progress50
                case 75: type = .progress75
                case 90: type = .progress90
                default: type = .completed
                }
                
                return (percentage: milestone - progressPercentage, type: type)
            }
        }
        
        return nil
    }
}
