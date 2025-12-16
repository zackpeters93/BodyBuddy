# Implementation Plan: BodyBuddy Core v0.1

**Feature**: `001-bodyfocus-core`
**Created**: 2025-12-15
**Status**: Planning
**Target Completion**: TBD (phased approach)

---

## Overview

This plan outlines the implementation approach for BodyBuddy v0.1, a minimal viable workout planning app for iOS. The implementation follows a **bottom-up approach**: build the core data models and workout engine first, then wrap them in SwiftUI views.

---

## Implementation Phases

### Phase 1: Foundation & Models (Days 1-2)

**Goal**: Create the core Swift package with all data models and enums.

**Tasks**:
1. Create `BodyBuddyCore` Swift Package
2. Define all enums (`PrimaryGoal`, `KneeProfile`, `MuscleGroup`, `EquipmentType`, `KneeLoadLevel`, `DayType`)
3. Define core models (`UserProfile`, `Exercise`, `WorkoutExercise`, `WorkoutSession`, `PreWorkoutCheckIn`)
4. Add `Identifiable` and `Codable` conformance to all models
5. Write unit tests for model serialization/deserialization

**Deliverable**: Compilable `BodyBuddyCore` package with all models defined.

**Dependencies**: None

---

### Phase 2: Exercise Library & Workout Engine (Days 3-4)

**Goal**: Build the rules-based workout generation engine.

**Tasks**:
1. Create `ExerciseLibrary.swift` with static exercise database (15-20 exercises covering all muscle groups)
2. Tag exercises with `kneeLoad` (low/moderate/high), `primaryMuscle`, `equipment`, `isCompound`
3. Implement `WorkoutEngine` struct with `generateWeek(for:startDate:)` function
4. Implement exercise filtering logic based on knee profile
5. Implement day-type generation (fullBody only in v0.1)
6. Implement exercise selection algorithm (1 hinge, 1 push, 1 pull, 1-2 arms)
7. Implement `adjust(session:with:)` function for pre-workout check-ins
8. Write unit tests for engine logic (knee filtering, goal-based arm volume, check-in adjustments)

**Deliverable**: Fully functional workout engine that generates valid 3-day plans.

**Dependencies**: Phase 1 (models)

---

### Phase 3: Data Persistence Layer (Day 5)

**Goal**: Implement local storage for user profile and workout sessions.

**Tasks**:
1. Create `DataStore` protocol with methods: `loadProfile()`, `saveProfile()`, `loadSessions()`, `saveSessions()`
2. Implement `JSONDataStore` using FileManager to save/load JSON to Documents directory
3. Add error handling for file I/O operations
4. Write unit tests for persistence (save/load profile, save/load sessions)

**Deliverable**: Working local storage layer.

**Dependencies**: Phase 1 (models)

---

### Phase 4: iOS App Structure & Navigation (Days 6-7)

**Goal**: Set up the iOS app target with navigation and tab structure.

**Tasks**:
1. Create `BodyBuddyApp` iOS app target in Xcode
2. Link `BodyBuddyCore` package to app target
3. Create `BodyBuddyApp.swift` (main app entry point with @main)
4. Create `RootView.swift` with conditional logic: show onboarding if no profile, else show main tabs
5. Create empty placeholder views for: `OnboardingView`, `TodayView`, `WorkoutPlayerView`, `SettingsView`
6. Set up basic navigation structure (no functionality yet, just wireframes)

**Deliverable**: Navigable app shell with placeholder screens.

**Dependencies**: Phase 1 (models), Phase 3 (data store for profile check)

---

### Phase 5: Onboarding Flow (Days 8-10)

**Goal**: Build the complete onboarding experience.

**Tasks**:
1. Create `OnboardingViewModel` to manage state across steps
2. Implement `GoalSelectionView` (Step 1) with segmented control or cards for goal selection
3. Implement `KneeProfileView` (Step 2) with radio buttons for knee status
4. Implement `ScheduleView` (Step 3) with pickers for days/week and minutes/session
5. Implement `EquipmentView` (Step 4) with checkboxes for equipment types
6. Add navigation controls (Continue, Back buttons) between steps
7. On final step submit, save profile to data store and generate first week's workout plan
8. Trigger navigation to `TodayView` after onboarding completion

**Deliverable**: Fully functional onboarding flow that creates user profile and workout plan.

**Dependencies**: Phase 2 (workout engine to generate plan), Phase 3 (data store to save profile), Phase 4 (navigation structure)

---

### Phase 6: Today Screen & Pre-Workout Check-In (Days 11-12)

**Goal**: Build the main dashboard and check-in feature.

**Tasks**:
1. Create `TodayViewModel` to load profile, sessions, and determine today's workout
2. Implement `TodayView` layout with three sections:
   - Pre-workout check-in card (if workout exists for today)
   - Today's workout summary (exercise list, estimated time)
   - Weekly overview (Mon-Fri with status indicators)
