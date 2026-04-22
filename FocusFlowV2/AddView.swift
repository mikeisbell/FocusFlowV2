import SwiftUI
import SwiftData

private enum InputMode: Equatable {
    case chooser, voice, keyboard
}

struct AddView: View {
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    @State private var mode: InputMode = .chooser
    @State private var taskTitle = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backRow
            Group {
                switch mode {
                case .chooser: chooserContent
                case .voice:   voiceContent
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

    private var backRow: some View {
        HStack {
            if mode != .chooser {
                Button {
                    taskTitle = ""
                    mode = .chooser
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }
                .padding(.leading)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }

    private var chooserContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What needs doing?")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)

            HStack(spacing: 16) {
                InputCard(icon: "mic.fill", label: "Speak it") {
                    mode = .voice
                }
                InputCard(icon: "keyboard", label: "Type it") {
                    mode = .keyboard
                }
            }
            .padding(.horizontal)
        }
    }

    private var voiceContent: some View {
        VoiceInputView { title in
            let slot = SchedulerService.nextAvailableSlot(after: Date())
            let task = TaskItem(title: title, scheduledFor: slot, orderIndex: 0)
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
                .padding(.horizontal)

            Button("Schedule it →") {
                scheduleTask()
            }
            .buttonStyle(.borderedProminent)
            .disabled(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal)
        }
    }

    private func scheduleTask() {
        let slot = SchedulerService.nextAvailableSlot(after: Date())
        let task = TaskItem(
            title: taskTitle.trimmingCharacters(in: .whitespaces),
            scheduledFor: slot,
            orderIndex: 0
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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddView(selectedTab: .constant(2))
        .modelContainer(for: TaskItem.self, inMemory: true)
}
