//
//  ModelService.swift
//  Swift-Starter-Example
//
//  RunAnywhere iOS SDK Starter App - Model Management Service
//

import SwiftUI
import Combine
import RunAnywhere
import LlamaCPPRuntime
import ONNXRuntime

/// Service for managing AI models - handles downloading, loading, and state tracking
@MainActor
final class ModelService: ObservableObject {
    // MARK: - Model IDs (must match registered model IDs)
    static let llmModelId = "lfm2-350m-q4_k_m"
    static let sttModelId = "sherpa-onnx-whisper-tiny.en"
    static let ttsModelId = "vits-piper-en_US-lessac-medium"
    
    // MARK: - Download State
    @Published var isLLMDownloading = false
    @Published var isSTTDownloading = false
    @Published var isTTSDownloading = false
    
    @Published var llmDownloadProgress: Double = 0.0
    @Published var sttDownloadProgress: Double = 0.0
    @Published var ttsDownloadProgress: Double = 0.0
    
    // MARK: - Load State
    @Published var isLLMLoading = false
    @Published var isSTTLoading = false
    @Published var isTTSLoading = false
    
    // MARK: - Loaded State
    @Published private(set) var isLLMLoaded = false
    @Published private(set) var isSTTLoaded = false
    @Published private(set) var isTTSLoaded = false
    
    // MARK: - Computed Properties
    var isVoiceAgentReady: Bool {
        isLLMLoaded && isSTTLoaded && isTTSLoaded
    }
    
    var isAnyDownloading: Bool {
        isLLMDownloading || isSTTDownloading || isTTSDownloading
    }
    
    var isAnyLoading: Bool {
        isLLMLoading || isSTTLoading || isTTSLoading
    }
    
    // MARK: - Initialization
    init() {
        Task {
            await refreshLoadedStates()
        }
    }
    
    // MARK: - Model Registration
    /// Register default models with the SDK
    static func registerDefaultModels() {
        // Register LLM model - LiquidAI LFM2 350M Q4 (small, fast, efficient)
        if let lfm2URL = URL(string: "https://huggingface.co/LiquidAI/LFM2-350M-GGUF/resolve/main/LFM2-350M-Q4_K_M.gguf") {
            RunAnywhere.registerModel(
                id: llmModelId,
                name: "LiquidAI LFM2 350M Q4_K_M",
                url: lfm2URL,
                framework: .llamaCpp,
                memoryRequirement: 250_000_000
            )
        }
        
        // Register STT model - Whisper Tiny (fast, accurate for English)
        if let whisperURL = URL(string: "https://github.com/RunanywhereAI/sherpa-onnx/releases/download/runanywhere-models-v1/sherpa-onnx-whisper-tiny.en.tar.gz") {
            RunAnywhere.registerModel(
                id: sttModelId,
                name: "Sherpa Whisper Tiny (ONNX)",
                url: whisperURL,
                framework: .onnx,
                modality: .speechRecognition,
                artifactType: .archive(.tarGz, structure: .nestedDirectory),
                memoryRequirement: 75_000_000
            )
        }
        
        // Register TTS voice - Piper US English (natural sounding)
        if let piperURL = URL(string: "https://github.com/RunanywhereAI/sherpa-onnx/releases/download/runanywhere-models-v1/vits-piper-en_US-lessac-medium.tar.gz") {
            RunAnywhere.registerModel(
                id: ttsModelId,
                name: "Piper TTS (US English - Medium)",
                url: piperURL,
                framework: .onnx,
                modality: .speechSynthesis,
                artifactType: .archive(.tarGz, structure: .nestedDirectory),
                memoryRequirement: 65_000_000
            )
        }
        
        print("✅ Models registered: LLM, STT, TTS")
    }
    
    // MARK: - State Refresh
    func refreshLoadedStates() async {
        isLLMLoaded = await RunAnywhere.isModelLoaded
        isSTTLoaded = await RunAnywhere.isSTTModelLoaded
        isTTSLoaded = await RunAnywhere.isTTSVoiceLoaded
    }
    
