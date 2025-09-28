import Foundation

extension DateFormatter {
    static func formatDateRange(startDate: Date, endDate: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        // Check if it's a full month
        if let monthInterval = calendar.dateInterval(of: .month, for: startDate) {
            let monthStart = monthInterval.start
            let monthEnd = calendar.date(byAdding: .day, value: -1, to: monthInterval.end)!
            
            if calendar .isDate(startDate, inSameDayAs: monthStart) &&
                calendar.isDate(endDate, inSameDayAs: monthEnd) {
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: startDate)
        }
    }
        
        // Check if it's a full year (from start of year to today or end of year)
        if let yearInterval = calendar.dateInterval(of: .year, for: startDate) {
            let yearStart = yearInterval.start
            
            if calendar.isDate(startDate, inSameDayAs: yearStart) {
                formatter.dateFormat = "yyyy"
                return formatter.string(from: startDate)
            }
        }
        
        // Same day
        if calendar.isDate(startDate, inSameDayAs: endDate) {
            formatter.dateStyle = .medium
            return formatter.string(from: startDate)
        }
        
        // Default range format (including weeks)
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - Date Period Helpers
extension Date {
    static var startOfCurrentYear: Date {
        return Calendar.current.dateInterval(of: .year, for: Date())?.start ?? Date()
    }
    
    static var endOfCurrentYear: Date {
        let calendar = Calendar.current
        let yearStart = calendar.dateInterval(of: .year, for: Date())?.start ?? Date()
        return calendar.date(byAdding: .second, value: -1, to: calendar.date(byAdding: .year, value: 1, to: yearStart)!) ?? Date()
    }
    
    static var startOfCurrentMonth: Date {
        return Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
    }
    
    static var endOfCurrentMonth: Date {
        let calendar = Calendar.current
        let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        return calendar.date(byAdding: .second, value: -1, to: calendar.date(byAdding: .month, value: 1, to: monthStart)!) ?? Date()
    }
    
    static var startOfCurrentWeek: Date {
        return Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
    }
    
    static var endOfCurrentWeek: Date {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return calendar.date(byAdding: .second, value: -1, to: calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!) ?? Date()
    }
}
