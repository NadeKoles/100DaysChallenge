//
//  OnboardingView.swift
//  100DaysChallenge
//
//  Onboarding flow with 3 slides
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicators
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<viewModel.slides.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index == viewModel.currentSlide ? 
                                  viewModel.slides[index].color : Color.gray200)
                            .frame(width: index == viewModel.currentSlide ? 32 : 8, 
                                   height: 6)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentSlide)
                    }
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xl)
                
                // Content
                TabView(selection: $viewModel.currentSlide) {
                    ForEach(0..<viewModel.slides.count, id: \.self) { index in
                        OnboardingSlideView(slide: viewModel.slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                
                Spacer()
                
                // Bottom button
                Button(action: {
                    if viewModel.currentSlide < viewModel.slides.count - 1 {
                        withAnimation {
                            viewModel.currentSlide += 1
                        }
                    } else {
                        appState.handleOnboardingComplete()
                    }
                }) {
                    HStack(spacing: Spacing.sm) {
                        Text(viewModel.currentSlide < viewModel.slides.count - 1 ? 
                             "Continue" : "Get Started")
                            .font(.label)
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.slides[viewModel.currentSlide].color)
                    .cornerRadius(CornerRadius.xl)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}

struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    
    var body: some View {
        VStack(spacing: Spacing.xxxl) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.xxl)
                    .fill(slide.color.opacity(0.15))
                    .frame(width: 160, height: 160)
                
                Image(systemName: slide.iconName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(slide.color)
            }
            
            // Text
            VStack(spacing: Spacing.lg) {
                Text(slide.title)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(slide.description)
                    .font(.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
        }
        .padding(.top, Spacing.xxxl)
    }
}

