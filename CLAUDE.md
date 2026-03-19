# CLAUDE.md

### Keeping Instructions in Sync
- **`CLAUDE.md` and `AGENTS.md` must stay in sync.** When you add, edit, or remove a rule in one file, apply the same change to the other. They contain the same project guidelines — one for Claude Code, one for other coding agents.

### Dev Server
- **NEVER kill the dev server (`npm run dev`, port 3456) without asking the user first.** The user is often actively working against it, and other agents may be running tests against it. Always confirm before stopping, restarting, or killing the dev server process.

### Code Quality

**Lint baseline is a release gate.** Run `npm run lint:baseline` before any production release. The baseline must pass — no net-new lint fingerprints. If you fix existing violations, run `npm run lint:baseline:update` to lock in the improvement.

**Embrace TypeScript and the type system.** Use proper types, interfaces, and generics. Never use `any` — use `unknown`, `Record<string, unknown>`, or define a proper interface. The type system is there to catch bugs at compile time; circumventing it defeats the purpose.

**Lint rules exist to protect us.** Do not suppress, disable, or work around lint rules. Fix the underlying code instead. If a rule is genuinely wrong for the project, change the rule in the lint config with a clear justification — but this should be rare. The default is to fix the code, not silence the linter.

### Architecture

**Prefer simple, maintainable, reliable architectures.** Choose the straightforward approach over the clever one. Code that is easy to read, easy to debug, and easy to delete is better than code that is abstract, configurable, or "elegant." Avoid premature abstraction — three similar lines are better than a premature helper. Build for the current requirement, not hypothetical future ones.

### Commit Messages
- Never reference "Claude", "Anthropic", "Codex", "Co-Authored-By", or any AI tool in commit messages. Write commit messages as if a human authored the code.

### Testing

**Always test with live agents.** After making changes to chat execution, streaming, plugins, connectors, or any agent-facing code path, verify the work by running a live agent chat on the platform. Unit tests and type checks are necessary but not sufficient — the real test is whether an agent can actually hold a conversation, use its plugins, and produce correct results through the running application.

**Lock in working behavior with tests.** When a feature or fix is confirmed working — whether by user verification, live agent testing, or manual QA — add regression tests (frontend and/or backend as appropriate) to prevent it from breaking later. The goal is to ratchet forward: once something works, it stays working. Don't skip this step just because the fix was small or the feature seems simple. A quick unit test today saves a painful debugging session tomorrow.

### UX Philosophy

OneMind UI serves non-technical users alongside power users. Every UI surface should follow these principles:

**Progressive disclosure.** Hide power-user controls behind expandable sections — don't dump every option on screen at once. Use `AdvancedSettingsSection` (`src/components/shared/advanced-settings-section.tsx`) for collapsible expert panels (routing config, runtime behavior, overrides). Default state is collapsed.

**Smart defaults — never leave blanks.** Every field that can have a sensible default should have one. `setup-defaults.ts` (`src/lib/setup-defaults.ts`) is the single source of truth for provider defaults, starter agent kits, `keyUrl`/`keyLabel` pairs, and default model selections. When adding a new provider or agent preset, add its defaults there — don't scatter magic values across components. `randomSoul()` (`src/lib/soul-suggestions.ts`) provides personality suggestions so the soul field is never empty.

**Contextual help.** Use `HintTip` (`src/components/shared/hint-tip.tsx`) — the `?` tooltip component — next to any field that isn't self-explanatory. For connector config fields, add entries to `FIELD_HINTS` in `connector-sheet.tsx`. Multi-step setup guides (Discord developer portal, Slack app creation, Telegram BotFather, etc.) include exact URLs so users don't have to hunt for them.

**Never leave the user stuck.** If a form requires an API key, link directly to where they get one (`keyUrl` in `setup-defaults.ts`). If a connector needs setup steps, show them inline with clickable links. Error states should say what went wrong and what to do next.

### Zustand Store Updates

**Always use `setIfChanged` for async loaders.** Every async loader that fetches data from the API and writes it to the store must use `setIfChanged` (`src/stores/set-if-changed.ts`) instead of raw `set()`. The API always returns fresh object references, so raw `set()` triggers re-renders in every subscribed component even when the data hasn't changed. `setIfChanged` keeps a JSON fingerprint and skips the write if nothing changed.

```ts
// Wrong — causes render cascade on every poll
set({ agents: freshAgents })

// Right — only triggers re-renders when data actually changed
setIfChanged(set, 'agents', freshAgents)
```

After local mutations (optimistic updates, removes), call `invalidateFingerprint(key)` so the next loader write goes through.

### Adding Providers

**Most new providers are OpenAI-compatible.** Don't write a new streaming handler from scratch. Instead, patch the session's `apiEndpoint` and delegate to `streamOpenAiChat` (`src/lib/providers/openai.ts`). This is how google, deepseek, groq, together, mistral, xai, fireworks, nebius, deepinfra, and all custom providers work — each one is a thin wrapper that sets the base URL and calls `streamOpenAiChat({ ...opts, session: patchedSession })`.

