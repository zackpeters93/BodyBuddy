# Tasks: BodyBuddy Core v0.1

**Feature**: `001-bodyfocus-core`
**Created**: 2025-12-15
**Status**: Planning

---

## Task Breakdown

### Phase 1: Foundation & Models

- [ ] **TASK-001**: Create BodyBuddyCore Swift Package in Xcode
  - Create new Swift Package in project
  - Name it `BodyBuddyCore`
  - Set minimum platform to iOS 17

- [ ] **TASK-002**: Define all enums in `Enums.swift`
  - `PrimaryGoal: String, Codable, CaseIterable`
  - `KneeProfile: String, Codable, CaseIterable`
  - `MuscleGroup: String, Codable`
  - `EquipmentType: String, Codable`
  - `KneeLoadLevel: Int, Codable`
  - `DayType: String, Codable`

- [ ] **TASK-003**: Define `UserProfile` model
  - Properties: id (UUID), name (String), primaryGoal, kneeProfile, daysPerWeek, minutesPerSession, equipment
  - Conformance: Identifiable, Codable

- [ ] **TASK-004**: Define `Exercise` model
  - Properties: id, name, primaryMuscle, kneeLoad, equipment, isCompound
  - Conformance: Identifiable, Codable

- [ ] **TASK-005**: Define `WorkoutExercise` model
  - Properties: id, exercise (Exercise), targetSets, targetReps
  - Conformance: Identifiable, Codable

- [ ] **TASK-006**: Define `WorkoutSession` model
  - Properties: id, date, dayIndex, dayType, plannedExercises, isCompleted
  - Conformance: Identifiable, Codable

- [ ] **TASK-007**: Define `PreWorkoutCheckIn` model
  - Properties: energy (Int), kneePainLevel (Int)
  - Conformance: Codable

- [ ] **TASK-008**: Write unit tests for model serialization
  - Test encode/decode round-trip for all models
  - Test edge cases (nil values, empty arrays)

---

### Phase 2: Exercise Library & Workout Engine

- [ ] **TASK-009**: Create `ExerciseLibrary.swift` with static exercise database
  - Add 15-20 exercises covering all muscle groups
  - Tag each with kneeLoad, primaryMuscle, equipment, isCompound
  - Include: RDL, glute bridge, bench press, push-up, row, curls, triceps, etc.

- [ ] **TASK-010**: Create `WorkoutEngine.swift` struct
  - Define struct with no state
  - Add static property `exerciseLibrary`

- [ ] **TASK-011**: Implement `generateWeek(for:startDate:)` function
  - Take UserProfile and start date
  - Return array of 3 WorkoutSession objects
  - Call `generateSession()` for each day

- [ ] **TASK-012**: Implement `generateSession(for:dayIndex:date:)` private function
  - Set dayType to .fullBody
  - Filter exercises by equipment and knee profile
  - Select 1 hinge/glute, 1 push, 1 pull, 1-2 arms
  - Create WorkoutExercise objects with target sets/reps

- [ ] **TASK-013**: Implement `isAllowed(exercise:for:)` private function
  - Return true for healthy (all exercises)
  - Return false for sensitive if kneeLoad == .high
  - Return false for restricted if kneeLoad != .low

- [ ] **TASK-014**: Implement `adjust(session:with:)` function
  - Take WorkoutSession and PreWorkoutCheckIn
  - If energy <= 2 or kneePainLevel >= 1, reduce targetSets by 1 (min 1)
  - Return adjusted WorkoutSession

- [ ] **TASK-015**: Write unit tests for WorkoutEngine
  - Test exercise filtering by knee profile
  - Test arm volume increases for arms goal
  - Test check-in adjustment logic
  - Test edge cases (no matching exercises, empty equipment)

---

### Phase 3: Data Persistence Layer

- [ ] **TASK-016**: Create `DataStore.swift` protocol
  - Define methods: `loadProfile()`, `saveProfile()`, `loadSessions()`, `saveSessions()`
  - Use async/throws signatures

- [ ] **TASK-017**: Create `JSONDataStore.swift` implementation
  - Implement `DataStore` protocol
  - Use FileManager to get Documents directory
  - Save profile as `profile.json`
  - Save sessions as `sessions.json`

- [ ] **TASK-018**: Implement `loadProfile()` method
  - Read `profile.json` from Documents
  - Decode JSON to UserProfile
  - Return nil if file doesn't exist
  - Throw error on decode failure

- [ ] **TASK-019**: Implement `saveProfile()` method
  - Encode UserProfile to JSON
  - Write to `profile.json` in Documents
  - Use atomic write (write to temp, then rename)

- [ ] **TASK-020**: Implement `loadSessions()` and `saveSessions()` methods
  - Similar to profile methods but for array of WorkoutSession

- [ ] **TASK-021**: Write unit tests for JSONDataStore
  - Test save/load profile round-trip
  - Test save/load sessions round-trip
  - Test handling of missing files
  - Test error handling for corrupted JSON

---

### Phase 4: iOS App Structure & Navigation

