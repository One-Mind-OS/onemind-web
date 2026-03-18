# Tactical Solarpunk Theme Design
**Date**: 2026-02-16
**Status**: Approved
**Theme Identity**: "Soldier in a Solarpunk World"

## Executive Summary

This document describes the design for adding a **Tactical Solarpunk** theme to OneMind OS v3 as a third theme option alongside Light and Dark. The theme combines military precision with forest guardian energy, creating a "command center for protecting a living planetary ecosystem" aesthetic.

**Core Design Principle**: Maintain tactical discipline (structure, clarity, efficiency) while using solarpunk aesthetics (natural colors, organic energy, living systems).

---

## 1. Design Philosophy

### Theme Identity
**Tactical Solarpunk** represents "precision in nature" — the intersection of:
- **Tactical**: Military command centers, ranger stations, precision monitoring
- **Solarpunk**: Living systems, forest ecosystems, sustainable technology, organic energy

### Visual References
- Forest ranger command center monitoring ecosystem health
- The Expanse botanical bay control systems
- Avatar RDA facilities reimagined with ecological conscience
- Biomonitor dashboards for planetary systems

### Key Metaphors
- **Agents** = Organisms in an ecosystem
- **Connections** = Mycelial networks (organic, interconnected)
- **Status** = Health indicators (breathing, pulsing like living systems)
- **Energy** = Solar/amber warmth (renewable, life-giving)
- **Structure** = Forest layers (depth, natural hierarchy)

---

## 2. Color System: Forest Tech Palette

### Background Colors
```
Background:  #0A1810  (Deep forest night)
Surface:     #122820  (Elevated moss surface)
Card:        #1A3328  (Rich forest floor)
Elevated:    #234030  (Highlighted natural elements)
Input:       #15281E  (Input fields with earthy depth)
```

### Primary Accent: Amber Energy
```
Primary:      #FFB703  (Warm amber/golden energy)
PrimaryDim:   #D99000  (Pressed state)
PrimaryGlow:  #FFC933  (Hover/focus with warm glow)
PrimaryMuted: #FFB70326 (15% opacity overlay)
Critical:     #FF9500  (Important actions - warmer orange)
```

**Rationale**: Amber represents solar energy, warmth, and life-giving light. Replaces tactical red with warmer, more optimistic tone while maintaining urgency for critical actions.

### Secondary Accent: Living Green
```
Moss:     #52B788  (Life indicator, growth)
MossDim:  #2D6A4F  (Dimmed moss)
MossGlow: #74C69D  (Bright growth effect)
Jade:     #40916C  (Alternative green accent)
```

**Rationale**: Moss green represents living systems, growth, and health. Replaces tactical cyan with natural vitality indicator.

### Status Colors
```
Success:  #52B788  (Healthy growth green)
Warning:  #F4A460  (Sandy/desert warning)
Error:    #E07A5F  (Terracotta alert)
Info:     #81B29A  (Sage information)
Inactive: #5C6F64  (Stone gray - warmer than tactical)
```

**Rationale**: Natural tones reduce visual aggression while maintaining clear status communication. Terracotta error is urgent without being harsh.

### Text Colors
```
TextPrimary:   #F0F4F0  (Soft white with green tint)
TextSecondary: #C8D5C8  (Light sage)
TextMuted:     #9AAF9A  (Muted moss)
TextDim:       #6B7F6B  (Dim forest)
TextDisabled:  #4A5F4A  (Disabled stone)
```

**Rationale**: Warm tinted whites reduce eye strain, maintain readability, add organic warmth.

### Border & Effects
```
Border:       #2D4438  (Subtle natural border)
BorderBright: #3A5544  (Brighter organic edge)
Divider:      #2D4438  (Natural separation)
```

### Agent Category Colors
```
Code:         #6A8CAF  (Stone blue - cool precision)
Research:     #9A7BB0  (Lavender sage - contemplative)
Creative:     #D98A8A  (Rose clay - warm expression)
Productivity: #52B788  (Living moss - active growth)
IoT:          #81B29A  (Jade tech - physical/digital bridge)
```

---

## 3. Typography & Visual Language