When adding a new provider:
1. Add an entry in the provider registry (`src/lib/providers/index.ts`) that patches the endpoint and delegates to `streamOpenAiChat`
2. Add defaults to `setup-defaults.ts` — display name, `keyUrl`, `keyLabel`, default model, description
3. Only write a custom handler if the provider's API is genuinely incompatible with the OpenAI chat completions format

### Chat Execution Pipeline

**`enqueueSessionRun()` is the only correct entry point for running a chat turn.** Never call `executeSessionChatTurn()` directly — it bypasses queuing, dedup, coalescing, and execution locking.

The pipeline (`src/lib/server/runtime/session-run-manager.ts`):
1. **Dedup** — duplicate requests with the same `dedupeKey` are dropped
2. **Collect-mode coalescing** — rapid messages within a 1500ms window are merged into a single turn (prevents multiple LLM calls when a user sends several messages quickly)
3. **Heartbeat preemption** — a user-initiated chat aborts any running heartbeat turn for that session
4. **Execution lock** — only one turn runs per session at a time; others queue

Connectors, heartbeat, scheduler, and the chat API all go through `enqueueSessionRun()`. If you're adding a new caller, use it too.

### `hmrSingleton` for Module-Level State

**Never use bare `const x = new Map()` at module scope.** Next.js HMR re-executes the module on save, wiping the state. Use `hmrSingleton<T>(key, init)` from `src/lib/shared-utils.ts` instead — it attaches to `globalThis` and survives reloads.

```ts
// Wrong — lost on HMR reload
const running = new Map<string, RunState>()

// Right — survives HMR
const running = hmrSingleton('myFeature_running', () => new Map<string, RunState>())
```

**Backfilling new fields:** When you add a field to an existing `hmrSingleton` object, the initializer won't re-run (the key already exists on `globalThis`). Apply defaults at the usage site or add a migration check after the `hmrSingleton` call.

### Terminal Tool Boundaries

**Some tool completions force-exit the agent loop immediately.** Code that runs after tool execution (post-tool hooks, continuation logic) will not run for terminal tools. If you add a new tool or post-execution logic, you need to know which tools are terminal.

Three boundary kinds:
- **`memory_write`** — memory persistence tools; loop exits after successful write
- **`durable_wait`** — tools that block on external input (e.g., approval gates); loop exits to avoid holding resources
- **`context_compaction`** — context window management; loop exits to restart with compacted context

Resolved in `resolveSuccessfulTerminalToolBoundary()` (`src/lib/server/chat-execution/chat-streaming-utils.ts`). Only mark a new tool as terminal if it genuinely needs to end the turn — most tools should not be terminal.

### Storage: Load-Modify-Save

**`saveCollection()` silently blocks bulk deletes.** If the save would delete more rows than it upserts, the guard prevents it and logs a warning. This protects against accidentally wiping a collection by saving a partial record set.

The correct pattern:
1. **Load all** records from the collection
2. **Modify** the in-memory array (add, update, or remove items)
3. **Save all** back with `saveCollection()`

For single-item updates, use `upsertCollectionItem()` instead — it doesn't trigger the bulk-delete guard.

**Normalization on load:** `storage-normalization.ts` auto-migrates records when they're loaded, applying default values for new fields. When you add a new field to a stored type, add its default to the normalization function — don't rely on `undefined` checks scattered across the codebase.

### Preparing a Release

When preparing a new version release, follow this checklist in order:

1. **Fix lint blockers**: run `npx eslint <changed-files>` to catch issues. Fix them, then run `npm run lint:baseline:update` to lock in the new count.
2. **Verify storage normalization**: if any stored type fields were renamed or removed, confirm `storage-normalization.ts` migrates old data on load. Add normalization if missing.
3. **Version bump**: update `"version"` in `package.json`.
4. **Update README release notes**: add a new `### vX.Y.Z Highlights` section above the previous version in the `## Release Notes` block in `README.md`. Include concise bullet points for each notable change.
5. **Update site docs release notes**: if a docs site exists, add a new `## vX.Y.Z (date)` entry at the top of the release notes with `### Highlights` and `### Upgrade Guidance` subsections.
6. **Register new API routes in CLI**: if new API routes were added, add them to the CLI manifest in `src/cli/index.js` (and `src/cli/spec.js` if applicable) so the route-coverage test passes.
7. **Run CI validation** (all must pass):
   - `npm run lint:baseline` — lint gate
   - `NODE_ENV=production npm run build:ci` — production build
   - `npm run test:cli` — CLI tests
   - `npm run test:openclaw` — OpenClaw tests
8. **Commit**: stage all changes and commit with a release message (e.g., `Release v1.1.6`). Do not push until the user confirms.

### Extensions, Not Plugins

**The codebase has fully migrated from "plugins" to "extensions."** Use `extensions` in all new code — variable names, function signatures, interfaces, UI copy.

- **Type names:** `Extension`, `ExtensionHooks`, `ExtensionMeta` (not `Plugin`, `PluginHooks`)
- **Server module:** `src/lib/server/extensions.ts` (not `plugins.ts` — deleted)
- **Storage directory:** `data/extensions/` (not `data/plugins/`)
- **Session field:** `session.extensions` (not `session.plugins`)

