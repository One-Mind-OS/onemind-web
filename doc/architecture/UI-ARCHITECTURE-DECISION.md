# UI Architecture Decision Document

**Date**: February 5, 2026
**Status**: CRITICAL DECISION REQUIRED
**Impact**: Frontend architecture, documentation accuracy, development velocity

---

## Executive Summary

**The Problem**: OneMind OS has **two complete UI architectures** that exist in parallel, but only one is active. The documentation (CLAUDE.md) describes a "chat-first" architecture with OSColors theme, but the production application runs a "tactical" architecture with TacticalColors theme and completely different navigation.

**Timeline**:
- **Jan 31, 2026**: Chat-first architecture documented, EnhancedChatScreen activated (commit `07dd2a0`)
- **Feb 2, 2026**: Tactical UI introduced in "major UI/UX overhaul" (commit `f8b7ee8`) - **ONE DAY LATER**
- **Current State**: `main.dart` uses `tacticalRouter`, documentation describes unused `app_router`

**Critical Stats**:
- **TacticalColors**: 153 files, 4603 occurrences (PRODUCTION)
- **OSColors**: 9 files, 91 occurrences (ASPIRATIONAL)
- **Tactical screens**: 30 custom screens
- **Active router**: `tacticalRouter` (ATOC-inspired 5-tab navigation)
- **Documented router**: `app_router` (6-pillar chat-first) - **NOT USED**

---

## Current State Analysis

### Production Architecture: TACTICAL UI

**Active Since**: February 2, 2026
**Entry Point**: `frontend/lib/main.dart` → `tacticalRouter`
**Design System**: TacticalColors (military-grade aesthetics)

#### Navigation Structure

```
Bottom Navigation (5 tabs):
┌─────────────────────────────────────────────────┐
│  COMMAND  │  MAP  │  SITREPS  │  MISSIONS  │  MORE  │
└─────────────────────────────────────────────────┘

COMMAND    → CommandScreen (dashboard, 1012 lines)
MAP        → TacticalMapScreen (Google Maps, geofences)
SITREPS    → SitrepsScreen (activity feed)
MISSIONS   → MissionsScreen (active operations)
MORE       → MoreScreen (hierarchical menu)
```

#### MORE Menu Sections

| Section | Contains | Routes |
|---------|----------|--------|
| **ASSETS** | Agents, Teams, Models, Tools, MCP, Robotics, Drones, Vehicles | `/agents`, `/teams`, `/models`, `/tools`, `/mcp`, `/robotics`, `/drones`, `/vehicles` |
| **PROTOCOLS** | Skills, Workflows | `/skills`, `/workflows` |
| **VAULT** | Knowledge | `/knowledge` |
| **INTEL** | Memory | `/memory` |
| **OPERATIONS** | Sessions, Approvals, Metrics, Traces, Notifications, Activity | `/sessions`, `/approvals`, `/metrics`, `/traces`, `/notifications`, `/activity` |
| **OPERATOR** | Health, Presence, Biometrics | `/health`, `/presence`, `/biometrics` |
| **SURVEILLANCE** | Eagle Eye | `/eagle-eye` |
| **HARDWARE** | Watch, Frame | `/watch`, `/frame` |
| **COMMS** | Terminal (Chat) | `/chat` |

#### Design Tokens

```dart
// TacticalColors (military-grade, ATOC-inspired)
background: #000000  (pure black)
surface:    #0A0A0A  (slightly elevated)
card:       #111111  (card backgrounds)
primary:    #E63946  (Legacy red - Zeus signature)
critical:   #FF6B6B  (action red for NEW SITREP)
```

#### Key Features
- **Military aesthetics**: Monospace fonts, uppercase labels, ATOC-inspired
- **Hierarchical navigation**: Deep menu structure (9 sections)
- **Geographic focus**: TacticalMapScreen with real-time location tracking
- **Hardware integration**: Dedicated screens for Watch, Frame, Drones, Robotics
- **Operator-centric**: Presence, Biometrics, Health screens
- **Chat integration**: EnhancedChatScreen accessible via `/chat` route

---