### Typography Strategy

**What to KEEP (Tactical Precision)**:
- Monospace for technical data (IDs, timestamps, metrics)
- Uppercase for labels, buttons, section headers
- Letter-spacing: 2 for screen titles
- Letter-spacing: 1.5 for section headers

**What to CHANGE (Natural Warmth)**:
- Sans-serif for descriptions and body text (adds humanity)
- Mixed case for agent/team names and descriptions
- Slightly reduced letter-spacing in some contexts for warmth

### Typography Scale
```dart
screenTitle:    24px, monospace, uppercase, weight 700, spacing 2
sectionHeader:  11px, monospace, uppercase, weight 600, spacing 1.5
cardTitle:      14px, sans-serif, mixed case, weight 600
cardSubtitle:   12px, sans-serif, mixed case, weight 400
statusLabel:    11px, monospace, uppercase, weight 600, spacing 0.5
buttonLabel:    13px, monospace, uppercase, weight 600, spacing 1
statValue:      28px, monospace, weight 700
bodyLarge:      16px, sans-serif, weight 400
bodyMedium:     14px, sans-serif, weight 400
```

### Border Radius (Organic Softness)
```
Cards:          16px  (increased from 12px - softer, more organic)
Buttons:        12px  (increased from 8px - gentle curves)
Input fields:   10px  (comfortable interaction)
Badges/dots:    8px   (subtle rounding)
```

**Rationale**: Increased radius adds organic warmth while maintaining structured appearance. Not fully rounded (which would be too soft) but noticeably warmer than sharp tactical edges.

### Shadow System
```dart
// Warm amber-tinted shadows
cardShadow: BoxShadow(
  color: Color(0x14FFB703),  // Amber at 8% opacity
  blurRadius: 8,
  spreadRadius: 0,
  offset: Offset(0, 2),
)

elevatedShadow: BoxShadow(
  color: Color(0x1FFFB703),  // Amber at 12% opacity
  blurRadius: 16,
  spreadRadius: 0,
  offset: Offset(0, 4),
)
```

### Border Treatment
- **Width**: 1.5px (slightly thicker than tactical 1px for organic weight)
- **Color**: Natural borders with subtle warmth
- **Glow**: Amber or moss green glow on hover/active states

---

## 4. Animation & Motion

### Animation Philosophy
Animations should feel "living" — organic growth and breathing rather than mechanical snapping.

### Animation Durations
```dart
// Slightly slower than tactical for organic feel
instant:  50ms   (unchanged - immediate feedback)
fast:     100ms  (unchanged - quick response)
quick:    150ms  (unchanged)
normal:   250ms  (increased from 200ms - more settling)
slow:     350ms  (increased from 300ms - growth feeling)
medium:   450ms  (increased from 400ms)
```

### Easing Curves
```dart
standard: Curves.easeOutCubic    (natural deceleration)
smooth:   Curves.fastOutSlowIn   (organic settling)
organic:  Curves.easeOut         (growth effect)
```

### Breathing Pulse Animation
**Purpose**: Make status indicators feel alive

```dart
Duration: 2000ms
Loop: infinite, reverse
Properties:
  - Scale: 1.0 → 1.15 → 1.0
  - Opacity: 0.7 → 1.0 → 0.7
  - Glow radius: 4px → 8px → 4px
```

**Applied to**:
- Active status dots
- Processing indicators
- Real-time health monitors

### Hover States
```dart
Duration: 250ms
Scale: 1.0 → 1.02 (subtle lift)
Shadow: Increase blur + amber tint intensity
Border: Moss green glow brightens
Cursor: pointer
```

### Loading States
```dart
// Circular progress with organic feel
Animation: "Growing" (scale + opacity)
Colors: Moss green fill, amber glow pulse
Duration: 1200ms per rotation
Text: "INITIALIZING..." (maintain tactical language)
```

---

## 5. Component-Specific Design

