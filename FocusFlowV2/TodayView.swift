import SwiftUI
import SwiftData

struct TodayView: View {
    @Binding var selectedTab: Int
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }
    private var todayEnd: Date { Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! }

    private var currentTask: TaskItem? {
        allTasks.first { task in
            guard let scheduled = task.scheduledFor else { return false }
            return scheduled >= todayStart
                && scheduled < todayEnd
                && task.completedAt == nil
                && task.skippedAt == nil
        }
    }

    private var doneToday: Int {
        allTasks.filter { task in
            guard let completed = task.completedAt else { return false }
            return completed >= todayStart && completed < todayEnd
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(doneToday) done today")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)

            if let task = currentTask {
                TaskCard(task: task)
                    .padding(.horizontal)
                Spacer()
            } else {
                Spacer()
                emptyState
                    .frame(maxWidth: .infinity)
                Spacer()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("Nothing scheduled yet")
                .foregroundStyle(.secondary)
            Button("Add a task") {
                selectedTab = 2
            }
        }
    }
}

struct TaskCard: View {
    let task: TaskItem
    @State private var showingReschedule = false

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let scheduled = task.scheduledFor {
                Text(Self.timeFormatter.string(from: scheduled))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(task.title)
                .font(.title)
                .fontDesign(.serif)
                .fontWeight(.regular)

            VStack(spacing: 12) {
                Button("Done") {
                    task.completedAt = Date()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button("Not Now") {
                    showingReschedule = true
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showingReschedule) {
            RescheduleView(task: task)
        }
    }
}

#Preview {
    TodayView(selectedTab: .constant(0))
        .modelContainer(for: TaskItem.self, inMemory: true)
}