### Documented Architecture: CHAT-FIRST (Unused)

**Documented**: January 31, 2026
**Entry Point**: `frontend/lib/platform/router/app_router.dart` - **NOT IN main.dart**
**Design System**: OSColors (premium dark-first)

#### Navigation Structure

```
6-Pillar Bottom Navigation:
┌──────────────────────────────────────────────────────────┐
│  Home  │  Chat  │  Agents  │  Activity  │  Inbox  │  Awareness  │
└──────────────────────────────────────────────────────────┘

Primary Route: /home (HomeDashboardScreen)
Landing Page: Chat accessible as tab
```

#### Design Tokens

```dart
// OSColors (premium, chat-first)
background: #0A0A0C  (near-black with blue tint)
surface:    #12121A  (subtle depth)
card:       #1C1C24  (lifted feel)
primary:    #E63946  (same red accent)
glassSurface: #1A1A22 (frosted glass)
```

#### Key Features
- **Chat as primary interface**: Everything accessible through @mentions, /commands
- **Sidebar navigation**: Collapsible sidebar with sections
- **Multi-agent conversations**: @coder @researcher in same chat
- **Tool cards**: Rich UI cards for tool results
- **HITL approval cards**: Interactive approve/reject/edit
- **Conversation branching**: Fork conversations from any message
- **Glass morphism**: Frosted glass effects throughout

---

## Historical Context

### Timeline of Major Changes

| Date | Event | Commit | Impact |
|------|-------|--------|--------|
| **Jan 25-29** | Frontend integration sprint | `15a3a87` | AgentOS migration |
| **Jan 31** | Chat-first documented, EnhancedChatScreen activated | `07dd2a0` | Vision set |
| **Feb 1** | Chat redesign with model router | `ec5716c` | Chat improvements |
| **Feb 2** | **TACTICAL UI INTRODUCED** | `f8b7ee8` | Complete pivot |
| **Feb 2** | Tactical Map added | `1f46bc8` | Geographic features |
| **Feb 3** | Enhanced Tactical Map | `ddd577f` | Geofences, search |
| **Feb 5** | Current state | `615dddb` | Tactical in production |

### What Happened?

The commit history reveals a **rapid architectural pivot**:

1. **Jan 31**: Documentation updated to describe chat-first architecture
   - EnhancedChatScreen marked as "PRIMARY"
   - app_router.dart documented with 6-pillar navigation
   - OSColors design system documented

2. **Feb 2** (ONE DAY LATER): "major UI/UX overhaul with tactical theme"
   - 30+ new tactical screens created
   - TacticalColors introduced (military-grade aesthetics)
   - tacticalRouter created with 5-tab ATOC-inspired navigation
   - main.dart switched from app_router to tacticalRouter
   - EnhancedChatScreen **preserved** but moved to `/chat` route

3. **Outcome**: Two complete architectures exist side-by-side
   - **Tactical UI**: In production, actively developed
   - **Chat-first**: Documented but unused

### Why Two Architectures?

Based on commit messages and file structure, likely scenario:

1. **Vision evolution**: Chat-first was the planned direction
2. **User experience decision**: Military/ATOC aesthetics preferred
3. **Pragmatic approach**: Kept EnhancedChatScreen, wrapped in tactical shell
4. **Documentation lag**: CLAUDE.md not updated after architectural pivot
5. **Both have value**: Neither was "wrong" - different use cases

---

## Architecture Comparison

### Feature Matrix

