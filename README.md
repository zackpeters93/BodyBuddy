# BodyBuddy - Hyper-Personalized iOS Workout Planning App

> A SwiftUI-based workout planning app that adapts to your injuries, goals, and daily state using 4-Hour Body methodology.

**Status**: v0.1 Planning Complete | Implementation In Progress
**Platform**: iOS 17+ (watchOS planned for v0.2)
**Methodology**: Spec Kit (spec-driven development)

---

## 🎯 What is BodyBuddy?

BodyBuddy creates personalized, adaptive workout plans that respect your body's constraints and evolve with your progress. Unlike generic workout apps, it:

- **Prioritizes safety**: Filters exercises based on knee (or other joint) limitations
- **Adapts daily**: Pre-workout check-ins adjust volume based on energy and pain levels
- **Focuses on effectiveness**: 4-Hour Body philosophy (minimal effective dose, compound movements)
- **Learns over time**: (v0.3+) AI interprets feedback to refine future plans

### Built For

Originally built for Zack (54, recovering from knee issues, wants arm development, 3x/week training), then generalized for broader use.

---

## ✨ Features

### v0.1 (Current)

- ✅ **Smart Onboarding**: Capture goals, injury history, schedule, and equipment in 4 steps
- ✅ **Knee-Safe Workouts**: Automatic exercise filtering by knee load level
- ✅ **Pre-Workout Check-Ins**: Adjust volume based on energy and joint pain
- ✅ **Set-by-Set Tracking**: Mark sets complete, flag painful exercises
- ✅ **Weekly Planning**: See your workout schedule at a glance
- ✅ **Goal-Based Volume**: More arm work when arms are a priority goal
- ✅ **Local Storage**: Your data stays on your device (JSON-based)

### v0.2+ (Planned)

- ⏳ **HealthKit Integration**: Log workouts to Apple Health, track heart rate
- ⏳ **Apple Watch App**: Track workouts from your wrist
- ⏳ **AI Coaching**: Interpret free-text notes, suggest block-level adjustments
- ⏳ **Geolocation**: Auto-detect gym arrival, load appropriate equipment profile
- ⏳ **Calendar Sync**: Workout reminders and calendar integration
- ⏳ **Voice Control**: Hands-free workout logging

---

## 🏗️ Architecture

### Tech Stack

- **Language**: Swift 5.9+
- **UI**: SwiftUI (iOS 17+)
- **Storage**: JSON (v0.1) → SwiftData (v0.2+)
- **Package Manager**: Swift Package Manager

### Module Structure

```
BodyBuddy/
├── BodyBuddyCore/              # Swift Package (business logic)
│   ├── Models/                 # Data models (UserProfile, Exercise, WorkoutSession)
│   ├── Engine/                 # WorkoutEngine (generation logic)
│   └── Storage/                # DataStore (persistence)
├── BodyBuddyApp/               # iOS App (SwiftUI views)
│   ├── Views/                  # Onboarding, Today, WorkoutPlayer, Settings
│   └── ViewModels/             # ObservableObject controllers
└── BodyBuddyWatchApp/          # watchOS App (v0.2+)
```

### Data Flow

```
User Input (Onboarding)
    ↓
UserProfile (stored locally)
    ↓
WorkoutEngine.generateWeek() → 3-day plan
    ↓
PreWorkoutCheckIn → WorkoutEngine.adjust()
    ↓
WorkoutSession (adjusted for today's state)
    ↓
WorkoutPlayer (set tracking)
    ↓
Completed session saved → Today screen shows ✓
```

---

## 🚀 Getting Started

### Prerequisites

- **macOS**: Sonoma 14.0+ (for Xcode)
- **Xcode**: 15.0+ (for iOS 17 SDK)
- **iOS Device or Simulator**: iOS 17+

### Installation

1. **Clone the repository**:
   ```bash
   cd /Users/techdev/Projects/ClaudeDC/Workout
   ```

2. **Open in Xcode**:
   ```bash
   open BodyBuddy.xcodeproj
   ```
   *(Note: Project creation is Phase 4 of implementation - not yet created)*

3. **Select target**:
   - Choose `BodyBuddyApp` scheme
   - Select your iPhone or simulator

4. **Run**:
   - Press ⌘R or click "Run" in Xcode

---

## 📖 Usage

### First Time Setup

1. **Launch app** → Onboarding displays
2. **Step 1**: Select your primary goal (fitness, arms, knees, fat loss, strength)
3. **Step 2**: Select knee status (healthy, sensitive, restricted)
4. **Step 3**: Choose days per week (1-3) and minutes per session (20/30/45)
5. **Step 4**: Select available equipment (bodyweight, dumbbells)
6. **Tap "Start"** → Your first week's workout plan generates

### Daily Workflow

1. **Open app** on a workout day
2. **Pre-Workout Check-In**:
   - Slide energy level (1-5)
   - Slide knee pain level (0-2)
   - Tap "Adjust & Start" (or "Skip")
3. **Workout Player**:
   - Complete each set, tap checkbox
   - Flag any exercises that irritate your knees
   - Tap "Next" to move to next exercise
   - Tap "Finish Workout" when done
4. **Weekly Overview**: See your completed workouts (✓)

### Adjusting Settings

1. **Tap Settings tab**
2. **Edit** goal, knee status, schedule, or equipment
3. **Tap "Save Changes"**
4. **Tap "Regenerate Plan"** to create new workouts with updated constraints

---

## 🏋️ How It Works

### Workout Generation Algorithm

