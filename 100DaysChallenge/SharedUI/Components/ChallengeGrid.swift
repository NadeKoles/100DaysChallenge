//
//  ChallengeGrid.swift
//  100DaysChallenge
//
//  100-day grid component
//

import SwiftUI

struct ChallengeGridView: View {
    let challenge: Challenge
    let onToggleDay: (Int) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 10)
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(LocalizedStrings.Progress.gridTitle)
                .font(.labelTiny)
                .foregroundColor(.textSecondary)
                .tracking(1)
            
            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                ForEach(1...100, id: \.self) { day in
                    DayCell(
                        day: day,
                        isCompleted: challenge.completedDaysSet.contains(day),
                        isCurrent: day == challenge.currentDay,
                        isFuture: day > challenge.currentDay,
                        accentColor: Color(hex: challenge.accentColor),
                        onTap: {
                            onToggleDay(day)
                        }
                    )
                }
            }
        }
        .padding(Spacing.xl)
        .background(Color.background)
        .cornerRadius(CornerRadius.xxl)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.xxl)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

