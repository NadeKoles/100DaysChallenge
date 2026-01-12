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
                        .frame(width: geometry.size.width * progress, height: 16)
                        .animation(.easeOut(duration: 0.5), value: progress)
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
    }
}

