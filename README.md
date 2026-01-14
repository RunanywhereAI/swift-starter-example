# RunAnywhere Swift SDK Starter App

A comprehensive starter app demonstrating RunAnywhere SDK capabilities - **privacy-first, on-device AI for iOS**.

![RunAnywhere](https://img.shields.io/badge/RunAnywhere-SDK-00D9FF)
![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-8B5CF6)
![Swift](https://img.shields.io/badge/Swift-5.9-EC4899)

## Features

This starter app showcases all the core capabilities of the RunAnywhere SDK:

- 🤖 **Chat (LLM)** - On-device text generation with streaming support
- 🎤 **Speech to Text (STT)** - On-device speech recognition using Whisper
- 🔊 **Text to Speech (TTS)** - On-device voice synthesis using Piper
- 🎯 **Voice Pipeline** - Full voice agent: Speak → Transcribe → Generate → Speak

## Requirements

- iOS 17.0+ / macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

### 1. Open in Xcode

```bash
open Swift-Starter-Example.xcodeproj
```

### 2. SDK Package Dependencies (Pre-configured)

This project is pre-configured to fetch the RunAnywhere SDK directly from GitHub:

```
https://github.com/RunanywhereAI/runanywhere-sdks
Version: 0.16.0-test.39
```

The following SDK products are included:
- ✅ `RunAnywhere` - Core SDK (unified API for all AI capabilities)
- ✅ `RunAnywhereLlamaCPP` - LLM text generation backend
- ✅ `RunAnywhereONNX` - Speech-to-text, text-to-speech, VAD

When you open the project, Xcode will automatically fetch and resolve the packages from GitHub.

### 3. Configure Signing

In Xcode:
1. Select the project in the navigator
2. Go to **Signing & Capabilities**
3. Select your **Team**
4. Update the **Bundle Identifier** if needed

### 4. Build and Run

Press `Cmd + R` to build and run on your device or simulator.

> **Note:** The first build may take a few minutes as Xcode downloads the SDK and its dependencies from GitHub. For best AI inference performance, run on a physical device.

## SDK Dependencies

This app uses the RunAnywhere Swift SDK v0.16.0-test.39 from [GitHub releases](https://github.com/RunanywhereAI/runanywhere-sdks/releases/tag/v0.16.0-test.39):

| Module | Import | Description |
|--------|--------|-------------|
| Core SDK | `import RunAnywhere` | Unified API for all AI capabilities |
| LlamaCPP | `import LlamaCPPRuntime` | LLM text generation backend |
| ONNX | `import ONNXRuntime` | STT/TTS/VAD via Sherpa-ONNX |

## Models Used

| Capability | Model | Size |
|------------|-------|------|
| LLM | SmolLM2 360M Instruct Q8_0 | ~400MB |
| STT | Sherpa Whisper Tiny (English) | ~75MB |
| TTS | Piper (US English - Lessac Medium) | ~65MB |

Models are downloaded on-demand and cached locally on the device.

## Project Structure

```
Swift-Starter-Example/
├── Swift_Starter_ExampleApp.swift   # App entry point & SDK initialization
├── ContentView.swift                 # Main content view wrapper
├── Info.plist                        # Privacy permissions (microphone)
├── Theme/
│   └── AppTheme.swift               # Colors, fonts, and styling
├── Services/
│   └── ModelService.swift           # AI model management
├── Views/
│   ├── HomeView.swift               # Home screen with feature cards
│   ├── ChatView.swift               # LLM chat interface
│   ├── SpeechToTextView.swift       # Speech recognition
│   ├── TextToSpeechView.swift       # Voice synthesis
│   └── VoicePipelineView.swift      # Voice agent pipeline
└── Components/
    ├── FeatureCard.swift            # Reusable feature card
    ├── ModelLoaderView.swift        # Model download/load UI
    ├── AudioVisualizer.swift        # Audio level visualization
    └── ChatMessageBubble.swift      # Chat message component
```

## Usage Examples

### Initialize the SDK

```swift
import RunAnywhere
import LlamaCPPRuntime
import ONNXRuntime

// Initialize SDK (call once at app launch)
try RunAnywhere.initialize(environment: .development)

// Register backends
LlamaCPP.register()  // For LLM text generation
ONNX.register()      // For STT, TTS, VAD
```

### Text Generation (LLM)

```swift
// Simple chat (blocking)
let response = try await RunAnywhere.chat("What is the capital of France?")

// Streaming generation with metrics
let result = try await RunAnywhere.generateStream(
    prompt,
    options: LLMGenerationOptions(maxTokens: 256, temperature: 0.8)
)

for try await token in result.stream {
    print(token, terminator: "")
}

let metrics = try await result.result.value
print("Speed: \(metrics.tokensPerSecond) tok/s")
```

### Speech to Text

```swift
// Load STT model (once)
try await RunAnywhere.loadSTTModel("sherpa-onnx-whisper-tiny.en")

// Transcribe audio (Data from microphone)
let text = try await RunAnywhere.transcribe(audioData)
```

### Text to Speech

```swift
// Load TTS voice (once)
try await RunAnywhere.loadTTSVoice("vits-piper-en_US-lessac-medium")

// Synthesize speech
let output = try await RunAnywhere.synthesize(
    "Hello, world!",
    options: TTSOptions(rate: 1.0)
)

// Play audio
let player = try AVAudioPlayer(data: output.audioData)
player.play()
```

## Adding the SDK to Your Own Project

To add the RunAnywhere SDK to a new Swift project:

### Option 1: Xcode UI
1. In Xcode: **File → Add Package Dependencies...**
2. Enter: `https://github.com/RunanywhereAI/runanywhere-sdks`
3. Select **Exact Version**: `0.16.0-test.39`
4. Add all three products: `RunAnywhere`, `RunAnywhereLlamaCPP`, `RunAnywhereONNX`

### Option 2: Package.swift
```swift
dependencies: [
    .package(url: "https://github.com/RunanywhereAI/runanywhere-sdks", exact: "0.16.0-test.39")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "RunAnywhere", package: "runanywhere-sdks"),
            .product(name: "RunAnywhereLlamaCPP", package: "runanywhere-sdks"),
            .product(name: "RunAnywhereONNX", package: "runanywhere-sdks"),
        ]
    ),
]
```

## Privacy Permissions

The app requires microphone access for speech recognition. The Info.plist includes:

- `NSMicrophoneUsageDescription` - Required for recording audio
- `NSSpeechRecognitionUsageDescription` - Optional, for system speech recognition

## Troubleshooting

### Package Resolution Fails

1. In Xcode: **File → Packages → Reset Package Caches**
2. Clean build: **Product → Clean Build Folder** (Cmd+Shift+K)
3. Close and reopen the project

### Build Errors with SDK Imports

Ensure all three SDK products are added to your target:
1. Select your target in Xcode
2. Go to **General → Frameworks, Libraries, and Embedded Content**
3. Verify: `RunAnywhere`, `RunAnywhereLlamaCPP`, `RunAnywhereONNX`

### Models Not Downloading

Check network connectivity. Models are downloaded from:
- HuggingFace (LLM models)
- GitHub (RunanywhereAI/sherpa-onnx for STT/TTS models)

## Privacy

All AI processing happens **entirely on-device**. No data is ever sent to external servers. This ensures:

- ✅ Complete data privacy
- ✅ Offline functionality
- ✅ Low latency responses
- ✅ No API costs

## License

MIT License - See [LICENSE](LICENSE) for details.

## Resources

- [RunAnywhere SDK Repository](https://github.com/RunanywhereAI/runanywhere-sdks)
- [SDK Releases](https://github.com/RunanywhereAI/runanywhere-sdks/releases)
- [Swift SDK API Documentation](https://github.com/RunanywhereAI/runanywhere-sdks/blob/main/sdk/runanywhere-swift/Documentation.md)
