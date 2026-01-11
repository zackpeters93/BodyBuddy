// ContentView.swift
// Root view for watchOS app

import SwiftUI
import BodyBuddyCore

struct ContentView: View {
    @EnvironmentObject var appState: WatchAppState

    var body: some View {
        Group {
            if appState.isWorkoutInProgress {
                WatchWorkoutPlayerView()
            } else {
                WatchTodayView()
            }
        }
        .onAppear {
            appState.refreshWorkout()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchAppState())
}