### Agent Cards
```
┌─────────────────────────────────┐  ← Moss green border (1.5px)
│ AGENT-4729              [●]     │  ← Uppercase ID (mono), amber pulse
│ Strategic Analyst              │  ← Mixed case (sans-serif)
│                                 │
│ STATUS: OPERATIONAL             │  ← Uppercase, moss green badge
│ UPTIME: 47:32:19               │  ← Monospace metrics
│ ──────────────────────────────  │
│ [DEPLOY]  [CONFIGURE]          │  ← Uppercase buttons
└─────────────────────────────────┘
```

**Features**:
- Forest floor card background with subtle texture (3% opacity)
- Moss green border with gentle glow when active
- Amber breathing pulse for status dot
- Warm shadow (amber-tinted)

### Network Graph (Game Screen)

**Nodes**:
- Organic circles with subtle pulse animation
- Moss green for healthy/idle nodes
- Amber glow for active processing
- Terracotta for error states

**Connections**:
- Slight bezier curves (not rigid straight lines)
- Control point offset: 10% of distance between nodes
- Gradient along line (moss → amber when processing)
- Line width: 1px idle, 2px active
- Suggests mycelial network connections

**Particles**:
- Amber "energy motes" for active processing
- Moss green "growth particles" for success
- Slower, floating movement (like fireflies)
- Soft glow trails instead of harsh streaks

### Buttons

**Primary Button** (Call-to-action):
```dart
Background: Amber (#FFB703)
Text: White, uppercase, monospace
Border radius: 12px
Hover:
  - Background: #FFC933 (primaryGlow)
  - Shadow: Amber glow (12px blur, 8% opacity)
  - Scale: 1.02
```

**Secondary Button** (Alternative action):
```dart
Background: Transparent
Border: 1.5px moss green (#52B788)
Text: Moss green, uppercase, monospace
Hover:
  - Background: Moss tint (5% opacity)
  - Border glow brightens
```

**Ghost Button** (Tertiary):
```dart
Background: Transparent
Text: Secondary text color
Hover:
  - Text: Primary text color
  - Background: Subtle moss tint (3% opacity)
```

### Input Fields
```dart
Background: #15281E (dark forest input)
Border: 1.5px natural border (#2D4438)
Border radius: 10px
Focus state:
  - Border: Amber (#FFB703)
  - Glow: Amber shadow (8px blur)
Placeholder: Warm muted text (#9AAF9A)
Selection: Amber highlight (20% opacity)
```

### Status Badges
```
OPERATIONAL:  Moss green bg (15% opacity), moss border, pulsing glow
MAINTENANCE:  Sandy amber bg, amber border, steady glow
CRITICAL:     Terracotta bg, terracotta border, gentle pulse
OFFLINE:      Stone gray, no glow, 50% opacity
```

### Sidebar/Navigation
```
Background: Deepest forest (#0A1810)
Section headers: Uppercase, reduced spacing, warm secondary text
Items:
  - Default: Secondary text color
  - Hover: Moss green tint (5% opacity), scale 1.01
  - Active:
    - Amber left border (4px)
    - Moss green background tint (8% opacity)
    - Primary text color
```

### Data Tables
```
Header:
  - Background: Surface color
  - Text: Uppercase, monospace, amber accent
  - Border bottom: 2px amber

Rows:
  - Hover: Moss green tint (5% opacity)
  - Selected: Amber left border (3px) + moss background (8%)
  - Alternating: Very subtle (2% opacity difference)

Cells:
  - Data: Monospace
  - Labels: Sans-serif
  - Padding: Comfortable spacing
```

---

## 6. Implementation Architecture

### Approach: Enum Extension
Extend existing `AppThemeMode` enum to include `solarpunk` as a peer of `light` and `dark`.

**Benefits**:
- Zero breaking changes
- Follows existing pattern
- Easy to add future themes
- Single source of truth
- Instant switching

### File Structure