    // MARK: - LLM Operations
    /// Download and load LLM model
    func downloadAndLoadLLM() async {
        guard !isLLMDownloading && !isLLMLoading else { return }
        
        // Try to load first if already downloaded
        isLLMLoading = true
        do {
            try await RunAnywhere.loadModel(Self.llmModelId)
            isLLMLoaded = true
            isLLMLoading = false
            print("✅ LLM model loaded from cache")
            return
        } catch {
            print("LLM load attempt failed (will download): \(error)")
            isLLMLoading = false
        }
        
        // If loading failed, download the model
        isLLMDownloading = true
        llmDownloadProgress = 0.0
        
        do {
            let progressStream = try await RunAnywhere.downloadModel(Self.llmModelId)
            for await progress in progressStream {
                llmDownloadProgress = progress.overallProgress
                if progress.stage == .completed {
                    break
                }
            }
        } catch {
            print("LLM download error: \(error)")
            isLLMDownloading = false
            return
        }
        
        isLLMDownloading = false
        
        // Load the model after download
        isLLMLoading = true
        
        do {
            try await RunAnywhere.loadModel(Self.llmModelId)
            isLLMLoaded = true
        } catch {
            print("LLM load error: \(error)")
        }
        
        isLLMLoading = false
    }
    
    // MARK: - STT Operations
    /// Download and load STT model
    func downloadAndLoadSTT() async {
        guard !isSTTDownloading && !isSTTLoading else { return }
        
        // Try to load first if already downloaded
        isSTTLoading = true
        do {
            try await RunAnywhere.loadSTTModel(Self.sttModelId)
            isSTTLoaded = true
            isSTTLoading = false
            print("✅ STT model loaded from cache")
            return
        } catch {
            print("STT load attempt failed (will download): \(error)")
            isSTTLoading = false
        }
        
        // If loading failed, download the model
        isSTTDownloading = true
        sttDownloadProgress = 0.0
        
        do {
            let progressStream = try await RunAnywhere.downloadModel(Self.sttModelId)
            for await progress in progressStream {
                sttDownloadProgress = progress.overallProgress
                if progress.stage == .completed {
                    break
                }
            }
        } catch {
            print("STT download error: \(error)")
            isSTTDownloading = false
            return
        }
        
        isSTTDownloading = false
        
        // Load the model after download
        isSTTLoading = true
        
        do {
            try await RunAnywhere.loadSTTModel(Self.sttModelId)
            isSTTLoaded = true
        } catch {
            print("STT load error: \(error)")
        }
        
        isSTTLoading = false
    }
    
    // MARK: - TTS Operations
    /// Download and load TTS voice
    func downloadAndLoadTTS() async {
        guard !isTTSDownloading && !isTTSLoading else { return }
        
        // Try to load first if already downloaded
        isTTSLoading = true
        do {
            try await RunAnywhere.loadTTSVoice(Self.ttsModelId)
            isTTSLoaded = true
            isTTSLoading = false
            print("✅ TTS voice loaded from cache")
            return
        } catch {
            print("TTS load attempt failed (will download): \(error)")
            isTTSLoading = false
        }
        
        // If loading failed, download the model
        isTTSDownloading = true
        ttsDownloadProgress = 0.0
        
        do {
            let progressStream = try await RunAnywhere.downloadModel(Self.ttsModelId)
            for await progress in progressStream {
                ttsDownloadProgress = progress.overallProgress
                if progress.stage == .completed {
                    break
                }
            }
        } catch {
            print("TTS download error: \(error)")
            isTTSDownloading = false
            return
        }
        
        isTTSDownloading = false
        
        // Load the voice after download
        isTTSLoading = true
        
        do {
            try await RunAnywhere.loadTTSVoice(Self.ttsModelId)
            isTTSLoaded = true
        } catch {
            print("TTS load error: \(error)")
        }
        
        isTTSLoading = false
    }
    
    // MARK: - Batch Operations
    /// Download and load all models for voice agent
    /// Note: Downloads run sequentially to avoid SDK concurrency issues
    func downloadAndLoadAllModels() async {
        // Run sequentially to avoid race conditions in SDK's download service
        await downloadAndLoadLLM()
        await downloadAndLoadSTT()
        await downloadAndLoadTTS()
    }
    
    /// Unload all models
    func unloadAllModels() async {
        do {
            try await RunAnywhere.unloadModel()
        } catch {
            print("LLM unload error: \(error)")
        }
        
        do {
            try await RunAnywhere.unloadSTTModel()
        } catch {
            print("STT unload error: \(error)")
        }
        
        do {
            try await RunAnywhere.unloadTTSVoice()
        } catch {
            print("TTS unload error: \(error)")
        }
        
        await refreshLoadedStates()
    }
}
