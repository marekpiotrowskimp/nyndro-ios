//
//  HapticService.swift
//  Nyndro
//
//  Service for providing haptic feedback
//

import UIKit

/// Service responsible for haptic feedback
final class HapticService {
    
    // MARK: - Singleton
    
    static let shared = HapticService()
    
    // MARK: - Generators
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - Initialization
    
    private init() {
        // Prepare generators
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Impact Feedback
    
    /// Trigger impact feedback based on style
    func impact(style: HapticStyle) {
        switch style {
        case .none:
            return
        case .light:
            lightGenerator.impactOccurred()
            lightGenerator.prepare()
        case .medium:
            mediumGenerator.impactOccurred()
            mediumGenerator.prepare()
        case .heavy:
            heavyGenerator.impactOccurred()
            heavyGenerator.prepare()
        }
    }
    
    /// Light impact for subtle feedback
    func lightImpact() {
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }
    
    /// Medium impact for standard feedback
    func mediumImpact() {
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }
    
    /// Heavy impact for strong feedback
    func heavyImpact() {
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }
    
    // MARK: - Notification Feedback
    
    /// Success notification (e.g., task completed)
    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }
    
    /// Warning notification
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }
    
    /// Error notification
    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }
    
    // MARK: - Selection Feedback
    
    /// Selection changed feedback (e.g., picker changed)
    func selectionChanged() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
    
    // MARK: - Composite Feedback
    
    /// Counter tap feedback - based on user preference
    func counterTap(style: HapticStyle) {
        impact(style: style)
    }
    
    /// Milestone reached - strong celebratory feedback
    func milestoneReached(level: Int) {
        switch level {
        case 1:
            mediumImpact()
        case 2:
            heavyImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.mediumImpact()
            }
        case 3:
            // Triple impact for major milestones
            heavyImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.heavyImpact()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.heavyImpact()
            }
        default:
            success()
        }
    }
    
    /// Practice completed celebration
    func practiceCompleted() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.heavyImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.success()
        }
    }
    
    /// Button tap feedback
    func buttonTap() {
        lightImpact()
    }
    
    /// Delete action feedback
    func deleteAction() {
        warning()
    }
}
