# OneMind OS Design System

> Your personal AI command center. Dark-first, premium, tactile.

---

## Quick Start

```dart
import 'package:onemind/shared/theme/os.dart';

MaterialApp(
  theme: OSTheme.dark,
  home: Scaffold(
    backgroundColor: OSColors.background,
    body: Text('Hello', style: OSTypography.body),
  ),
)
```

---

## 1. Design Principles

| Principle | Description |
|-----------|-------------|
| **Personal** | Your private AI space - intimate, individual, deeply customized |
| **Dark-First** | Deep blacks optimized for OLED, not just "dark mode" |
| **Agent-Centric** | UI reinforces YOUR agent/workforce mental model |
| **Glanceable** | Information hierarchy that works at a glance |
| **Tactile** | Micro-interactions that feel responsive and alive |

### Personal App Philosophy

OneMind OS is NOT an enterprise tool. It's YOUR personal AI command center:

- **Your Agents** - AI assistants you configure for YOUR needs
- **Your Memory** - Context that learns YOUR patterns
- **Your Workflows** - Automations built around YOUR life
- **Your Data** - Private by default, no sharing features
- **Your Interface** - Customizable to YOUR style

---

## 2. Color System

### Core Palette

| Token | Value | Usage |
|-------|-------|-------|
| `OSColors.background` | `#0A0A0C` | Main background |
| `OSColors.surface` | `#12121A` | Panels, sidebars |
| `OSColors.card` | `#1C1C24` | Card backgrounds |
| `OSColors.elevated` | `#242430` | Modals, dropdowns |
| `OSColors.input` | `#16161E` | Input fields |

### Primary (Brand Red)

| Token | Value | Usage |
|-------|-------|-------|
| `OSColors.primary` | `#E63946` | Main accent |
| `OSColors.primaryDim` | `#B82D3A` | Pressed state |
| `OSColors.primaryGlow` | `#FF6B6B` | Hover/glow |
| `OSColors.primaryMuted` | 15% opacity | Backgrounds |

### Status Colors

| Token | Value | Usage |
|-------|-------|-------|
| `OSColors.success` | `#2ECC71` | Success, online |
| `OSColors.warning` | `#F39C12` | Warnings |
| `OSColors.error` | `#E74C3C` | Errors, offline |
| `OSColors.info` | `#3B82F6` | Information |
| `OSColors.inactive` | `#4A4A5A` | Disabled |

### Text Colors

| Token | Value | Usage |
|-------|-------|-------|
| `OSColors.textPrimary` | `#FAFAFA` | Main text |
| `OSColors.textSecondary` | `#B8B8C8` | Labels |
| `OSColors.textMuted` | `#7A7A8A` | Hints |
| `OSColors.textDim` | `#4D4D5D` | Subtle hints |

### Agent Category Colors

| Token | Color | Category |
|-------|-------|----------|
| `OSColors.agentCoding` | `#3B82F6` | Blue - Coding |
| `OSColors.agentResearch` | `#8B5CF6` | Purple - Research |
| `OSColors.agentCreative` | `#EC4899` | Pink - Creative |
| `OSColors.agentProductivity` | `#10B981` | Green - Productivity |
| `OSColors.agentLifeos` | `#F59E0B` | Amber - LifeOS |
| `OSColors.agentHome` | `#06B6D4` | Cyan - Home/IoT |

### Helper Methods

```dart
OSColors.getAgentColor('coding')      // Returns blue
OSColors.getStatusColor('success')    // Returns green
OSColors.getAwarenessColor('present') // For awareness modes
OSColors.getPriorityColor('high')     // For priorities
```

---

## 3. Typography

### Text Styles

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `OSTypography.displayLarge` | 32px | Bold | Hero text |
| `OSTypography.headline` | 24px | SemiBold | Headlines |
| `OSTypography.title` | 18px | SemiBold | Titles |
| `OSTypography.subtitle` | 15px | Medium | Subtitles |
| `OSTypography.body` | 15px | Regular | Body text |
| `OSTypography.bodySmall` | 13px | Regular | Small body |
| `OSTypography.label` | 11px | SemiBold | Labels |
| `OSTypography.caption` | 12px | Regular | Captions |
| `OSTypography.code` | 13px | Mono | Code |

### Font Families

- **UI**: Inter (system fallback)
- **Code**: JetBrains Mono (monospace fallback)

---

## 4. Spacing

### Scale (4px base)

| Token | Value | Usage |
|-------|-------|-------|
| `OSSpacing.xs` | 4px | Micro |
| `OSSpacing.sm` | 8px | Tight |
| `OSSpacing.md` | 12px | Compact |
| `OSSpacing.lg` | 16px | Default |
| `OSSpacing.xl` | 20px | Comfortable |
| `OSSpacing.xxl` | 24px | Section |
| `OSSpacing.xxxl` | 32px | Large gaps |
| `OSSpacing.huge` | 40px | Screen sections |

