import SwiftUI
import SwiftData

struct RescheduleView: View {
    let task: TaskItem
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]

    private var incompleteTasks: [TaskItem] {
        allTasks.filter { $0.completedAt == nil && $0.skippedAt == nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("No worries.")
                    .font(.title2)
                    .fontWeight(.semibold)

                (Text("What do you want to do with ")
                    .foregroundStyle(.secondary)
                + Text(task.title)
                    .fontWeight(.semibold)
                + Text("?")
                    .foregroundStyle(.secondary))
            }
            .padding(.horizontal)
            .padding(.top, 28)
            .padding(.bottom, 20)

            Divider()

            VStack(spacing: 0) {
                RescheduleOption(label: "Do it next") {
                    let minIndex = incompleteTasks.map(\.orderIndex).min() ?? 0
                    task.orderIndex = minIndex - 1
                    dismiss()
                }
                Divider().padding(.leading)
                RescheduleOption(label: "Do it later") {
                    let maxIndex = allTasks.map(\.orderIndex).max() ?? 0
                    task.orderIndex = maxIndex + 1
                    dismiss()
                }
                Divider().padding(.leading)
                RescheduleOption(label: "Skip today") {
                    task.skippedAt = Date()
                    dismiss()
                }
            }

            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct RescheduleOption: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(minHeight: 56)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RescheduleView(task: TaskItem(title: "Write the project summary"))
        .modelContainer(for: [TaskItem.self, UserSettings.self], inMemory: true)
}
