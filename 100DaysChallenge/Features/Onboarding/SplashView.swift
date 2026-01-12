//
//  SplashView.swift
//  100DaysChallenge
//
//  Splash/Start screen
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color.gradientSplash
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xxxl) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.xxl)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FF9D5C"), Color(hex: "#FF6BB5")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)
                        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.white)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
                
                // Text
                VStack(spacing: Spacing.sm) {
                    Text("100 Days")
                        .font(.displayLarge)
                        .foregroundColor(.textPrimary)
                        .tracking(-1)
                    
                    Text("Build lasting habits")
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
            
            // Navigate after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                appState.handleSplashComplete()
            }
        }
    }
}

