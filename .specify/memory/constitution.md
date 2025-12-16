# BodyBuddy Project Constitution

**Version**: 1.0.0
**Created**: 2025-12-15
**Project**: BodyBuddy - iOS Workout Planning App

---

## 🎯 Project Purpose

BodyBuddy exists to create a **safe, personalized, and adaptive workout planning experience** for individuals with injury constraints, specific goals, and varying daily capacity.

This app embodies the principle: **Build for real bodies, not idealized ones.**

---

## 🔒 Non-Negotiable Principles

### 1. Safety Over Everything

- **Knee safety is paramount** (or any joint constraint the user specifies)
- Exercise filtering by `kneeLoad` MUST be strictly enforced
- Pre-workout check-ins MUST reduce volume when pain is reported
- No feature is worth compromising user safety

### 2. Spec-Driven Development

- All features MUST have a specification in `specs/` before implementation
- User stories define acceptance criteria
- Technical constraints define boundaries
- Out-of-scope features are deferred, not ignored

### 3. Evidence-Based Decisions

- Code changes require justification (bug fix, spec requirement, optimization with proof)
- "I think this is better" is not sufficient
- Performance optimizations require before/after measurements
- UI changes should reference accessibility or usability principles

### 4. Data Integrity

- User data MUST persist correctly (no silent data loss)
- File I/O operations MUST be atomic (temp file → rename)
- Errors MUST be handled gracefully (don't crash, show user-friendly message)
- Mid-operation progress MUST be saved when possible

### 5. Simplicity First

- v0.1 focuses on core functionality, not advanced features
- Premature optimization is prohibited
- Hard-coded defaults are acceptable in v0.1 (JSON, exercise library)
- Advanced features (AI, HealthKit, Watch) are deferred to v0.2+

---

## 📋 Development Standards

### Code Quality

- **Swift Style**: Follow [Swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- **Naming**: Descriptive names (no abbreviations like `usr`, `ex`, `wkout`)
- **Comments**: Document "why", not "what" (code should be self-documenting)
- **Tests**: Unit tests required for all models, engine logic, and data store

### Git Workflow

- **Commit Messages**: Follow [Conventional Commits](https://www.conventionalcommits.org/)
  - `feat:` new feature
  - `fix:` bug fix
  - `docs:` documentation only
  - `test:` adding or updating tests
  - `refactor:` code change that neither fixes a bug nor adds a feature

- **Commits**: Small, focused commits (one logical change per commit)
- **Branches**: Not required for solo development, but use feature branches if collaborating

### Testing Requirements

- **Unit Tests**: All models, engine functions, data store operations
- **Manual Tests**: All user stories from spec must be verified before phase completion
- **Edge Cases**: Test boundary conditions (no equipment, restricted knees, etc.)
- **Device Testing**: Test on physical iOS device before release

---

## 🚫 Prohibited Practices

### What NOT to Do

1. **No unauthorized changes**: Only modify what's in the spec or task list
2. **No feature creep**: Out-of-scope features are deferred, not implemented "while we're at it"
3. **No premature abstraction**: Don't create protocols/generics for single implementations in v0.1
4. **No unsafe force unwraps**: Use `if let`, `guard let`, or `??` instead of `!`
5. **No magic numbers**: Use named constants (e.g., `let maxSets = 5`, not `if sets > 5`)
6. **No skipping errors**: Handle errors, don't use `try!` or `try?` without justification
7. **No silent failures**: If an operation fails, inform the user (gracefully)

### What TO Do Instead

- **Ask first** if you think something needs changing that's not in the spec
- **Update the spec** if requirements change, then implement
- **Keep it simple** until complexity is justified by real needs
- **Use optionals correctly** and handle nil cases explicitly
- **Define constants** at the top of files or in a Constants.swift file
- **Handle errors** with proper error types and user-facing messages
- **Log failures** for debugging, show friendly messages to users

---

## 🎨 UI/UX Standards

### Design Principles

- **Clarity**: Labels and controls should be obvious (no guessing required)
- **Consistency**: Follow iOS Human Interface Guidelines
- **Accessibility**: Use standard SwiftUI controls (automatic VoiceOver support)
- **Feedback**: Provide immediate visual feedback for user actions

### Interaction Patterns

- **Onboarding**: Step-by-step with clear progress indicators
- **Forms**: Clear labels, validation feedback, save/cancel actions
- **Lists**: Swipe actions for common operations (delete, edit)
- **Buttons**: Descriptive labels ("Adjust & Start Workout" not just "Start")

---

## 📊 Decision Framework

When faced with a decision, ask:

1. **Is this in the spec?**
   - Yes → Implement as specified
   - No → Ask for clarification or update spec first

2. **Does this compromise safety?**
   - Yes → Don't do it
   - No → Proceed if justified

3. **Is this the simplest solution?**
   - Yes → Proceed
   - No → Simplify first, optimize later

4. **Can I test this independently?**
   - Yes → Good, implement and test
   - No → Break it down into testable units

5. **Will this add tech debt?**
   - Yes → Document why and plan to address in future version
   - No → Proceed

---

## 🔄 Change Management

### When Requirements Change

1. **Update the spec** (`specs/001-bodyfocus-core/spec.md`)
2. **Update the plan** if phases need adjustment
3. **Update tasks** to reflect new work
4. **Communicate changes** (commit message, update README)

### When Bugs are Found

1. **Document the bug** (expected vs actual behavior)
2. **Identify the spec violation** (which requirement failed?)
3. **Fix the bug** and add regression test
4. **Update documentation** if spec was unclear

### When Performance Issues Arise

1. **Measure first** (don't optimize without data)
2. **Identify bottleneck** (profiling tools)
3. **Consider alternatives** (simpler algorithm, caching, etc.)
4. **Measure after** (did it actually improve?)

---

## 🎯 Success Metrics

### v0.1 is successful when:

- ✅ User can complete onboarding and see a workout plan in < 3 minutes
- ✅ Pre-workout check-in correctly adjusts workout volume
- ✅ User can track and complete a full workout session
- ✅ Knee constraints are strictly respected (no high-load for sensitive/restricted)
- ✅ Arm-focused users receive correct volume increase
- ✅ App persists data across restarts without loss
- ✅ All 73 tasks are complete with passing tests

### Future versions succeed when:

- v0.2: HealthKit and Watch integration work seamlessly
- v0.3: AI suggestions demonstrably improve workout adherence
- v0.4: Geolocation and calendar features reduce friction
- v0.5: App is ready for App Store submission and positive reviews

---

## 📚 Living Document

This constitution evolves with the project:

- **Add principles** when new patterns emerge
- **Clarify rules** when ambiguity causes issues
- **Update metrics** as success criteria change
- **Document decisions** in the Decision Framework

---

## 🤝 Commitment

By working on this project, we commit to:

- **Prioritize user safety** over feature velocity
- **Follow the spec** instead of ad-hoc implementation
- **Test thoroughly** before marking tasks complete
- **Communicate clearly** when requirements are unclear
- **Build with care** for real people with real constraints

---

**This is not just code. This is a tool for people managing real bodies, real pain, and real goals.**

**Build accordingly.**

---

**Last Updated**: 2025-12-15
**Next Review**: After v0.1 completion