```
frontend/lib/config/
├── tactical_theme.dart (MODIFY)
│   ├── Add AppThemeMode.solarpunk
│   ├── Add TacticalColorsSolarpunk class
│   ├── Update TacticalColors getters (3-way switch)
│   ├── Add TacticalDecorationSolarpunk presets
│   └── Add TacticalAnimations class
└── app_constants.dart (NO CHANGES)

frontend/lib/providers/
└── theme_provider.dart (NO CHANGES - already supports any mode)

frontend/lib/screens/
└── settings_screen.dart (MODIFY - add solarpunk option)

frontend/lib/widgets/
├── app_shell.dart (MODIFY - apply solarpunk colors)
└── sidebar.dart (MODIFY - apply solarpunk styles)

frontend/lib/game/components/
├── node_component.dart (MODIFY - organic appearance)
├── connection_component.dart (MODIFY - bezier curves)
└── particle_system.dart (MODIFY - warmer particles)
```

### Code Changes Overview

**1. tactical_theme.dart**
```dart
// Add to enum
enum AppThemeMode {
  light,
  dark,
  solarpunk,  // NEW
}

// Add new color class (150+ lines)
class TacticalColorsSolarpunk {
  static const Color background = Color(0xFF0A1810);
  static const Color primary = Color(0xFFFFB703);
  // ... (complete palette)
}

// Update all TacticalColors getters (use switch statement)
static Color get background {
  switch (_currentTheme) {
    case AppThemeMode.dark:
      return TacticalColorsDark.background;
    case AppThemeMode.light:
      return TacticalColorsLight.background;
    case AppThemeMode.solarpunk:
      return TacticalColorsSolarpunk.background;
  }
}

// Add solarpunk-specific decorations
class TacticalDecorationSolarpunk { ... }

// Add animation helpers
class TacticalAnimations {
  static AnimationController breathingPulse(TickerProvider vsync) { ... }
}
```

**2. settings_screen.dart**
```dart
// Add third radio option
RadioListTile(
  title: Text('Tactical Solarpunk'),
  subtitle: Text('Forest guardian command center'),
  value: AppThemeMode.solarpunk,
  groupValue: currentTheme,
  onChanged: (value) => ref.read(themeProvider.notifier).setTheme(value),
)
```

**3. Component updates**
- Use `TacticalColors.primary` (already does this) → automatically gets amber
- Use `TacticalColors.moss` (new getter) for secondary accents
- Add breathing animation to status dots
- Update connection rendering for bezier curves
- Update particle colors and movement

### Backward Compatibility
- ✅ Existing `light` and `dark` themes completely unchanged
- ✅ All components work without modification (colors update automatically)
- ✅ Theme persistence works automatically
- ✅ Users who don't select solarpunk see zero changes

---

## 7. Implementation Phases

### Phase 1: Core Theme Infrastructure
**Goal**: Add solarpunk theme, make it selectable

**Tasks**:
1. Add `AppThemeMode.solarpunk` to enum
2. Create `TacticalColorsSolarpunk` class with complete palette
3. Update all `TacticalColors` getters to 3-way switch
4. Add `TacticalDecorationSolarpunk` class with decoration presets
5. Add `TacticalAnimations` class with breathing pulse
6. Update settings screen to show solarpunk option
7. Test theme switching between all 3 modes

**Success Criteria**:
- Can select solarpunk theme in settings
- Theme persists across app restart
- All screens render without errors
- Colors apply correctly throughout app

### Phase 2: Universal Components
**Goal**: Polish shared UI components with solarpunk styling

**Tasks**:
1. Update `app_shell.dart` for forest background
2. Update `sidebar.dart` with amber accents and moss hover states
3. Update button widgets with new hover effects
4. Update input field decorations with amber focus
5. Update card widgets with warm shadows
6. Add texture overlays to cards (optional)
7. Update status badges with breathing animation

**Success Criteria**:
- Sidebar navigation feels organic yet tactical
- Buttons have warm hover effects
- Input fields glow amber on focus
- Cards have subtle depth and warmth
- Status indicators pulse gently

### Phase 3: Specialized Components
**Goal**: Add organic behavior to visualization components

**Tasks**:
1. Update `node_component.dart` for organic circles with pulse
2. Update `connection_component.dart` for bezier curves
3. Update `particle_system.dart` for amber/moss particles
4. Add floating animation to particles
5. Update agent card hover states
6. Update data table styling with moss hover
7. Polish loading states with growth animation

