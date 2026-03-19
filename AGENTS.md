# AGENTS.md

> Instructions for AI coding agents working on this repository. Kept in sync with `CLAUDE.md`.

---

## Project Overview

**OneMind Web** is a Next.js 16 AI command center — a full-stack platform for managing AI agents, chat sessions, missions, connectors, knowledge bases, and more. Forked from SwarmClaw, fully rebranded to OneMind.

| Field | Value |
|-------|-------|
| Framework | Next.js 16.1.7 (standalone output, webpack) |
| Language | TypeScript (strict) |
| UI | React 19, Tailwind CSS 4, Zustand 5, React Three Fiber |
| Storage | better-sqlite3 (55 tables), LangGraph for agents |
| npm package | `@onemind-os/onemind-ui` |
| GitHub repo | `One-Mind-OS/onemind-web` |
| CLI entry | `bin/onemind.js` |
| Docker image | `ghcr.io/one-mind-os/onemind-web` |

---

## Build & Test Commands

```bash
npm run dev              # Dev server on port 3456 (Turbopack)
npm run build:ci         # Production build (NEXT_DISABLE_ESLINT=1)
npm run test:cli         # CLI tests (Node test runner, 62 tests)
npm run test:openclaw    # OpenClaw protocol tests
npm run lint:baseline    # Lint gate (must pass before release)
```

---

## Deployment

**Production runs on `onemind-main` (`100.77.52.93` via Tailscale).**

- **Deploy path**: `/opt/onemind-web` on the server
- **Stack**: Docker Compose → single `onemind` service
- **Ports**: `3456` (HTTP) + `3457` (WebSocket)
- **Access**: Tailscale mesh only — `http://100.77.52.93:3456`
- **Auth**: Access key in `.env.local` on the server; auto-generated on first run
- **Data**: Persisted in `./data/` volume (SQLite DBs, uploads, logs)
- **Env config**: `.env.local` loaded via `env_file` in docker-compose (not volume-mounted)
- **Co-located with**: NATS, OmniDB (PostgreSQL+TimescaleDB+pgvector), n8n — all in `/opt/onemind/`

**Deploy commands** (on server):
```bash
cd /opt/onemind-web
git pull origin main
docker compose up -d --build
```

**Data dir must be owned by UID 1000** (`node` user inside container). If fresh: `chown -R 1000:1000 /opt/onemind-web/data`

---

## Key Rules

### Dev Server
- **NEVER kill the dev server (`npm run dev`, port 3456) without asking the user first.** Other agents may be running tests against it.

### Code Quality
- **Lint baseline is a release gate.** Run `npm run lint:baseline` before any production release.
- **Embrace TypeScript.** Never use `any` — use `unknown`, `Record<string, unknown>`, or define a proper interface.
- **Do not suppress lint rules.** Fix the underlying code instead.
- **Prefer simple architectures.** Straightforward over clever. Easy to read, debug, and delete.

### Commit Messages
- Never reference "Claude", "Anthropic", "Codex", "Co-Authored-By", or any AI tool in commit messages. Write as if a human authored the code.

### Testing
- **Always test with live agents** after changes to chat execution, streaming, plugins, connectors, or agent-facing code.
- **Lock in working behavior with tests.** Once something works, add regression tests to keep it working.

---

## Architecture Essentials

### Chat Execution Pipeline
`enqueueSessionRun()` is the **only** correct entry point for running a chat turn. Never call `executeSessionChatTurn()` directly — it bypasses queuing, dedup, coalescing, and execution locking.

### Zustand Stores
Always use `setIfChanged` for async loaders (`src/stores/set-if-changed.ts`). Raw `set()` triggers re-renders even when data hasn't changed.

### HMR Singletons
Never use bare `const x = new Map()` at module scope. Use `hmrSingleton<T>(key, init)` from `src/lib/shared-utils.ts` — it survives HMR reloads.

### Storage Pattern
Load-Modify-Save with `saveCollection()`. For single items use `upsertCollectionItem()`. Add normalization defaults for new fields in `storage-normalization.ts`.

### Extensions, Not Plugins
The codebase migrated from "plugins" to "extensions." Use `extensions` in all new code.

### Adding Providers
Most new providers are OpenAI-compatible. Patch `apiEndpoint` and delegate to `streamOpenAiChat`. Add defaults to `setup-defaults.ts`.

---

## UX Philosophy

- **Progressive disclosure** — hide power-user controls behind expandable sections. Use `AdvancedSettingsSection`.
- **Smart defaults** — every field should have a sensible default. Source of truth: `setup-defaults.ts`.
- **Contextual help** — use `HintTip` (the `?` tooltip) next to non-obvious fields.
- **Never leave the user stuck** — link to where they get API keys, show setup steps inline.

---

## Theme System

CSS uses a `--neutral-tint` single-knob approach. Theme tokens in `src/app/globals.css`:
- `--sp-*` — Solarpunk palette (primary, path-specific, gradients, semantic)
- `--td-*` — Tactical Dark (Zeus Red + Cyan)
- `--ts-*` — Tactical Solarpunk (Amber + Moss)
- `--cat-*` — Agent category colors

Tokens are defined but **not yet wired to components** — applying the Solarpunk theme to UI is a future task.

---

## Intentionally Kept SwarmClaw References

These are internal/non-user-facing and must NOT be renamed (would break deployments):
- HMR singleton keys (`__swarmclaw_rate_limit__`, `__swarmclaw_shutdown_state__`)
- Custom events (`swarmclaw:open-search`, `swarmclaw:scroll-bottom`, `swarmclaw:settings-focus`)
- Environment variables (`SWARMCLAW_HOME`, `SWARMCLAW_BUILD_MODE`, `SWARMCLAW_URL`, etc.)
- Test fixture data (`swarmclawai/swarmclaw` repo examples)
- Platform identifiers in types (`'swarmclaw'`, `'swarmclaw-site'`)

---

## Gamification System (Extracted, Not Yet Built)

Constants in `src/config/constants.ts`, types in `src/types/index.ts` (end of file). Specs in:
- `doc/features/GAMIFICATION-SYSTEM.md`
- `doc/features/GAME-VISUALIZATION.md`

No UI exists yet — types and constants are ready for implementation.

---

## Documentation

All design, architecture, feature, and product docs are in `doc/`. See `doc/README.md` for the full index.

**Key docs:**
- `doc/design/theme/SOLARPUNK-THEME.md` — Color palette, gradients, nav remap
- `doc/features/MENTION-SYSTEM.md` — @type:entity syntax (⚠️ partial)
- `doc/features/NOTIFICATION-SYSTEM.md` — Multi-channel routing (⚠️ partial)
- `doc/features/UNIFIED-INBOX-SYSTEM.md` — Task + approval hub (⚠️ partial)
- `doc/architecture/AG-UI-INTEGRATION.md` — API contracts and data flow
- `doc/product/VISION.md` — The Legacy vision
- `doc/product/MASTER_BUILD_PLAN.md` — Full stack architecture plan

---

## Release Checklist

1. Fix lint blockers → `npm run lint:baseline:update`
2. Verify storage normalization for renamed/removed fields
3. Version bump in `package.json`
4. Update README release notes
5. Register new API routes in CLI manifest
6. Run CI: `npm run lint:baseline && npm run build:ci && npm run test:cli && npm run test:openclaw`
7. Commit and wait for user confirmation before pushing

---

## Related Repositories

- **onemind-os** — Monorepo with core OS stack (NATS, OmniDB docker-compose, codex vault)
- **onemind-codex-live** — Standalone Codex vault (knowledge management, CODEX method)
