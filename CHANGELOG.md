# Changelog

All notable changes to BodyBuddy will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-10

### Added

#### Core Features
- **Smart Onboarding**: 4-step flow capturing goals, knee status, schedule, and equipment
- **Workout Generation**: Automatic creation of personalized weekly workout plans
- **Pre-Workout Check-In**: Energy and knee pain sliders that adjust workout volume
- **Workout Player**: Full-screen exercise tracking with set-by-set completion
- **Rest Day Override**: "Work Out Anyway" button to start workouts on rest days

#### Exercise Library
- 21 exercises across 8 muscle groups
- Knee load classification (low, moderate, high) for each exercise
- Equipment tagging (bodyweight, dumbbells)
- Support for compound and isolation movements

#### Safety Features
- Knee-safe filtering based on user's knee profile
- Three knee profiles: Healthy, Sensitive, Restricted
- Automatic exclusion of high-load exercises for sensitive/restricted profiles
- Knee pain flagging during workouts for future AI analysis

#### Goal-Based Customization
- Primary goals: General Fitness, Fat Loss, Strength, Arm Development, Knee Rehab
- Arm-focused goal increases arm exercise volume (2 per session vs 1)
- Schedule options: 1-3 days/week, 20/30/45 minutes per session

#### Data & Storage
- Local JSON-based persistence
- Atomic writes to prevent data corruption
- Profile, weekly plan, and session storage
- Data survives app restarts and force quits

#### User Interface
- SwiftUI-based iOS 17+ app
- Tab navigation (Today, Settings)
- Weekly overview with completion indicators
- Progress tracking within workouts
- Profile editing and plan regeneration

### Technical Details

#### Architecture
- **BodyBuddyCore**: Swift Package with models, engine, and storage
- **BodyBuddy**: iOS app target with SwiftUI views
- 62 unit tests covering models, engine, and storage

#### Models
- `UserProfile`: User preferences and constraints
- `Exercise`: Exercise definitions with safety metadata
- `WorkoutSession`: Daily workout with exercises and status
- `WorkoutExercise`: Exercise instance with set tracking
- `WeeklyPlan`: Collection of sessions for the week
- `PreWorkoutCheckIn`: Energy and pain levels

#### Key Files
- `ExerciseLibrary.swift`: 21 hard-coded exercises
- `WorkoutEngine.swift`: Generation and adjustment logic
- `JSONDataStore.swift`: File-based persistence

### Known Limitations
- No cloud sync (local storage only)
- No HealthKit integration
- No Apple Watch support
- Exercise library is hard-coded (not user-expandable)
- Single user profile only

---

## Future Releases

### [0.2.0] - Planned
- HealthKit integration
- watchOS companion app
- Activity ring support

### [0.3.0] - Planned
- Sign in with Apple authentication
- Cloud sync across devices
- AI-powered constraint questionnaire

### [0.4.0] - Planned
- Geolocation-based gym detection
- Calendar/Reminders integration

### [0.5.0] - Planned
- App Store submission
- Preset workout templates
- Shareable plans