**Success Criteria**:
- Network graph feels like mycelial network
- Particles feel organic (fireflies, not sparks)
- Connections have natural curves
- All animations feel "living"
- Tables maintain tactical precision with natural warmth

---

## 8. Quality Standards

### Accessibility
- **Color contrast**: All text meets WCAG AA (4.5:1 minimum for normal text, 3:1 for large text)
- **Reduced motion**: Respect `prefers-reduced-motion` system setting for animations
- **Focus indicators**: 3px amber outline for keyboard navigation
- **Screen reader**: No visual-only information, all states announced

### Performance
- **Animation FPS**: 60fps minimum for all animations
- **Theme switch**: <100ms transition time
- **Memory**: No memory leaks from animation controllers
- **Particle count**: Cap at 200 particles max for performance

### Browser Support
- **Chrome/Edge**: Full support (primary target)
- **Firefox**: Full support
- **Safari**: Full support (test bezier curves carefully)
- **Mobile**: Responsive, touch-friendly

### Testing Requirements
1. **Visual regression**: All 30+ screens in solarpunk mode
2. **Color contrast**: Automated WCAG checks
3. **Theme switching**: Verify light ↔ dark ↔ solarpunk
4. **Persistence**: Theme survives app restart
5. **Animation**: Smooth 60fps performance
6. **Accessibility**: Screen reader + keyboard navigation

---

## 9. Optional Enhancements (Future)

### Texture Overlays
Add very subtle (3% opacity) organic texture to cards:
- Fine grain/noise pattern
- Applied via CustomPainter or image overlay
- Breaks up flat digital feel
- Toggleable in settings

### Time-of-Day Adaptive Tones
Theme adjusts slightly based on system time:
- Morning (6-12): Warmer ambers, brighter
- Afternoon (12-18): Full saturation
- Evening (18-22): Cooler, deeper greens
- Night (22-6): Dimmest, restful palette

**Implementation**: Adjust HSV values ±5% based on time

### Seasonal Variants
Subtle palette shifts by season:
- Spring: Brighter greens, fresh
- Summer: Full saturation, warm
- Autumn: More amber/orange tones
- Winter: Cooler, deeper palette

### Custom Accent Colors
Let users customize primary accent (amber) while keeping rest of palette:
- Preset options: Amber, Jade, Rose Clay, Lavender
- Maintains visual harmony through HSV relationships

---

## 10. Success Metrics

### Qualitative
- Users describe theme as "warm but professional"
- Theme feels "alive" without being distracting
- Tactical precision is maintained
- New users can use app without confusion

### Quantitative
- Theme adoption: >20% of users try solarpunk
- Retention: >50% of users who try it keep it
- Performance: 60fps animations, <100ms theme switch
- Accessibility: 100% WCAG AA compliance

---

## 11. Design Rationale Summary

### Why Tactical Solarpunk Works for OneMind OS

**1. Maintains Professional Context**
- Deep forest colors provide sophistication
- Monospace + uppercase preserve command center authority
- Grid layouts keep tactical precision

**2. Adds Emotional Warmth**
- Amber replaces harsh red (optimism over alarm)
- Organic curves soften digital harshness
- Breathing animations suggest life, not machinery

**3. Aligns with Agent Metaphor**
- Multi-agent systems = forest ecosystems (natural parallel)
- Connections = mycelial networks (organic collaboration)
- Status = health indicators (living system monitoring)

**4. Future-Proof**
- Easy to add more themes (biopunk, steampunk, etc.)
- Validates theme system architecture
- Demonstrates commitment to user choice

**5. Low Risk**
- Pure addition, no breaking changes
- Users can switch back instantly
- Tactical and light themes remain untouched

---

## 12. Visual Examples

### Color Palette Comparison

```
TACTICAL DARK          TACTICAL SOLARPUNK
═══════════════════    ═══════════════════
Background:  #000000   Background:  #0A1810
Primary:     #E63946   Primary:     #FFB703
Accent:      #00D9FF   Accent:      #52B788
Success:     #22C55E   Success:     #52B788
Warning:     #F59E0B   Warning:     #F4A460
Error:       #EF4444   Error:       #E07A5F

Vibe: Cold neon        Vibe: Warm nature
Feel: Cyberpunk        Feel: Solarpunk
```

