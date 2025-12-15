//
//  NotificationService.swift
//  Nyndro
//
//  Service for managing local notifications and reminders
//

import Foundation
import UserNotifications
import SwiftData

// MARK: - Notification Service

/// Service responsible for scheduling and managing local notifications
@MainActor
final class NotificationService: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// Request notification authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Reminder Scheduling
    
    /// Schedule a notification for a reminder
    func scheduleReminder(_ reminder: Reminder) async throws {
        if !isAuthorized {
            let granted = await requestAuthorization()
            if !granted {
                throw NotificationError.notAuthorized
            }
        }
        
        guard reminder.isActive else { return }
        
        // Cancel existing notification for this reminder
        await cancelReminder(reminder)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = L10n.App.name
        content.body = createReminderBody(for: reminder)
        content.sound = .default
        content.badge = 1
        
        // Add practice info to userInfo
        if let practice = reminder.practice {
            content.userInfo = [
                "reminderId": reminder.id.uuidString,
                "practiceId": practice.id.uuidString,
                "practiceName": practice.name
            ]
        }
        
        // Create trigger based on repeat type
        let trigger = createTrigger(for: reminder)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: reminder.notificationId,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        try await notificationCenter.add(request)
    }
    
    /// Cancel a scheduled reminder notification
    func cancelReminder(_ reminder: Reminder) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.notificationId])
    }
    
    /// Cancel all scheduled notifications for a practice
    func cancelAllReminders(for practice: Practice) async {
        let identifiers = practice.reminders.map { $0.notificationId }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Reschedule all active reminders
    func rescheduleAllReminders(from modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<Reminder>(
            predicate: #Predicate { $0.isActive }
        )
        
        guard let reminders = try? modelContext.fetch(descriptor) else { return }
        
        for reminder in reminders {
            try? await scheduleReminder(reminder)
        }
    }
    
    // MARK: - Notification Management
    
    /// Get all pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }
    
    /// Remove all pending notifications
    func removeAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    /// Clear badge count
    func clearBadge() async {
        try? await notificationCenter.setBadgeCount(0)
    }
    
    // MARK: - Private Methods
    
    private func createReminderBody(for reminder: Reminder) -> String {
        if let practice = reminder.practice {
            return String(
                localized: "notification.reminder.body",
                defaultValue: "Time for your \(practice.name) practice"
            )
        }
        return String(
            localized: "notification.reminder.body.generic",
            defaultValue: "Time for your practice"
        )
    }
    
    private func createTrigger(for reminder: Reminder) -> UNNotificationTrigger {
        let calendar = Calendar.current
        let dateComponents: DateComponents
        
        switch reminder.repeatType {
        case .none:
            // One-time notification at exact date/time
            dateComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.nextOccurrence
            )
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
        case .daily:
            // Daily at same time
            dateComponents = calendar.dateComponents(
                [.hour, .minute],
                from: reminder.scheduledDate
            )
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
        case .weekly:
            // Weekly on same day at same time
            dateComponents = calendar.dateComponents(
                [.weekday, .hour, .minute],
                from: reminder.scheduledDate
            )
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
        case .monthly:
            // Monthly on same day at same time
            dateComponents = calendar.dateComponents(
                [.day, .hour, .minute],
                from: reminder.scheduledDate
            )
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
    }
}

// MARK: - Notification Errors

enum NotificationError: LocalizedError {
    case notAuthorized
    case schedulingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notification permission not granted"
        case .schedulingFailed(let reason):
            return "Failed to schedule notification: \(reason)"
        }
    }
}

// MARK: - Notification Center Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle navigation to practice if needed
        if let practiceIdString = userInfo["practiceId"] as? String,
           let practiceId = UUID(uuidString: practiceIdString) {
            // Post notification to navigate to practice
            NotificationCenter.default.post(
                name: .navigateToPractice,
                object: nil,
                userInfo: ["practiceId": practiceId]
            )
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToPractice = Notification.Name("navigateToPractice")
}
