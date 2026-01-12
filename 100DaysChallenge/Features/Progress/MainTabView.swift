//
//  MainTabView.swift
//  100DaysChallenge
//
//  Main tab bar container
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch appState.currentTab {
                case .progress:
                    ProgressView()
                case .newChallenge:
                    NewChallengeView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom tab bar
            CustomTabBar(currentTab: appState.currentTab) { tab in
                appState.currentTab = tab
            }
        }
        .background(Color.background)
    }
}

struct CustomTabBar: View {
    let currentTab: MainTab
    let onTabChange: (MainTab) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.border)
            
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "house.fill",
                    label: "Progress",
                    isSelected: currentTab == .progress,
                    action: { onTabChange(.progress) }
                )
                
                TabBarButton(
                    icon: "plus.circle.fill",
                    label: "New",
                    isSelected: currentTab == .newChallenge,
                    action: { onTabChange(.newChallenge) }
                )
                
                TabBarButton(
                    icon: "gearshape.fill",
                    label: "Settings",
                    isSelected: currentTab == .settings,
                    action: { onTabChange(.settings) }
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(Color.background)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .tabBarActive : .tabBarInactive)
                
                Text(label)
                    .font(.labelTiny)
                    .foregroundColor(isSelected ? .tabBarActive : .tabBarInactive)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
    }
}

