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
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !upcomingTasks.isEmpty {
                            sectionHeader("Queue")
                            VStack(spacing: 8) {
                                ForEach(Array(upcomingTasks.enumerated()), id: \.element.id) { index, task in
                                    UpcomingRow(task: task, position: index + 1, isCurrent: index == 0)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .background(AppColors.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                                        .padding(.horizontal, 24)
                                }
                            }
                        }

                        if !finishedTasks.isEmpty {
                            sectionHeader("Done")
                                .padding(.top, upcomingTasks.isEmpty ? 0 : 8)
                            VStack(spacing: 8) {
                                ForEach(finishedTasks) { task in
                                    FinishedRow(task: task)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .background(AppColors.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                                        .padding(.horizontal, 24)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.mutedText)
            .tracking(1)
            .textCase(.uppercase)
            .padding(.horizontal, 24)
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
    }
}

#Preview {
    LaterView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
