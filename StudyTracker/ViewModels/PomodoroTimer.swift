import SwiftUI
import Foundation
import AppKit
import Charts
import UserNotifications

enum TimerMode {
    case work
    case shortBreak
    case longBreak
    case idle
}

class PomodoroTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var mode: TimerMode = .idle
    @Published var isRunning = false
    @Published var completedSessions = 0
    @Published var sessions: [PomodoroSession] = []
    @Published var settings = PomodoroSettings()
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    
    private let sessionsKey = "SavedPomodoroSessions"
    private let settingsKey = "PomodoroSettings"
    
    init() {
        loadSessions()
        loadSettings()
        resetTimer()
    }
    
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        if mode == .idle {
            mode = .work
            resetTimerForCurrentMode()
        }
        
        if sessionStartTime == nil {
            sessionStartTime = Date()
        }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeCurrentSession()
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        mode = .idle
        resetTimerForCurrentMode()
        sessionStartTime = nil
    }
    
    func completeCurrentSession() {
        pauseTimer()
        
        // Play sound and show notification
        NSSound(named: "Glass")?.play()
        showNotification()
        
        if mode == .work {
            // Record completed work session
            if let startTime = sessionStartTime {
                let session = PomodoroSession(
                    date: startTime,
                    completed: true,
                    duration: settings.workDuration
                )
                sessions.append(session)
                saveSessions()
            }
            
            completedSessions += 1
            
            // Determine next break type
            if completedSessions % settings.sessionsBeforeLongBreak == 0 {
                mode = .longBreak
            } else {
                mode = .shortBreak
            }
        } else {
            // After a break, go back to work mode
            mode = .work
        }
        
        resetTimerForCurrentMode()
        sessionStartTime = Date()
        startTimer()
    }
    
    private func resetTimerForCurrentMode() {
        switch mode {
        case .work:
            timeRemaining = settings.workDuration
        case .shortBreak:
            timeRemaining = settings.shortBreakDuration
        case .longBreak:
            timeRemaining = settings.longBreakDuration
        case .idle:
            timeRemaining = settings.workDuration
        }
    }
    
    func showNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                
                switch self.mode {
                case .work:
                    content.title = "Work Session Completed!"
                    content.body = "Time for a break."
                case .shortBreak, .longBreak:
                    content.title = "Break Completed!"
                    content.body = "Ready to focus again?"
                case .idle:
                    return
                }
                
                content.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: nil
                )
                
                center.add(request)
            }
        }
    }
    
    // MARK: - Session Tracking & Persistence
    
    func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([PomodoroSession].self, from: data) {
            sessions = decoded
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(PomodoroSettings.self, from: data) {
            settings = decoded
        }
    }
    
    func sessionsForDate(_ date: Date) -> [PomodoroSession] {
        let calendar = Calendar.current
        return sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }
    }
    
    func sessionsInRange(from startDate: Date, to endDate: Date) -> [PomodoroSession] {
        let calendar = Calendar.current
        
        return sessions.filter { session in
            let sessionDate = calendar.startOfDay(for: session.date)
            return sessionDate >= calendar.startOfDay(for: startDate) &&
                   sessionDate <= calendar.startOfDay(for: endDate)
        }
    }
}

