//
//  ConfirmCompleteDayModal.swift
//  100DaysChallenge
//
//  Confirmation modal for completing a day
//

import SwiftUI

struct ConfirmCompleteDayModal: View {
    let day: Int
    let accentColor: Color
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(accentColor)
            }
            .padding(.top, Spacing.xl)
            
            // Text
            VStack(spacing: Spacing.sm) {
                Text("Complete Day \(day)?")
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Great work! Mark today as completed and keep your streak going.")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            
            // Buttons
            HStack(spacing: Spacing.md) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.label)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray100)
                        .cornerRadius(CornerRadius.xl)
                }
                
                Button(action: onConfirm) {
                    Text("Complete")
                        .font(.label)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(accentColor)
                        .cornerRadius(CornerRadius.xl)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: 400)
        .background(Color.background)
        .cornerRadius(CornerRadius.xxl)
        .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
        .padding(Spacing.xl)
    }
}