3. Implement `PreWorkoutCheckInView` with sliders for energy (1-5) and knee pain (0-2)
4. Implement "Adjust & Start Workout" button that calls `WorkoutEngine.adjust()` and navigates to Workout Player
5. Implement "Skip Check-in & Start" button that navigates directly to Workout Player
6. Display "Rest day" message when no workout is scheduled for today
7. Handle edge cases (no sessions generated, future dates)

**Deliverable**: Functional Today screen with working check-in adjustments.

**Dependencies**: Phase 2 (workout engine for adjustment), Phase 3 (data store for loading sessions), Phase 5 (onboarding must be complete)

---

### Phase 7: Workout Player (Days 13-15)

**Goal**: Build the core workout tracking experience.

**Tasks**:
1. Create `WorkoutViewModel` to manage active session state
2. Implement `WorkoutPlayerView` layout:
   - Header with progress (Exercise X of Y), elapsed timer
   - Current exercise card with name, muscle groups, knee load badge, target sets/reps/weight
   - Set tracking table (rows for each set with checkboxes, editable reps/weight fields)
   - "This irritated my knees" toggle
   - Navigation controls (Previous, Next exercise, Finish workout)
3. Implement set completion logic (mark set as done, move to next set)
4. Implement exercise navigation (move forward/back through exercises)
5. Implement workout completion flow (mark session as complete, save to data store, navigate back to Today)
6. Implement progress persistence (save partial progress if user exits mid-workout)
7. Add simple elapsed timer display

**Deliverable**: Fully functional workout tracking with set completion and persistence.

**Dependencies**: Phase 3 (data store for saving progress), Phase 6 (navigation from Today screen)

---

### Phase 8: Settings Screen (Days 16-17)

**Goal**: Allow users to view and edit their profile.

**Tasks**:
1. Create `SettingsViewModel` to load and update profile
2. Implement `SettingsView` layout:
   - Display current profile values (goal, knee status, days/week, minutes, equipment)
   - Edit controls for each setting (segmented control, pickers, checkboxes)
   - "Save Changes" button
   - "Regenerate Plan" button (triggers workout engine to create new week)
   - "Reset App Data" button (with confirmation alert)
3. Implement profile update logic (save changes to data store)
4. Implement plan regeneration (call workout engine with updated profile)
5. Implement data reset (delete all local files, show onboarding on next launch)

**Deliverable**: Functional settings screen with profile editing.

**Dependencies**: Phase 2 (workout engine for regeneration), Phase 3 (data store for profile updates)

---

### Phase 9: Testing & Bug Fixes (Days 18-19)

**Goal**: Comprehensive testing and bug fixing.

**Tasks**:
1. Manual testing of all user stories from spec.md
2. Test edge cases (no equipment selected, restricted knees with no low-load exercises, etc.)
3. Test data persistence (app restart, partial workout completion, profile changes)
4. Fix any bugs discovered during testing
5. Add logging/debugging statements for troubleshooting
6. Test on physical iOS device (not just simulator)

**Deliverable**: Stable, tested v0.1 app.

**Dependencies**: All previous phases

---

### Phase 10: Polish & Documentation (Days 20-21)

**Goal**: Final polish and documentation.

**Tasks**:
1. Add app icon and launch screen
2. Improve UI styling (colors, typography, spacing)
3. Add loading states and error messages
4. Write README.md with setup instructions
5. Write CHANGELOG.md
6. Create user-facing documentation (how to use the app)
7. Document code with comments where needed

**Deliverable**: Polished, documented v0.1 ready for personal use.

**Dependencies**: Phase 9 (testing complete)

---

## Technical Architecture

### Module Structure

```
BodyBuddy/
├── BodyBuddyCore/               # Swift Package (shared logic)
│   ├── Sources/BodyBuddyCore/
│   │   ├── Models/
│   │   │   ├── Enums.swift
│   │   │   ├── UserProfile.swift
│   │   │   ├── Exercise.swift
│   │   │   ├── WorkoutSession.swift
│   │   │   └── CheckIn.swift
│   │   ├── Engine/
│   │   │   ├── WorkoutEngine.swift
│   │   │   └── ExerciseLibrary.swift
│   │   └── Storage/
│   │       ├── DataStore.swift
│   │       └── JSONDataStore.swift
│   └── Tests/BodyBuddyCoreTests/
│       ├── ModelTests.swift
│       ├── EngineTests.swift
│       └── StorageTests.swift
├── BodyBuddyApp/                # iOS App Target
│   ├── BodyBuddyApp.swift       # @main entry point
│   ├── RootView.swift           # Conditional: onboarding vs tabs
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   ├── OnboardingView.swift
│   │   │   ├── GoalSelectionView.swift
│   │   │   ├── KneeProfileView.swift
│   │   │   ├── ScheduleView.swift
│   │   │   └── EquipmentView.swift
│   │   ├── Today/
│   │   │   ├── TodayView.swift
│   │   │   └── PreWorkoutCheckInView.swift
│   │   ├── Workout/
│   │   │   └── WorkoutPlayerView.swift
│   │   └── Settings/
│   │       └── SettingsView.swift
│   ├── ViewModels/
│   │   ├── OnboardingViewModel.swift
│   │   ├── TodayViewModel.swift
│   │   ├── WorkoutViewModel.swift
│   │   └── SettingsViewModel.swift
│   └── Assets.xcassets/
└── README.md
```

