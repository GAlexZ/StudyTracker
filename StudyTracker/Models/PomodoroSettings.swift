import SwiftUI
import Foundation
import AppKit
import Charts
import UserNotifications

class PomodoroSettings: ObservableObject, Codable {
    @Published var workDuration: TimeInterval = 25 * 60 // 25 minutes in seconds
    @Published var shortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    @Published var longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    @Published var sessionsPerDay: Int = 8
    @Published var sessionsBeforeLongBreak: Int = 4
    
    enum CodingKeys: String, CodingKey {
        case workDuration, shortBreakDuration, longBreakDuration, sessionsPerDay, sessionsBeforeLongBreak
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workDuration = try container.decode(TimeInterval.self, forKey: .workDuration)
        shortBreakDuration = try container.decode(TimeInterval.self, forKey: .shortBreakDuration)
        longBreakDuration = try container.decode(TimeInterval.self, forKey: .longBreakDuration)
        sessionsPerDay = try container.decode(Int.self, forKey: .sessionsPerDay)
        sessionsBeforeLongBreak = try container.decode(Int.self, forKey: .sessionsBeforeLongBreak)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workDuration, forKey: .workDuration)
        try container.encode(shortBreakDuration, forKey: .shortBreakDuration)
        try container.encode(longBreakDuration, forKey: .longBreakDuration)
        try container.encode(sessionsPerDay, forKey: .sessionsPerDay)
        try container.encode(sessionsBeforeLongBreak, forKey: .sessionsBeforeLongBreak)
    }
}

