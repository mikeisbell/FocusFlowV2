import Foundation

struct SchedulerService {
    // Returns the top of the next clock hour after `date`.
    // e.g. 9:30 AM → 10:00 AM, 9:00 AM → 10:00 AM
    static func nextAvailableSlot(after date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.hour = (components.hour ?? 0) + 1
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components) ?? date
    }
}
