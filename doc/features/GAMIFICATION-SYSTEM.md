# Gamification System

> Extracted from Flutter reference implementation (`flutter-archive/providers/game_provider.dart`)

---

## Overview

OneMind uses a gamification layer to encourage daily engagement, skill progression, and system exploration. The system tracks XP, levels, achievements, a skill tree, daily ops, and missions.

## Game State

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `level` | number | 1 | Current player level |
| `xp` | number | 0 | Total experience points |
| `streak` | number | 0 | Consecutive login days |
| `gold` | number | 1000 | In-app currency |
| `audioEnabled` | boolean | true | Sound effects toggle |

### Level Progression

```
xpToNextLevel = level × 1000
levelProgress = (xp % 1000) / xpToNextLevel
```

### Rank System

| Min Level | Rank |
|-----------|------|
| 1 | Operative |
| 10 | Commander |
| 20 | Overseer |

---

## XP Rewards

| Action | XP |
|--------|----|
| Complete a daily op | +50 |
| Complete a mission | +200 |
| Achievement unlock | Variable (50–1000) |

Level-up triggers when `currentLevelXP >= xpToNextLevel`.

---

## Achievements

| ID | Title | Icon | Category | XP | Unlock Condition |
|----|-------|------|----------|----|------------------|
| a1 | First Login | 🔑 | system | 50 | Session start |
| a2 | Task Master | ✅ | productivity | 200 | 10 daily ops completed |
| a3 | Deep Diver | 🗺️ | exploration | 150 | 5+ screens visited |
| a4 | Commander | ⭐ | mastery | 1000 | Reach level 10 |
| a5 | Agent Operator | 🤖 | agents | 100 | Deploy first agent |

**Categories**: `system`, `productivity`, `exploration`, `mastery`, `agents`

---

## Skill Tree

| ID | Name | Icon | Branch | Level Req | Description |
|----|------|------|--------|-----------|-------------|
| s1 | Voice Command | 🗣️ | command | 1 | Unlock voice-based interactions |
| s2 | Entity Search | 🔍 | intel | 2 | Advanced search filters for assets |
| s3 | NATS Bridge | 🌉 | engineering | 5 | Direct NATS message bus access |
| s4 | Quick Tasks | ⚡ | combat | 3 | Create tasks from chat interface |
| s5 | Asset Tracking | 📍 | exploration | 1 | Real-time GPS tracking on world map |

**Branches**: `command`, `intel`, `engineering`, `combat`, `exploration`

Skills unlock when `player.level >= skill.levelRequired` and all `prerequisites` are met.

---

## Daily Ops

Recurring tasks with streak tracking.

| Field | Type | Description |
|-------|------|-------------|
| `schedule` | string | Cron-like schedule ("Daily 09:00") |
| `streak` | number | Consecutive completions |
| `completedToday` | boolean | Reset daily |
| `xpReward` | number | Default 100 |
| `creditsReward` | number | Default 50 |

---

## Missions

Goal-oriented multi-step tasks.

| Field | Type | Description |
|-------|------|-------------|
| `difficulty` | easy/medium/hard/expert | Affects rewards |
| `objectives` | string[] | Checklist items |
| `progress` | 0.0–1.0 | Completion percentage |
| `xpReward` | number | Default 500 |
| `creditsReward` | number | Default 200 |

---

## Implementation

- **Types**: `src/types/index.ts` — `Achievement`, `SkillNode`, `DailyOp`, `GameMission`, `GameState`
- **Constants**: `src/config/constants.ts` — `XP_CONFIG`, `RANKS`, `DEFAULT_ACHIEVEMENTS`, `DEFAULT_SKILL_TREE`
- **Persistence**: localStorage keys — `level`, `xp`, `streak`, `last_login`, `audio_enabled`, `dark_mode`

---

*Extracted from `_archive/design-reference/flutter-archive/`. See `src/config/constants.ts` for all default data.*
