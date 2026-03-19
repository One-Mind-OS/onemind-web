# Frontend UX Requirements

## Overview

UX improvements needed to make OneMind OS feel as polished as Todoist, Things 3, and other best-in-class productivity apps.

---

## Quick Capture

**Current:** Full modal form for creating tasks
**Target:** Quick add bar at top of screen

### Requirements

```
┌─────────────────────────────────────────────────┐
│ + Add task...                           [Enter] │
└─────────────────────────────────────────────────┘
```

| Feature | Implementation |
|---------|----------------|
| **Always visible** | Sticky bar at top of tasks screen |
| **Keyboard shortcut** | `n` or `q` to focus quick add |
| **Inline parsing** | Parse date from text (see below) |
| **Project prefix** | `#ProjectName` sets project |
| **Pillar prefix** | `@hp` `@le` `@ge` sets pillar |
| **Priority prefix** | `!1` `!2` `!3` sets priority |
| **Expand to full** | Click expand icon → full modal |

### Natural Language Parsing Examples

```
"Review PR tomorrow" → due_date: tomorrow
"Call mom next Monday" → due_date: next Monday
"Buy groceries today @hp" → due_date: today, pillar: HP
"Ship feature #OneMind !1" → project: OneMind, priority: P1
```

---

## Natural Language Date Input

**Current:** Date picker modal
**Target:** Natural language parsing with smart suggestions

### Supported Patterns

| Input | Parsed Date |
|-------|-------------|
| `today` | Today |
| `tomorrow`, `tmrw` | Tomorrow |
| `monday`, `mon` | Next Monday |
| `next week` | +7 days |
| `next month` | +1 month |
| `in 3 days` | +3 days |
| `jan 15`, `1/15` | January 15 |
| `no date` | Clear date |

### UI Behavior

```
┌─────────────────────────────────────┐
│ Due: [tomorrow        ▼]            │
├─────────────────────────────────────┤
│ Today                               │
│ Tomorrow              ★ Suggested   │
│ Next Monday                         │
│ Next Week                           │
│ Pick a date...                      │
│ No date                             │
└─────────────────────────────────────┘
```

---

## Today View

**Current:** Filter chip
**Target:** Dedicated screen as default view

### Requirements

| Feature | Details |
|---------|---------|
| **Default view** | Today is the default when opening app |
| **Sections** | Overdue, Morning, Afternoon, Evening |
| **Time awareness** | Highlight current time section |
| **Progress bar** | Show tasks completed today |
| **Habits section** | Today's habits at bottom |
| **Empty state** | "All done for today!" celebration |

### Layout

```
┌──────────────────────────────────────┐
│ Today          Jan 29       4/12 ✓   │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━░░░░░░ │
├──────────────────────────────────────┤
│ OVERDUE (2)                    🔴    │
│ ○ Review Q4 report                   │
│ ○ Send invoice to client             │
├──────────────────────────────────────┤
│ MORNING                              │
│ ✓ Morning workout                    │
│ ○ Team standup @ 9:00                │
├──────────────────────────────────────┤
│ AFTERNOON                      ← Now │
│ ○ Code review for PR #123            │
│ ○ Write documentation                │
├──────────────────────────────────────┤
│ EVENING                              │
│ ○ Call mom                           │
├──────────────────────────────────────┤
│ HABITS                               │
│ ○ Read 30 mins                       │
│ ✓ Meditation                         │
└──────────────────────────────────────┘
```

---

## Upcoming View

**Current:** Missing
**Target:** Next 7 days view with clear date grouping

### Requirements

| Feature | Details |
|---------|---------|
| **Date groups** | Today, Tomorrow, Wed, Thu, Fri, Sat, Sun |
| **Week navigation** | Swipe/arrows to see next week |
| **Drag to reschedule** | Drag task between date groups |
| **Day summary** | Task count per day |
| **Calendar sync** | Show calendar events |

### Layout

```
┌──────────────────────────────────────┐
│ Upcoming                    Jan 29 → │
├──────────────────────────────────────┤
│ TODAY • Wed                     4    │
│ ○ Code review for PR #123            │
│ ○ Write documentation                │
├──────────────────────────────────────┤
│ TOMORROW • Thu                  2    │
│ ○ Team planning meeting              │
│ ○ Ship feature v2                    │
├──────────────────────────────────────┤
│ FRI • Jan 31                    1    │
│ ○ Weekly review                      │
├──────────────────────────────────────┤
│ SAT • Feb 1                     0    │
│ No tasks scheduled                   │
├──────────────────────────────────────┤
│ SUN • Feb 2                     0    │
│ Family Day 🌴                        │
└──────────────────────────────────────┘
```

