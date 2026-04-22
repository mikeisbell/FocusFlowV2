import SwiftUI
import SwiftData

struct TodayView: View {
    @Binding var selectedTab: Int
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]
    @State private var showingReschedule = false

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

    private var remainingCount: Int {
        allTasks.filter { $0.completedAt == nil && $0.skippedAt == nil }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("\(doneToday) done · \(remainingCount) left today")
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedText)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 20)

                    if let task = currentTask {
                        TaskCard(task: task)
                            .padding(.horizontal, 24)

                        VStack(spacing: 12) {
                            Button("Done") { task.completedAt = Date() }
                                .buttonStyle(PrimaryButtonStyle())
                            Button("Not Now") { showingReschedule = true }
                                .buttonStyle(OutlineButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        Spacer()
                    } else {
                        Spacer()
                        emptyState.frame(maxWidth: .infinity)
                        Spacer()
                    }
                }
                .navigationDestination(isPresented: $showingReschedule) {
                    if let task = currentTask {
                        RescheduleView(task: task)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("Nothing scheduled yet")
                .font(.body)
                .foregroundStyle(AppColors.mutedText)
            Button("Add a task") {
                selectedTab = 2
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 200)
        }
    }
}

struct TaskCard: View {
    let task: TaskItem

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(AppColors.accent.opacity(0.07))
                .frame(width: 140, height: 140)
                .offset(x: 40, y: -40)

            VStack(alignment: .leading, spacing: 16) {
                Text("UP NOW")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.mutedText)
                    .tracking(1.5)

                Text(task.title)
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.regular)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: 6)
    }
}

#Preview {
    TodayView(selectedTab: .constant(0))
        .modelContainer(for: TaskItem.self, inMemory: true)
}