| Feature | Tactical UI | Chat-First |
|---------|-------------|------------|
| **Primary Navigation** | 5-tab bottom nav | 6-pillar bottom nav |
| **Landing Page** | COMMAND (dashboard) | /home or /chat |
| **Design Language** | Military, ATOC, uppercase | Premium, glass, minimal |
| **Color Scheme** | Pure black (#000000) | Near-black (#0A0A0C) |
| **Primary Accent** | #E63946 (same) | #E63946 (same) |
| **Navigation Depth** | Deep hierarchy (9 sections) | Flat with sidebar |
| **Chat Position** | Hidden in MORE → COMMS | Primary interface |
| **Geographic Features** | TacticalMapScreen (full tab) | Not prioritized |
| **Hardware Integration** | Dedicated screens | Redirect to chat |
| **Agent Access** | MORE → ASSETS | Primary tab |
| **Multi-agent Support** | Via chat | Native in chat |
| **Tool Cards** | Yes (reused) | Yes (original) |
| **HITL System** | Yes (reused) | Yes (original) |
| **Glass Morphism** | No (tactical) | Yes (frosted) |
| **EnhancedChatScreen** | Used at `/chat` | Primary screen |

### Code Reuse

**Shared Components** (both architectures use):
- `EnhancedChatScreen` - Chat interface (100% reused)
- `AgentsScreen` - Agent management
- `TeamsScreen` - Team management
- `WorkflowsScreen` - Workflow management
- `ToolsScreen` - Tool registry
- `ModelsScreen` - Model selection
- `ApprovalsScreen` - HITL queue
- `KnowledgeScreen` - RAG documents
- `MemoryScreen` - Memory management

**Tactical-Specific Screens** (30 files):
- `CommandScreen` (1012 lines) - Dashboard
- `TacticalMapScreen` - Geographic view
- `SitrepsScreen` - Activity feed
- `MissionsScreen` - Active operations
- `MoreScreen` - Hierarchical menu
- Hardware screens (Watch, Frame, Drones, Robotics)
- Operator screens (Presence, Biometrics, Health)
- Surveillance screens (Eagle Eye)
- Operations screens (Edge AI, Vision Pipeline)

**Chat-First Specific**:
- `HomeDashboardScreen` (287 lines) - Lighter dashboard
- Sidebar navigation components
- Glass morphism widgets

### User Experience Comparison

#### Tactical UI Workflow

```
User opens app
  ↓
COMMAND screen (tactical dashboard)
  ↓
Bottom nav to MAP (see geographic assets)
  ↓
Bottom nav to SITREPS (check activity)
  ↓
Bottom nav to MORE
  ↓
Select COMMS → Terminal
  ↓
EnhancedChatScreen opens
  ↓
Chat with @mention agents
```

**Steps to chat**: 5 taps

#### Chat-First Workflow

```
User opens app
  ↓
HomeDashboard or Chat screen
  ↓
Already in chat interface
  ↓
@mention agents directly
```

**Steps to chat**: 1 tap (or 0 if landing on /chat)

---

## Migration Analysis

### Option A: Keep Tactical UI (Minimal Effort)

**Effort**: 2-4 hours
**Scope**: Documentation updates only

**Tasks**:
1. Update CLAUDE.md to reflect tactical architecture
2. Document tacticalRouter as primary
3. Move app_router.dart to `.paused/` folder
4. Update design system docs for TacticalColors
5. Document ATOC-inspired navigation

**Pros**:
- Zero code changes
- Preserves current user experience
- Tactical UI is actively developed and stable
- Hardware/operator screens are unique value
- Military aesthetics may be user preference

**Cons**:
- Chat is buried (5 taps deep)
- Navigation is complex (9 sections)
- Contradicts "chat-first" vision
- OSColors wasted (only 9 files use it)

---

### Option B: Migrate to Chat-First (Major Effort)

**Effort**: 2-3 weeks, 138+ files
**Scope**: Full architectural migration

**Phase 1: Preparation** (2 days)
- [ ] Audit all TacticalColors usages (153 files)
- [ ] Create OSColors mapping guide
- [ ] Update design system components

**Phase 2: Theme Migration** (1 week)
- [ ] Replace TacticalColors with OSColors (153 files)
- [ ] Update tactical widgets to use glass morphism
- [ ] Migrate CommandScreen to HomeDashboardScreen
- [ ] Remove tactical-specific components

**Phase 3: Router Migration** (3 days)
- [ ] Switch main.dart to app_router
- [ ] Test all 50+ routes
- [ ] Update navigation components
- [ ] Fix broken links

**Phase 4: Screen Adaptation** (1 week)
- [ ] Move hardware screens to chat agents or redirects
- [ ] Integrate TacticalMapScreen into chat
- [ ] Adapt operator screens to chat tools
- [ ] Update 30+ tactical screens

**Phase 5: Testing** (2 days)
- [ ] Full regression testing
- [ ] Navigation flow testing
- [ ] Visual consistency check
- [ ] Mobile responsiveness

**Pros**:
- Aligns with documented vision
- Chat becomes primary (0-1 tap)
- Flatter information architecture
- Premium glass aesthetics
- Multi-agent chat is central

**Cons**:
- 2-3 weeks of development time
- Risk of regressions
- Lose tactical aesthetic (may be preferred)
- Hardware screens lose dedicated homes
- Geographic features less prominent

---

### Option C: Hybrid Approach (Medium Effort)

**Effort**: 1 week, selective integration
**Scope**: Best of both worlds

**Tasks**:
1. **Make chat more accessible** (1 day)
   - Add chat icon to tactical bottom nav (replace MORE)
   - Make chat a primary tab: COMMAND | MAP | CHAT | MISSIONS | MORE
   - Or add floating chat button (always visible)

2. **Integrate multi-agent in tactical** (2 days)
   - Wire @mentions to tactical chat
   - Add agent mention overlay to CommandScreen
   - Enable /commands in all tactical screens

3. **Preserve tactical screens** (1 day)
   - Keep hardware/operator screens
   - Keep TacticalMapScreen
   - Keep COMMAND dashboard

4. **Update documentation** (1 day)
   - Document hybrid architecture
   - Explain when to use each paradigm
   - Create migration guide for future

**Pros**:
- Chat becomes accessible (1 tap)
- Keeps unique tactical features
- Preserves 2 weeks of tactical development
- Supports both workflows
- Gradual migration path

**Cons**:
- Two design systems to maintain
- Cognitive overhead (two navigation patterns)
- More complex codebase
- Duplicated functionality

---

### Option D: Run Both (Route-Based Switching)

**Effort**: 3 days, router-level integration
**Scope**: Two modes, user choice

**Implementation**:
```dart
// Add mode switcher in settings
enum UIMode { tactical, chatFirst }

// Switch router based on mode
final router = uiMode == UIMode.tactical
  ? tacticalRouter
  : appRouter;
```

**Tasks**:
1. Add UI mode setting (1 day)
2. Implement router switching (1 day)
3. Add mode toggle in settings (0.5 day)
4. Update documentation (0.5 day)

**Pros**:
- User chooses preferred experience
- Preserves both architectures
- A/B test which users prefer
- Easy rollback if one fails

**Cons**:
- Highest maintenance burden
- Double QA/testing effort
- Confusing for new users
- Technical debt compounds

---

## Technical Debt Assessment

### Current State

| Component | Tactical | Chat-First | Status |
|-----------|----------|------------|--------|
| **Router** | ✅ Active | ⚠️ Exists, unused | CONFLICT |
| **Design System** | ✅ TacticalColors (153 files) | ⚠️ OSColors (9 files) | CONFLICT |
| **Theme** | ✅ Tactical theme in main.dart | ⚠️ OSTheme defined | CONFLICT |
| **Navigation** | ✅ TacticalShell | ⚠️ AppShell exists | CONFLICT |
| **Documentation** | ❌ Not documented | ✅ CLAUDE.md | CONFLICT |
| **EnhancedChatScreen** | ✅ Used at /chat | ✅ Designed for primary | SHARED |
| **Agno Screens** | ✅ Used in MORE menu | ✅ Designed for tabs | SHARED |

### Maintenance Burden

**Current**:
- Two routers (1 active, 1 documented)
- Two design systems (1 used, 1 documented)
- Two navigation shells
- Documentation drift

**If no action taken**:
- New developers will be confused
- Documentation becomes unreliable
- Technical debt increases
- Design inconsistency grows

---

## Decision Framework

### Evaluation Criteria

| Criterion | Weight | Tactical | Chat-First | Hybrid | Both |
|-----------|--------|----------|------------|--------|------|
| **Development Effort** | 20% | 10/10 | 2/10 | 6/10 | 5/10 |
| **User Experience** | 25% | 7/10 | 9/10 | 8/10 | 6/10 |
| **Alignment with Vision** | 15% | 4/10 | 10/10 | 7/10 | 5/10 |
| **Feature Completeness** | 15% | 9/10 | 6/10 | 9/10 | 10/10 |
| **Maintainability** | 15% | 8/10 | 9/10 | 6/10 | 3/10 |
| **Risk** | 10% | 10/10 | 3/10 | 7/10 | 5/10 |
| **Total Score** | 100% | **7.65** | **7.25** | **7.45** | **5.75** |

### Scoring Explanation

**Tactical UI (7.65)**:
- ✅ Zero effort, already working
- ✅ Stable, actively developed
- ✅ Feature-complete with unique screens
- ⚠️ Chat buried, UX friction
- ⚠️ Doesn't match documented vision

**Chat-First (7.25)**:
- ✅ Best UX for AI-first workflow
- ✅ Matches documented vision
- ✅ Clean, maintainable
- ❌ 2-3 weeks migration effort
- ❌ Lose tactical features
- ❌ High risk of regressions

**Hybrid (7.45)**:
- ✅ Balanced approach
- ✅ Keeps best of both
- ✅ Lower risk than full migration
- ⚠️ Two systems to maintain
- ⚠️ Complexity overhead

**Run Both (5.75)**:
- ✅ Preserves everything
- ✅ User choice
- ❌ Highest maintenance
- ❌ Double testing effort
- ❌ Confusing for users

---

## Recommendations

### Primary Recommendation: **Option C - Hybrid Approach**

**Rationale**: The hybrid approach offers the best balance of:
1. **Pragmatism**: Preserves 2 weeks of tactical UI development
2. **User Value**: Makes chat accessible without losing tactical features
3. **Vision Alignment**: Moves toward chat-first without throwing away work
4. **Risk Management**: Gradual migration, easy rollback
5. **Feature Preservation**: Keeps unique tactical screens (Map, Hardware, Operator)

### Implementation Plan (1 Week)

#### Day 1-2: Make Chat Primary

**Task**: Elevate chat in tactical navigation

```dart
// Option 1: Replace MORE tab with CHAT
Bottom Navigation:
COMMAND | MAP | CHAT | MISSIONS | SITREPS

// Option 2: Add floating chat button
Floating Action Button: Always visible, opens EnhancedChatScreen

// Option 3: Add chat to top bar
AppBar: Always has chat icon (like notifications)
```

**Recommendation**: Option 1 (replace MORE) + move MORE sections to drawer

#### Day 3-4: Integrate Multi-Agent

**Tasks**:
1. Add @mention overlay to CommandScreen
2. Enable /commands in TacticalMapScreen
3. Wire agent mention system to tactical router
4. Add quick agent switcher to chat

**Result**: User can @mention agents from anywhere

#### Day 5: Preserve Tactical Screens

**Tasks**:
1. Keep TacticalMapScreen (unique geographic value)
2. Keep hardware screens (Watch, Frame, Drones, Robotics)
3. Keep operator screens (Presence, Biometrics, Health)
4. Move MORE sections to drawer (accessible but not primary)

**Navigation**:
```
Bottom Nav: COMMAND | MAP | CHAT | MISSIONS | DRAWER
Drawer: All MORE sections (ASSETS, PROTOCOLS, VAULT, etc.)
```

#### Day 6-7: Documentation & Testing

**Tasks**:
1. Update CLAUDE.md to describe hybrid architecture
2. Document when to use tactical vs chat paradigm
3. Full regression testing
4. Update onboarding for new navigation

### Migration Path (Future)

**Phase 1** (Current): Hybrid architecture
- Chat accessible in 1 tap
- Tactical screens preserved
- Both design systems coexist

**Phase 2** (2-3 months): Gradual convergence
- Monitor usage analytics
- See which screens users actually use
- Deprecate unused tactical screens
- Migrate high-use screens to chat agents

**Phase 3** (6 months): Converge on winner
- If chat wins: Migrate remaining screens
- If tactical wins: Update docs, embrace ATOC
- If hybrid works: Maintain both permanently

### Alternative Recommendation: **Option A - Keep Tactical**

**If you prefer tactical aesthetics and workflow**:

The tactical UI is not technical debt - it's a **deliberate design choice** with unique value:

1. **Military aesthetics**: ATOC-inspired design may be core to your brand
2. **Hardware integration**: Dedicated screens for Watch, Frame, Drones
3. **Geographic focus**: TacticalMapScreen is a killer feature
4. **Operator-centric**: Presence, Biometrics, Health screens are unique
5. **Hierarchical navigation**: Deep menu structure works for power users

**If choosing this path**:
- Update CLAUDE.md to embrace tactical architecture
- Move app_router.dart to `.paused/`
- Document TacticalColors as primary design system
- Enhance chat discoverability (add to bottom nav or floating button)
- Accept chat-first vision was wrong, tactical is better

---

## Key Questions for Decision

Before deciding, answer these:

1. **Vision**: Is OneMind OS a "chat-first AI command center" or a "tactical operations system"?

2. **User Workflow**: Do you primarily:
   - A) Chat with agents → Tactical is friction
   - B) Monitor dashboards/maps → Tactical is perfect

