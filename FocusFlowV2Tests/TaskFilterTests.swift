import Testing
import Foundation
import SwiftData
@testable import FocusFlowV2

// MARK: - Shared filter helpers (mirror TodayView / LaterView logic)

private func currentTask(from tasks: [TaskItem]) -> TaskItem? {
    tasks.first { $0.completedAt == nil && $0.skippedAt == nil }
}

private func upcomingTasks(from tasks: [TaskItem]) -> [TaskItem] {
    tasks.filter { $0.completedAt == nil && $0.skippedAt == nil }
}

private func doneTasks(from tasks: [TaskItem]) -> [TaskItem] {
    tasks.filter { $0.completedAt != nil || $0.skippedAt != nil }
}

// MARK: - Container factory

private func makeContainer() throws -> ModelContainer {
    let schema = Schema([TaskItem.self, UserSettings.self])
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

    @Test func currentTask_returnsFirstIncomplete() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(title: "Active", orderIndex: 0))
        #expect(currentTask(from: try fetchTasks(context))?.title == "Active")
    }

    @Test func currentTask_ignoresCompletedTask() throws {
        let context = ModelContext(try makeContainer())
        let task = TaskItem(title: "Done", orderIndex: 0)
        task.completedAt = Date()
        context.insert(task)
        #expect(currentTask(from: try fetchTasks(context)) == nil)
    }

    @Test func currentTask_ignoresSkippedTask() throws {
        let context = ModelContext(try makeContainer())
        let task = TaskItem(title: "Skipped", orderIndex: 0)
        task.skippedAt = Date()
        context.insert(task)
        #expect(currentTask(from: try fetchTasks(context)) == nil)
    }

    @Test func currentTask_returnsLowestOrderIndex() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(title: "First",  orderIndex: 0))
        context.insert(TaskItem(title: "Second", orderIndex: 1))
        #expect(currentTask(from: try fetchTasks(context))?.title == "First")
    }

    // --- doneTasks ---

    @Test func doneTasks_includesCompleted() throws {
        let context = ModelContext(try makeContainer())
        let task = TaskItem(title: "Completed", orderIndex: 0)
        task.completedAt = Date()
        context.insert(task)
        #expect(doneTasks(from: try fetchTasks(context)).count == 1)
    }

    @Test func doneTasks_includesSkipped() throws {
        let context = ModelContext(try makeContainer())
        let task = TaskItem(title: "Skipped", orderIndex: 0)
        task.skippedAt = Date()
        context.insert(task)
        #expect(doneTasks(from: try fetchTasks(context)).count == 1)
    }

    // --- queue ordering ---

    @Test func upcomingTasks_excludesCurrent() throws {
        let context = ModelContext(try makeContainer())
        context.insert(TaskItem(title: "First",  orderIndex: 0))
        context.insert(TaskItem(title: "Second", orderIndex: 1))
        let tasks = try fetchTasks(context)
        let current  = currentTask(from: tasks)
        let upcoming = upcomingTasks(from: tasks)
        let laterItems = upcoming.filter { $0.id != current?.id }
        #expect(current?.title == "First")
        #expect(laterItems.count == 1)
        #expect(laterItems.first?.title == "Second")
    }
}
