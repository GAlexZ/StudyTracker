import SwiftUI
import Foundation
import AppKit
import Charts

struct TimerView: View {
    @ObservedObject var pomodoroTimer: PomodoroTimer
    
    var body: some View {
        VStack(spacing: 30) {
            // Session indicator
            Text(modeTitle)
                .font(.headline)
                .foregroundColor(modeColor)
            
            // Timer display
            Text(formatTime(pomodoroTimer.timeRemaining))
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(modeColor)
            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    pomodoroTimer.toggleTimer()
                }) {
                    Text(pomodoroTimer.isRunning ? "Pause" : "Start")
                        .frame(width: 100)
                }
                .buttonStyle(.borderedProminent)
                .tint(modeColor)
                
                Button(action: {
                    pomodoroTimer.resetTimer()
                }) {
                    Text("Reset")
                        .frame(width: 100)
                }
                .buttonStyle(.bordered)
            }
            
            // Session counter
            Text("Completed sessions today: \(todayCompletedSessions)")
                .font(.subheadline)
                .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var modeTitle: String {
        switch pomodoroTimer.mode {
        case .work:
            return "Work Session"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        case .idle:
            return "Ready to Start"
        }
    }
    
    var modeColor: Color {
        switch pomodoroTimer.mode {
        case .work:
            return .red
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        case .idle:
            return .gray
        }
    }
    
    var todayCompletedSessions: Int {
        let today = Date()
        return pomodoroTimer.sessionsForDate(today).count
    }
}
