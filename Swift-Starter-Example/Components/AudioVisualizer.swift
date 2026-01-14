//
//  AudioVisualizer.swift
//  Swift-Starter-Example
//
//  RunAnywhere iOS SDK Starter App
//

import SwiftUI

struct AudioVisualizer: View {
    let level: Double
    var color: Color = AppColors.accentViolet
    
    @State private var barHeights: [CGFloat] = Array(repeating: 0.3, count: 15)
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<barHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 6, height: 80 * barHeights[index])
                    .shadow(color: level > 0.3 ? color.opacity(0.4) : .clear, radius: 8)
            }
        }
        .frame(height: 80)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: level) { _, _ in
            updateBars()
        }
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateBars()
        }
    }
    
    private func updateBars() {
        withAnimation(.easeInOut(duration: 0.05)) {
            for i in 0..<barHeights.count {
                let baseHeight = level * 0.8
                let variation = Double.random(in: -0.2...0.2)
                let waveOffset = sin(Date().timeIntervalSince1970 * 5 + Double(i) * 0.5) * 0.15 * level
                barHeights[i] = CGFloat(max(0.15, min(1.0, baseHeight + variation + waveOffset)))
            }
        }
    }
}

// MARK: - Playback Waveform Visualizer
struct WaveformVisualizer: View {
    let amplitudes: [Double]
    var progress: Double = 0.0
    var activeColor: Color = AppColors.accentPink
    var inactiveColor: Color = AppColors.textMuted
    
    var body: some View {
        let progressIndex = Int(progress * Double(amplitudes.count))
        
        HStack(spacing: 4) {
            ForEach(0..<amplitudes.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= progressIndex ? activeColor : inactiveColor.opacity(0.3))
                    .frame(width: 4, height: 60 * max(0.1, min(1.0, CGFloat(amplitudes[index]))))
            }
        }
        .frame(height: 60)
    }
}

#Preview {
    VStack(spacing: 40) {
        AudioVisualizer(level: 0.7)
        
        WaveformVisualizer(
            amplitudes: [0.3, 0.5, 0.8, 0.4, 0.9, 0.6, 0.7, 0.5, 0.8, 0.3],
            progress: 0.5
        )
    }
    .padding()
    .background(AppColors.primaryDark)
}
