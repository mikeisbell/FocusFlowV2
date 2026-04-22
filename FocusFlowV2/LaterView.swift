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
        ZStack {
            AppColors.background.ignoresSafeArea()

            if upcomingTasks.isEmpty && finishedTasks.isEmpty {
                emptyState
            } else {
                List {
                    if !upcomingTasks.isEmpty {
                        Section("Queue") {
                            ForEach(Array(upcomingTasks.enumerated()), id: \.element.id) { index, task in
                                UpcomingRow(task: task, position: index + 1, isCurrent: index == 0)
                                    .listRowBackground(AppColors.cardBackground)
                            }
                        }
                    }
                    if !finishedTasks.isEmpty {
                        Section("Done") {
                            ForEach(finishedTasks) { task in
                                FinishedRow(task: task)
                                    .listRowBackground(AppColors.cardBackground)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("Queue is empty")
                .foregroundStyle(AppColors.mutedText)
            Text("Add a task to get started")
                .font(.caption)
                .foregroundStyle(AppColors.mutedText.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UpcomingRow: View {
    let task: TaskItem
    let position: Int
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(isCurrent ? AppColors.accent : Color.clear)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))

            Text("\(position)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(AppColors.mutedText)
                .frame(width: 24, alignment: .trailing)

            Text(task.title)
                .font(.body)
                .foregroundStyle(isCurrent ? .primary : .secondary)

            Spacer()
        }
        .padding(.vertical, 4)
        .opacity(isCurrent ? 1.0 : 0.7)
    }
}

struct FinishedRow: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(AppColors.doneGreen)
                .frame(width: 16)

            Text(task.title)
                .strikethrough()
                .foregroundStyle(AppColors.mutedText)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LaterView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
