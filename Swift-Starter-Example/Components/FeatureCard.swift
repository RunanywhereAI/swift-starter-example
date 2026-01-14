//
//  FeatureCard.swift
//  Swift-Starter-Example
//
//  RunAnywhere iOS SDK Starter App
//

import SwiftUI

struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradientColors: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.surfaceCard, AppColors.surfaceCard.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(gradientColors.first?.opacity(0.3) ?? .clear, lineWidth: 1.5)
                    )
                    .shadow(color: gradientColors.first?.opacity(0.1) ?? .clear, radius: 20, y: 10)
                
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [gradientColors.first?.opacity(0.3) ?? .clear, .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .offset(x: 40, y: -40)
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: gradientColors.first?.opacity(0.4) ?? .clear, radius: 12, y: 4)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 48, height: 48)
                    
                    Spacer()
                    
                    // Title
                    Text(title)
                        .font(AppFonts.titleLarge())
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textPrimary)
                    
                    // Subtitle
                    Text(subtitle)
                        .font(AppFonts.bodySmall())
                        .foregroundStyle(AppColors.textMuted)
                        .padding(.top, 4)
                    
                    // Try it link
                    HStack(spacing: 4) {
                        Text("Try it")
                            .font(AppFonts.labelLarge())
                            .foregroundStyle(gradientColors.first ?? AppColors.accentCyan)
                        
                        Image(systemName: "arrow.forward")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(gradientColors.first ?? AppColors.accentCyan)
                    }
                    .padding(.top, 12)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        FeatureCard(
            title: "Chat",
            subtitle: "LLM Text Generation",
            icon: "bubble.left.and.bubble.right.fill",
            gradientColors: [AppColors.accentCyan, Color(hex: "0EA5E9")]
        ) {
            print("Tapped")
        }
        .frame(height: 180)
    }
    .padding()
    .background(AppColors.primaryDark)
}
