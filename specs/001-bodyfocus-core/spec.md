# Feature Specification: BodyFocus Core - iOS Workout Planning App

**Feature Branch**: `001-bodyfocus-core`
**Created**: 2025-12-15
**Status**: Draft
**Input**: User description: "Create a hyper-personalized workout planning app for iOS and watchOS that adapts to injuries, goals, and real-time feedback using 4-Hour Body methodology"

## Overview

BodyFocus is a SwiftUI-based workout planning application for iOS and watchOS that creates personalized, adaptive workout plans. The app emphasizes minimal effective dose training (4-Hour Body philosophy), knee-safety, arms focus, and real-time adjustment based on pre-workout check-ins. This specification covers v0.1: the core rules-based workout engine with local storage, no AI, HealthKit, or geolocation.

The app follows a dogfooding approach: built for personal use first, then extended to app market distribution.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete Onboarding and Generate First Workout Plan (Priority: P1)

A new user opens the app for the first time and needs to provide their profile information to generate a personalized workout plan.

**Why this priority**: This is the absolute foundation. Without onboarding, no workout plan can be generated. This delivers immediate value by creating the user's first customized plan.

**Independent Test**: Can be fully tested by completing the onboarding flow and verifying a 3-day workout plan is generated and displayed on the Today screen.

**Acceptance Scenarios**:

1. **Given** the user launches the app for the first time, **When** no profile exists, **Then** the onboarding flow displays automatically
2. **Given** the user is in onboarding Step 1 (Goals), **When** they select a primary goal (e.g., "Build Stronger Arms"), **Then** the selection is highlighted and Continue button enables
3. **Given** the user is in onboarding Step 2 (Knee Status), **When** they select their knee profile (healthy/sensitive/restricted), **Then** the selection is saved and they can proceed
4. **Given** the user is in onboarding Step 3 (Schedule), **When** they select days per week (1-3) and minutes per session (20/30/45), **Then** the values are stored
5. **Given** the user is in onboarding Step 4 (Equipment), **When** they select available equipment (bodyweight, dumbbells), **Then** multi-select checkboxes update
6. **Given** the user completes all onboarding steps, **When** they submit the final step, **Then** a 3-day workout plan generates and Today screen displays
7. **Given** a workout plan is generated, **When** the user returns to the app, **Then** onboarding does not display again

---

### User Story 2 - Complete Pre-Workout Check-In and Adjust Workout (Priority: P1)

Before starting a workout, the user checks in with their current energy and knee pain levels, and the app adjusts the workout accordingly.

**Why this priority**: This is the core adaptive feature that makes the app "smart". It demonstrates immediate personalization and safety.

**Independent Test**: Can be fully tested by setting low energy or high knee pain and verifying the workout's sets are reduced.

**Acceptance Scenarios**:

1. **Given** the user opens the app on a scheduled workout day, **When** the Today screen loads, **Then** a pre-workout check-in card displays with energy (1-5) and knee pain (0-2) sliders
2. **Given** the user sets energy to 2 (low) and knee pain to 0, **When** they tap "Adjust & Start Workout", **Then** the workout's target sets decrease by 1 per exercise
3. **Given** the user sets energy to 5 (high) and knee pain to 2 (high), **When** they tap "Adjust & Start Workout", **Then** the workout's target sets decrease by 1 per exercise
4. **Given** the user sets energy to 4 and knee pain to 0, **When** they tap "Skip Check-in & Start", **Then** the workout loads without modifications
5. **Given** the check-in adjusts the workout, **When** the user enters the workout player, **Then** the adjusted sets display correctly

---

### User Story 3 - Track Workout Progress and Mark Sets Complete (Priority: P1)

During a workout, the user needs to track which sets they've completed for each exercise.

**Why this priority**: This is the core workout execution feature. Without this, the app is just a plan viewer, not a tracker.

**Independent Test**: Can be fully tested by marking sets as done and verifying progress persists.

**Acceptance Scenarios**:

1. **Given** the user starts a workout, **When** the Workout Player opens, **Then** the first exercise displays with its name, muscle groups, knee load, target sets/reps/weight
2. **Given** the user is viewing an exercise, **When** they complete a set and tap "Mark set done", **Then** that set shows a checkmark and the next set highlights
3. **Given** the user marks all sets for an exercise complete, **When** they tap "Next", **Then** the next exercise in the plan displays
4. **Given** the user is on the last exercise and completes all sets, **When** they tap "Finish Workout", **Then** the session is marked complete in local storage
5. **Given** the user completes a workout, **When** they return to Today screen, **Then** that day shows a checkmark in the weekly overview
6. **Given** the user exits the Workout Player mid-session, **When** they return to the app, **Then** progress is saved and they can resume where they left off

