import SwiftUI
import SwiftData

private enum InputMode: Equatable {
    case chooser, voice, keyboard
}

struct AddView: View {
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.orderIndex) private var allTasks: [TaskItem]
    @State private var mode: InputMode = .chooser
    @State private var taskTitle = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                backRow
                Group {
                    switch mode {
                    case .chooser:  chooserContent
                    case .voice:    voiceContent
                    case .keyboard: keyboardContent
                    }
                }
                Spacer()
            }
            .padding(.top, 16)
            .animation(.easeInOut(duration: 0.2), value: mode)
            .onChange(of: mode) { _, newMode in
                if newMode == .keyboard {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        fieldFocused = true
                    }
                } else {
                    fieldFocused = false
                }
            }
        }
    }

    private var backRow: some View {
        HStack {
            if mode != .chooser {
                Button {
                    taskTitle = ""
                    mode = .chooser
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.accent)
                }
                .padding(.leading, 24)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }

    private var chooserContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What needs doing?")
                .font(.title2)
                .fontDesign(.serif)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)

            HStack(spacing: 16) {
                InputCard(icon: "mic.fill", label: "Speak it") {
                    mode = .voice
                }
                InputCard(icon: "keyboard", label: "Type it") {
                    mode = .keyboard
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var voiceContent: some View {
        VoiceInputView { title in
            let task = TaskItem(
                title: title,
                orderIndex: SchedulerService.nextOrderIndex(in: allTasks)
            )
            modelContext.insert(task)
            mode = .chooser
            selectedTab = 0
        }
    }

    private var keyboardContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            TextField("Describe the task…", text: $taskTitle, axis: .vertical)
                .font(.title3)
                .focused($fieldFocused)
                .padding(.horizontal, 24)

            Button("Add to queue →") {
                scheduleTask()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 24)
        }
    }

    private func scheduleTask() {
        let task = TaskItem(
            title: taskTitle.trimmingCharacters(in: .whitespaces),
            orderIndex: SchedulerService.nextOrderIndex(in: allTasks)
        )
        modelContext.insert(task)
        taskTitle = ""
        mode = .chooser
        selectedTab = 0
    }
}

struct InputCard: View {
    let icon: String
    let label: String
    let action: () -> Void
    @GestureState private var isPressing = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.accent)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        AppColors.accent.opacity(isPressing ? 1.0 : 0.2),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressing) { _, state, _ in state = true }
        )
    }
}

#Preview {
    AddView(selectedTab: .constant(2))
        .modelContainer(for: TaskItem.self, inMemory: true)
}
