//
//  ChatMessageBubble.swift
//  Swift-Starter-Example
//
//  RunAnywhere iOS SDK Starter App
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    var tokensPerSecond: Double?
    var totalTokens: Int?
    var isError: Bool = false
    var wasCancelled: Bool = false
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChatMessageBubble: View {
    let message: ChatMessage
    var isStreaming: Bool = false
    
    @State private var cursorVisible = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !message.isUser {
                // AI Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.accentGradient)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(width: 36, height: 36)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                // Message bubble
                HStack(alignment: .bottom, spacing: 4) {
                    Text(message.text)
                        .font(AppFonts.bodyLarge())
                        .foregroundStyle(
                            message.isUser ? .white :
                                message.isError ? AppColors.error :
                                AppColors.textPrimary
                        )
                        .lineSpacing(4)
                    
                    if isStreaming {
                        Rectangle()
                            .fill(AppColors.accentCyan)
                            .frame(width: 8, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .opacity(cursorVisible ? 1 : 0)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                                    cursorVisible.toggle()
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if message.isUser {
                            LinearGradient(
                                colors: [AppColors.accentCyan, Color(hex: "0EA5E9")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            AppColors.surfaceCard
                        }
                    }
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                        .corners(
                            topLeft: 18,
                            topRight: 18,
                            bottomLeft: message.isUser ? 18 : 4,
                            bottomRight: message.isUser ? 4 : 18
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            message.isError ? AppColors.error.opacity(0.5) :
                                message.isUser ? .clear : AppColors.textMuted.opacity(0.1),
                            lineWidth: message.isUser ? 0 : 1
                        )
                )
                .shadow(
                    color: message.isUser ? AppColors.accentCyan.opacity(0.3) : .clear,
                    radius: 12,
                    y: 4
                )
                
                // Metrics for AI messages
                if !message.isUser && !isStreaming && message.tokensPerSecond != nil {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 12))
                            Text(String(format: "%.1f tok/s", message.tokensPerSecond ?? 0))
                        }
                        
                        if let tokens = message.totalTokens {
                            HStack(spacing: 4) {
                                Image(systemName: "number")
                                    .font(.system(size: 12))
                                Text("\(tokens) tokens")
                            }
                        }
                    }
                    .font(AppFonts.labelSmall())
                    .foregroundStyle(AppColors.textMuted)
                }
                
                // Cancelled badge
                if message.wasCancelled {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 12))
                        Text("Cancelled")
                    }
                    .font(AppFonts.labelSmall())
                    .foregroundStyle(AppColors.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.warning.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            #if os(iOS)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            #else
            .frame(maxWidth: 500, alignment: message.isUser ? .trailing : .leading)
            #endif
            
            if message.isUser {
                // User Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.surfaceElevated)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(width: 36, height: 36)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .padding(.vertical, 6)
    }
}

// MARK: - Custom Corner Radius Shape
extension RoundedRectangle {
    func corners(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) -> some Shape {
        CustomRoundedRectangle(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        )
    }
}

struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
                    radius: topRight,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                    radius: bottomRight,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                    radius: bottomLeft,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                    radius: topLeft,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        return path
    }
}

#Preview {
    VStack {
        ChatMessageBubble(
            message: ChatMessage(
                text: "Hello! How are you?",
                isUser: true,
                timestamp: Date()
            )
        )
        
        ChatMessageBubble(
            message: ChatMessage(
                text: "I'm doing great! How can I help you today?",
                isUser: false,
                timestamp: Date(),
                tokensPerSecond: 25.5,
                totalTokens: 42
            )
        )
    }
    .padding()
    .background(AppColors.primaryDark)
}
