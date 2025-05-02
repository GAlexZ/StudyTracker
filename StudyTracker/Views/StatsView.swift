import SwiftUI
import Foundation
import AppKit
import Charts
import UserNotifications
struct StatsView: View {
    @ObservedObject var pomodoroTimer: PomodoroTimer
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedDate = Date()
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack {
            // Time range picker
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Date picker
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal)
            
            // Chart and stats
            Group {
                if let chartData = getChartData() {
                    if chartData.isEmpty {
                        Text("No sessions found for the selected period")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        Chart {
                            ForEach(chartData, id: \.date) { item in
                                BarMark(
                                    x: .value("Date", item.date, unit: .day),
                                    y: .value("Sessions", item.count)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        
                        Divider()
                        
                        // Stats summary
                        HStack(spacing: 20) {
                            StatCard(title: "Total Sessions", value: "\(calculateTotalSessions())")
                            StatCard(title: "Total Time", value: formatHours(calculateTotalTime()))
                            StatCard(title: "Daily Average", value: String(format: "%.1f", calculateDailyAverage()))
                        }
                        .padding()
                    }
                } else {
                    Text("Select a time range to view statistics")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            
            Spacer()
        }
    }
    
    struct ChartDataPoint {
        var date: Date
        var count: Int
    }
    
    func getChartData() -> [ChartDataPoint]? {
        let calendar = Calendar.current
        let endDate = selectedDate
        
        let startDate: Date
        switch selectedTimeRange {
        case .day:
            // For day view, we'll break down by hours
            return nil // Not implemented for day view
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        case .month:
            startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        }
        
        // Get all sessions in the range
        let sessions = pomodoroTimer.sessionsInRange(from: startDate, to: endDate)
        
        // Create date points for each day in the range
        var result: [ChartDataPoint] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayEnd = calendar.endOfDay(for: currentDate)
            
            let sessionsOnDay = sessions.filter { session in
                session.date >= dayStart && session.date <= dayEnd
            }
            
            result.append(ChartDataPoint(date: currentDate, count: sessionsOnDay.count))
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    func calculateTotalSessions() -> Int {
        let (startDate, endDate) = getDateRange()
        return pomodoroTimer.sessionsInRange(from: startDate, to: endDate).count
    }
    
    func calculateTotalTime() -> TimeInterval {
        let (startDate, endDate) = getDateRange()
        let sessions = pomodoroTimer.sessionsInRange(from: startDate, to: endDate)
        return sessions.reduce(0) { $0 + $1.duration }
    }
    
    func calculateDailyAverage() -> Double {
        let (startDate, endDate) = getDateRange()
        let sessions = pomodoroTimer.sessionsInRange(from: startDate, to: endDate)
        
        // Calculate number of days in range
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let numberOfDays = max(1, components.day! + 1) // Add 1 because range is inclusive
        
        return Double(sessions.count) / Double(numberOfDays)
    }
    
    func getDateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let endDate = selectedDate
        
        let startDate: Date
        switch selectedTimeRange {
        case .day:
            startDate = calendar.startOfDay(for: endDate)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        case .month:
            startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        }
        
        return (startDate, endDate)
    }
    
    func formatHours(_ seconds: TimeInterval) -> String {
        let hours = seconds / 3600
        if hours < 1 {
            let minutes = Int(seconds / 60)
            return "\(minutes)m"
        } else {
            return String(format: "%.1fh", hours)
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