Legacy `data/plugins/` files are auto-migrated to `data/extensions/` on first access. Deprecated aliases exist for backward compatibility but must not be used in new code.

### OneMind-Specific Notes

- **OpenClaw is the primary provider.** OneMind UI connects to the OpenClaw gateway for agent management, chat, and real-time events. Other providers remain available for direct LLM access.
- **Office visualization** lives in `src/office/` — ported from the standalone onemind-office repo. It contains its own gateway layer, Zustand store, 2D SVG floor plan, 3D R3F scene, and i18n (zh/en).
- **Upstream**: This codebase is forked from SwarmClaw. The SwarmClaw upstream remote is tracked on the `upstream-latest` branch for cherry-picking improvements.

### Deployment & Infrastructure

**Production runs on `onemind-main` (`100.77.52.93` via Tailscale).**

- **Deploy path**: `/opt/onemind-web` on the server
- **Stack**: Docker Compose → single `onemind` service
- **Ports**: `3456` (HTTP) + `3457` (WebSocket)
- **Access**: Tailscale mesh only — `http://100.77.52.93:3456`
- **Auth**: Access key in `.env.local` on the server; auto-generated on first run
- **Data**: Persisted in `./data/` volume (SQLite DBs, uploads, logs)
- **Env config**: `.env.local` on the server, loaded via `env_file` in docker-compose (not volume-mounted)
- **Co-located with**: NATS, OmniDB (PostgreSQL+TimescaleDB+pgvector), n8n — all in `/opt/onemind/`

**Deploy commands** (on server):
```bash
cd /opt/onemind-web
git pull origin main
docker compose up -d --build
```

**Data dir must be owned by UID 1000** (`node` user inside the container). If fresh: `chown -R 1000:1000 /opt/onemind-web/data`

### Package Identity

| Field | Value |
|-------|-------|
| npm package | `@onemind-os/onemind-ui` |
| GitHub repo | `One-Mind-OS/onemind-web` |
| CLI command | `onemind` (entry: `bin/onemind.js`) |
| Docker image | `ghcr.io/one-mind-os/onemind-web` |
| Docker service | `onemind` |

### Intentionally Kept SwarmClaw References

These are internal/non-user-facing and must NOT be renamed (would break existing deployments):
- HMR singleton keys (`__swarmclaw_rate_limit__`, `__swarmclaw_shutdown_state__`)
- Custom events (`swarmclaw:open-search`, `swarmclaw:scroll-bottom`, `swarmclaw:settings-focus`)
- Environment variables (`SWARMCLAW_HOME`, `SWARMCLAW_BUILD_MODE`, `SWARMCLAW_URL`, etc.)
- Test fixture data (`swarmclawai/swarmclaw` repo examples)
- Platform identifiers in types (`'swarmclaw'`, `'swarmclaw-site'`)

### Gamification System (Extracted, Not Yet Built)

Constants in `src/config/constants.ts`, types in `src/types/index.ts` (end of file). Specs in `doc/features/GAMIFICATION-SYSTEM.md` and `doc/features/GAME-VISUALIZATION.md`. No UI exists yet — these are ready for implementation.

### Documentation Reference

All design, architecture, feature, and product docs are in `doc/`. See `doc/README.md` for the full index.

**Design System & Theme:**
- `doc/design/theme/SOLARPUNK-THEME.md` — Primary color palette, gradients, icon mappings, nav remap
- `doc/design/theme/THEME_COLOR_GUIDE.md` — Color semantics and usage
- `doc/design/DESIGN_SYSTEM.md` — Component patterns, tokens, spacing
- `doc/design/UI_WIREFRAMES.md` — Complete screen taxonomy and layouts
- Solarpunk CSS tokens are defined in `src/app/globals.css` under `/* Solarpunk Palette */` and `/* Solarpunk Path Badges */`

**Feature Specs (implementation status varies):**
- `doc/features/MENTION-SYSTEM.md` — @type:entity syntax, autocomplete, resolution (⚠️ partial)
- `doc/features/NOTIFICATION-SYSTEM.md` — Multi-channel routing, awareness modes (⚠️ partial)
- `doc/features/UNIFIED-INBOX-SYSTEM.md` — Task + approval + notification hub (⚠️ partial)
- `doc/features/CHAT_FEATURES_SPEC.md` — 7-platform competitive analysis
- `doc/features/NAVIGATION-SYSTEM.md` — 6-section nav structure

**Architecture:**
- `doc/architecture/AG-UI-INTEGRATION.md` — API contracts and backend data flow
- `doc/architecture/UI-ARCHITECTURE-DECISION.md` — Why tactical UI was chosen over chat-first
- `doc/architecture/ONEMIND-INTERFACES.md` — Full system surface area (web, mobile, CLI, wearables)

**Product Vision:**
- `doc/product/VISION.md` — The Legacy vision
- `doc/product/MASTER_BUILD_PLAN.md` — Full stack architecture plan
- `doc/product/MASTER-FEATURE-MATRIX.md` — Feature scope across HP/LE/GE/Commons
