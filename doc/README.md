# OneMind Web — Documentation Index

> All design, architecture, feature, and product documentation for the OneMind Web project.

---

## Architecture

| Document | Description |
|----------|-------------|
| [AG-UI-INTEGRATION](architecture/AG-UI-INTEGRATION.md) | How the UI connects to the Agno backend — API contracts and data flow |
| [AGNO_BACKEND_INTEGRATION](architecture/AGNO_BACKEND_INTEGRATION.md) | Backend integration patterns and service boundaries |
| [CORTEX_SCREEN_INTEGRATION](architecture/CORTEX_SCREEN_INTEGRATION.md) | Cortex screen data mapping and display logic |
| [ONEMIND-INTERFACES](architecture/ONEMIND-INTERFACES.md) | All communication interfaces (web, mobile, desktop, CLI, wearables) |
| [UI-ARCHITECTURE-DECISION](architecture/UI-ARCHITECTURE-DECISION.md) | Decision record: tactical UI vs chat-first (tactical won) |
| [UI-ARCHITECTURE-SUMMARY](architecture/UI-ARCHITECTURE-SUMMARY.md) | High-level architecture overview |
| [UI-ARCHITECTURE-VISUAL](architecture/UI-ARCHITECTURE-VISUAL.md) | Visual architecture diagrams |
| [UI-DESIGN-PLAN](architecture/UI-DESIGN-PLAN.md) | Tech stack decisions (Next.js, shadcn/ui, Tailwind) |
| [UNIFIED-INTERFACE-ARCHITECTURE](architecture/UNIFIED-INTERFACE-ARCHITECTURE.md) | End-to-end interface architecture |

## Design

| Document | Description |
|----------|-------------|
| [DESIGN_SYSTEM](design/DESIGN_SYSTEM.md) | Component design system — patterns, tokens, spacing |
| [FRONTEND-UX-REQUIREMENTS](design/FRONTEND-UX-REQUIREMENTS.md) | UX requirements: quick capture, glanceability, flow |
| [UI_PLAN](design/UI_PLAN.md) | Product-level UI planning and priorities |
| [UI_WIREFRAMES](design/UI_WIREFRAMES.md) | Complete screen taxonomy and wireframe layouts |

### Theme (Solarpunk)

| Document | Description |
|----------|-------------|
| [SOLARPUNK-THEME](design/theme/SOLARPUNK-THEME.md) | **Primary** — Full color palette, gradients, icons, nav remap |
| [THEME_COLOR_GUIDE](design/theme/THEME_COLOR_GUIDE.md) | Color semantics and usage patterns |
| [SOLARPUNK_TECH](design/theme/SOLARPUNK_TECH.md) | Technical implementation of Solarpunk theme |
| [TACTICAL_SOLARPUNK_THEME](design/theme/TACTICAL_SOLARPUNK_THEME.md) | Tactical variant of the Solarpunk theme |
| [HOW_TO_SWITCH_THEMES](design/theme/HOW_TO_SWITCH_THEMES.md) | Theme switching mechanism |

## Features

| Document | Description | Status |
|----------|-------------|--------|
| [CHAT_FEATURES_SPEC](features/CHAT_FEATURES_SPEC.md) | 7-platform competitive analysis (Claude, ChatGPT, Grok, etc.) | ✅ Mostly implemented |
| [MENTION-SYSTEM](features/MENTION-SYSTEM.md) | @type:entity syntax, autocomplete, entity resolution | ⚠️ Partial (basic highlights only) |
| [NOTIFICATION-SYSTEM](features/NOTIFICATION-SYSTEM.md) | Multi-channel routing, awareness modes, escalation | ⚠️ Partial (in-app only) |
| [NAVIGATION-SYSTEM](features/NAVIGATION-SYSTEM.md) | 6-section nav with Solarpunk remap | ⚠️ Routes exist, Solarpunk styling pending |
| [UNIFIED-INBOX-SYSTEM](features/UNIFIED-INBOX-SYSTEM.md) | Task + notification + approval hub | ⚠️ Connector inbox only |
| [GAMIFICATION-SYSTEM](features/GAMIFICATION-SYSTEM.md) | XP, levels, achievements, skill tree, daily ops | ✅ Types + constants extracted |
| [GAME-VISUALIZATION](features/GAME-VISUALIZATION.md) | Node topology graph, particles, audio events | ✅ Constants extracted |
| [NOTE-TOOL](features/NOTE-TOOL.md) | Note capture tool specification | ❌ Not implemented |
| [ONEMIND_SUPERPOWER_CHAT_ANALYSIS](features/ONEMIND_SUPERPOWER_CHAT_ANALYSIS.md) | Deep chat UX analysis and power-user workflows | Reference |

## Product & Vision

| Document | Description |
|----------|-------------|
| [VISION](product/VISION.md) | The Legacy vision — personal AI companion |
| [MASTER_BUILD_PLAN](product/MASTER_BUILD_PLAN.md) | Full stack architecture plan |
| [MASTER-FEATURE-MATRIX](product/MASTER-FEATURE-MATRIX.md) | Feature scope across all paths (HP/LE/GE/Commons) |
| [ONEMIND-UNIFIED-PRODUCT](product/ONEMIND-UNIFIED-PRODUCT.md) | Unified product combining Relevance AI + Pipedream + Motion |
| [ONEMIND-MOBILE-FIRST-VISION](product/ONEMIND-MOBILE-FIRST-VISION.md) | Mobile-first design and platform strategy |
| [WORKFLOW-AUTONOMY-ROADMAP](product/WORKFLOW-AUTONOMY-ROADMAP.md) | Automation and workflow execution roadmap |
| [LIFE-OS-BUILD-PLAN](product/LIFE-OS-BUILD-PLAN.md) | Homestead automation (FarmBot, sensors, robotics) |
| [EVOLUTION-SUMMARY](product/EVOLUTION-SUMMARY.md) | Product evolution history |
| [THE_POTENTIAL](product/THE_POTENTIAL.md) | Vision statement |
| [LEGACY-MASTERPLAN](product/LEGACY-MASTERPLAN.md) | ⚠️ Old Letta stack — historical reference only |

## Reference

| Resource | Description |
|----------|-------------|
| [prototypes/](reference/prototypes/) | React JSX educational prototypes (explainer, deep-dive, unified-session) |
| [assets/](assets/) | Provider logos and screenshots |