- [ ] **TASK-022**: Create BodyBuddyApp iOS app target in Xcode
  - Create new iOS App (SwiftUI)
  - Name it `BodyBuddyApp`
  - Set minimum iOS version to 17

- [ ] **TASK-023**: Link BodyBuddyCore package to BodyBuddyApp target
  - Add BodyBuddyCore as dependency in target settings
  - Import BodyBuddyCore in Swift files

- [ ] **TASK-024**: Create `BodyBuddyApp.swift` main entry point
  - Define `@main struct BodyBuddyApp: App`
  - Set `RootView()` as initial view

- [ ] **TASK-025**: Create `RootView.swift` with conditional navigation
  - Check if profile exists in data store
  - Show `OnboardingView()` if no profile
  - Show main tabs if profile exists

- [ ] **TASK-026**: Create placeholder views
  - `OnboardingView.swift` (just "Onboarding" text)
  - `TodayView.swift` (just "Today" text)
  - `WorkoutPlayerView.swift` (just "Workout Player" text)
  - `SettingsView.swift` (just "Settings" text)

- [ ] **TASK-027**: Set up TabView navigation in RootView
  - Tab 1: TodayView (icon: calendar)
  - Tab 2: SettingsView (icon: gear)

---

### Phase 5: Onboarding Flow

- [ ] **TASK-028**: Create `OnboardingViewModel` ObservableObject
  - Properties: currentStep (Int), profile (UserProfile draft)
  - Methods: nextStep(), previousStep(), submitOnboarding()

- [ ] **TASK-029**: Create `OnboardingView.swift` navigation container
  - Use TabView with .page style for horizontal swiping
  - Show progress indicator (step X of 4)
  - Embed step views: GoalSelectionView, KneeProfileView, ScheduleView, EquipmentView

- [ ] **TASK-030**: Create `GoalSelectionView` (Step 1)
  - Display segmented control or VStack of cards for PrimaryGoal options
  - Bind selection to viewModel.profile.primaryGoal
  - Show "Continue" button

- [ ] **TASK-031**: Create `KneeProfileView` (Step 2)
  - Display radio buttons (Picker) for KneeProfile options
  - Bind selection to viewModel.profile.kneeProfile
  - Show "Back" and "Continue" buttons

- [ ] **TASK-032**: Create `ScheduleView` (Step 3)
  - Display Picker for daysPerWeek (1-3)
  - Display Picker for minutesPerSession (20, 30, 45)
  - Bind selections to viewModel.profile
  - Show "Back" and "Continue" buttons

- [ ] **TASK-033**: Create `EquipmentView` (Step 4)
  - Display checkboxes for EquipmentType options
  - Bind selections to viewModel.profile.equipment array
  - Show "Back" and "Start" buttons

- [ ] **TASK-034**: Implement `submitOnboarding()` in ViewModel
  - Save profile using DataStore
  - Generate first week using WorkoutEngine
  - Save sessions using DataStore
  - Dismiss onboarding (trigger RootView to show tabs)

---

### Phase 6: Today Screen & Pre-Workout Check-In

- [ ] **TASK-035**: Create `TodayViewModel` ObservableObject
  - Properties: profile, todaySession, allSessions, checkIn (PreWorkoutCheckIn)
  - Methods: loadData(), adjustAndStart(), skipAndStart()

- [ ] **TASK-036**: Implement `loadData()` method
  - Load profile from DataStore
  - Load sessions from DataStore
  - Find today's session by matching date

- [ ] **TASK-037**: Create `TodayView.swift` layout
  - VStack with three sections: check-in card, workout summary, weekly overview
  - Show "Rest day" message if no session for today

- [ ] **TASK-038**: Create `PreWorkoutCheckInView` embedded in TodayView
  - Slider for energy (1-5) with labels
  - Slider for kneePainLevel (0-2) with labels
  - Bind to viewModel.checkIn

- [ ] **TASK-039**: Implement workout summary card
  - Display session.dayType and estimated time
  - List exercises with sets/reps (e.g., "Romanian Deadlift (3 x 8)")

- [ ] **TASK-040**: Implement weekly overview section
  - HStack with 5 day indicators (Mon-Fri)
  - Show ✓ for completed, ● for today, ○ for planned

- [ ] **TASK-041**: Implement "Adjust & Start Workout" button
  - Call WorkoutEngine.adjust(session, checkIn)
  - Navigate to WorkoutPlayerView with adjusted session

- [ ] **TASK-042**: Implement "Skip Check-in & Start" button
  - Navigate to WorkoutPlayerView with original session

---

### Phase 7: Workout Player

- [ ] **TASK-043**: Create `WorkoutViewModel` ObservableObject
  - Properties: session, currentExerciseIndex, completedSets (array of bools)
  - Methods: markSetDone(), nextExercise(), previousExercise(), finishWorkout()

- [ ] **TASK-044**: Create `WorkoutPlayerView.swift` layout
  - Header: progress indicator, timer
  - Body: current exercise card, set tracking table
  - Footer: navigation buttons

- [ ] **TASK-045**: Implement header section
  - Text: "Exercise X of Y"
  - Simple timer (elapsed time in MM:SS format)

