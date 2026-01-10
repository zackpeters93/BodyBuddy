// RootView.swift
// Root navigation view that switches between onboarding and main app

import SwiftUI
import BodyBuddyCore

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.navigationState {
            case .loading:
                LoadingView()

            case .onboarding:
                OnboardingContainerView()

            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.navigationState)
        .alert(item: $appState.currentError) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.errorDescription ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK")) {
                    appState.dismissError()
                }
            )
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
        .tint(.blue)
    }
}

// MARK: - Preview

#Preview("Root View - Main") {
    RootView()
        .environmentObject({
            let state = AppState()
            // Simulate logged in state
            return state
        }())
}

#Preview("Root View - Loading") {
    LoadingView()
}
