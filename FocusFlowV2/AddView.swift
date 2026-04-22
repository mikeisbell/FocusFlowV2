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
    @State private var cardSize: CGFloat = 159
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
                        .font(.title3)
                        .foregroundStyle(AppColors.accent)
                }
                .padding(.leading, 28)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }

    private var chooserContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("What needs doing?")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 36)

            GeometryReader { geo in
                let size = (geo.size.width - 56 - 16) / 2
                HStack(spacing: 16) {
                    InputCard(icon: "mic.fill", label: "Speak it", sublabel: "Fastest") {
                        mode = .voice
                    }
                    .frame(width: size, height: size)
                    InputCard(icon: "keyboard", label: "Type it", sublabel: "Your way") {
                        mode = .keyboard
                    }
                    .frame(width: size, height: size)
                }
                .padding(.horizontal, 28)
                .onAppear { cardSize = size }
            }
            .frame(height: cardSize)
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
        VStack(alignment: .leading, spacing: 0) {
            Text("What needs doing?")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 36)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $taskTitle)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .focused($fieldFocused)
                    .padding(16)
                    .frame(minHeight: 120)

                if taskTitle.isEmpty {
                    Text("Describe the task…")
                        .font(.body)
                        .foregroundStyle(AppColors.mutedText.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .allowsHitTesting(false)
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(AppColors.accent.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
            .padding(.horizontal, 28)
            .padding(.bottom, 24)

            Button("Add to queue →") {
                scheduleTask()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 28)
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
    let sublabel: String
    let action: () -> Void
    @GestureState private var isPressing = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.12))
                        .frame(width: 64, height: 64)
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(AppColors.accent)
                }

                VStack(spacing: 4) {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(sublabel)
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        AppColors.accent.opacity(isPressing ? 1.0 : 0.2),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
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
