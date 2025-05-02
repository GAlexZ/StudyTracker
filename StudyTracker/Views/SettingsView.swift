import SwiftUI
import Foundation
import AppKit
import Charts
import UserNotifications
struct SettingsView: View {
    @ObservedObject var pomodoroTimer: PomodoroTimer
    @State private var workMinutes: Double
    @State private var shortBreakMinutes: Double
    @State private var longBreakMinutes: Double
    @State private var sessionsPerDay: Double
    @State private var sessionsBeforeLongBreak: Double
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
        _workMinutes = State(initialValue: pomodoroTimer.settings.workDuration / 60)
        _shortBreakMinutes = State(initialValue: pomodoroTimer.settings.shortBreakDuration / 60)
        _longBreakMinutes = State(initialValue: pomodoroTimer.settings.longBreakDuration / 60)
        _sessionsPerDay = State(initialValue: Double(pomodoroTimer.settings.sessionsPerDay))
        _sessionsBeforeLongBreak = State(initialValue: Double(pomodoroTimer.settings.sessionsBeforeLongBreak))
    }
    
    var body: some View {
        Form {
            Section("Timer Settings") {
                HStack {
                    Text("Work Duration:")
                    Slider(value: $workMinutes, in: 1...60, step: 1)
                    Text("\(Int(workMinutes)) min")
                        .frame(width: 60)
                }
                
                HStack {
                    Text("Short Break:")
                    Slider(value: $shortBreakMinutes, in: 1...30, step: 1)
                    Text("\(Int(shortBreakMinutes)) min")
                        .frame(width: 60)
                }
                
                HStack {
                    Text("Long Break:")
                    Slider(value: $longBreakMinutes, in: 5...60, step: 5)
                    Text("\(Int(longBreakMinutes)) min")
                        .frame(width: 60)
                }
            }
            
            Section("Session Settings") {
                HStack {
                    Text("Sessions per day:")
                    Slider(value: $sessionsPerDay, in: 1...16, step: 1)
                    Text("\(Int(sessionsPerDay))")
                        .frame(width: 40)
                }
                
                HStack {
                    Text("Sessions before long break:")
                    Slider(value: $sessionsBeforeLongBreak, in: 1...8, step: 1)
                    Text("\(Int(sessionsBeforeLongBreak))")
                        .frame(width: 40)
                }
            }
            
            Section {
                Button("Save Settings") {
                    pomodoroTimer.settings.workDuration = workMinutes * 60
                    pomodoroTimer.settings.shortBreakDuration = shortBreakMinutes * 60
                    pomodoroTimer.settings.longBreakDuration = longBreakMinutes * 60
                    pomodoroTimer.settings.sessionsPerDay = Int(sessionsPerDay)
                    pomodoroTimer.settings.sessionsBeforeLongBreak = Int(sessionsBeforeLongBreak)
                    
                    pomodoroTimer.saveSettings()
                    if pomodoroTimer.mode == .idle {
                        pomodoroTimer.resetTimer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
    }
}
