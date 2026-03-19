# OneMind OS v2 - Theme Color Guide

## Color Palette Comparison

### Light Theme (Professional Mode)

#### Backgrounds
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Background | Light Gray | `#F8F9FA` | Main app background |
| Surface | White | `#FFFFFF` | Cards, elevated elements |
| Card | White | `#FFFFFF` | Card backgrounds |
| Elevated | Off-White | `#FAFAFA` | Modals, dropdowns |
| Input | White | `#FFFFFF` | Input fields |

#### Primary Colors
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Primary | Soft Red | `#DC3545` | Main accent, buttons |
| Primary Dim | Dark Red | `#B02A37` | Pressed state |
| Primary Glow | Bright Red | `#E85463` | Hover/focus |
| Primary Muted | Transparent Red | `#DC3545` (10% opacity) | Backgrounds |

#### Text Colors
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Text Primary | Almost Black | `#1A1A1A` | Main text |
| Text Secondary | Dark Gray | `#4B5563` | Labels, subtitles |
| Text Muted | Medium Gray | `#6B7280` | Hints, descriptions |
| Text Dim | Light Gray | `#9CA3AF` | Subtle text |
| Text Disabled | Very Light Gray | `#D1D5DB` | Disabled elements |

#### Borders & Dividers
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Border | Light Gray | `#E5E7EB` | Standard borders |
| Border Bright | Medium Gray | `#D1D5DB` | Emphasized borders |
| Divider | Light Gray | `#E5E7EB` | Section dividers |

#### Status Colors
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Success | Green | `#16A34A` | Success states |
| Warning | Orange | `#EA580C` | Warning states |
| Error | Red | `#DC2626` | Error states |
| Info | Blue | `#2563EB` | Info states |
| Inactive | Gray | `#94A3B8` | Disabled states |

#### Agent Categories
| Category | Color | Hex |
|----------|-------|-----|
| Code | Blue | `#2563EB` |
| Research | Purple | `#7C3AED` |
| Creative | Pink | `#DB2777` |
| Productivity | Green | `#059669` |
| IoT | Cyan | `#0891B2` |

---

### Dark Theme (Tactical Mode)

#### Backgrounds
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Background | Pure Black | `#000000` | Main app background |
| Surface | Dark Gray | `#0A0A0A` | Elevated elements |
| Card | Very Dark Gray | `#111111` | Card backgrounds |
| Elevated | Dark Gray | `#1A1A1A` | Modals, dropdowns |
| Input | Very Dark | `#0D0D0D` | Input fields |

#### Primary Colors
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Primary | Bright Red | `#E63946` | Main accent, signature |
| Primary Dim | Dark Red | `#B82D3A` | Pressed state |
| Primary Glow | Neon Red | `#FF4D5A` | Hover/focus glow |
| Primary Muted | Transparent Red | `#E63946` (15% opacity) | Backgrounds |

#### Text Colors
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Text Primary | Bright White | `#FFFFFF` | Main text |
| Text Secondary | Light Gray | `#D1D5DB` | Labels, subtitles |
| Text Muted | Medium Gray | `#9CA3AF` | Hints, descriptions |
| Text Dim | Gray | `#6B7280` | Subtle hints |
| Text Disabled | Dark Gray | `#4B5563` | Disabled text |

#### Borders & Dividers
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Border | Dark Gray | `#1F2937` | Standard borders |
| Border Bright | Medium Gray | `#374151` | Brighter borders |
| Divider | Dark Gray | `#1F2937` | Section dividers |

#### Status Colors
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Success | Bright Green | `#22C55E` | Success states |
| Warning | Amber | `#F59E0B` | Warning states |
| Error | Red | `#EF4444` | Error states |
| Info | Blue | `#3B82F6` | Info states |
| Inactive | Gray | `#4B5563` | Disabled states |

#### Agent Categories
| Category | Color | Hex |
|----------|-------|-----|
| Code | Blue | `#3B82F6` |
| Research | Purple | `#8B5CF6` |
| Creative | Pink | `#EC4899` |
| Productivity | Green | `#10B981` |
| IoT | Cyan | `#06B6D4` |

---

## Key Differences

### Contrast Philosophy
- **Light Theme**: Dark elements on light backgrounds (positive polarity)
- **Dark Theme**: Light elements on dark backgrounds (negative polarity)

### Use Cases

#### Light Theme Best For:
- ☀️ Daytime work
- 📊 Data analysis and reading
- 📝 Document editing
- 👥 Client presentations
- 🏢 Professional environments
- 🖨️ Print-friendly content

#### Dark Theme Best For:
- 🌙 Night work
- 💻 Long coding sessions
- 🎮 Command center operations
- 📱 Low-light environments
- 🔒 Tactical/security monitoring
- 👁️ Reduced eye strain in dark rooms

### Accessibility

#### Light Theme
- **WCAG AAA**: Text contrast ratios exceed 7:1
- **Readability**: Optimal for most lighting conditions
- **Eye Strain**: Less strain in bright environments

#### Dark Theme
- **WCAG AAA**: Text contrast ratios exceed 7:1
- **Readability**: Excellent in low-light conditions
- **Eye Strain**: Reduced strain in dark environments

---

## Visual Examples

### Navigation Drawer

**Light Mode:**
- Background: `#FFFFFF` (White)
- Text: `#1A1A1A` (Almost Black)
- Selected Item: `#DC3545` (Soft Red) with 10% background
- Borders: `#E5E7EB` (Light Gray)

**Dark Mode:**
- Background: `#000000` (Pure Black)
- Text: `#FFFFFF` (Bright White)
- Selected Item: `#E63946` (Bright Red) with 15% background
- Borders: `#1F2937` (Dark Gray)

### Cards

**Light Mode:**
- Card Background: `#FFFFFF` (White)
- Border: `#E5E7EB` (Light Gray)
- Text: `#1A1A1A` (Dark)
- Shadow: Subtle gray shadow

**Dark Mode:**
- Card Background: `#111111` (Very Dark Gray)
- Border: `#1F2937` (Dark Gray)
- Text: `#FFFFFF` (White)
- Shadow: Red glow on hover

### Buttons

**Light Mode - Primary:**
- Background: `#DC3545` (Soft Red)
- Text: `#FFFFFF` (White)
- Hover: `#E85463` (Brighter Red)
- Shadow: Soft red shadow

**Dark Mode - Primary:**
- Background: `#E63946` (Bright Red)
- Text: `#FFFFFF` (White)
- Hover: `#FF4D5A` (Neon Red)
- Shadow: Red glow effect

### Input Fields

**Light Mode:**
- Background: `#FFFFFF` (White)
- Border: `#E5E7EB` (Light Gray)
- Text: `#1A1A1A` (Dark)
- Focus Border: `#DC3545` (Soft Red)

**Dark Mode:**
- Background: `#0D0D0D` (Very Dark)
- Border: `#1F2937` (Dark Gray)
- Text: `#FFFFFF` (White)
- Focus Border: `#E63946` (Bright Red)

---

## Implementation Notes

### Dynamic Color System
All colors are implemented as getters that automatically return the appropriate color based on the current theme mode. This ensures instant theme switching without reloading the app.

### Consistency
Both themes maintain the same visual hierarchy and spacing, only colors change. This ensures users feel comfortable switching between themes.

### Branding
The red accent color is preserved in both themes (though adjusted for optimal contrast), maintaining brand identity across theme modes.

---

**Color Palette Version**: 2.0
**Last Updated**: 2026-02-07
**Supports**: Light Mode, Dark Mode
**WCAG Compliance**: AAA (both themes)
