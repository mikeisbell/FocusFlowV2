import SwiftUI

struct VoiceInputView: View {
    let onTaskConfirmed: (String) -> Void

    @State private var service = SpeechRecognitionService()
    @State private var phase: Phase = .serviceIdle

    private enum Phase: Equatable {
        case serviceIdle            // waiting for user to tap mic
        case processing             // Claude API call in flight
        case confirm(String)        // cleaned title ready
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            content
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            service.onFinished = { transcript in
                let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                phase = .processing
                Task {
                    let cleaned = (try? await callClaude(transcript: trimmed)) ?? trimmed
                    phase = .confirm(cleaned)
                }
            }
        }
        .onDisappear { service.stopRecording() }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .serviceIdle:
            serviceStateContent
        case .processing:
            processingContent
        case .confirm(let title):
            confirmContent(title: title)
        }
    }

    @ViewBuilder
    private var serviceStateContent: some View {
        switch service.state {
        case .idle:
            idleContent
        case .requestingPermissions:
            VStack(spacing: 16) {
                ProgressView()
                Text("Checking permissions…")
                    .foregroundStyle(.secondary)
            }
        case .recording:
            recordingContent
        case .denied:
            deniedContent
        }
    }

    private var idleContent: some View {
        VStack(spacing: 16) {
            Button {
                service.startRecording()
            } label: {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.purple)
            }
            .buttonStyle(.plain)
            Text("Tap to speak")
                .foregroundStyle(.secondary)
        }
    }

    private var recordingContent: some View {
        VStack(spacing: 20) {
            WaveformView(level: service.audioLevel)
                .frame(height: 60)
            if !service.transcript.isEmpty {
                Text(service.transcript)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private var processingContent: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Cleaning that up…")
                .foregroundStyle(.secondary)
        }
    }

    private func confirmContent(title: String) -> some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

            VStack(spacing: 12) {
                Button("Looks right") {
                    onTaskConfirmed(title)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button("Try again") {
                    phase = .serviceIdle
                    service.startRecording()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
    }

    private var deniedContent: some View {
        VStack(spacing: 12) {
            Text("Microphone access needed")
                .foregroundStyle(.secondary)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private func callClaude(transcript: String) async throws -> String {
        guard
            let plistURL = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let plistData = try? Data(contentsOf: plistURL),
            let dict = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
            let apiKey = dict["AnthropicAPIKey"] as? String,
            !apiKey.isEmpty, apiKey != "REPLACE_ME"
        else {
            return transcript  // key not configured yet — return raw transcript
        }

        var req = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "model": "claude-sonnet-4-6",
            "max_tokens": 128,
            "system": "You are a task title cleaner. The user has spoken a task description. Return only a clean, concise task title — no punctuation at the end, no explanations, no quotation marks. Maximum 60 characters.",
            "messages": [["role": "user", "content": transcript]]
        ])

        let (data, _) = try await URLSession.shared.data(for: req)

        struct Response: Decodable {
            struct Block: Decodable { let type: String; let text: String }
            let content: [Block]
        }
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.content
            .first(where: { $0.type == "text" })?
            .text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? transcript
    }
}

struct WaveformView: View {
    let level: Float

    // Per-bar variation multipliers — gives the waveform a natural uneven look
    private let variations: [CGFloat] = [0.75, 1.0, 0.60, 0.90, 0.55, 0.85, 0.70]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<variations.count, id: \.self) { i in
                let h = 8 + 44 * CGFloat(level) * variations[i]
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.purple)
                    .frame(width: 5, height: h)
                    .animation(.easeOut(duration: 0.1), value: level)
            }
        }
    }
}

#Preview {
    VoiceInputView { _ in }
}
