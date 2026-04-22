import SwiftUI
import SwiftData

struct LaterView: View {
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }
    private var todayEnd: Date { Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! }

    private var upcomingTasks: [TaskItem] {
        allTasks.filter { $0.completedAt == nil && $0.skippedAt == nil }
    }

    private var completedTasks: [TaskItem] {
        allTasks.filter { task in
            guard let completed = task.completedAt else { return false }
            return completed >= todayStart && completed < todayEnd
        }
    }

    private var skippedTasks: [TaskItem] {
        allTasks.filter { task in
            guard let skipped = task.skippedAt else { return false }
            return skipped >= todayStart && skipped < todayEnd
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if upcomingTasks.isEmpty && completedTasks.isEmpty && skippedTasks.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if !upcomingTasks.isEmpty {
                            sectionHeader("Queue")
                                .padding(.top, 24)
                            VStack(spacing: 10) {
                                ForEach(Array(upcomingTasks.enumerated()), id: \.element.id) { index, task in
                                    UpcomingRow(task: task, isCurrent: index == 0)
                                        .padding(.horizontal, 24)
                                }
                            }
                        }

                        if !completedTasks.isEmpty {
                            sectionHeader("Done")
                                .padding(.top, 28)
                            VStack(spacing: 10) {
                                ForEach(completedTasks) { task in
                                    FinishedRow(task: task)
                                        .padding(.horizontal, 24)
                                }
                            }
                        }

                        if !skippedTasks.isEmpty {
                            sectionHeader("Skipped today")
                                .padding(.top, 28)
                            VStack(spacing: 10) {
                                ForEach(skippedTasks) { task in
                                    SkippedRow(task: task)
                                        .padding(.horizontal, 24)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.mutedText)
            .tracking(1.5)
            .textCase(.uppercase)
            .padding(.horizontal, 28)
            .padding(.bottom, 12)
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
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(isCurrent ? AppColors.accent : Color.clear)
                .frame(width: 4, height: 44)
                .padding(.trailing, 14)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(isCurrent ? .medium : .regular)
                    .foregroundStyle(isCurrent ? Color.primary : Color.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .opacity(isCurrent ? 1.0 : 0.65)
    }
}

struct FinishedRow: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundStyle(AppColors.doneGreen)
            Text(task.title)
                .font(.body)
                .strikethrough(true, color: AppColors.mutedText)
                .foregroundStyle(AppColors.mutedText)
            Spacer()
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct SkippedRow: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "minus.circle")
                .font(.body)
                .foregroundStyle(AppColors.mutedText)
            Text(task.title)
                .font(.body)
                .foregroundStyle(AppColors.mutedText)
            Spacer()
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    LaterView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
