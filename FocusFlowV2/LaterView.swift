import SwiftUI
import SwiftData

struct LaterView: View {
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }
    private var todayEnd: Date { Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! }

    private var upcomingTasks: [TaskItem] {
        allTasks.filter { task in
            guard let scheduled = task.scheduledFor else { return false }
            return scheduled >= todayStart
                && scheduled < todayEnd
                && task.completedAt == nil
                && task.skippedAt == nil
        }
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
                    Section("Today") {
                        ForEach(Array(upcomingTasks.enumerated()), id: \.element.id) { index, task in
                            UpcomingRow(task: task, isCurrent: index == 0)
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
            Text("Nothing scheduled yet")
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
    let isCurrent: Bool

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(isCurrent ? Color.purple : Color.clear)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))

            if let scheduled = task.scheduledFor {
                Text(Self.timeFormatter.string(from: scheduled))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 56, alignment: .leading)
            }

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
