# Voice Input

## Load this skill when
Touching anything related to the Speech framework, microphone permissions, or Claude-based transcript parsing.

## Content

### Files
- `FocusFlowV2/SpeechRecognitionService.swift` — `@Observable` class managing `SFSpeechRecognizer` + `AVAudioEngine`
- `FocusFlowV2/VoiceInputView.swift` — full voice flow UI + `WaveformView` + Claude API call
- `FocusFlowV2/Secrets.plist` — API key store (gitignored, `REPLACE_ME` placeholder)

### Permission request timing
Both permissions are requested at the moment `startRecording()` is called — NOT on app launch. This is intentional: the user has just tapped "Speak it", so the permission prompt appears in context. `AVAudioApplication.requestRecordPermission()` (iOS 17+) and `SFSpeechRecognizer.requestAuthorization` are awaited concurrently. If either is denied, `state` becomes `.denied` and the UI shows an inline "Open Settings" link.

### SFSpeechRecognizer locale handling
`SFSpeechRecognizer(locale: .current)` is tried first. If the current locale's recognizer is unavailable (not downloaded on-device or region unsupported), it falls back to `Locale(identifier: "en-US")`. If neither is available, `state` becomes `.denied`.

### AVAudioEngine tap setup
`inputNode.installTap(onBus: 0, bufferSize: 1024, format:)` appends PCM buffers to `SFSpeechAudioBufferRecognitionRequest`. The audio session is configured as `.record` / `.measurement` / `.duckOthers` before `audioEngine.start()`. The `capturedRequest` variable is used inside the tap closure instead of capturing `self` — this avoids crossing the `@MainActor` isolation boundary from the tap callback thread.

### Swift concurrency notes (SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor)
The entire app is `@MainActor` by default. Key patterns used:
- `nonisolated static func rmsLevel(from:)` — called from the tap callback thread
- `Task { @MainActor [weak self] in }` — used inside the tap closure and the recognition task callback to safely update `@MainActor`-isolated properties
- Timer callback also wraps in `Task { @MainActor }` for correctness

### Silence detection approach
A 2-second `Timer` (`scheduleSilenceTimer()`) is started when recording begins. Each time `SFSpeechRecognitionTask` produces a new non-empty result, the timer is reset. If 2 seconds pass with no new recognition results, the timer fires: `tearDown()` is called and `onFinished?(finalTranscript)` is invoked with whatever transcript was accumulated. This detects speech-level silence, not raw audio silence.

### Claude API call pattern
Called from `VoiceInputView.callClaude(transcript:)` after recording stops. The API key is read at call time from `Secrets.plist` via `Bundle.main.url(forResource:withExtension:)`. If the key is missing or still `REPLACE_ME`, the function returns the raw transcript unchanged — the flow still works, just without cleaning. Model: `claude-sonnet-4-6`, max_tokens: 128, system prompt instructs single-line title output with no trailing punctuation.

### Secrets.plist
Located at `FocusFlowV2/Secrets.plist`. In `.gitignore`. The user must manually replace `REPLACE_ME` with a real Anthropic API key. The file is in the app bundle via `PBXFileSystemSynchronizedRootGroup` auto-inclusion.

### What's not implemented yet
- Real-time audio level fed back to waveform uses RMS of raw PCM — not calibrated to dBFS. May need tuning for quiet environments.
- No retry on Claude API failure — falls back to raw transcript silently.
- No streaming transcription display beyond partial results from SFSpeechRecognizer.
