import SwiftUI
import SwiftData

struct LaterView: View {
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }
    private var todayEnd: Date { Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! }

    private var upcomingTasks: [TaskItem] {
        allTasks.filter { $0.completedAt == nil && $0.skippedAt == nil }
    }

    private var finishedTasks: [TaskItem] {
        allTasks.filter { task in
            if let completed = task.completedAt {
                return completed >= todayStart && completed < todayEnd
            }
            if let skipped = task.skippedAt {
                return skipped >= todayStart && skipped < todayEnd
            }
            return false
        }
    }

    var body: some View {
        if upcomingTasks.isEmpty && finishedTasks.isEmpty {
            emptyState
        } else {
            List {
                if !upcomingTasks.isEmpty {
                    Section("Queue") {
                        ForEach(Array(upcomingTasks.enumerated()), id: \.element.id) { index, task in
                            UpcomingRow(task: task, position: index + 1, isCurrent: index == 0)
                        }
                    }
                }
                if !finishedTasks.isEmpty {
                    Section("Done") {
                        ForEach(finishedTasks) { task in
                            FinishedRow(task: task)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("Queue is empty")
                .foregroundStyle(.secondary)
            Text("Add a task to get started")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UpcomingRow: View {
    let task: TaskItem
    let position: Int
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(isCurrent ? Color.purple : Color.clear)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))

            Text("\(position)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)

            Text(task.title)
                .font(.body)

            Spacer()
        }
        .opacity(isCurrent ? 1.0 : 0.6)
    }
}

struct FinishedRow: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 16)

            Text(task.title)
                .strikethrough()
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    LaterView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
