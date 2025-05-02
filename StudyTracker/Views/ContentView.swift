import SwiftUI
import Foundation
import AppKit
import Charts
import UserNotifications

struct ContentView: View {
    @StateObject private var pomodoroTimer = PomodoroTimer()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView(pomodoroTimer: pomodoroTimer)
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(0)
            
            SettingsView(pomodoroTimer: pomodoroTimer)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
            
            StatsView(pomodoroTimer: pomodoroTimer)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(2)
        }
        .frame(minWidth: 400, minHeight: 400)
        .onAppear {
            // Create menu bar controller with the same timer instance
            _ = MenuBarController(pomodoroTimer: pomodoroTimer)
            
            // Request notification permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }
}

