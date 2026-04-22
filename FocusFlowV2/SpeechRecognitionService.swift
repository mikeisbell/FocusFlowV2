import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechRecognitionService {

    enum State { case idle, requestingPermissions, recording, denied }

    var state: State = .idle
    var transcript: String = ""
    var audioLevel: Float = 0

    var onFinished: ((String) -> Void)?

    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?
    private var silenceTimer: Timer?

    func startRecording() {
        guard state != .recording else { return }
        state = .requestingPermissions
        transcript = ""

        Task {
            let micOK = await AVAudioApplication.requestRecordPermission()
            let speechOK = await withCheckedContinuation { (c: CheckedContinuation<Bool, Never>) in
                SFSpeechRecognizer.requestAuthorization { status in
                    c.resume(returning: status == .authorized)
                }
            }
            if micOK && speechOK {
                beginRecording()
            } else {
                state = .denied
            }
        }
    }

    func stopRecording() {
        tearDown()
    }

    private func beginRecording() {
        let recognizer = SFSpeechRecognizer(locale: .current)
            ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        guard let recognizer, recognizer.isAvailable else {
            state = .denied
            return
        }
        speechRecognizer = recognizer

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(
                true, options: .notifyOthersOnDeactivation)
        } catch {
            state = .denied
            return
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Capture request directly — avoids crossing actor boundary with self
        let capturedRequest = request
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            capturedRequest.append(buffer)
            let level = SpeechRecognitionService.rmsLevel(from: buffer)
            Task { @MainActor [weak self] in
                self?.audioLevel = level
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            tearDown()
            return
        }

        state = .recording
        scheduleSilenceTimer()

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, _ in
            guard let result else { return }
            let text = result.bestTranscription.formattedString
            Task { @MainActor [weak self] in
                self?.transcript = text
                if !text.isEmpty { self?.scheduleSilenceTimer() }
            }
        }
    }

    private func scheduleSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let final = self.transcript
                self.tearDown()
                self.onFinished?(final)
            }
        }
    }

    private func tearDown() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation)
        state = .idle
        audioLevel = 0
    }

    // nonisolated so it can be called from the AVAudioEngine tap callback thread
    nonisolated private static func rmsLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let data = buffer.floatChannelData?[0] else { return 0 }
        let count = Int(buffer.frameLength)
        guard count > 0 else { return 0 }
        var sum: Float = 0
        for i in 0..<count { sum += abs(data[i]) }
        return min(sum / Float(count) * 30, 1.0)
    }
}
