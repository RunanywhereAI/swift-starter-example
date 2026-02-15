# RunAnywhere Swift SDK Starter App

A comprehensive starter app demonstrating RunAnywhere SDK capabilities - **privacy-first, on-device AI for iOS and macOS**.

![RunAnywhere](https://img.shields.io/badge/RunAnywhere-SDK-00D9FF)
![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B%20%7C%20macOS%2014%2B-8B5CF6)
![Swift](https://img.shields.io/badge/Swift-5.9-EC4899)

## Features

This starter app showcases all the core capabilities of the RunAnywhere SDK:

- 🤖 **Chat (LLM)** - On-device text generation with streaming support
- 🛠️ **Tool Calling** - Function calling with structured tool definitions
- 👁️ **Vision (VLM)** - Image understanding with Vision Language Models
- 🎨 **Image Generation (Diffusion)** - On-device image generation via CoreML Stable Diffusion
- 🎤 **Speech to Text (STT)** - On-device speech recognition using Whisper
- 🔊 **Text to Speech (TTS)** - On-device voice synthesis using Piper
- 🎯 **Voice Pipeline** - Full voice agent: Speak → Transcribe → Generate → Speak

All AI processing runs **entirely on-device** with no data sent to external servers.

## Platforms

| Platform | Min Version | Architecture | Status |
|----------|-------------|-------------|--------|
| iOS | 17.0+ | arm64 | Fully supported |
| iOS Simulator | 17.0+ | arm64 | Fully supported |
| macOS | 14.0+ | arm64 (Apple Silicon) | Fully supported |

## Requirements

- iOS 17.0+ / macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Silicon Mac (for macOS target)

## Getting Started

### 1. Open in Xcode

```bash
open Swift-Starter-Example.xcodeproj
```

### 2. SDK Package Dependencies (Pre-configured)

This project is pre-configured to fetch the RunAnywhere SDK directly from GitHub:

```
https://github.com/RunanywhereAI/runanywhere-sdks
Version: 0.19.1+
```

The following SDK products are included:
- **`RunAnywhere`** - Core SDK (unified API for all AI capabilities)
- **`RunAnywhereLlamaCPP`** - LLM and VLM text generation backend (llama.cpp with Metal GPU)
- **`RunAnywhereONNX`** - Speech-to-text, text-to-speech, VAD (Sherpa-ONNX)

When you open the project, Xcode will automatically fetch and resolve the packages from GitHub.

### 3. Configure Signing

In Xcode:
1. Select the project in the navigator
2. Go to **Signing & Capabilities**
3. Select your **Team**
4. Update the **Bundle Identifier** if needed

### 4. Select Target and Run

- **iPhone / iPad**: Select a simulator or connected device, press `Cmd + R`
- **Mac (My Mac)**: Select "My Mac" in the destination picker, press `Cmd + R`

> **Note:** The first build may take a few minutes as Xcode downloads the SDK and its dependencies from GitHub. For best AI inference performance, run on a physical device.

## SDK Dependencies

This app uses the RunAnywhere Swift SDK v0.19.1 from [GitHub releases](https://github.com/RunanywhereAI/runanywhere-sdks/releases/tag/v0.19.1):

| Module | Import | Description |
|--------|--------|-------------|
| Core SDK | `import RunAnywhere` | Unified API for all AI capabilities |
| LlamaCPP | `import LlamaCPPRuntime` | LLM/VLM text generation (Metal GPU accelerated) |
| ONNX | `import ONNXRuntime` | STT/TTS/VAD via Sherpa-ONNX |

## Models Used

| Capability | Model | Framework | Size |
|------------|-------|-----------|------|
| LLM (Chat) | LFM2 350M Q4_K_M | LlamaCPP | ~250MB |
| VLM (Vision) | SmolVLM 256M Instruct | LlamaCPP | ~300MB |
| STT | Sherpa Whisper Tiny (English) | ONNX | ~75MB |
| TTS | Piper (US English - Lessac Medium) | ONNX | ~65MB |
| Diffusion | Stable Diffusion 1.5 CoreML Palettized | CoreML | ~1.5GB |

Models are downloaded on-demand and cached locally on the device. No internet required after initial download.

## Project Structure

```
Swift-Starter-Example/
├── Swift_Starter_ExampleApp.swift   # App entry point & SDK initialization
├── ContentView.swift                 # Main content view wrapper
├── Info.plist                        # Privacy permissions (mic, camera, photos)
├── Theme/
│   └── AppTheme.swift               # Colors, fonts, and styling
├── Services/
│   └── ModelService.swift           # AI model management & registration
├── Views/
│   ├── HomeView.swift               # Home screen with feature cards
│   ├── ChatView.swift               # LLM chat interface with streaming
│   ├── ToolCallingView.swift        # Tool calling demo (weather, calc, time)
│   ├── VisionView.swift             # VLM image understanding
│   ├── ImageGenerationView.swift    # Stable Diffusion image generation
│   ├── SpeechToTextView.swift       # Speech recognition with audio visualizer
│   ├── TextToSpeechView.swift       # Voice synthesis with rate control
│   └── VoicePipelineView.swift      # Full voice agent pipeline
└── Components/
    ├── FeatureCard.swift            # Reusable feature card
    ├── ModelLoaderView.swift        # Model download/load UI with progress
    ├── AudioVisualizer.swift        # Audio level visualization
    └── ChatMessageBubble.swift      # Chat message with metrics display
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
LlamaCPP.register()  // For LLM/VLM text generation
ONNX.register()      // For STT, TTS, VAD
```

### Text Generation (LLM)

```swift
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

### Tool Calling

```swift
// Register tools
RunAnywhere.registerTool(
    name: "get_weather",
    description: "Get weather for a location",
    parameters: ["location": .string("City name")]
) { args in
    return "72°F and sunny in \(args["location"] ?? "unknown")"
}

// Generate with tools
let result = try await RunAnywhere.generateWithTools(
    "What's the weather in San Francisco?",
    options: ToolCallingOptions(maxTokens: 256)
)
```

### Vision (VLM)

```swift
// Load VLM model
try await RunAnywhere.loadVLMModel(model)

// Process image with prompt
let result = try await RunAnywhere.processImageStream(
    VLMImage(image: uiImage),
    prompt: "Describe this image in detail.",
    maxTokens: 300
)

for try await token in result.stream {
    print(token, terminator: "")
}
```

### Image Generation (Diffusion)

```swift
// Load diffusion model
try await RunAnywhere.loadDiffusionModel(model)

// Generate image
let result = try await RunAnywhere.generateImage(
    prompt: "A serene mountain landscape at sunset",
    options: DiffusionOptions(steps: 20, guidanceScale: 7.5)
) { update in
    print("Step \(update.currentStep)/\(update.totalSteps)")
    return true // continue
}
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

// Speak text (synthesis + playback)
try await RunAnywhere.speak("Hello, world!", options: TTSOptions(rate: 1.0))
```

## Adding the SDK to Your Own Project

To add the RunAnywhere SDK to a new Swift project:

### Option 1: Xcode UI
1. In Xcode: **File > Add Package Dependencies...**
2. Enter: `https://github.com/RunanywhereAI/runanywhere-sdks`
3. Select **Up to Next Major Version**: `0.19.1`
4. Add all three products: `RunAnywhere`, `RunAnywhereLlamaCPP`, `RunAnywhereONNX`

### Option 2: Package.swift
```swift
dependencies: [
    .package(url: "https://github.com/RunanywhereAI/runanywhere-sdks", from: "0.19.1")
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

The app requires the following permissions (configured in Info.plist):

| Permission | Purpose | Required for |
|-----------|---------|-------------|
| `NSMicrophoneUsageDescription` | Recording audio | STT, Voice Pipeline |
| `NSSpeechRecognitionUsageDescription` | Speech recognition | STT |
| `NSCameraUsageDescription` | Camera access | VLM (Vision) |
| `NSPhotoLibraryUsageDescription` | Photo library access | VLM, Diffusion |

## Troubleshooting

### Package Resolution Fails

1. In Xcode: **File > Packages > Reset Package Caches**
2. Clean build: **Product > Clean Build Folder** (Cmd+Shift+K)
3. Close and reopen the project

### Build Errors with SDK Imports

Ensure all three SDK products are added to your target:
1. Select your target in Xcode
2. Go to **General > Frameworks, Libraries, and Embedded Content**
3. Verify: `RunAnywhere`, `RunAnywhereLlamaCPP`, `RunAnywhereONNX`

### macOS Code Signing

If you see `CodeSign failed` when running on Mac:
1. Clean build: **Product > Clean Build Folder** (Cmd+Shift+K)
2. Rebuild: Xcode will re-sign the embedded frameworks

### Models Not Downloading

Check network connectivity. Models are downloaded from:
- HuggingFace (LLM, VLM, Diffusion models)
- GitHub (RunanywhereAI/sherpa-onnx for STT/TTS models)

## Privacy

All AI processing happens **entirely on-device**. No data is ever sent to external servers. This ensures:

- Complete data privacy
- Offline functionality (after model download)
- Low latency responses
- No API costs

## License

MIT License - See [LICENSE](LICENSE) for details.

## Resources

- [RunAnywhere SDK Repository](https://github.com/RunanywhereAI/runanywhere-sdks)
- [SDK Releases](https://github.com/RunanywhereAI/runanywhere-sdks/releases)
- [Swift SDK Documentation](https://github.com/RunanywhereAI/runanywhere-sdks/blob/main/sdk/runanywhere-swift/README.md)
