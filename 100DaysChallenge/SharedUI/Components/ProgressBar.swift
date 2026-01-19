//
//  ProgressBar.swift
//  100DaysChallenge
//
//  Progress bar component
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    let accentColor: Color
    let delay: TimeInterval
    let duration: TimeInterval
    
    @State private var displayedProgress: Double = 0
    @State private var animationTask: Task<Void, Never>?
    
    init(progress: Double, accentColor: Color, delay: TimeInterval = 0.25, duration: TimeInterval = 0.55) {
        self.progress = progress
        self.accentColor = accentColor
        self.delay = delay
        self.duration = duration
    }
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray100)
                        .frame(height: 16)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accentColor)
                        .frame(width: geometry.size.width * displayedProgress, height: 16)
                }
            }
            .frame(height: 16)
            
            // Percentage labels
            HStack {
                Text("0%")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.labelSmall)
                    .foregroundColor(accentColor)
                
                Spacer()
                
                Text("100%")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
        .onAppear {
            displayedProgress = progress
        }
        .onChange(of: progress) { newProgress in
            animationTask?.cancel()
            
            let previousProgress = displayedProgress
            let isIncreasing = newProgress > previousProgress
            
            animationTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
                guard !Task.isCancelled else { return }
                
                // Phase 1: Overshoot in the direction of change
                let overshootValue: Double
                if isIncreasing {
                    // Overshoot above target when increasing
                    overshootValue = min(newProgress * 1.01, 1.0)
                } else {
                    // Overshoot below target when decreasing
                    overshootValue = max(newProgress * 0.99, 0.0)
                }
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: duration * 0.4)) {
                        displayedProgress = overshootValue
                    }
                }
                
                try? await Task.sleep(nanoseconds: UInt64(duration * 0.6 * 1_000_000_000))
                
                guard !Task.isCancelled else { return }
                
                // Phase 2: Settle back to final value
                await MainActor.run {
                    withAnimation(.easeOut(duration: duration * 0.6)) {
                        displayedProgress = newProgress
                    }
                }
            }
        }
    }
}

