import Foundation

protocol DateProviding {
    func now() -> Date
    func startOfDay(_ date: Date) -> Date
    func endOfDay(_ date: Date) -> Date
    func isNewDay(_ lastCheckedDate: Date) -> Bool
}

struct DateProvider: DateProviding {
    private let calendar = Calendar.current
    
    func now() -> Date {
        Date()
    }
    
    func startOfDay(_ date: Date = Date()) -> Date {
        calendar.startOfDay(for: date)
    }
    
    func endOfDay(_ date: Date = Date()) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay(date)) ?? date
    }
    
    func isNewDay(_ lastCheckedDate: Date) -> Bool {
        !calendar.isDate(lastCheckedDate, inSameDayAs: now())
    }
}

// Mock implementation for testing
struct MockDateProvider: DateProviding {
    var mockNow: Date = Date()
    
    func now() -> Date {
        mockNow
    }
    
    func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    func endOfDay(_ date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay(date)) ?? date
    }
    
    func isNewDay(_ lastCheckedDate: Date) -> Bool {
        !Calendar.current.isDate(mockNow, inSameDayAs: lastCheckedDate)
    }
}