### Common Patterns

```dart
OSSpacing.screenPadding    // EdgeInsets.symmetric(horizontal: 16)
OSSpacing.cardPadding      // EdgeInsets.all(12)
OSSpacing.listItemPadding  // Symmetric(h: 12, v: 8)
OSSpacing.buttonPadding    // Symmetric(h: 16, v: 12)
```

---

## 5. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `OSRadius.xs` | 4px | Badges |
| `OSRadius.sm` | 6px | Small |
| `OSRadius.md` | 8px | Buttons |
| `OSRadius.lg` | 12px | Cards |
| `OSRadius.xl` | 16px | Modals |
| `OSRadius.full` | 9999px | Pills |

### BorderRadius Instances

```dart
OSRadius.card        // BorderRadius.circular(12)
OSRadius.button      // BorderRadius.circular(8)
OSRadius.input       // BorderRadius.circular(8)
OSRadius.chatBubble  // BorderRadius.circular(16)
OSRadius.bottomSheet // Vertical top: 20
OSRadius.pill        // BorderRadius.circular(9999)

// Message bubble with tail
OSRadius.messageBubble(isUser: true)
```

---

## 6. Sizes

### Icons (`OSIconSize`)

| Token | Value |
|-------|-------|
| `xs` | 12px |
| `sm` | 16px |
| `md` | 18px |
| `lg` | 20px |
| `xl` | 24px |
| `xxl` | 32px |

### Avatars (`OSAvatarSize`)

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 24px | Inline |
| `sm` | 32px | Chat |
| `md` | 40px | List items |
| `lg` | 48px | Cards |
| `xl` | 64px | Detail |
| `xxl` | 80px | Profile |

### Component Heights (`OSHeight`)

| Token | Value | Usage |
|-------|-------|-------|
| `buttonSm` | 32px | Small button |
| `button` | 48px | Standard button |
| `buttonLg` | 56px | Large button |
| `appBar` | 48px | App bar |
| `bottomNav` | 56px | Bottom nav |
| `listItem` | 72px | List item |
| `inputField` | 48px | Input |

---

## 7. Shadows

### Elevation

```dart
OSShadows.none     // No shadow
OSShadows.sm       // Subtle (cards at rest)
OSShadows.card     // Standard card shadow
OSShadows.md       // Elevated (dropdowns)
OSShadows.lg       // High (dialogs)
```

### Glows

```dart
OSShadows.glowPrimary   // Red glow
OSShadows.glowSuccess   // Green glow
OSShadows.glowInfo      // Blue glow
OSShadows.glowWarning   // Amber glow
OSShadows.glowError     // Red glow

// Dynamic
OSShadows.glow(color)
OSShadows.agentGlow('coding')
OSShadows.statusGlow('success')
OSShadows.focusRing()
```

---

## 8. Decorations

Pre-built `BoxDecoration` presets:

```dart
// Cards
OSDecoration.card()
OSDecoration.elevatedCard()
OSDecoration.gradientCard()
OSDecoration.surfaceCard()

// Inputs
OSDecoration.input(focused: true, error: false)

// Chat
OSDecoration.chatBubble(isUser: true)

// Status
OSDecoration.statusBadge(color)
OSDecoration.statusDot(color)
OSDecoration.statusDotNamed('success')

// Misc
OSDecoration.activeItem(isActive)
OSDecoration.bottomSheet()
OSDecoration.toolCard(status: 'running')
```

---

## 9. Motion

### Durations

| Token | Value | Usage |
|-------|-------|-------|
| `OSMotion.instant` | 50ms | Press feedback |
| `OSMotion.fast` | 100ms | Button transitions |
| `OSMotion.quick` | 150ms | Micro-interactions |
| `OSMotion.normal` | 200ms | Default |
| `OSMotion.slow` | 300ms | Page transitions |
| `OSMotion.slower` | 500ms | Complex animations |

### Curves

```dart
OSMotion.easeOut     // Standard exit
OSMotion.easeIn      // Standard enter
OSMotion.easeInOut   // Symmetric
OSMotion.standard    // General purpose
OSMotion.smooth      // Natural movement
OSMotion.spring      // Bouncy
OSMotion.overshoot   // Slight bounce
```

### Animation Widgets

