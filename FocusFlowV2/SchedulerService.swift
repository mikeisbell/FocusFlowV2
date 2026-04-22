import Foundation

struct SchedulerService {
    // Returns the next orderIndex value for a newly added task.
    static func nextOrderIndex(in tasks: [TaskItem]) -> Int {
        (tasks.map(\.orderIndex).max() ?? -1) + 1
    }

    // Returns the 1-based queue position of a task among incomplete tasks.
    static func queuePosition(for task: TaskItem, in tasks: [TaskItem]) -> Int? {
        let incomplete = tasks.filter { $0.completedAt == nil && $0.skippedAt == nil }
        guard let idx = incomplete.firstIndex(where: { $0.id == task.id }) else { return nil }
        return idx + 1
    }
}
