# Quick Start Guide: BodyFocus Core Development

**Feature**: `001-bodyfocus-core`
**Version**: v0.1
**Last Updated**: 2025-12-15

---

## 🚀 Getting Started in 5 Minutes

### Prerequisites Check

```bash
# Verify Xcode is installed (15.0+)
xcodebuild -version

# Verify Swift version (5.9+)
swift --version

# Navigate to project directory
cd /Users/techdev/Projects/ClaudeDC/Workout
```

---

## 📁 Project Structure Overview

```
Workout/
├── .claude/                    # Claude Code config
│   ├── commands/               # /speckit.* slash commands
│   └── settings.local.json     # Permissions
├── .specify/                   # Spec Kit templates
│   ├── templates/              # spec, plan, task templates
│   └── memory/                 # constitution.md
├── specs/                      # Feature specifications
│   └── 001-bodyfocus-core/
│       ├── spec.md             # ⭐ Start here - Feature spec
│       ├── plan.md             # Implementation plan
│       ├── tasks.md            # 73 actionable tasks
│       └── quickstart.md       # This file
├── chat.md                     # Original ChatGPT blueprint
├── CLAUDE.md                   # Project instructions
└── README.md                   # Project overview
```

---

## 📖 Read These First (in order)

1. **README.md** (2 min) - Project overview and vision
2. **specs/001-bodyfocus-core/spec.md** (10 min) - User stories and requirements
3. **specs/001-bodyfocus-core/plan.md** (10 min) - Implementation approach
4. **CLAUDE.md** (5 min) - Development guidelines

**Total reading time**: ~30 minutes

---

## ✅ Current Status

**Phase**: Planning Complete ✅ | Implementation Ready to Start

**Next Step**: Phase 1 - Foundation & Models

---

## 🛠️ Phase 1: Create BodyFocusCore Package (Next)

### Step 1: Create Swift Package

```bash
# Open Xcode
open -a Xcode

# File → New → Package
# Name: BodyFocusCore
# Minimum platform: iOS 17
```

### Step 2: Define Models

Create these files in `BodyFocusCore/Sources/BodyFocusCore/Models/`:

- `Enums.swift` - All enum types
- `UserProfile.swift` - User profile model
- `Exercise.swift` - Exercise model
- `WorkoutSession.swift` - Workout session model
- `CheckIn.swift` - Pre-workout check-in model

### Step 3: Write Unit Tests

```bash
# Run tests
swift test

# Or in Xcode: ⌘U
```

**See**: `specs/001-bodyfocus-core/tasks.md` (TASK-001 through TASK-008)

---

## 🎯 Key Deliverables by Phase

| Phase | Deliverable | Test |
|-------|-------------|------|
| **Phase 1** | BodyFocusCore package with models | Unit tests pass |
| **Phase 2** | WorkoutEngine generates valid plans | Engine tests pass |
| **Phase 3** | JSONDataStore saves/loads data | Persistence tests pass |
| **Phase 4** | iOS app with navigation structure | App builds and runs |
| **Phase 5** | Onboarding flow complete | Generate first plan |
| **Phase 6** | Today screen with check-ins | Adjust workout volume |
| **Phase 7** | Workout player with tracking | Complete a session |
| **Phase 8** | Settings screen functional | Edit and save profile |
| **Phase 9** | All user stories tested | No critical bugs |
| **Phase 10** | Polished and documented | Ready for personal use |

---

## 🧪 Testing Strategy

### Unit Tests (BodyFocusCore)

```bash
cd BodyFocusCore
swift test
```

**What to test**:
- ✅ Models encode/decode correctly
- ✅ WorkoutEngine filters exercises by knee profile
- ✅ Adjustment logic reduces sets correctly
- ✅ DataStore saves and loads without data loss

### Manual Tests (iOS App)

**Critical paths**:
1. Complete onboarding → verify plan generates
2. Check-in with low energy → verify sets reduce
3. Complete workout → verify session marks complete
4. Force quit mid-workout → relaunch → verify progress saved

---

## 📋 Daily Development Workflow

### Morning Routine

1. **Review current phase** in `specs/001-bodyfocus-core/plan.md`
2. **Check next task** in `specs/001-bodyfocus-core/tasks.md`
3. **Open relevant spec section** in `specs/001-bodyfocus-core/spec.md`

### Implementation Loop

