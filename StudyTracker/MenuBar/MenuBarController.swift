import SwiftUI
import Foundation
import AppKit
import Charts
import UserNotifications
class MenuBarController {
    private var statusItem: NSStatusItem?
    private var pomodoroTimer: PomodoroTimer
    private var timerMenuItem: NSMenuItem?
    private var startStopMenuItem: NSMenuItem?
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
        setupMenuBar()
        
        // Update menu bar whenever timer changes
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateMenuBar()
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro Timer")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        buildMenu()
    }
    
    private func buildMenu() {
        let menu = NSMenu()
        
        // Timer display
        timerMenuItem = NSMenuItem(title: "25:00 (Idle)", action: nil, keyEquivalent: "")
        menu.addItem(timerMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        // Start/Stop
        startStopMenuItem = NSMenuItem(title: "Start", action: #selector(startStopAction), keyEquivalent: "")
        startStopMenuItem?.target = self
        menu.addItem(startStopMenuItem!)
        
        // Reset
        let resetMenuItem = NSMenuItem(title: "Reset", action: #selector(resetAction), keyEquivalent: "")
        resetMenuItem.target = self
        menu.addItem(resetMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Open Main Window
        let openMenuItem = NSMenuItem(title: "Open Pomodoro Timer", action: #selector(openMainWindow), keyEquivalent: "")
        openMenuItem.target = self
        menu.addItem(openMenuItem)
        
        // Quit
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "q")
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        statusItem?.menu = menu
    }
    
    func updateMenuBar() {
        let modeText: String
        switch pomodoroTimer.mode {
        case .work:
            modeText = "Work"
        case .shortBreak:
            modeText = "Short Break"
        case .longBreak:
            modeText = "Long Break"
        case .idle:
            modeText = "Idle"
        }
        
        timerMenuItem?.title = "\(formatTime(pomodoroTimer.timeRemaining)) (\(modeText))"
        startStopMenuItem?.title = pomodoroTimer.isRunning ? "Pause" : "Start"
        
        // Update icon based on timer mode
        if let button = statusItem?.button {
            switch pomodoroTimer.mode {
            case .work:
                button.image = NSImage(systemSymbolName: "timer.circle.fill", accessibilityDescription: "Work")
            case .shortBreak:
                button.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "Short Break")
            case .longBreak:
                button.image = NSImage(systemSymbolName: "figure.walk.circle.fill", accessibilityDescription: "Long Break")
            case .idle:
                button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Idle")
            }
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        // This is handled by the menu now
    }
    
    @objc func startStopAction() {
        pomodoroTimer.toggleTimer()
    }
    
    @objc func resetAction() {
        pomodoroTimer.resetTimer()
    }
    
    @objc func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc func quitAction() {
        NSApp.terminate(nil)
    }
}