---

## Subtasks

**Current:** Hidden in detail view
**Target:** Visible nested on task card

### Requirements

| Feature | Details |
|---------|---------|
| **Inline display** | Show subtasks collapsed under parent |
| **Progress indicator** | `2/5 subtasks` on parent |
| **Quick add** | `+` button to add subtask inline |
| **Indentation** | Visual indent for hierarchy |
| **Collapse/expand** | Toggle subtask visibility |

### Layout

```
┌──────────────────────────────────────┐
│ ○ Ship OneMind v2          2/5 ▾    │
│   ├─ ✓ Update database schema       │
│   ├─ ✓ Write API endpoints          │
│   ├─ ○ Build Flutter UI             │
│   ├─ ○ Write tests                  │
│   └─ ○ Deploy to production         │
│   + Add subtask...                   │
└──────────────────────────────────────┘
```

---

## Project Badge

**Current:** Missing from task list
**Target:** Show project badge on task card

### Requirements

| Feature | Details |
|---------|---------|
| **Badge style** | Colored pill with project emoji |
| **Position** | Right side of task title |
| **Click action** | Filter to project |
| **Color coding** | Match project color |

### Layout

```
┌──────────────────────────────────────┐
│ ○ Code review for PR #123            │
│   📦 OneMind                  !P2    │
├──────────────────────────────────────┤
│ ○ Buy groceries                      │
│   🏠 House              @HP   !P3    │
├──────────────────────────────────────┤
│ ○ Review Q4 finances                 │
│   💰 Wealth             @GE   !P1    │
└──────────────────────────────────────┘
```

---

## Keyboard Shortcuts

**Current:** None
**Target:** Full keyboard navigation for desktop

### Global Shortcuts

| Shortcut | Action |
|----------|--------|
| `n` / `q` | Quick add task |
| `g t` | Go to Today |
| `g u` | Go to Upcoming |
| `g p` | Go to Projects |
| `g h` | Go to Habits |
| `/` | Open search |
| `?` | Show shortcuts help |
| `Esc` | Close modal/cancel |

### Task List Shortcuts

| Shortcut | Action |
|----------|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `Enter` | Open task |
| `Space` | Toggle complete |
| `e` | Edit task |
| `#` | Change project |
| `p` | Change priority |
| `d` | Set due date |
| `Delete` | Delete task |
| `Tab` | Indent (make subtask) |
| `Shift+Tab` | Outdent |

### Task Detail Shortcuts

| Shortcut | Action |
|----------|--------|
| `Esc` | Close detail |
| `Enter` | Save changes |
| `d` | Focus due date |
| `n` | Add note |
| `s` | Add subtask |

---

## Implementation Priority

| Priority | Feature | Effort |
|----------|---------|--------|
| **P0** | Quick capture bar | 4h |
| **P0** | Today view | 6h |
| **P1** | Natural language dates | 8h |
| **P1** | Subtasks visible | 4h |
| **P1** | Project badge | 2h |
| **P2** | Upcoming view | 6h |
| **P2** | Keyboard shortcuts | 8h |

---

## Technical Notes

### Date Parsing Library

Recommend using `chrono` for Dart/Flutter:
- https://pub.dev/packages/chrono

Or build custom parser with regex patterns.

### State Management

Use existing Riverpod providers:
- `tasksProvider` - extend for today/upcoming filtering
- `projectsProvider` - for project badges

### Keyboard Handling

Use `Shortcuts` and `Actions` widgets:
```dart
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.keyN): AddTaskIntent(),
    LogicalKeySet(LogicalKeyboardKey.keyG, LogicalKeyboardKey.keyT): GoToTodayIntent(),
  },
  child: Actions(
    actions: {
      AddTaskIntent: CallbackAction(onInvoke: (_) => openQuickAdd()),
    },
    child: Focus(
      autofocus: true,
      child: ...,
    ),
  ),
)
```

---

## Related Files

- [frontend/lib/lifeos/features/tasks/](frontend/lib/lifeos/features/tasks/)
- [frontend/lib/lifeos/features/habits/](frontend/lib/lifeos/features/habits/)
- [frontend/lib/lifeos/providers/](frontend/lib/lifeos/providers/)
