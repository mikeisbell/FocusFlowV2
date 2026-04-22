import Testing
import Foundation
@testable import FocusFlowV2

@Suite("SchedulerService")
struct SchedulerServiceTests {

    // Build a fixed Date from components in the current calendar/timezone.
    private func date(year: Int, month: Int, day: Int, hour: Int, minute: Int = 0) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        c.hour = hour; c.minute = minute; c.second = 0
        return Calendar.current.date(from: c)!
    }

    private func components(_ d: Date) -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
    }

    @Test func nextAvailableSlot_roundsUpToNextHour() {
        let input = date(year: 2026, month: 4, day: 21, hour: 9, minute: 30)
        let result = SchedulerService.nextAvailableSlot(after: input)
        let c = components(result)
        #expect(c.hour == 10)
        #expect(c.minute == 0)
        #expect(c.second == 0)
    }

    @Test func nextAvailableSlot_atTopOfHour_advancesOneHour() {
        // An exact hour should still advance — the slot is always the NEXT hour.
        let input = date(year: 2026, month: 4, day: 21, hour: 9, minute: 0)
        let result = SchedulerService.nextAvailableSlot(after: input)
        let c = components(result)
        #expect(c.hour == 10)
        #expect(c.minute == 0)
        #expect(c.second == 0)
    }

    @Test func nextAvailableSlot_lateEvening_crossesMidnight() {
        let input = date(year: 2026, month: 4, day: 21, hour: 23, minute: 30)
        let result = SchedulerService.nextAvailableSlot(after: input)
        let c = components(result)
        #expect(c.hour == 0)
        #expect(c.minute == 0)
        #expect(c.second == 0)
        #expect(c.day == 22)    // rolled into the next day
        #expect(c.month == 4)
        #expect(c.year == 2026)
    }

    @Test func nextAvailableSlot_preservesDate() {
        // For a same-day slot the date components must stay on the input day.
        let input = date(year: 2026, month: 4, day: 21, hour: 9, minute: 30)
        let result = SchedulerService.nextAvailableSlot(after: input)
        let c = components(result)
        #expect(c.year == 2026)
        #expect(c.month == 4)
        #expect(c.day == 21)
    }
}
