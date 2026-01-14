//
//  ContentView.swift
//  Swift-Starter-Example
//
//  RunAnywhere iOS SDK Starter App
//  Note: Main entry point is HomeView, this file kept for reference
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(ModelService())
}
