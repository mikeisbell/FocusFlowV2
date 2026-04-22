import Testing
import Foundation
@testable import FocusFlowV2

@Suite("SchedulerService")
struct SchedulerServiceTests {

    @Test func nextOrderIndex_emptyQueue_returnsZero() {
        let result = SchedulerService.nextOrderIndex(in: [])
        #expect(result == 0)
    }

    @Test func nextOrderIndex_existingTasks_returnsMaxPlusOne() {
        let tasks = [
            TaskItem(title: "A", orderIndex: 0),
            TaskItem(title: "B", orderIndex: 1),
            TaskItem(title: "C", orderIndex: 2),
        ]
        let result = SchedulerService.nextOrderIndex(in: tasks)
        #expect(result == 3)
    }

    @Test func queuePosition_returnsOneBasedPosition() {
        let tasks = [
            TaskItem(title: "First",  orderIndex: 0),
            TaskItem(title: "Second", orderIndex: 1),
            TaskItem(title: "Third",  orderIndex: 2),
        ]
        #expect(SchedulerService.queuePosition(for: tasks[0], in: tasks) == 1)
        #expect(SchedulerService.queuePosition(for: tasks[1], in: tasks) == 2)
        #expect(SchedulerService.queuePosition(for: tasks[2], in: tasks) == 3)
    }

    @Test func queuePosition_excludesCompletedTasks() {
        let completed = TaskItem(title: "Done", orderIndex: 0)
        completed.completedAt = Date()
        let active = TaskItem(title: "Active", orderIndex: 1)
        let tasks = [completed, active]
        #expect(SchedulerService.queuePosition(for: completed, in: tasks) == nil)
        #expect(SchedulerService.queuePosition(for: active, in: tasks) == 1)
    }
}
