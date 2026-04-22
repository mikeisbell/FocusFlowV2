import SwiftUI
import SwiftData

struct TodayView: View {
    @Binding var selectedTab: Int
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]

    private var todayStart: Date { Calendar.current.startOfDay(for: Date()) }
    private var todayEnd: Date { Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! }

    private var currentTask: TaskItem? {
        allTasks.first { $0.completedAt == nil && $0.skippedAt == nil }
    }

    private var doneToday: Int {
        allTasks.filter { task in
            guard let completed = task.completedAt else { return false }
            return completed >= todayStart && completed < todayEnd
        }.count
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("\(doneToday) done today")
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                if let task = currentTask {
                    TaskCard(task: task)
                        .padding(.horizontal, 24)
                    Spacer()
                } else {
                    Spacer()
                    emptyState.frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("Queue is empty")
                .foregroundStyle(AppColors.mutedText)
            Button("Add a task") {
                selectedTab = 2
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 180)
        }
    }
}

struct TaskCard: View {
    let task: TaskItem
    @State private var showingReschedule = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(AppColors.accent.opacity(0.06))
                .frame(width: 120, height: 120)
                .offset(x: 30, y: -30)

            VStack(alignment: .leading, spacing: 24) {
                Text("UP NEXT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.mutedText)
                    .tracking(1)

                Text(task.title)
                    .font(.title)
                    .fontDesign(.serif)
                    .fontWeight(.regular)
                    .foregroundStyle(.primary)

                VStack(spacing: 12) {
                    Button("Done") {
                        task.completedAt = Date()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Not Now") {
                        showingReschedule = true
                    }
                    .buttonStyle(OutlineButtonStyle())
                }
            }
            .padding(28)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
        .sheet(isPresented: $showingReschedule) {
            RescheduleView(task: task)
        }
    }
}

#Preview {
    TodayView(selectedTab: .constant(0))
        .modelContainer(for: TaskItem.self, inMemory: true)
}
