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
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No worries.")
                        .font(.title2)
                        .fontWeight(.semibold)

                    (Text("What do you want to do with ")
                        .foregroundStyle(AppColors.mutedText)
                    + Text(task.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("?")
                        .foregroundStyle(AppColors.mutedText))
                        .font(.body)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 32)

                VStack(spacing: 12) {
                    RescheduleOption(label: "Do it next") {
                        let minIndex = incompleteTasks.map(\.orderIndex).min() ?? 0
                        task.orderIndex = minIndex - 1
                        dismiss()
                    }
                    RescheduleOption(label: "Do it later") {
                        let maxIndex = allTasks.map(\.orderIndex).max() ?? 0
                        task.orderIndex = maxIndex + 1
                        dismiss()
                    }
                    RescheduleOption(label: "Skip today") {
                        task.skippedAt = Date()
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()
            }
        }
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
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .padding(.horizontal, 20)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RescheduleView(task: TaskItem(title: "Write the project summary"))
        .modelContainer(for: [TaskItem.self, UserSettings.self], inMemory: true)
}
