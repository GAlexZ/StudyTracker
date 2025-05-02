import SwiftUI
import Foundation
import AppKit
import Charts
import UserNotifications

struct PomodoroSession: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var completed: Bool
    var duration: TimeInterval
    
    init(date: Date = Date(), completed: Bool = true, duration: TimeInterval) {
        self.date = date
        self.completed = completed
        self.duration = duration
    }
}
