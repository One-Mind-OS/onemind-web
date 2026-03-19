# Game Visualization Reference

> Extracted from Flutter reference implementation (`flutter-archive/game/`)

---

## Overview

The game visualization renders an interactive system topology graph showing agents, infrastructure, tools, and integrations as connected nodes. It supports both tactical (straight lines, cyan) and solarpunk (bezier curves, amber) visual styles.

---

## Node Types & Colors

| Type | Color | Hex | Role |
|------|-------|-----|------|
| Core | Green | `#4ADE80` | Central hub node |
| Infrastructure | Cyan | `#06B6D4` | NATS, Redis, API, PostgreSQL |
| Agent | Green | `#4ADE80` | Orchestrator, Researcher, Coder, Analyst |
| Tool | Orange | `#F97316` | External tool integrations |
| Integration | Purple | `#8B5CF6` | Third-party service connections |
| Sensor | Blue | `#3B82F6` | IoT / monitoring devices |

### Status Colors

| Status | Color | Hex |
|--------|-------|-----|
| Active | Green | `#22C55E` |
| Offline | Gray | `#6B7280` |
| Alert | Red | `#EF4444` |

---

## Layout System

Nodes are arranged in concentric orbits around a central "Core" node:

```
┌─────────────────────────────────────┐
│         Outer Orbit (350px)         │
│  ┌─────────────────────────────┐    │
│  │    Inner Orbit (200px)      │    │
│  │  ┌───────────────────┐     │    │
│  │  │     [CORE]        │     │    │
│  │  │                   │     │    │
│  │  └───────────────────┘     │    │
│  │  NATS  PostgreSQL  Redis   │    │
│  │       FastAPI              │    │
│  └─────────────────────────────┘    │
│  Orchestrator  Researcher           │
│       Coder   Analyst               │
└─────────────────────────────────────┘
```

- **Inner orbit (200px)**: Infrastructure machines
- **Outer orbit (350px)**: Agents (top half), Devices (bottom half), Locations (perimeter)

---

## Connection Styles

### Tactical Theme
- **Straight lines** between nodes
- Flow dots: cyan palette (`#00D9FF`, `#4ECDC4`, `#00A8CC`, `#33E0FF`)

### Solarpunk Theme
- **Bezier curves** (organic, flowing)
- Flow dots: amber palette (`#FFB703`, `#FFC933`, `#FFC300`, `#FFAA00`, `#FFD166`)

### Animation
- 3 animated dots travel along each active connection
- Active connections: 0.4 opacity
- Inactive connections: 0.05 opacity

---

## Particle System

| Setting | Value |
|---------|-------|
| Spawn rate | 1 particle every 300ms |
| Max particles | 50 |
| Burst on event (add/remove) | 10–20 particles |
| Burst on critical alert | 15–20 particles |

### Particle Palettes

**Tactical**: `#00D9FF`, `#4ECDC4`, `#00A8CC`, `#33E0FF`
**Solarpunk**: `#FFB703`, `#FFC933`, `#FFC300`, `#FFAA00`, `#FFD166`

---

## Audio System

| Event | Trigger |
|-------|---------|
| `alert` | Health drops >20% AND below 30% |
| `warning` | Health drops >20% AND still above 30% |
| `success` | Health rises >20% AND above 80% |
| `click` | UI interactions (0.5× volume) |
| `connect` | Asset comes online |
| `disconnect` | Asset goes offline |

---

## Demo Topology

When no real assets are connected, show these default nodes:

**Infrastructure (inner ring)**:
- NATS Bus
- PostgreSQL
- FastAPI
- Redis Cache

**Agents (outer ring)**:
- Orchestrator
- Researcher
- Coder
- Analyst

---

## Implementation

- **Constants**: `src/config/constants.ts` — `GAME_NODE_COLORS`, `GAME_STATUS_COLORS`, `GAME_LAYOUT`, `PARTICLE_CONFIG`, `PARTICLE_PALETTES`, `AUDIO_EVENTS`, `AUDIO_HEALTH_RULES`
- **Existing office visualization**: `src/office/` has a 2D SVG floor plan and 3D R3F scene that could incorporate these patterns

---

*Extracted from `_archive/design-reference/flutter-archive/game/`. See constants.ts for all color and config values.*
