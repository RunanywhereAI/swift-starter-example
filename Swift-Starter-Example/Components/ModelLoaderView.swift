//
//  ModelLoaderView.swift
//  Swift-Starter-Example
//
//  RunAnywhere iOS SDK Starter App
//

import SwiftUI

struct ModelLoaderView: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let isDownloading: Bool
    let isLoading: Bool
    let progress: Double
    let onLoad: () -> Void
    
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 32) {
            // Icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 128, height: 128)
                
                Circle()
                    .stroke(accentColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 128, height: 128)
                
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundStyle(accentColor)
            }
            .scaleEffect(iconScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    iconScale = 1.05
                }
            }
            
            // Title
            Text(title)
                .font(AppFonts.headlineMedium())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text(subtitle)
                .font(AppFonts.bodyMedium())
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            // Progress / Button
            if isDownloading {
                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: accentColor))
                        .frame(width: 240)
                    
                    Text("Downloading... \(Int(progress * 100))%")
                        .font(AppFonts.bodySmall())
                        .foregroundStyle(accentColor)
                }
            } else if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                        .scaleEffect(1.2)
                    
                    Text("Loading model...")
                        .font(AppFonts.bodySmall())
                        .foregroundStyle(accentColor)
                }
            } else {
                Button(action: onLoad) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Download & Load")
                    }
                    .font(AppFonts.titleMedium())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Info box
            HStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.textMuted)
                
                Text("Models are downloaded once and stored locally")
                    .font(AppFonts.bodySmall())
                    .foregroundStyle(AppColors.textMuted)
            }
            .padding(16)
            .background(AppColors.surfaceCard.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.textMuted.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(32)
    }
}

#Preview {
    ModelLoaderView(
        title: "LLM Model Required",
        subtitle: "Download and load the language model to start chatting",
        icon: "bubble.left.and.bubble.right.fill",
        accentColor: AppColors.accentCyan,
        isDownloading: false,
        isLoading: false,
        progress: 0.0
    ) {
        print("Load")
    }
    .background(AppColors.primaryDark)
}
