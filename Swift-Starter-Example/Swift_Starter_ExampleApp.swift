//
//  Swift_Starter_ExampleApp.swift
//  Swift-Starter-Example
//
//  RunAnywhere iOS SDK Starter App
//  Privacy-first, on-device AI for iOS
//

import SwiftUI
import RunAnywhere
import LlamaCPPRuntime
import ONNXRuntime

@main
struct Swift_Starter_ExampleApp: App {
    @StateObject private var modelService = ModelService()
    
    init() {
        // Initialize the RunAnywhere SDK
        initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(modelService)
                .preferredColorScheme(.dark)
        }
    }
    
    private func initializeSDK() {
        do {
            // Initialize the RunAnywhere SDK in development mode
            try RunAnywhere.initialize(environment: .development)
            
            // Register the LlamaCPP backend for LLM text generation
            LlamaCPP.register()
            
            // Register the ONNX backend for STT, TTS, and VAD
            ONNX.register()
            
            // Register default models
            ModelService.registerDefaultModels()
            
            print("✅ RunAnywhere SDK initialized successfully")
            print("   Version: \(RunAnywhere.version)")
        } catch {
            print("❌ Failed to initialize RunAnywhere SDK: \(error)")
        }
    }
}