### Agent Card Evolution

```
TACTICAL                        SOLARPUNK
┌──────────────────────┐       ┌──────────────────────┐
│ AGENT-4729      [●]  │       │ AGENT-4729      [●]  │
│ Strategic Analyst    │  →    │ Strategic Analyst    │
│ STATUS: OPERATIONAL  │       │ STATUS: OPERATIONAL  │
│ [DEPLOY] [CONFIG]    │       │ [DEPLOY] [CONFIG]    │
└──────────────────────┘       └──────────────────────┘
 ↑                               ↑
 Sharp edges, red accent         Rounded, amber glow
 Cold feel                       Warm feel
 Static                          Breathing pulse
```

---

## Conclusion

The Tactical Solarpunk theme brings "precision in nature" to OneMind OS — maintaining the tactical command center structure while infusing it with forest guardian warmth. By keeping disciplined layouts and adding organic colors, animations, and energy, we create an interface that feels both professional and alive.

**Theme Motto**: "Command center for protecting a living planetary ecosystem"

**Implementation**: Low-risk enum extension approach with 3 phased rollout

**Timeline**: Core infrastructure (1-2 days) → Universal components (2-3 days) → Specialized components (2-3 days)

**Total Effort**: ~5-8 days for complete implementation + polish

---

## Appendix A: Complete Color Reference

```dart
// TacticalColorsSolarpunk - Complete Palette

// Backgrounds
static const Color background = Color(0xFF0A1810);  // Deep forest night
static const Color surface = Color(0xFF122820);     // Elevated moss
static const Color card = Color(0xFF1A3328);        // Rich forest floor
static const Color elevated = Color(0xFF234030);    // Highlighted natural
static const Color input = Color(0xFF15281E);       // Input earthy depth

// Primary Accent (Amber Energy)
static const Color primary = Color(0xFFFFB703);     // Warm amber/golden
static const Color primaryDim = Color(0xFFD99000);  // Pressed state
static const Color primaryGlow = Color(0xFFFFC933); // Hover/focus glow
static const Color primaryMuted = Color(0x26FFB703);// 15% opacity
static const Color critical = Color(0xFFFF9500);    // Important actions

// Secondary Accent (Living Green)
static const Color moss = Color(0xFF52B788);        // Life indicator
static const Color mossDim = Color(0xFF2D6A4F);     // Dimmed moss
static const Color mossGlow = Color(0xFF74C69D);    // Bright growth
static const Color jade = Color(0xFF40916C);        // Alternative green

// Status Colors
static const Color success = Color(0xFF52B788);     // Healthy growth
static const Color warning = Color(0xFFF4A460);     // Sandy warning
static const Color error = Color(0xFFE07A5F);       // Terracotta alert
static const Color info = Color(0xFF81B29A);        // Sage information
static const Color inactive = Color(0xFF5C6F64);    // Stone gray

// Text Colors
static const Color textPrimary = Color(0xFFF0F4F0); // Soft white/green
static const Color textSecondary = Color(0xFFC8D5C8);// Light sage
static const Color textMuted = Color(0xFF9AAF9A);   // Muted moss
static const Color textDim = Color(0xFF6B7F6B);     // Dim forest
static const Color textDisabled = Color(0xFF4A5F4A);// Disabled stone

// Borders & Effects
static const Color border = Color(0xFF2D4438);      // Subtle natural
static const Color borderBright = Color(0xFF3A5544);// Brighter organic
static const Color divider = Color(0xFF2D4438);     // Natural separation

// Agent Category Colors
static const Color categoryCode = Color(0xFF6A8CAF);        // Stone blue
static const Color categoryResearch = Color(0xFF9A7BB0);    // Lavender sage
static const Color categoryCreative = Color(0xFFD98A8A);    // Rose clay
static const Color categoryProductivity = Color(0xFF52B788);// Living moss
static const Color categoryIoT = Color(0xFF81B29A);         // Jade tech
```

---

**Design Status**: ✅ Approved
**Next Step**: Implementation Planning (writing-plans skill)