---

## Risk Assessment

### High Risk

- **Data persistence edge cases**: File I/O failures, corrupted JSON, app crashes mid-save
  - *Mitigation*: Comprehensive error handling, backup files, atomic writes

### Medium Risk

- **Workout generation produces empty plans**: Edge case where no exercises match constraints
  - *Mitigation*: Fallback logic (default to bodyweight exercises, warn user)

- **UI/UX complexity in Workout Player**: Set tracking, navigation, state management
  - *Mitigation*: Build incrementally, test frequently, simplify UI where possible

### Low Risk

- **Onboarding step navigation**: Relatively straightforward SwiftUI navigation
  - *Mitigation*: Use established SwiftUI patterns

---

## Testing Strategy

### Unit Tests (BodyBuddyCore)

- **Models**: Test Codable conformance (encode/decode round-trip)
- **Workout Engine**: Test exercise filtering, volume calculations, adjustment logic
- **Data Store**: Test save/load operations, file path handling

### Integration Tests

- **Onboarding → Workout Generation**: Verify profile saves and workout plan generates
- **Check-in → Adjustment**: Verify check-in values correctly reduce sets
- **Workout Completion → Persistence**: Verify completed sessions save and load

### Manual Testing

- **User Story Walkthroughs**: Test each acceptance scenario from spec.md
- **Edge Cases**: Test boundary conditions (no equipment, restricted knees, etc.)
- **Device Testing**: Test on physical iPhone (not just simulator)

---

## Success Metrics (v0.1)

- ✅ User can complete onboarding and see a workout plan in under 3 minutes
- ✅ Pre-workout check-in successfully adjusts workout volume
- ✅ User can track and complete a full workout session
- ✅ Workout plan respects knee constraints (no high-load exercises for sensitive/restricted)
- ✅ Arm-focused users receive 2 arm exercises per session
- ✅ App persists data across restarts (no data loss)

---

## Future Phases (Post v0.1)

### v0.2 - Health & Watch
- HealthKit integration (HR tracking, workout logging)
- watchOS companion app
- Pre/post check-in on Watch
- WatchConnectivity for real-time sync

### v0.3 - AI & Intelligence
- Backend API for AI services
- Free-text note interpretation (knee pain descriptions)
- Block-level plan adjustments based on history
- Insight cards ("arm volume up 30%")

### v0.4 - Context & Integration
- Geolocation-based gym detection
- Calendar and Reminders integration
- Multiple location profiles (home, gym, travel)
- Voice commands for workout logging

### v0.5 - Market Ready
- Preset workout templates (4HB Minimal, Desk Worker Arms & Knees, etc.)
- Shareable plans
- Onboarding presets
- Polished design and animations

---

## Open Questions

- **Q1**: Use SwiftData or JSON for v0.1 storage?
  - *Recommendation*: JSON (simpler, fewer dependencies, easier debugging)

- **Q2**: Hard-code exercise library or load from JSON?
  - *Recommendation*: Hard-coded Swift array (faster, type-safe, easier to start)

- **Q3**: Allow manual workout plan editing in v0.1?
  - *Recommendation*: No (keep it simple, add in v0.2)

- **Q4**: Single-user or multi-profile support?
  - *Recommendation*: Single user (simplify v0.1)

---

## Estimated Timeline

**Total Duration**: 21 days (3 weeks) assuming 1 person, 6-8 hours/day

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: Foundation & Models | 2 days | Day 2 |
| Phase 2: Workout Engine | 2 days | Day 4 |
| Phase 3: Data Persistence | 1 day | Day 5 |
| Phase 4: App Structure | 2 days | Day 7 |
| Phase 5: Onboarding | 3 days | Day 10 |
| Phase 6: Today Screen | 2 days | Day 12 |
| Phase 7: Workout Player | 3 days | Day 15 |
| Phase 8: Settings | 2 days | Day 17 |
| Phase 9: Testing | 2 days | Day 19 |
| Phase 10: Polish | 2 days | Day 21 |

**Note**: Timeline is flexible and follows Zack's principle of flexibility in timing/strategy over rigid plans.

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-12-15 | 1.0 | Initial implementation plan | Claude |
