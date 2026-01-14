import Foundation

extension DateFormatter {
    static func formatDateRange(startDate: Date, endDate: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        // Check if it's a full month
        if let monthInterval = calendar.dateInterval(of: .month, for: startDate) {
            let monthStart = monthInterval.start
            let monthEnd = calendar.date(byAdding: .day, value: -1, to: monthInterval.end)!
            
            if calendar.isDate(startDate, inSameDayAs: monthStart) &&
               calendar.isDate(endDate, inSameDayAs: monthEnd) {
                
                formatter.dateFormat = "LLLL yyyy"
                let formattedString = formatter.string(from: startDate)
                return formattedString.prefix(1).uppercased() + formattedString.dropFirst()
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
        
        // Check if dates are in the same month and year for compact format
        let startComponents = calendar.dateComponents([.year, .month], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month], from: endDate)
        
        if startComponents.year == endComponents.year && startComponents.month == endComponents.month {
            // Same month and year: "5-11 jan. 2026"
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d"
            
            let monthYearFormatter = DateFormatter()
            monthYearFormatter.dateFormat = "MMM yyyy"
            
            let startDay = dayFormatter.string(from: startDate)
            let endDay = dayFormatter.string(from: endDate)
            let monthYear = monthYearFormatter.string(from: startDate)
            
            return "\(startDay)-\(endDay) \(monthYear)"
        } else if startComponents.year == endComponents.year {
            // Same year but different months: "25 dec. - 5 jan. 2026"
            let dayMonthFormatter = DateFormatter()
            dayMonthFormatter.dateFormat = "d MMM"
            
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            
            let startDayMonth = dayMonthFormatter.string(from: startDate)
            let endDayMonth = dayMonthFormatter.string(from: endDate)
            let year = yearFormatter.string(from: endDate)
            
            return "\(startDayMonth) - \(endDayMonth) \(year)"
        }
        
        // Default range format (different years)
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
