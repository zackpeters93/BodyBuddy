# BodyBuddyApp

SwiftUI iOS application for the BodyBuddy workout planner.

## Requirements

- Xcode 15+
- iOS 17+
- macOS 14+ (Sonoma)

## Project Structure

```
BodyBuddyApp/
├── Sources/
│   ├── App/
│   │   └── BodyBuddyApp.swift      # Main app entry point
│   ├── ViewModels/
│   │   ├── AppState.swift           # Global app state
│   │   └── OnboardingViewModel.swift
│   └── Views/
│       ├── RootView.swift           # Root navigation
│       ├── Onboarding/
│       │   └── OnboardingContainerView.swift
│       ├── Today/
│       │   └── TodayView.swift
│       ├── Workout/
│       │   └── WorkoutPlayerView.swift
│       └── Settings/
│           └── SettingsView.swift
├── Resources/
│   └── (Assets.xcassets - to be created in Xcode)
└── Package.swift
```

## Setup Instructions

### Option 1: Create Xcode Project (Recommended)

1. Open Xcode
2. File → New → Project
3. Choose **App** under iOS
4. Configure:
   - Product Name: `BodyBuddy`
   - Team: Your team
   - Organization Identifier: `com.yourname`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
   - Uncheck "Include Tests" (for now)

5. Save in: `/Users/techdev/Projects/ClaudeDC/Workout/`

6. Add BodyBuddyCore package:
   - File → Add Package Dependencies
   - Click "Add Local..."
   - Navigate to `BodyBuddyCore` folder
   - Click "Add Package"

7. Replace generated files:
   - Delete the auto-generated `BodyBuddyApp.swift` and `ContentView.swift`
   - Drag the `Sources` folder contents into your project
   - When prompted, select "Create folder references"

8. Set deployment target to iOS 17.0

9. Build and run!

### Option 2: Open as Swift Package (Development Only)

For quick previews and testing without a full Xcode project:

```bash
cd /Users/techdev/Projects/ClaudeDC/Workout/BodyBuddyApp
open Package.swift
```

Note: This won't run as an iOS app, but Xcode previews will work.

## Features

### Implemented Views

- **RootView**: Conditional navigation (onboarding vs main app)
- **OnboardingContainerView**: 4-step onboarding flow
  - Goal selection
  - Knee status
  - Schedule preferences
  - Equipment selection
- **TodayView**: Dashboard with weekly overview and today's workout
- **WorkoutPlayerView**: Exercise tracking with set completion
- **SettingsView**: Profile editing and app management

### AppState

Global state management using `@EnvironmentObject`:
- User profile management
- Weekly plan generation
- Workout tracking
- Error handling

## Dependencies

- **BodyBuddyCore**: Core models, workout engine, and data persistence