1. **Pick next unchecked task** from tasks.md
2. **Read acceptance criteria** from spec.md
3. **Implement the feature**
4. **Write/run tests**
5. **Mark task complete** (✅) in tasks.md
6. **Commit with clear message**

### End of Day

1. **Update task progress** in tasks.md
2. **Commit any WIP** with clear state
3. **Note blockers** in comments or issues

---

## 🔧 Using Spec Kit Commands

This project uses Spec Kit slash commands:

### Available Commands

```bash
/speckit.plan         # Generate implementation plan
/speckit.specify      # Create feature spec
/speckit.tasks        # Break plan into tasks
/speckit.implement    # Start implementation with tracking
/speckit.checklist    # Generate acceptance checklist
```

### Example Usage

```
/speckit.tasks
```
→ Generates a task breakdown from the current plan

---

## 🎨 Code Style Guide

### Swift Conventions

```swift
// ✅ Good: Descriptive names
func generateWeek(for user: UserProfile) -> [WorkoutSession]

// ❌ Bad: Abbreviations
func genWk(for usr: UsrProf) -> [WkSess]

// ✅ Good: Handle optionals safely
guard let profile = loadProfile() else {
    showError("Unable to load profile")
    return
}

// ❌ Bad: Force unwrap
let profile = loadProfile()!
```

### File Organization

```swift
// MARK: - Models
// Define your models here

// MARK: - Properties
// Class/struct properties

// MARK: - Initializers
// Init methods

// MARK: - Public Methods
// Public API

// MARK: - Private Methods
// Internal helpers
```

---

## 🚨 Common Pitfalls to Avoid

### 1. Skipping the Spec

❌ **Don't**: Start coding without reading the spec
✅ **Do**: Review acceptance scenarios before implementing

### 2. Ignoring Knee Safety

❌ **Don't**: Allow high knee-load exercises for restricted users
✅ **Do**: Strictly enforce `kneeLoad` filtering based on `KneeProfile`

### 3. Premature Optimization

❌ **Don't**: Build abstract factories and dependency injection in v0.1
✅ **Do**: Keep it simple with hard-coded defaults

### 4. Silent Failures

❌ **Don't**: Use `try?` without handling the nil case
✅ **Do**: Handle errors and inform the user

### 5. Skipping Tests

❌ **Don't**: Mark tasks complete without writing tests
✅ **Do**: Write unit tests for all core logic

---

## 📞 Getting Help

### Questions About Requirements?

→ Check `specs/001-bodyfocus-core/spec.md` (User Stories section)

### Questions About Implementation?

→ Check `specs/001-bodyfocus-core/plan.md` (Technical Architecture)

### Questions About Tasks?

→ Check `specs/001-bodyfocus-core/tasks.md` (Detailed breakdown)

### Questions About Guidelines?

→ Check `CLAUDE.md` (Development standards)

### Still Stuck?

→ Ask Claude Code or create a GitHub issue (if repo exists)

---

## 🎯 Success Checklist

Before marking Phase 1 complete:

- [ ] BodyFocusCore package created in Xcode
- [ ] All enums defined (6 total)
- [ ] All models defined (5 total)
- [ ] All models conform to Identifiable and Codable
- [ ] Unit tests written and passing (8 test cases minimum)
- [ ] No compiler warnings
- [ ] Code follows Swift style guide
- [ ] Tasks 001-008 marked complete in tasks.md

Before marking v0.1 complete:

- [ ] All 73 tasks complete
- [ ] All user stories manually tested
- [ ] No critical bugs
- [ ] README updated with usage instructions
- [ ] App tested on physical iOS device
- [ ] Data persists correctly across restarts

---

## 🔗 Quick Links

- **Spec**: [spec.md](spec.md)
- **Plan**: [plan.md](plan.md)
- **Tasks**: [tasks.md](tasks.md)
- **Project Root**: [../../../README.md](../../../README.md)
- **CLAUDE.md**: [../../../CLAUDE.md](../../../CLAUDE.md)

---

## 💡 Pro Tips

1. **Start small**: Implement one model at a time, test immediately
2. **Commit often**: Small, focused commits make debugging easier
3. **Test as you go**: Don't accumulate untested code
4. **Read error messages**: Swift errors are usually helpful
5. **Use Xcode previews**: SwiftUI previews speed up UI development

---

**Ready to start? → Open [tasks.md](tasks.md) and begin with TASK-001**

**Questions? → Read [spec.md](spec.md) and [CLAUDE.md](../../../CLAUDE.md)**

🏋️ **Let's build something great!**