```swift
func generateWeek(for user: UserProfile) -> [WorkoutSession] {
    // 1. Filter exercises by equipment and knee profile
    let allowedExercises = library.filter { exercise in
        user.equipment.contains(exercise.equipment) &&
        isKneeSafe(exercise, for: user.kneeProfile)
    }

    // 2. Select exercises for each day
    for day in 1...user.daysPerWeek {
        // Pick 1 hinge/glute, 1 push, 1 pull
        // Pick 1-2 arms (2 if goal == .arms)

        // 3. Create WorkoutSession with target sets/reps
    }

    return sessions
}
```

### Knee Safety Rules

| Knee Profile | Allowed Exercises |
|--------------|-------------------|
| **Healthy** | All exercises (low, moderate, high knee load) |
| **Sensitive** | Low and moderate only (exclude high) |
| **Restricted** | Low only (no impact, limited flexion) |

**Examples**:
- **Low**: Romanian Deadlift, Glute Bridge, Push-ups, Rows, Curls
- **Moderate**: Bench Dips, Step-ups to low box
- **High**: Heavy Back Squats, Jump Squats, Running (excluded for sensitive/restricted)

### Pre-Workout Adjustment Logic

```swift
func adjust(session: WorkoutSession, with checkIn: PreWorkoutCheckIn) -> WorkoutSession {
    if checkIn.energy <= 2 || checkIn.kneePainLevel >= 1 {
        // Reduce target sets by 1 (minimum 1 set)
        session.plannedExercises = session.plannedExercises.map { exercise in
            exercise.targetSets = max(1, exercise.targetSets - 1)
            return exercise
        }
    }
    return session
}
```

---

## 📋 Project Status

### v0.1 Development Progress

See `specs/001-bodyfocus-core/tasks.md` for detailed task list.

**Current Phase**: Phase 1 - Foundation & Models

| Phase | Status | Tasks | Description |
|-------|--------|-------|-------------|
| Phase 1 | ⏳ Next | 8 tasks | Models, enums, Swift Package setup |
| Phase 2 | ⏳ | 7 tasks | Workout engine and exercise library |
| Phase 3 | ⏳ | 6 tasks | JSON data persistence |
| Phase 4 | ⏳ | 6 tasks | iOS app structure and navigation |
| Phase 5 | ⏳ | 7 tasks | Onboarding flow |
| Phase 6 | ⏳ | 8 tasks | Today screen and check-ins |
| Phase 7 | ⏳ | 9 tasks | Workout player |
| Phase 8 | ⏳ | 6 tasks | Settings screen |
| Phase 9 | ⏳ | 8 tasks | Testing and bug fixes |
| Phase 10 | ⏳ | 8 tasks | Polish and documentation |

**Estimated Timeline**: 21 days (3 weeks) | **Start Date**: TBD

---

## 🧪 Testing

### Unit Tests

Run unit tests for `BodyBuddyCore`:
```bash
swift test
```

**Coverage**:
- ✅ Model serialization (Codable round-trip)
- ✅ Exercise filtering by knee profile
- ✅ Workout generation for various goals
- ✅ Pre-workout check-in adjustment logic
- ✅ Data store save/load operations

### Manual Testing

See `specs/001-bodyfocus-core/spec.md` for acceptance scenarios.

**Key Test Cases**:
1. Complete onboarding and verify 3-day plan generates
2. Set energy=2, knee pain=1 → verify sets reduce by 1
3. Complete a workout → verify session marks as complete
4. Force quit mid-workout → relaunch → verify progress saved
5. Change knee profile from healthy to sensitive → verify high-load exercises removed

---

## 📚 Documentation

### Primary Documents

- **[Feature Specification](specs/001-bodyfocus-core/spec.md)** - User stories, requirements, success criteria
- **[Implementation Plan](specs/001-bodyfocus-core/plan.md)** - Phase breakdown, architecture, risks
- **[Task Breakdown](specs/001-bodyfocus-core/tasks.md)** - 73 actionable tasks with estimates
- **[CLAUDE.md](CLAUDE.md)** - Project instructions for Claude Code
- **[chat.md](chat.md)** - Original ChatGPT conversation (full feature exploration)

### Methodology

This project uses **Spec Kit** (from ClaudeControlCenter):
- `.claude/commands/` - Slash commands for spec-driven workflow
- `.specify/templates/` - Templates for specs, plans, tasks
- `specs/` - Feature specifications and implementation plans

---

## 🤝 Contributing

This is currently a personal project (dogfooding phase). Future plans may include:
- Community workout template library
- Shared exercise database
- Plugin system for custom integrations

---

## 📄 License

MIT License (TBD)

---

## 🔗 References

### Inspiration

- **4-Hour Body** (Tim Ferriss) - Minimal effective dose philosophy
- **Starting Strength** (Mark Rippetoe) - Compound movement emphasis
- **Knee Over Toes Guy** - Joint-friendly training adaptations

### Related Projects

- **ClaudeControlCenter** - Source of Spec Kit methodology

### External Resources

- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [HealthKit Framework](https://developer.apple.com/documentation/healthkit/)

---

## 💡 Philosophy

Built on principles that matter:

- ✅ **Evidence-based**: Spec-driven development, not guesswork
- ✅ **Safety-first**: Respect injuries and constraints
- ✅ **Systematic**: Comprehensive planning before coding
- ✅ **Real-world**: Dogfooding ensures it works for actual use
- ✅ **Distributable**: Personal tool → community resource

---

## 📞 Support

For issues or questions:
1. Check the [Spec](specs/001-bodyfocus-core/spec.md)
2. Review [CLAUDE.md](CLAUDE.md)
3. See [Implementation Plan](specs/001-bodyfocus-core/plan.md)

---

**Status**: v0.1 Planning Complete | Ready to begin Phase 1
**Last Updated**: 2025-12-15
**Next Milestone**: Create BodyBuddyCore Swift Package and define models

🏋️ **Building workouts that work for real bodies, not just idealized ones!**