3. **Aesthetics**: Which design language better represents your brand?
   - A) Premium, glass, minimal (OSColors)
   - B) Military, ATOC, tactical (TacticalColors)

4. **Hardware**: Are Watch, Frame, Drones, Robotics core features?
   - If yes → Keep tactical screens
   - If no → Redirect to chat agents

5. **Geographic**: Is location/mapping a primary feature?
   - If yes → Keep TacticalMapScreen as tab
   - If no → Integrate into chat tool cards

6. **Development Velocity**: Would you rather:
   - A) Ship now, iterate later (Hybrid or Keep Tactical)
   - B) Align architecture, even if it takes 2-3 weeks (Chat-First)

---

## Success Metrics

Whichever option you choose, measure:

**User Behavior**:
- Chat usage frequency
- Time to first chat message
- @mention usage
- Navigation path analysis
- Screen view duration

**Development Velocity**:
- New feature development time
- Bug resolution time
- Design consistency violations
- Documentation accuracy

**Technical Health**:
- Router complexity
- Design token usage
- Component reuse rate
- Test coverage

---

## Conclusion

OneMind OS has two high-quality UI architectures that serve different philosophies:

- **Tactical UI**: Military operations center, hierarchical, feature-rich
- **Chat-First**: AI command center, conversational, minimal

