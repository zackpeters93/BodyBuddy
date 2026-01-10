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
        .sheet(item: $appState.currentError) { error in
            ErrorSheet(error: error) {
                appState.dismissError()
            } onRetry: {
                appState.dismissError()
                // Attempt to reload data
                if appState.navigationState == .main {
                    appState.regeneratePlan()
                }
            }
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("BodyBuddy")
                .font(.title)
                .fontWeight(.bold)

            ProgressView()
                .scaleEffect(1.2)

            Text("Loading your workouts...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
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

// MARK: - Error Sheet

struct ErrorSheet: View {
    let error: AppError
    let onDismiss: () -> Void
    let onRetry: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)

                Text("Something Went Wrong")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(error.errorDescription ?? "An unknown error occurred")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        Text("Try Again")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: onDismiss) {
                        Text("Dismiss")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)

                Spacer()
            }
            .padding(.top, 60)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onDismiss()
                    }
                }
            }
        }
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
