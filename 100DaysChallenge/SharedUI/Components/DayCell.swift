//
//  DayCell.swift
//  100DaysChallenge
//
//  Individual day cell in the 100-day grid
//

import SwiftUI

struct DayCell: View {
    let day: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isFuture: Bool
    let accentColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if !isFuture {
                onTap()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(borderColor, lineWidth: isCurrent ? 2 : 0)
                    )
                
                Text("\(day)")
                    .font(.labelTiny)
                    .foregroundColor(textColor)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .disabled(isFuture)
        .opacity(isFuture ? 0.4 : 1)
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return accentColor
        } else if isFuture {
            return Color.gray50
        } else {
            return Color.gray100
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .white
        } else if isFuture {
            return Color.gray400
        } else {
            return Color.gray500
        }
    }
    
    private var borderColor: Color {
        isCurrent ? accentColor : Color.clear
    }
}