```dart
// Fade in + slide up
OSFadeIn(
  child: MyWidget(),
  delay: Duration(milliseconds: 100),
)

// Scale in
OSScaleIn(child: MyWidget())

// Staggered list
OSStaggered(
  index: 0,
  child: ListTile(...),
)

// Pulse (loading)
OSPulse(child: Icon(Icons.circle))

// Press scale (buttons)
OSPressable(
  onTap: () {},
  child: MyButton(),
)
```

---

## 10. Theme

### Complete ThemeData

```dart
MaterialApp(
  theme: OSTheme.dark,
  ...
)
```

The theme configures all Material components:
- AppBar, BottomNav, NavigationBar
- Cards, Dialogs, BottomSheets
- Buttons (Elevated, Outlined, Text, Icon)
- Inputs, Chips, Tabs
- Progress indicators, Sliders, Switches
- Checkboxes, Radios, Tooltips

### Theme Extension

Access agent colors via extension:

```dart
final theme = Theme.of(context);
final codingColor = theme.os.agentCoding;
```

---

## 11. File Structure

```
frontend/lib/shared/theme/
├── os.dart              # Barrel export (USE THIS)
├── colors.dart          # OSColors
├── typography.dart      # OSTypography
├── spacing.dart         # OSSpacing, OSRadius, OSIconSize, OSAvatarSize, OSHeight
├── shadows.dart         # OSShadows, OSDecoration
├── motion.dart          # OSMotion + animation widgets
├── theme.dart           # OSTheme.dark
├── tactical_colors.dart # DEPRECATED - re-exports
└── dimensions.dart      # DEPRECATED - re-exports
```

---

## 12. Migration Guide

### From Old Classes

```dart
// OLD                          // NEW
TacticalColors.background   →   OSColors.background
TacticalColors.primary      →   OSColors.primary
TacticalText.body           →   OSTypography.body
TacticalDecoration.card()   →   OSDecoration.card()
Spacing.lg                  →   OSSpacing.lg
Radii.card                  →   OSRadius.card
Durations.fast              →   OSMotion.fast
```

Old imports still work via re-exports:

```dart
// Still works (deprecated)
import 'package:onemind/shared/theme/tactical_colors.dart';

// Recommended
import 'package:onemind/shared/theme/os.dart';
```

---

## 13. Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:onemind/shared/theme/os.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OSColors.background,
      appBar: AppBar(title: Text('Example')),
      body: Padding(
        padding: OSSpacing.screenPadding,
        child: Column(
          children: [
            // Card with animation
            OSFadeIn(
              child: Container(
                decoration: OSDecoration.card(),
                padding: OSSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Title', style: OSTypography.title),
                    SizedBox(height: OSSpacing.sm),
                    Text(
                      'Card description here',
                      style: OSTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: OSSpacing.lg),

            // Button with press effect
            OSPressable(
              onTap: () {},
              child: Container(
                height: OSHeight.button,
                decoration: BoxDecoration(
                  color: OSColors.primary,
                  borderRadius: OSRadius.button,
                  boxShadow: OSShadows.glowPrimary,
                ),
                alignment: Alignment.center,
                child: Text('Action', style: OSTypography.buttonPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Migration Guide

### From TacticalColors to OSColors

The legacy `TacticalColors` class has been deprecated. Use `OSColors` instead:

```dart
// Before (deprecated)
import '../../shared/theme/tactical_colors.dart';
color: TacticalColors.primary

// After
import '../../shared/theme/os.dart';
color: OSColors.primary
```

### Status Color Mappings

| Old Name | New Name |
|----------|----------|
| `statusOnline` | `success` |
| `statusInfo` | `info` |
| `statusOrange` | `orange` |
| `statusError` | `error` |

### Hardcoded Color Replacement

| Hardcoded | OS Token |
|-----------|----------|
| `Color(0xFF0A0A0C)` | `OSColors.background` |
| `Color(0xFF12121A)` | `OSColors.surface` |
| `Color(0xFF1C1C24)` | `OSColors.card` |
| `Color(0xFF242430)` | `OSColors.elevated` |
| `Color(0xFFE63946)` | `OSColors.primary` |
| `Colors.white` | `OSColors.textPrimary` |
| `Color(0xFFB8B8C8)` | `OSColors.textSecondary` |
| `Color(0xFF7A7A8A)` | `OSColors.textMuted` |

### Finding Violations

```bash
# Check for tactical_colors imports
grep -r "tactical_colors" frontend/lib --include="*.dart"

# Check for hardcoded colors
grep -r "Color(0x" frontend/lib --include="*.dart" | wc -l
```

---

## Status

**Design System Status**: Complete

- [x] Color tokens defined
- [x] Typography scale
- [x] Spacing system
- [x] Shadow presets
- [x] Motion/animation tokens
- [x] Theme integration
- [x] Documentation
- [x] Migration guide

Last updated: January 2025
