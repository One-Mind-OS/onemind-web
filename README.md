# OneMind UI

The unified command center for [OneMind OS](https://github.com/One-Mind-OS/onemind-os) — a personal AI operating system powered by [OpenClaw](https://github.com/openclaw/openclaw).

OneMind UI merges multi-agent orchestration (tasks, missions, memory, schedules, delegation) with a real-time 3D/2D office visualization of your agent fleet. All agents route through an OpenClaw gateway.

GitHub: https://github.com/One-Mind-OS/onemind-ui

## What's Inside

- **Agent Management** — create, configure, and monitor agents with heartbeats, schedules, skills, and memory
- **Office Visualization** — isometric 2D SVG floor plan and 3D R3F scene showing live agent status, collaboration lines, and tool calls
- **Task Board** — Kanban + DAG task management with delegation and agent assignment
- **Missions** — multi-step planner/verifier workflows with operator controls
- **Memory** — hybrid recall (FTS5 + vector), graph traversal, journaling, reflection, and project-scoped context
- **Chat** — streaming conversations with tool execution, history, and connector bridging
- **Structured Sessions** — bounded runs with templates, branching, parallel joins, and durable transcripts
- **Schedules & Heartbeats** — autonomous agent loops, cron jobs, and supervisor recovery
- **Extensions** — runtime tool extensions with 20+ hooks
- **Connectors** — Discord, Slack, Telegram, WhatsApp, Teams, Matrix, OpenClaw gateway
- **Wallets** — Solana + Ethereum agent-linked wallets with approval gates
- **Org Chart** — visualize agent hierarchy, delegation, and live activity

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Next.js 16 |
| UI | React 19, Tailwind CSS 4 |
| State | Zustand 5, Immer |
| 3D | React Three Fiber, drei, Three.js |
| Storage | better-sqlite3 (55 tables) |
| Agents | LangGraph |
| i18n | i18next (zh/en) |
| Node | >=22.6.0 |

## Quick Start

```bash
git clone https://github.com/One-Mind-OS/onemind-ui.git
cd onemind-ui
npm install
npm run dev
```

Opens at `http://localhost:3456`.

## Project Structure

```
src/
├── app/                  # Next.js routes (~48 pages)
│   ├── office/           # 3D/2D agent office visualization
│   └── ...               # agents, tasks, missions, memory, chat, settings, etc.
├── components/           # 190+ React components
├── office/               # Ported office visualization module
│   ├── gateway/          # WebSocket client + auth + reconnect (OpenClaw protocol)
│   ├── store/            # Zustand store for office state
│   ├── components/       # 2D SVG floor plan, 3D R3F scene, panels, chat
│   ├── hooks/            # Custom React hooks
│   ├── lib/              # Utilities
│   ├── i18n/             # Translations (zh/en)
│   └── styles/           # Global styles
├── lib/
│   ├── providers/        # LLM providers (OpenClaw, OpenAI, Anthropic, Ollama, + 13 more)
│   └── server/           # Storage, chat execution, missions, memory, extensions
├── stores/               # Zustand stores
└── types/                # TypeScript types
```

## OpenClaw Integration

OneMind UI is built for OpenClaw operators.

- Connect agents to OpenClaw gateway profiles
- Discover, verify, and manage multiple gateways from one control plane
- Edit OpenClaw agent files (SOUL.md, IDENTITY.md, USER.md, TOOLS.md, AGENTS.md)
- Import OpenClaw SKILL.md files into the runtime skill system
- Real-time office visualization via persistent WebSocket to the gateway

## Development

```bash
npm install        # Install dependencies
npm run dev        # Start dev server (port 3456)
npm run build      # Production build
npm run test       # Run tests
npm run lint       # Lint check
```

## Origin

OneMind UI is built on [SwarmClaw](https://github.com/swarmclawai/swarmclaw) (v1.2.4), with the [OpenClaw Office](https://github.com/One-Mind-OS/onemind-office) visualization module merged in. The upstream SwarmClaw branch is tracked at `upstream-latest` for cherry-picking improvements.

## License

MIT
