import Testing
import Foundation
import SwiftData
@testable import FocusFlowV2

// Reference point: 2026-04-21 at 09:00:00 local time.
// All test dates are expressed relative to this anchor so no test calls Date().
private let referenceDate: Date = {
    var c = DateComponents()
    c.year = 2026; c.month = 4; c.day = 21; c.hour = 9; c.minute = 0; c.second = 0
    return Calendar.current.date(from: c)!
}()

// MARK: - Shared filter helpers (mirror TodayView / LaterView logic)

private var todayStart: Date { Calendar.current.startOfDay(for: referenceDate) }
private var todayEnd: Date { Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! }

private func currentTask(from tasks: [TaskItem]) -> TaskItem? {
    tasks.first { task in
        guard let s = task.scheduledFor else { return false }
        return s >= todayStart && s < todayEnd
            && task.completedAt == nil && task.skippedAt == nil
    }
}

private func upcomingTasks(from tasks: [TaskItem]) -> [TaskItem] {
    tasks.filter { task in
        guard let s = task.scheduledFor else { return false }
        return s >= todayStart && s < todayEnd
            && task.completedAt == nil && task.skippedAt == nil
    }
}

private func doneTasks(from tasks: [TaskItem]) -> [TaskItem] {
    tasks.filter { task in
        if let c = task.completedAt { return c >= todayStart && c < todayEnd }
        if let s = task.skippedAt  { return s >= todayStart && s < todayEnd }
        return false
    }
}

// MARK: - Reschedule date-math helpers (mirror RescheduleView's private functions, parameterised)

private func in30Minutes(from date: Date) -> Date {
    let target = date.addingTimeInterval(30 * 60)
    let fiveMin = 5.0 * 60.0
    let rounded = (target.timeIntervalSinceReferenceDate / fiveMin).rounded() * fiveMin
    return Date(timeIntervalSinceReferenceDate: rounded)
}

private func tonight(from date: Date) -> Date {
    var c = Calendar.current.dateComponents([.year, .month, .day], from: date)
    c.hour = 18; c.minute = 0; c.second = 0
    return Calendar.current.date(from: c)!
}

private func tomorrowMorning(from date: Date, startHour: Int = 9) -> Date {
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)!
    var c = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
    c.hour = startHour; c.minute = 0; c.second = 0
    return Calendar.current.date(from: c)!
}

// MARK: - Container factory

private func makeContainer() throws -> ModelContainer {
    let schema = Schema([TaskItem.self, UserSettings.self, ScheduledSlot.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}

private func fetchTasks(_ context: ModelContext) throws -> [TaskItem] {
    try context.fetch(FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.orderIndex)]))
}

// MARK: - Test suite

@Suite("Task Filtering")
struct TaskFilterTests {

    // --- currentTask ---

    @Test func currentTask_returnsFirstIncompleteScheduledToday() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(title: "Active", scheduledFor: referenceDate, orderIndex: 0))
        #expect(currentTask(from: try fetchTasks(context))?.title == "Active")
    }

    @Test func currentTask_ignoresCompletedTask() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(
            title: "Done", scheduledFor: referenceDate,
            completedAt: referenceDate, orderIndex: 0))
        #expect(currentTask(from: try fetchTasks(context)) == nil)
    }

    @Test func currentTask_ignoresSkippedTask() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(
            title: "Skipped", scheduledFor: referenceDate,
            skippedAt: referenceDate, orderIndex: 0))
        #expect(currentTask(from: try fetchTasks(context)) == nil)
    }

    @Test func currentTask_ignoresTaskScheduledTomorrow() throws {
        let context = ModelContext(try makeContainer())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: referenceDate)!
        context.insert(TaskItem(title: "Tomorrow", scheduledFor: tomorrow, orderIndex: 0))
        #expect(currentTask(from: try fetchTasks(context)) == nil)
    }

    // --- doneTasks ---

    @Test func doneTasks_includesCompleted() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(
            title: "Completed", scheduledFor: referenceDate,
            completedAt: referenceDate, orderIndex: 0))
        #expect(doneTasks(from: try fetchTasks(context)).count == 1)
    }

    @Test func doneTasks_includesSkipped() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(
            title: "Skipped", scheduledFor: referenceDate,
            skippedAt: referenceDate, orderIndex: 0))
        #expect(doneTasks(from: try fetchTasks(context)).count == 1)
    }

    // --- queue ordering ---

    @Test func upcomingTasks_excludesCurrent() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(title: "First",  scheduledFor: referenceDate, orderIndex: 0))
        context.insert(TaskItem(
            title: "Second",
            scheduledFor: referenceDate.addingTimeInterval(3600),
            orderIndex: 1))
        let tasks = try fetchTasks(context)
        let current  = currentTask(from: tasks)
        let upcoming = upcomingTasks(from: tasks)
        // "Later" items: upcoming minus the current task
        let laterItems = upcoming.filter { $0.id != current?.id }
        #expect(current?.title == "First")
        #expect(laterItems.count == 1)
        #expect(laterItems.first?.title == "Second")
    }

    // --- reschedule date math ---

    @Test func rescheduleOption_in30Minutes_roundsToNearest5() {
        // 9:07 AM + 30 min = 9:37 AM → rounds to nearest 5-min boundary
        var c = DateComponents()
        c.year = 2026; c.month = 4; c.day = 21; c.hour = 9; c.minute = 7; c.second = 0
        let input = Calendar.current.date(from: c)!
        let result = in30Minutes(from: input)

        // Must be within ±3 min of 30 minutes from input
        let delta = result.timeIntervalSince(input)
        #expect(delta >= 27 * 60)
        #expect(delta <= 33 * 60)

        // Must land on an exact 5-minute boundary in absolute seconds
        let fiveMin = 5.0 * 60.0
        let remainder = result.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: fiveMin)
        #expect(remainder == 0)
    }

    @Test func rescheduleOption_tonight_returns6PM() {
        let result = tonight(from: referenceDate)
        let c = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: result)
        #expect(c.year == 2026)
        #expect(c.month == 4)
        #expect(c.day == 21)
        #expect(c.hour == 18)
        #expect(c.minute == 0)
        #expect(c.second == 0)
    }

    @Test func rescheduleOption_tomorrowMorning_returnsNextDayAt9AM() {
        let result = tomorrowMorning(from: referenceDate, startHour: 9)
        let c = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: result)
        #expect(c.year == 2026)
        #expect(c.month == 4)
        #expect(c.day == 22)
        #expect(c.hour == 9)
        #expect(c.minute == 0)
        #expect(c.second == 0)
    }
}
