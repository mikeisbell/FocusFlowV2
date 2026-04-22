import SwiftUI
import SwiftData

struct RescheduleView: View {
    let task: TaskItem
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]

    private var dayStartHour: Int { settings.first?.dayStartHour ?? 9 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("No worries.")
                    .font(.title2)
                    .fontWeight(.semibold)

                (Text("When works better for ")
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
                RescheduleOption(label: "In 30 minutes") {
                    task.scheduledFor = in30Minutes()
                    dismiss()
                }
                Divider().padding(.leading)
                RescheduleOption(label: "Tonight") {
                    task.scheduledFor = tonight()
                    dismiss()
                }
                Divider().padding(.leading)
                RescheduleOption(label: "Tomorrow morning") {
                    task.scheduledFor = tomorrowMorning()
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

    private func in30Minutes() -> Date {
        let target = Date().addingTimeInterval(30 * 60)
        let fiveMin = 5.0 * 60.0
        let rounded = (target.timeIntervalSinceReferenceDate / fiveMin).rounded() * fiveMin
        return Date(timeIntervalSinceReferenceDate: rounded)
    }

    private func tonight() -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 18; c.minute = 0; c.second = 0
        return Calendar.current.date(from: c) ?? Date()
    }

    private func tomorrowMorning() -> Date {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        var c = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        c.hour = dayStartHour; c.minute = 0; c.second = 0
        return Calendar.current.date(from: c) ?? Date()
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
