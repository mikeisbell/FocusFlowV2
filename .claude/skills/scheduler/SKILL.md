# Scheduler

## Load this skill when
Touching queue ordering, task positioning, or any logic that assigns `orderIndex`.

## Content

### Current implementation
`SchedulerService.swift` contains two static methods:

- `nextOrderIndex(in tasks: [TaskItem]) -> Int` — returns `(tasks.map(\.orderIndex).max() ?? -1) + 1`. Use this when inserting a new task at the end of the queue.
- `queuePosition(for task: TaskItem, in tasks: [TaskItem]) -> Int?` — returns the 1-based position of a task among all incomplete tasks (nil if the task is complete or not found).

### Queue model
The app uses a pure queue — no time-based scheduling. `orderIndex` is the sole ordering mechanism. Lower value = higher priority. The current task is always `allTasks.first { $0.completedAt == nil && $0.skippedAt == nil }`.

### Reschedule options
RescheduleView offers three options:
- "Do it next": sets `task.orderIndex = (incompleteTasks.map(\.orderIndex).min() ?? 0) - 1`
- "Do it later": sets `task.orderIndex = (allTasks.map(\.orderIndex).max() ?? 0) + 1`
- "Skip today": sets `task.skippedAt = Date()`

### Constraints
- `orderIndex` values are not guaranteed to be contiguous — gaps are intentional (reschedule operations shift a single task without renumbering others).
- Never renumber all tasks to close gaps; it creates unnecessary SwiftData writes.
