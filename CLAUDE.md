# CLAUDE.md - BodyBuddy Workout App

> **Version:** 1.0.0
> **Last Updated:** 2025-12-15
> **Project:** BodyBuddy - Hyper-personalized iOS Workout Planning App
> **Status:** v0.1 Development (Planning Phase Complete)

---

## 🎯 Project Overview

### What is BodyBuddy?

BodyBuddy is a SwiftUI-based workout planning application for iOS (and eventually watchOS) that creates personalized, adaptive workout plans based on:
- **Injury constraints** (especially knee safety)
- **Personal goals** (fat loss, strength, arm development, general fitness)
- **Real-time state** (energy levels, joint pain, recovery status)
- **4-Hour Body philosophy** (minimal effective dose training)

### Development Approach

This project follows a **dogfooding methodology**: built for personal use first (Zack's specific needs), then generalized for app market distribution. This ensures real-world testing and refinement before public release.

### Current Phase

**v0.1 - Core Rules Engine** (Local-only, iOS, no AI/HealthKit/Watch)
- ✅ Planning complete (spec.md, plan.md, tasks.md)
- ⏳ Implementation in progress
- 📍 Target: Minimal viable workout app with onboarding, workout generation, tracking, and settings

---

## 📋 Project Architecture

### Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (iOS 17+)
- **Data Persistence**: JSON-based local storage (v0.1), SwiftData migration (v0.2)
- **Package Structure**: Swift Package Manager
  - `BodyBuddyCore`: Shared models, workout engine, data store
  - `BodyBuddyApp`: iOS app target (main UI)
  - `BodyBuddyWatchApp`: watchOS target (v0.2+)

### Module Structure

```
Workout/
├── .claude/                    # Claude Code configuration
│   ├── commands/               # Spec Kit slash commands
│   └── settings.local.json     # Permissions and settings
├── .specify/                   # Spec Kit templates and memory
│   ├── templates/              # Spec, plan, task templates
│   ├── memory/                 # Agent context and constitution
│   └── scripts/                # Automation scripts
├── specs/                      # Feature specifications
│   └── 001-bodyfocus-core/
│       ├── spec.md             # Feature specification
│       ├── plan.md             # Implementation plan
│       ├── tasks.md            # Task breakdown
│       └── checklists/         # Acceptance criteria
├── BodyBuddyCore/              # Swift Package (shared logic)
│   ├── Sources/BodyBuddyCore/
│   │   ├── Models/             # Data models and enums
│   │   ├── Engine/             # Workout generation logic
│   │   └── Storage/            # Data persistence
│   └── Tests/                  # Unit tests
├── BodyBuddyApp/               # iOS App Target
│   ├── Views/                  # SwiftUI views
│   ├── ViewModels/             # ObservableObject view models
│   └── Assets.xcassets/        # App resources
├── chat.md                     # Original ChatGPT conversation blueprint
├── CLAUDE.md                   # This file (project instructions)
└── README.md                   # Project documentation
```

---

## 🔒 Critical Rules & Constraints

### 1. NEVER MAKE UNAUTHORIZED CHANGES

- **ONLY** modify what is explicitly requested or specified in tasks
- **NEVER** change unrelated code, files, or functionality
- If you think something else needs changing, **ASK FIRST**
- Changing anything not explicitly requested is considered a **prohibited change**

### 2. FOLLOW THE SPEC

- All implementation MUST align with `specs/001-bodyfocus-core/spec.md`
- User stories define the acceptance criteria
- Technical constraints define the boundaries
- Out-of-scope features are deferred to future versions

### 3. NO PREMATURE OPTIMIZATION

- v0.1 focuses on core functionality, not performance
- Keep it simple: hard-coded exercise library, JSON storage, no AI
- Advanced features (HealthKit, watchOS, geolocation, AI) are v0.2+
- Don't add features that aren't in the spec

### 4. SAFETY FIRST

- Knee safety is a PRIMARY constraint (this is non-negotiable)
- Exercise filtering by `kneeLoad` level MUST respect `KneeProfile`
  - `healthy`: all exercises allowed
  - `sensitive`: exclude `high` knee load
  - `restricted`: only `low` knee load
- Pre-workout check-ins MUST reduce volume when pain is reported

### 5. PRESERVE 4-HOUR BODY PHILOSOPHY

- Minimal effective dose: few big lifts, done hard
- Compound movements prioritized over isolation (except arms)
- Low-moderate frequency (2-3x/week in v0.1)
- Progression over time (future versions will track this)

### 6. DATA INTEGRITY

- User profile and workout data MUST persist across app restarts
- Use atomic writes (write to temp file, then rename) to prevent corruption
- Handle file I/O errors gracefully (don't crash, show user-friendly errors)
- Mid-workout progress MUST be saved (user can exit and resume)

### 7. EVIDENCE-BASED CODING

- When implementing features, refer to the spec's acceptance scenarios
- When fixing bugs, identify the specific requirement that was violated
- When answering "is this implemented?", **SHOW CODE EVIDENCE** with file paths and line numbers

---

## 🎨 Design Principles

### UI/UX Guidelines

- **Simplicity over features**: v0.1 is intentionally minimal
- **Clarity over cleverness**: Clear labels, obvious controls
- **Accessibility**: Use standard SwiftUI controls (automatic accessibility)
- **Consistency**: Follow iOS Human Interface Guidelines

### American Palette (inherited from ClaudeControlCenter)

While BodyBuddy will have its own visual identity, it follows the same design philosophy:
- Flat design, no gradients
- Clear typography hierarchy
- Generous spacing and padding
- Obvious touch targets (minimum 44pt)

---

## 📝 Development Workflow

### Using Spec Kit Commands

This project uses ClaudeControlCenter's **Spec Kit** methodology. Available slash commands:

- `/speckit.plan` - Generate implementation plan from spec
- `/speckit.specify` - Create feature specification
- `/speckit.tasks` - Break plan into actionable tasks
- `/speckit.implement` - Begin implementation with task tracking
- `/speckit.checklist` - Generate acceptance criteria checklist
- `/speckit.constitution` - Manage project governance rules

### Task Workflow

1. Review `specs/001-bodyfocus-core/tasks.md` for current phase
2. Select next unchecked task
3. Implement task following spec requirements
4. Test implementation (unit tests for core, manual for UI)
5. Mark task as complete with ✅
6. Commit changes with descriptive message

### Git Commit Messages

Follow conventional commits format:
```
feat: Add WorkoutEngine with knee-safe exercise filtering
fix: Correct set completion logic in WorkoutViewModel
docs: Update README with architecture diagram
test: Add unit tests for PreWorkoutCheckIn adjustment
```

---

## 🚧 Current Development Status

### v0.1 Roadmap

**Phase 1**: Foundation & Models (NEXT)
- [ ] Create BodyBuddyCore Swift Package
- [ ] Define all models and enums
- [ ] Write model serialization tests

**Phase 2**: Workout Engine
- [ ] Create ExerciseLibrary with 15-20 exercises
- [ ] Implement workout generation logic
- [ ] Add knee-safe filtering
- [ ] Test engine with various profiles

**Phase 3**: Data Persistence
- [ ] Implement JSONDataStore
- [ ] Test save/load operations
- [ ] Handle file I/O errors

**Phase 4-10**: See `specs/001-bodyfocus-core/plan.md`

### What's Out of Scope (v0.1)

The following features are **explicitly deferred** to future versions:
- ❌ AI-powered workout adjustments (v0.3)
- ❌ HealthKit integration (v0.2)
- ❌ watchOS companion app (v0.2)
- ❌ Geolocation-based gym detection (v0.4)
- ❌ Calendar/Reminders integration (v0.4)
- ❌ Exercise video demonstrations
- ❌ Social features or workout sharing
- ❌ Cloud sync or backup
- ❌ Nutrition tracking

---

## 🧪 Testing Requirements

### Unit Tests (BodyBuddyCore)

Every model and engine function MUST have unit tests:
- **Models**: Test Codable conformance (encode/decode round-trip)
- **WorkoutEngine**: Test exercise filtering, volume calculations, adjustment logic
- **DataStore**: Test save/load operations, error handling

### Manual Testing

Before marking a phase complete:
- ✅ Test all acceptance scenarios from spec.md
- ✅ Test edge cases (no equipment, restricted knees, etc.)
- ✅ Test on physical iOS device (not just simulator)
- ✅ Test data persistence (force quit app, relaunch)

---

## 💡 Decision Log

### Key Technical Decisions

**Q1: SwiftData vs JSON for v0.1?**
→ **Decision**: JSON (simpler, easier debugging, fewer dependencies)
→ **Rationale**: v0.1 is about functionality, not persistence performance

**Q2: Hard-coded exercise library vs JSON file?**
→ **Decision**: Hard-coded Swift array
→ **Rationale**: Type-safe, easier to start, can migrate to JSON in v0.2

**Q3: Allow manual workout editing in v0.1?**
→ **Decision**: No
→ **Rationale**: Keep it simple, focus on generation and tracking

**Q4: Single-user vs multi-profile support?**
→ **Decision**: Single user
→ **Rationale**: Simplify v0.1, add profiles in v0.5 (market-ready version)

---

## 📚 Reference Documents

### Primary Documents

- **Feature Spec**: `specs/001-bodyfocus-core/spec.md`
- **Implementation Plan**: `specs/001-bodyfocus-core/plan.md`
- **Task Breakdown**: `specs/001-bodyfocus-core/tasks.md`
- **Original Blueprint**: `chat.md` (ChatGPT conversation with full feature exploration)

### Related Projects

- **ClaudeControlCenter**: `/Users/techdev/Projects/ClaudeDC/ClaudeControlCenter`
  - Source of Spec Kit methodology
  - Reference for project structure patterns

### External Resources

- **4-Hour Body**: Tim Ferriss (minimal effective dose philosophy)
- **iOS Human Interface Guidelines**: Apple
- **SwiftUI Documentation**: Apple Developer

---

## 🎯 Success Criteria (v0.1)

BodyBuddy v0.1 is considered complete when:

- ✅ User can complete onboarding and see a workout plan in under 3 minutes
- ✅ Pre-workout check-in successfully adjusts workout volume based on energy/pain
- ✅ User can track and complete a full workout session with set-by-set progress
- ✅ Workout plan respects knee constraints (no high-load exercises for sensitive/restricted)
- ✅ Arm-focused users receive 2 arm exercises per session vs 1 for other goals
- ✅ App persists data across restarts (no data loss on force quit)
- ✅ All 73 tasks in tasks.md are complete with passing tests

---

## 🚀 Future Vision (Post v0.1)

### v0.2 - Health & Watch
- HealthKit integration (HR tracking, workout logging, close Activity rings)
- watchOS companion app for workout tracking on wrist
- WatchConnectivity for real-time iPhone ↔ Watch sync

### v0.3 - AI & Intelligence
- Backend API for AI services
- Free-text note interpretation ("left knee was crunchy going downstairs")
- Block-level plan adjustments based on workout history
- Insight cards ("arm volume up 30% in 4 weeks")

### v0.4 - Context & Integration
- Geolocation-based gym detection (auto-load gym equipment profile)
- Calendar and Reminders integration
- Multiple location profiles (home, gym, travel)
- Voice commands for hands-free workout logging

### v0.5 - Market Ready
- Preset workout templates (4HB Minimal, Desk Worker Arms & Knees, etc.)
- Shareable plans (export/import)
- Polished design and animations
- App Store submission

---

## 📞 Communication Guidelines

### When Asking Questions

- Reference specific files and line numbers
- Include relevant code snippets
- State assumptions clearly
- Propose solutions, not just problems

### When Reporting Issues

- Describe expected behavior (from spec)
- Describe actual behavior (what happened)
- Provide steps to reproduce
- Include error messages or screenshots

### When Proposing Changes

- Explain the problem being solved
- Reference the spec requirement
- Describe the proposed solution
- Ask for approval before implementing

---

## 🔗 Quick Links

- **Spec**: `specs/001-bodyfocus-core/spec.md`
- **Plan**: `specs/001-bodyfocus-core/plan.md`
- **Tasks**: `specs/001-bodyfocus-core/tasks.md`
- **Blueprint**: `chat.md`
- **Spec Kit**: `.claude/commands/` (slash commands)

---

## ✅ Philosophy Alignment

This project embodies Zack's principles:
- ✅ Evidence-based decision making (spec-driven development)
- ✅ Systematic analysis (Spec Kit methodology)
- ✅ Comprehensive documentation (spec, plan, tasks, this file)
- ✅ Build distributable solutions (dogfooding → app market)
- ✅ Transform personal challenges into community resources (knee-safe training → app for others)

---

**Status**: Planning complete, ready for Phase 1 implementation
**Next Step**: Create BodyBuddyCore Swift Package and define models
**Last Updated**: 2025-12-15

🏋️ **Let's build something that works for real bodies, not just idealized ones!**
