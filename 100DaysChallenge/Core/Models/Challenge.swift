//
//  Challenge.swift
//  100DaysChallenge
//
//  Challenge model
//

import Foundation

struct Challenge: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var accentColor: String // Hex color string
    var startDate: Date
    var completedDaysSet: Set<Int> // Days 1-100 that are completed
    
    init(id: String = UUID().uuidString, title: String, accentColor: String, startDate: Date = Date(), completedDaysSet: Set<Int> = []) {
        self.id = id
        self.title = title
        self.accentColor = accentColor
        self.startDate = startDate
        self.completedDaysSet = completedDaysSet
    }
    
    // Current day based on start date
    var currentDay: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)
        
        guard let days = calendar.dateComponents([.day], from: start, to: today).day else {
            return 1
        }
        
        let day = days + 1
        return max(1, min(day, 100))
    }
    
    // Progress percentage
    var progress: Double {
        Double(completedDaysSet.count) / 100.0
    }
    
    // Is today completed
    var isTodayCompleted: Bool {
        completedDaysSet.contains(currentDay)
    }
}

