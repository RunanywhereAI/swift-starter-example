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
    // MARK: - Model IDs
    static let llmModelId = "smollm2-360m-instruct-q8_0"
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
        // LLM Model - SmolLM2 360M (small, fast, good for demos)
        LlamaCPP.register()
        
        // Register ONNX backend for STT/TTS/VAD
        ONNX.register()
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
        
        // Check if already downloaded
        let models = try? await RunAnywhere.availableModels()
        let model = models?.first { $0.id == Self.llmModelId }
        let isDownloaded = model?.localPath != nil
        
        if !isDownloaded {
            isLLMDownloading = true
            llmDownloadProgress = 0.0
            
            do {
                for try await progress in RunAnywhere.downloadModel(Self.llmModelId) {
                    llmDownloadProgress = progress.percentage
                    if progress.state == .completed || progress.state == .failed {
                        break
                    }
                }
            } catch {
                print("LLM download error: \(error)")
            }
            
            isLLMDownloading = false
        }
        
        // Load the model
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
        
        // Check if already downloaded
        let models = try? await RunAnywhere.availableModels()
        let model = models?.first { $0.id == Self.sttModelId }
        let isDownloaded = model?.localPath != nil
        
        if !isDownloaded {
            isSTTDownloading = true
            sttDownloadProgress = 0.0
            
            do {
                for try await progress in RunAnywhere.downloadModel(Self.sttModelId) {
                    sttDownloadProgress = progress.percentage
                    if progress.state == .completed || progress.state == .failed {
                        break
                    }
                }
            } catch {
                print("STT download error: \(error)")
            }
            
            isSTTDownloading = false
        }
        
        // Load the model
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
        
        // Check if already downloaded
        let models = try? await RunAnywhere.availableModels()
        let model = models?.first { $0.id == Self.ttsModelId }
        let isDownloaded = model?.localPath != nil
        
        if !isDownloaded {
            isTTSDownloading = true
            ttsDownloadProgress = 0.0
            
            do {
                for try await progress in RunAnywhere.downloadModel(Self.ttsModelId) {
                    ttsDownloadProgress = progress.percentage
                    if progress.state == .completed || progress.state == .failed {
                        break
                    }
                }
            } catch {
                print("TTS download error: \(error)")
            }
            
            isTTSDownloading = false
        }
        
        // Load the voice
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
    func downloadAndLoadAllModels() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.downloadAndLoadLLM() }
            group.addTask { await self.downloadAndLoadSTT() }
            group.addTask { await self.downloadAndLoadTTS() }
        }
    }
    
    /// Unload all models
    func unloadAllModels() async {
        do {
            try await RunAnywhere.unloadModel()
            try await RunAnywhere.unloadSTTModel()
            try await RunAnywhere.unloadTTSVoice()
        } catch {
            print("Unload error: \(error)")
        }
        await refreshLoadedStates()
    }
}