---

### User Story 4 - View Weekly Workout Schedule (Priority: P2)

The user wants to see their workout schedule for the week to plan their time.

**Why this priority**: Important for planning and adherence, but not essential for completing a single workout.

**Independent Test**: Can be fully tested by viewing the calendar/week view and verifying workout days display correctly.

**Acceptance Scenarios**:

1. **Given** the user has a generated 3-day plan, **When** they view the Today screen, **Then** a weekly overview displays with Mon-Fri and markers for each day (✓ completed, ● today, ○ planned)
2. **Given** the user completes Monday's workout, **When** they view the weekly overview on Tuesday, **Then** Monday shows ✓ and Tuesday shows ●
3. **Given** the user taps a future workout day, **When** the detail loads, **Then** they can preview that day's exercises (but not start it early in v0.1)

---

### User Story 5 - Edit Profile Settings (Priority: P3)

The user wants to change their goals, knee status, schedule, or equipment to reflect their evolving needs.

**Why this priority**: Useful for long-term use but not needed for initial experience.

**Independent Test**: Can be fully tested by changing a setting and verifying it persists and affects future workout generation.

**Acceptance Scenarios**:

1. **Given** the user navigates to Settings, **When** the screen loads, **Then** current profile values display (goal, knee status, days/week, minutes, equipment)
2. **Given** the user changes their knee status from "healthy" to "sensitive", **When** they save changes, **Then** future workouts exclude high knee-load exercises
3. **Given** the user changes their primary goal from "General Fitness" to "Build Stronger Arms", **When** they regenerate the plan, **Then** arm exercises increase from 1 to 2 per session
4. **Given** the user taps "Reset App Data" in Settings, **When** they confirm the action, **Then** all profile and workout data is cleared and onboarding displays on next launch

---

### User Story 6 - Exercise Substitution for Knee Pain (Priority: P2)

The user experiences knee pain during a specific exercise and wants to flag it for future adjustments.

**Why this priority**: This is a key safety and personalization feature but requires workout history to be fully effective (v0.2+ territory).

**Acceptance Scenarios**:

1. **Given** the user is performing an exercise in the Workout Player, **When** they toggle "This irritated my knees", **Then** the flag saves to that workout session log
2. **Given** an exercise has been flagged for knee pain 3+ times (future: v0.2), **When** a new plan generates, **Then** that exercise is replaced with a lower knee-load alternative

---

### Edge Cases

- **What happens when the user completes onboarding but all equipment is deselected?**
  → System defaults to bodyweight only exercises.

- **What happens when the user's knee profile is "restricted" and no low knee-load exercises exist?**
  → App displays a message: "No exercises match your current constraints. Please adjust equipment or knee settings."

- **What happens when the user exits the app mid-workout without finishing?**
  → Progress is saved locally; when they return, they can resume from the last completed set.

- **What happens when the user tries to start a workout on a rest day?**
  → Today screen shows "Rest day" message with option to view other days' plans.

- **What happens when the workout generation fails due to data issues?**
  → Error message displays: "Unable to generate workout plan. Please check your settings."

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to select a primary goal (general fitness, arms, knees, fat loss, strength) during onboarding
- **FR-002**: System MUST allow users to select a knee profile (healthy, sensitive, restricted) that filters exercises by knee load level
- **FR-003**: System MUST allow users to select days per week (1-3) and minutes per session (20, 30, 45) during onboarding
- **FR-004**: System MUST allow users to multi-select equipment types (bodyweight, dumbbells) available for workouts
- **FR-005**: System MUST generate a 3-day workout plan after onboarding based on user profile constraints
- **FR-006**: System MUST display a pre-workout check-in on workout days with energy (1-5) and knee pain (0-2) sliders
- **FR-007**: System MUST adjust workout target sets based on check-in values (low energy or high knee pain reduces sets by 1)
- **FR-008**: System MUST display a Workout Player showing current exercise, sets/reps/weight, and set completion controls
- **FR-009**: System MUST persist workout progress to local storage (completed sets, session completion)
- **FR-010**: System MUST display a weekly overview showing completed (✓), today (●), and planned (○) workout days
- **FR-011**: System MUST filter exercises by knee load level based on user's knee profile (healthy=all, sensitive=exclude high, restricted=low only)
- **FR-012**: System MUST increase arm exercise volume when primary goal is "arms" (2 arm exercises vs 1)
- **FR-013**: System MUST allow users to flag exercises as causing knee pain during workout execution
- **FR-014**: System MUST save user profile and workout data to local storage (SwiftData or JSON)
- **FR-015**: System MUST allow users to reset all app data from Settings screen