Neither is "wrong" - they serve different use cases and user preferences.

**Recommended Path**: Start with hybrid (1 week), monitor usage (2-3 months), converge on winner (6 months).

This approach:
- ✅ Preserves existing work
- ✅ Reduces chat friction
- ✅ Keeps unique tactical features
- ✅ Provides data for final decision
- ✅ Low risk, high value

**Decision Required**: Which option aligns with your vision for OneMind OS?

---

## Appendix: File Statistics

### TacticalColors Usage (153 files, 4603 occurrences)

Top 10 files by usage:
1. `frontend/lib/tactical/screens/command_screen.dart` - 74 occurrences
2. `frontend/lib/tactical/screens/sitreps_screen.dart` - 13 occurrences
3. Various tactical screens - 10-50 occurrences each

### OSColors Usage (9 files, 91 occurrences)

Files using OSColors:
1. `frontend/lib/shared/theme/os.dart` - Definition file
2. `frontend/lib/shared/theme/colors.dart` - Implementation
3. `CLAUDE.md` - Documentation (7 occurrences)
4. `docs/design/DESIGN_SYSTEM.md` - Design docs
5. Various archived/documentation files

### Router Comparison

**tacticalRouter**:
- File: `frontend/lib/tactical/router/tactical_router.dart`
- Routes: 50+
- Shell: TacticalShell (5-tab bottom nav)
- Active: ✅ YES (in main.dart)

**appRouter**:
- File: `frontend/lib/platform/router/app_router.dart`
- Routes: 50+
- Shell: AppShell (6-pillar nav)
- Active: ❌ NO (not in main.dart)

---

**Document Version**: 1.0
**Last Updated**: February 5, 2026
**Next Review**: After decision is made and implementation begins