- [ ] **TASK-046**: Implement current exercise card
  - Exercise name (large, bold)
  - Muscle groups and knee load badge
  - Target sets/reps/weight

- [ ] **TASK-047**: Implement set tracking table
  - ForEach over targetSets
  - Each row: "Set X | [reps] reps | [weight] lb | [✓ checkbox]"
  - Bind checkboxes to viewModel.completedSets

- [ ] **TASK-048**: Implement "This irritated my knees" toggle
  - Toggle below set table
  - Save flag to session when toggled

- [ ] **TASK-049**: Implement navigation controls
  - "Previous" button (disabled on first exercise)
  - "Next" button (enabled when all sets complete or user can skip)
  - "Finish Workout" button (enabled on last exercise)

- [ ] **TASK-050**: Implement `markSetDone()` method
  - Update completedSets array
  - Save progress to DataStore (partial session update)

- [ ] **TASK-051**: Implement `finishWorkout()` method
  - Mark session.isCompleted = true
  - Save session to DataStore
  - Navigate back to TodayView

---

### Phase 8: Settings Screen

- [ ] **TASK-052**: Create `SettingsViewModel` ObservableObject
  - Properties: profile (editable copy)
  - Methods: loadProfile(), saveChanges(), regeneratePlan(), resetAppData()

- [ ] **TASK-053**: Create `SettingsView.swift` layout
  - Form with sections: Profile, Actions
  - Profile section: display/edit current values
  - Actions section: buttons for regenerate, reset

- [ ] **TASK-054**: Implement profile display/edit controls
  - Picker for primaryGoal
  - Picker for kneeProfile
  - Picker for daysPerWeek and minutesPerSession
  - Multi-select for equipment

- [ ] **TASK-055**: Implement "Save Changes" button
  - Call viewModel.saveChanges()
  - Save updated profile to DataStore
  - Show success message

- [ ] **TASK-056**: Implement "Regenerate Plan" button
  - Call WorkoutEngine.generateWeek() with updated profile
  - Save new sessions to DataStore
  - Show success message

- [ ] **TASK-057**: Implement "Reset App Data" button
  - Show confirmation alert
  - If confirmed, delete profile.json and sessions.json
  - Navigate to onboarding

---

### Phase 9: Testing & Bug Fixes

- [ ] **TASK-058**: Manual test User Story 1 (Onboarding)
  - Test all acceptance scenarios from spec.md
  - Verify workout plan generates correctly

- [ ] **TASK-059**: Manual test User Story 2 (Check-in)
  - Test low energy/high pain reduces sets
  - Verify skip option works

- [ ] **TASK-060**: Manual test User Story 3 (Workout tracking)
  - Test set completion and navigation
  - Verify session marks as complete

- [ ] **TASK-061**: Manual test User Story 4 (Weekly view)
  - Verify status indicators display correctly

- [ ] **TASK-062**: Manual test User Story 5 (Settings)
  - Test profile editing and plan regeneration
  - Test data reset

- [ ] **TASK-063**: Test edge cases
  - No equipment selected
  - Restricted knees with limited exercises
  - Mid-workout app exit and resume

- [ ] **TASK-064**: Test data persistence
  - Force quit app mid-workout
  - Relaunch and verify progress saved

- [ ] **TASK-065**: Fix all bugs discovered during testing

---

### Phase 10: Polish & Documentation

- [ ] **TASK-066**: Add app icon
  - Design or generate simple icon
  - Add to Assets.xcassets

- [ ] **TASK-067**: Create launch screen
  - Simple branded splash screen

- [ ] **TASK-068**: Improve UI styling
  - Define color scheme (primary, secondary, accent)
  - Apply consistent typography
  - Add spacing and padding

- [ ] **TASK-069**: Add loading states
  - Show ProgressView while loading data
  - Show empty states for missing data

- [ ] **TASK-070**: Add error messages
  - Display user-friendly errors for failures
  - Provide recovery actions

- [ ] **TASK-071**: Write README.md
  - Project overview
  - Setup instructions
  - Architecture diagram
  - Usage guide

- [ ] **TASK-072**: Write CHANGELOG.md
  - Document v0.1 features

- [ ] **TASK-073**: Add code comments
  - Document complex algorithms
  - Add header comments to files

---

## Task Summary

**Total Tasks**: 73
**Estimated Effort**: 21 days (3 weeks)

### By Phase:
- Phase 1: 8 tasks (2 days)
- Phase 2: 7 tasks (2 days)
- Phase 3: 6 tasks (1 day)
- Phase 4: 6 tasks (2 days)
- Phase 5: 7 tasks (3 days)
- Phase 6: 8 tasks (2 days)
- Phase 7: 9 tasks (3 days)
- Phase 8: 6 tasks (2 days)
- Phase 9: 8 tasks (2 days)
- Phase 10: 8 tasks (2 days)

---

## Next Steps

1. Review this task list with stakeholder (Zack)
2. Confirm priorities and timeline
3. Begin Phase 1: Foundation & Models
4. Update task status as work progresses

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-12-15 | 1.0 | Initial task breakdown | Claude |