### Key Entities

- **UserProfile**: Represents the user's fitness profile with name, primary goal, knee profile, schedule (days/week, minutes/session), and equipment list
- **Exercise**: Represents a specific movement with name, primary muscle group, knee load level (low/moderate/high), equipment required, and whether it's compound or isolation
- **WorkoutExercise**: Represents a planned exercise within a workout with target sets, reps, and weight
- **WorkoutSession**: Represents a single workout on a specific date with planned exercises, completion status, day index, and day type
- **PreWorkoutCheckIn**: Represents pre-workout state with energy level (1-5) and knee pain level (0-2)
- **WorkoutExerciseLog**: Represents completed sets with actual reps, weight, and pain flags

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete onboarding and generate their first workout plan in under 3 minutes
- **SC-002**: Pre-workout check-in successfully adjusts workout volume (reduces sets) when energy ≤ 2 or knee pain ≥ 1
- **SC-003**: Users can complete a full workout session with set tracking and mark the session as complete
- **SC-004**: Workout plan respects knee constraints: sensitive users receive 0 high knee-load exercises, restricted users receive only low knee-load exercises
- **SC-005**: Arm-focused users receive 2 arm exercises per session vs 1 for other goals
- **SC-006**: Workout progress persists across app restarts (user can exit mid-workout and resume)
- **SC-007**: Weekly overview correctly displays workout status for each day of the week

---

## Technical Constraints *(if applicable)*

### Platform Requirements

- **TC-001**: iOS 17+ required for SwiftUI and SwiftData features
- **TC-002**: watchOS 10+ required for companion app (future phase)
- **TC-003**: Local storage only (SwiftData or JSON) - no cloud sync in v0.1
- **TC-004**: No AI integration in v0.1 (rules-based engine only)
- **TC-005**: No HealthKit, CoreLocation, EventKit, or WatchConnectivity integration in v0.1

### Technology Stack

- **Swift + SwiftUI**: Core language and UI framework
- **SwiftData or Core Data**: Local data persistence (v0.1 may use JSON for simplicity)
- **BodyFocusCore**: Shared Swift Package for models, workout engine, and logic
- **BodyFocusApp**: iOS app target (SwiftUI, iOS 17+)
- **BodyFocusWatchApp**: watchOS target (future - v0.2+)

---

## Out of Scope (for v0.1)

The following features are explicitly deferred to future versions:

- AI-powered workout adjustments and note interpretation (v0.3)
- HealthKit integration for HR tracking and workout logging (v0.2)
- watchOS companion app (v0.2)
- Geolocation-based gym detection (v0.2)
- Calendar and Reminders integration (v0.2)
- Multi-location equipment profiles (v0.2)
- Exercise video demonstrations or form tips
- Social features or workout sharing
- Cloud sync or backup
- Nutrition tracking or body metrics tracking

---

## Open Questions

- **OQ-001**: Should v0.1 use SwiftData or simple JSON for local storage? (Recommendation: JSON for simplicity, migrate to SwiftData in v0.2)
- **OQ-002**: Should the exercise library be hard-coded in Swift or loaded from a JSON file? (Recommendation: Hard-coded in v0.1 for speed, JSON in v0.2 for extensibility)
- **OQ-003**: Should users be able to manually edit generated workout plans in v0.1? (Recommendation: No, keep it simple; add in v0.2)
- **OQ-004**: Should the app support multiple users or profiles? (Recommendation: No, single user in v0.1)

---

## References & Related Documents

- **Original Blueprint**: `/Users/techdev/Projects/ClaudeDC/Workout/chat.md`
- **ClaudeControlCenter**: `/Users/techdev/Projects/ClaudeDC/ClaudeControlCenter` (Spec Kit methodology)
- **4-Hour Body Philosophy**: Minimal effective dose, focus on compound movements, adequate recovery
- **Target User**: Zack (54, recovering from knee issues, wants arm development, 3x/week training)

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-12-15 | 1.0 | Initial specification based on chat.md blueprint | Claude |
