import { useState } from "react";

const sections = [
  {
    id: "bigpicture",
    title: "The Big Picture",
    subtitle: "Think of it like a human body",
  },
  {
    id: "llms",
    title: "The Two LLMs",
    subtitle: "Why two brains, and what each does",
  },
  {
    id: "flow",
    title: "How They Talk",
    subtitle: "The message flow between systems",
  },
  {
    id: "reactive",
    title: "Reactive vs Heartbeat",
    subtitle: "When agents wake up and why",
  },
  {
    id: "scenarios",
    title: "Real Scenarios",
    subtitle: "Walk through actual use cases",
  },
];

// ─── Big Picture ───
function BigPicture() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 32 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        Think of One Mind OS like <strong style={{ color: "#e2e8f0" }}>your body</strong>.
        You have a <strong style={{ color: "#7dd3fc" }}>brain</strong> that thinks, remembers, and plans.
        You have a <strong style={{ color: "#86efac" }}>body</strong> that sees, hears, and moves.
        They're different systems — but you're still <em>one person</em>.
      </p>

      <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
        {/* AGNO BOX */}
        <div style={{
          flex: 1, minWidth: 280,
          background: "linear-gradient(135deg, #0c1929 0%, #0f2238 100%)",
          border: "1px solid #1e3a5f",
          borderRadius: 12, padding: 24,
        }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
            <div style={{
              width: 36, height: 36, borderRadius: 8,
              background: "linear-gradient(135deg, #0ea5e9, #38bdf8)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 18, fontWeight: 700, color: "#0c1929",
            }}>A</div>
            <div>
              <div style={{ color: "#7dd3fc", fontWeight: 700, fontSize: 16 }}>AGNO = The Brain</div>
              <div style={{ color: "#64748b", fontSize: 12 }}>Cognitive Layer</div>
            </div>
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            <div style={{ marginBottom: 8 }}>
              <strong style={{ color: "#7dd3fc" }}>What it does:</strong>
            </div>
            <div style={{ paddingLeft: 12 }}>
              🧠 Thinks & reasons about complex tasks<br/>
              💾 Remembers everything long-term<br/>
              📚 Searches your knowledge base (RAG)<br/>
              📧 Sends emails, Slack, digital tasks<br/>
              🤝 Coordinates teams of specialists<br/>
              🔌 Connects to external tools (MCP)<br/>
              💬 Chats with you directly
            </div>
          </div>
        </div>

        {/* OM1 BOX */}
        <div style={{
          flex: 1, minWidth: 280,
          background: "linear-gradient(135deg, #091c09 0%, #0f2a12 100%)",
          border: "1px solid #1a3d1f",
          borderRadius: 12, padding: 24,
        }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
            <div style={{
              width: 36, height: 36, borderRadius: 8,
              background: "linear-gradient(135deg, #22c55e, #4ade80)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 18, fontWeight: 700, color: "#091c09",
            }}>O</div>
            <div>
              <div style={{ color: "#86efac", fontWeight: 700, fontSize: 16 }}>OM1 = The Body</div>
              <div style={{ color: "#64748b", fontSize: 12 }}>Embodiment Layer</div>
            </div>
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            <div style={{ marginBottom: 8 }}>
              <strong style={{ color: "#86efac" }}>What it does:</strong>
            </div>
            <div style={{ paddingLeft: 12 }}>
              👁️ Sees via cameras (computer vision)<br/>
              👂 Hears via microphones<br/>
              🦿 Moves the robot (walk, wave, sit)<br/>
              🗣️ Speaks out loud (TTS)<br/>
              ⚡ Reacts FAST to physical danger<br/>
              📡 Reads all sensors (LiDAR, etc.)<br/>
              🔄 Runs a constant loop (every 0.5–2 sec)
            </div>
          </div>
        </div>
      </div>

      {/* NATS */}
      <div style={{
        background: "linear-gradient(135deg, #1a1525 0%, #1f1a2e 100%)",
        border: "1px solid #3b2d5e",
        borderRadius: 12, padding: 20,
        textAlign: "center",
      }}>
        <div style={{ color: "#c4b5fd", fontWeight: 700, fontSize: 15, marginBottom: 6 }}>
          🔗 NATS = The Nervous System
        </div>
        <div style={{ color: "#94a3b8", fontSize: 13 }}>
          The message bus that connects brain and body. Agno publishes commands → OM1 receives them.
          OM1 publishes sensor data → Agno receives it. Sub-millisecond delivery.
        </div>
      </div>

      <div style={{
        background: "#0f172a", border: "1px solid #334155",
        borderRadius: 10, padding: 16,
      }}>
        <div style={{ color: "#fbbf24", fontWeight: 600, fontSize: 14, marginBottom: 6 }}>
          ⚡ The Key Insight
        </div>
        <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.7 }}>
          They are <strong>two separate programs</strong> running at the same time, talking through NATS.
          But to YOU, it feels like <strong>one personality</strong> because they share the same identity prompt
          and the same memories. You talk to ONE entity. Under the hood, it delegates.
        </div>
      </div>
    </div>
  );
}

// ─── Two LLMs ───
function TwoLLMs() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        Yes — <strong style={{ color: "#e2e8f0" }}>there are two LLMs</strong>. And that's on purpose.
        Here's why and exactly what each one handles:
      </p>

      {/* LLM 1 */}
      <div style={{
        background: "#0c1929", border: "1px solid #1e3a5f",
        borderRadius: 12, padding: 24,
      }}>
        <div style={{ display: "flex", alignItems: "baseline", gap: 10, marginBottom: 12 }}>
          <span style={{
            background: "#0ea5e9", color: "#0c1929",
            fontWeight: 800, fontSize: 13, padding: "3px 10px",
            borderRadius: 6,
          }}>LLM #1</span>
          <span style={{ color: "#7dd3fc", fontWeight: 700, fontSize: 16 }}>
            Agno's LLM — "The Thinker"
          </span>
        </div>
        <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8, marginBottom: 14 }}>
          <strong style={{ color: "#cbd5e1" }}>Model:</strong> GPT-4.1 / Claude / Gemini (your choice — cloud-based, powerful)<br/>
          <strong style={{ color: "#cbd5e1" }}>Speed:</strong> 1–5 seconds per response (fine for thinking tasks)<br/>
          <strong style={{ color: "#cbd5e1" }}>Lives inside:</strong> Agno agents
        </div>
        <div style={{
          background: "#0a1420", borderRadius: 8, padding: 14,
          border: "1px solid #1e3a5f",
        }}>
          <div style={{ color: "#7dd3fc", fontWeight: 600, fontSize: 12, marginBottom: 8 }}>
            WHAT IT HANDLES:
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            ✅ "Should I send this email or wait?"<br/>
            ✅ "Search my knowledge base for that document"<br/>
            ✅ "Remember that John prefers morning meetings"<br/>
            ✅ "Coordinate 3 agents to research this topic"<br/>
            ✅ "Draft a Slack message to the team"<br/>
            ✅ "The robot just saw a visitor — decide what to do"<br/>
            ✅ ALL digital tool usage (email, calendar, APIs)
          </div>
        </div>
      </div>

      {/* LLM 2 */}
      <div style={{
        background: "#091c09", border: "1px solid #1a3d1f",
        borderRadius: 12, padding: 24,
      }}>
        <div style={{ display: "flex", alignItems: "baseline", gap: 10, marginBottom: 12 }}>
          <span style={{
            background: "#22c55e", color: "#091c09",
            fontWeight: 800, fontSize: 13, padding: "3px 10px",
            borderRadius: 6,
          }}>LLM #2</span>
          <span style={{ color: "#86efac", fontWeight: 700, fontSize: 16 }}>
            OM1's Cortex LLM — "The Reflex"
          </span>
        </div>
        <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8, marginBottom: 14 }}>
          <strong style={{ color: "#cbd5e1" }}>Model:</strong> Qwen3-30B local OR GPT-4.1-nano cloud (fast, small)<br/>
          <strong style={{ color: "#cbd5e1" }}>Speed:</strong> 200–500ms per response (critical for physical safety)<br/>
          <strong style={{ color: "#cbd5e1" }}>Lives inside:</strong> OM1's cortex loop
        </div>
        <div style={{
          background: "#061408", borderRadius: 8, padding: 14,
          border: "1px solid #1a3d1f",
        }}>
          <div style={{ color: "#86efac", fontWeight: 600, fontSize: 12, marginBottom: 8 }}>
            WHAT IT HANDLES:
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            ✅ "Wall ahead — turn left NOW" (instant reflexes)<br/>
            ✅ "Person detected — wave hello"<br/>
            ✅ "Brain says patrol — choose walking path"<br/>
            ✅ "Obstacle while patrolling — reroute"<br/>
            ✅ Translating high-level goals → specific motor commands<br/>
            ✅ ALL real-time physical decisions<br/>
            ❌ Does NOT send emails, search knowledge, or remember things long-term
          </div>
        </div>
      </div>

      {/* Why Two */}
      <div style={{
        background: "#1a1207", border: "1px solid #854d0e",
        borderRadius: 12, padding: 20,
      }}>
        <div style={{ color: "#fbbf24", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
          Why not just one LLM?
        </div>
        <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.8 }}>
          If your robot is walking toward a wall, it can't wait 3 seconds for GPT-4.1 to think about it.
          It needs to react in 200ms. But when you ask it to "research competitors and email me a summary,"
          that needs deep reasoning — not a 200ms reflex.
          <br/><br/>
          <strong>Think of it like this:</strong> When you touch a hot stove, your spinal cord
          pulls your hand back BEFORE your brain even knows what happened.
          Same principle — LLM #2 is the spinal reflex, LLM #1 is the conscious thought.
        </div>
      </div>

      {/* Flow diagram */}
      <div style={{
        background: "#0f172a", border: "1px solid #334155",
        borderRadius: 12, padding: 24,
      }}>
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 16, textAlign: "center" }}>
          Which LLM fires when?
        </div>
        <div style={{ fontFamily: "'JetBrains Mono', 'Fira Code', monospace", fontSize: 12, color: "#94a3b8", lineHeight: 1.9 }}>
          <div style={{ color: "#64748b" }}>───────────────────────────────────────</div>
          <div>
            <span style={{ color: "#fbbf24" }}>You say:</span>
            <span style={{ color: "#e2e8f0" }}> "Go patrol the house and email me if you see anyone"</span>
          </div>
          <div style={{ color: "#64748b" }}>───────────────────────────────────────</div>
          <div style={{ paddingLeft: 8 }}>
            <span style={{ color: "#7dd3fc" }}>LLM #1</span> hears this → breaks it into 2 tasks:
          </div>
          <div style={{ paddingLeft: 24 }}>
            <span style={{ color: "#7dd3fc" }}>1.</span> Sends "patrol house" command → NATS → OM1
          </div>
          <div style={{ paddingLeft: 24 }}>
            <span style={{ color: "#7dd3fc" }}>2.</span> Tells itself "wait for person detection events"
          </div>
          <div style={{ color: "#64748b", paddingLeft: 8 }}>↓</div>
          <div style={{ paddingLeft: 8 }}>
            <span style={{ color: "#86efac" }}>LLM #2</span> receives "patrol house" → decides:
          </div>
          <div style={{ paddingLeft: 24 }}>
            <span style={{ color: "#86efac" }}>→</span> walk forward, turn at hallway, avoid chair, etc.
          </div>
          <div style={{ paddingLeft: 24 }}>
            <span style={{ color: "#86efac" }}>→</span> camera sees person → publishes "person detected" → NATS
          </div>
          <div style={{ color: "#64748b", paddingLeft: 8 }}>↓</div>
          <div style={{ paddingLeft: 8 }}>
            <span style={{ color: "#7dd3fc" }}>LLM #1</span> receives "person detected" event:
          </div>
          <div style={{ paddingLeft: 24 }}>
            <span style={{ color: "#7dd3fc" }}>→</span> drafts email → sends via Gmail tool → done
          </div>
          <div style={{ color: "#64748b" }}>───────────────────────────────────────</div>
        </div>
      </div>
    </div>
  );
}

// ─── How They Talk ───
function HowTheyTalk() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        Everything flows through <strong style={{ color: "#c4b5fd" }}>NATS subjects</strong> — think of them like labeled mailboxes. Each system publishes to and listens on specific subjects.
      </p>

      <div style={{
        background: "#0f172a", border: "1px solid #334155",
        borderRadius: 12, padding: 24, overflow: "auto",
      }}>
        <div style={{
          fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
          fontSize: 11.5, color: "#94a3b8", lineHeight: 2.2,
          whiteSpace: "pre", minWidth: 500,
        }}>
{`┌─────────────────┐                          ┌─────────────────┐
│                 │  onemind.commands.physical│                 │
│   AGNO          │ ─────────────────────────>│    OM1          │
│   (Brain)       │  "patrol the living room" │    (Body)       │
│                 │                           │                 │
│                 │  onemind.sensors.physical  │                 │
│                 │ <─────────────────────────│                 │
│                 │  "person at front door"    │                 │
│                 │                           │                 │
│                 │  onemind.context.status    │                 │
│                 │ <─────────────────────────│                 │
│                 │  "battery 45%, walking"    │                 │
│                 │                           │                 │
│                 │  onemind.personality       │                 │
│                 │ ─────────────────────────>│                 │
│                 │  "you are Legacy, speak    │                 │
│                 │   with authority..."       │                 │
└────────┬────────┘                          └─────────────────┘
         │
         │  Also receives from external world:
         │
    ┌────┴──────────────────────────────┐
    │  Webhooks:                        │
    │    → Calendar event fired         │
    │    → New email arrived            │
    │    → IoT sensor triggered         │
    │    → Flock Safety camera alert    │
    │                                   │
    │  Your chat messages:              │
    │    → Voice from Flutter app       │
    │    → Text from web UI             │
    └───────────────────────────────────┘`}
        </div>
      </div>

      <div style={{
        background: "#0f172a", border: "1px solid #334155",
        borderRadius: 12, padding: 20,
      }}>
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 12 }}>
          The simple rule:
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {[
            { color: "#7dd3fc", text: "Agno → OM1: High-level commands (\"patrol\", \"wave\", \"go to kitchen\")" },
            { color: "#86efac", text: "OM1 → Agno: Sensor events (\"saw person\", \"heard noise\", \"battery low\")" },
            { color: "#c4b5fd", text: "External → Agno: Webhooks, your chat messages, calendar triggers" },
            { color: "#fbbf24", text: "Agno → External: Emails, Slack messages, API calls, database writes" },
          ].map((item, i) => (
            <div key={i} style={{
              display: "flex", alignItems: "flex-start", gap: 10,
              padding: "8px 12px", background: "#1e293b", borderRadius: 8,
            }}>
              <div style={{ color: item.color, fontSize: 13, fontWeight: 600, flexShrink: 0 }}>→</div>
              <div style={{ color: "#cbd5e1", fontSize: 13 }}>{item.text}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Reactive vs Heartbeat ───
function ReactiveVsHeartbeat() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        This is the right question. The two systems work <strong style={{ color: "#e2e8f0" }}>completely differently</strong> in terms of when they "wake up":
      </p>

      <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
        {/* OM1 - always running */}
        <div style={{
          flex: 1, minWidth: 280,
          background: "#091c09", border: "1px solid #1a3d1f",
          borderRadius: 12, padding: 24,
        }}>
          <div style={{
            display: "inline-block", background: "#22c55e", color: "#091c09",
            fontWeight: 800, fontSize: 11, padding: "3px 10px", borderRadius: 6,
            marginBottom: 12,
          }}>ALWAYS-ON HEARTBEAT</div>
          <div style={{ color: "#86efac", fontWeight: 700, fontSize: 16, marginBottom: 10 }}>
            OM1 runs a constant loop
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            Every <strong style={{ color: "#e2e8f0" }}>0.5–2 seconds</strong>, OM1 does this:<br/><br/>
            1. Read ALL sensors (camera, mic, LiDAR)<br/>
            2. Convert sensor data to text descriptions<br/>
            3. Fuse everything together<br/>
            4. Ask LLM #2: "what should I do right now?"<br/>
            5. Execute the action (walk, speak, etc.)<br/>
            6. Repeat forever<br/><br/>
            <strong style={{ color: "#86efac" }}>This never stops.</strong> The robot is always
            perceiving and reacting. This is its heartbeat.
          </div>
        </div>

        {/* Agno - event-driven */}
        <div style={{
          flex: 1, minWidth: 280,
          background: "#0c1929", border: "1px solid #1e3a5f",
          borderRadius: 12, padding: 24,
        }}>
          <div style={{
            display: "inline-block", background: "#0ea5e9", color: "#0c1929",
            fontWeight: 800, fontSize: 11, padding: "3px 10px", borderRadius: 6,
            marginBottom: 12,
          }}>EVENT-DRIVEN (REACTIVE)</div>
          <div style={{ color: "#7dd3fc", fontWeight: 700, fontSize: 16, marginBottom: 10 }}>
            Agno wakes up when triggered
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            Agno agents <strong style={{ color: "#e2e8f0" }}>do NOT need a heartbeat</strong>.
            They activate when something happens:<br/><br/>
            ⚡ You send a chat message<br/>
            ⚡ A webhook fires (new email, calendar, etc.)<br/>
            ⚡ OM1 publishes an event via NATS<br/>
            ⚡ A scheduled cron job triggers<br/>
            ⚡ Another agent delegates a task<br/><br/>
            <strong style={{ color: "#7dd3fc" }}>Between events, they sleep.</strong> Zero CPU usage.
            They're like microservices — cold until called.
          </div>
        </div>
      </div>

      {/* Combined view */}
      <div style={{
        background: "#0f172a", border: "1px solid #334155",
        borderRadius: 12, padding: 24,
      }}>
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 14, textAlign: "center" }}>
          Timeline: What's running when?
        </div>
        <div style={{
          fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
          fontSize: 11, color: "#94a3b8", lineHeight: 2,
          whiteSpace: "pre", overflow: "auto",
        }}>
{`TIME ──────> 0s   1s   2s   3s   4s   5s   6s   7s   8s   9s
             │    │    │    │    │    │    │    │    │    │
OM1 (Body)   ████ ████ ████ ████ ████ ████ ████ ████ ████ ████
             loop loop loop loop loop loop loop loop loop loop
             ↑ always running its 0.5-2sec perception-action cycle

Agno (Brain) ░░░░ ░░░░ ████ ██░░ ░░░░ ░░░░ ████ ████ ███░ ░░░░
                       ↑              ↑         ↑
                   you chatted    OM1 event   webhook
                                  "saw person"  (new email)

░░░░ = sleeping (zero cost)
████ = active (processing)`}
        </div>
      </div>

      <div style={{
        background: "#1a1207", border: "1px solid #854d0e",
        borderRadius: 12, padding: 16,
      }}>
        <div style={{ color: "#fbbf24", fontWeight: 600, fontSize: 14, marginBottom: 6 }}>
          💡 But what if you WANT Agno to have a heartbeat?
        </div>
        <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.7 }}>
          You can add one. Set up a NATS subscriber that listens to OM1's sensor stream and triggers
          Agno periodically (e.g., every 30 seconds: "here's what the robot sees — anything I should act on?").
          But this is <strong>optional</strong> — and it costs LLM tokens every cycle. The default reactive
          model is more efficient: Agno only thinks when something actually needs thinking about.
        </div>
      </div>
    </div>
  );
}

// ─── Real Scenarios ───
function Scenarios() {
  const scenarios = [
    {
      title: "You say: \"Go check the front door and text me what you see\"",
      color: "#7dd3fc",
      steps: [
        { sys: "AGNO", color: "#7dd3fc", text: "LLM #1 reasons: 2 tasks — physical check + digital text" },
        { sys: "AGNO", color: "#7dd3fc", text: "Publishes 'go to front door, report what you see' → NATS" },
        { sys: "OM1", color: "#86efac", text: "LLM #2 plans walking path, avoids obstacles" },
        { sys: "OM1", color: "#86efac", text: "Camera sees: 'Amazon package on doorstep'" },
        { sys: "OM1", color: "#86efac", text: "Publishes 'amazon package at front door' → NATS" },
        { sys: "AGNO", color: "#7dd3fc", text: "LLM #1 receives event → composes text message" },
        { sys: "AGNO", color: "#7dd3fc", text: "Sends SMS: 'Package at the front door'" },
      ],
    },
    {
      title: "Calendar webhook fires: \"Meeting in 5 minutes\"",
      color: "#c4b5fd",
      steps: [
        { sys: "AGNO", color: "#7dd3fc", text: "Webhook triggers agent → LLM #1 sees meeting context" },
        { sys: "AGNO", color: "#7dd3fc", text: "Checks knowledge base for meeting prep notes" },
        { sys: "AGNO", color: "#7dd3fc", text: "Publishes 'announce: meeting in 5 minutes' → NATS" },
        { sys: "OM1", color: "#86efac", text: "LLM #2 picks 'speak' action → robot says it out loud" },
      ],
    },
    {
      title: "Robot sees a stranger while patrolling (autonomous)",
      color: "#86efac",
      steps: [
        { sys: "OM1", color: "#86efac", text: "LLM #2 detects unknown person — decides 'stand alert'" },
        { sys: "OM1", color: "#86efac", text: "Publishes 'unknown person detected, living room' → NATS" },
        { sys: "AGNO", color: "#7dd3fc", text: "LLM #1 receives event → checks if anyone expected" },
        { sys: "AGNO", color: "#7dd3fc", text: "Nobody expected → sends you a Flock Safety style alert" },
        { sys: "AGNO", color: "#7dd3fc", text: "Publishes 'ask the person to identify themselves' → NATS" },
        { sys: "OM1", color: "#86efac", text: "LLM #2 speaks: 'Hello, can I help you?'" },
      ],
    },
  ];

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        Here's how the two systems collaborate in real situations.
        Notice how <span style={{ color: "#7dd3fc" }}>AGNO (blue)</span> and <span style={{ color: "#86efac" }}>OM1 (green)</span> hand off seamlessly:
      </p>

      {scenarios.map((s, si) => (
        <div key={si} style={{
          background: "#0f172a", border: "1px solid #334155",
          borderRadius: 12, padding: 20,
        }}>
          <div style={{ color: s.color, fontWeight: 700, fontSize: 14, marginBottom: 14 }}>
            {s.title}
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            {s.steps.map((step, i) => (
              <div key={i} style={{
                display: "flex", alignItems: "flex-start", gap: 10,
                padding: "6px 10px",
                background: step.sys === "AGNO" ? "#0c192905" : "#091c0905",
                borderLeft: `3px solid ${step.color}`,
                borderRadius: "0 6px 6px 0",
              }}>
                <span style={{
                  color: step.color, fontSize: 10, fontWeight: 800,
                  fontFamily: "monospace", flexShrink: 0, paddingTop: 2,
                  minWidth: 36,
                }}>{step.sys}</span>
                <span style={{ color: "#cbd5e1", fontSize: 13 }}>{step.text}</span>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

// ─── Main App ───
export default function OneMindExplainer() {
  const [active, setActive] = useState("bigpicture");

  const renderSection = () => {
    switch (active) {
      case "bigpicture": return <BigPicture />;
      case "llms": return <TwoLLMs />;
      case "flow": return <HowTheyTalk />;
      case "reactive": return <ReactiveVsHeartbeat />;
      case "scenarios": return <Scenarios />;
      default: return null;
    }
  };

  return (
    <div style={{
      minHeight: "100vh",
      background: "#020617",
      color: "#e2e8f0",
      fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
      padding: "24px 16px",
    }}>
      <div style={{ maxWidth: 760, margin: "0 auto" }}>
        {/* Header */}
        <div style={{ marginBottom: 28 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 6 }}>
            <div style={{
              width: 8, height: 8, borderRadius: "50%",
              background: "#22c55e", boxShadow: "0 0 8px #22c55e80",
            }} />
            <span style={{ color: "#64748b", fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: "uppercase" }}>
              One Mind OS Architecture
            </span>
          </div>
          <h1 style={{
            fontSize: 26, fontWeight: 800, margin: 0, lineHeight: 1.2,
            background: "linear-gradient(135deg, #7dd3fc 0%, #86efac 50%, #c4b5fd 100%)",
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent",
          }}>
            Agno + OM1 — Simplified
          </h1>
          <p style={{ color: "#64748b", fontSize: 13, margin: "6px 0 0" }}>
            Two systems. One personality. Here's exactly what does what.
          </p>
        </div>

        {/* Nav */}
        <div style={{
          display: "flex", gap: 6, marginBottom: 24,
          overflowX: "auto", paddingBottom: 4,
        }}>
          {sections.map((s) => (
            <button
              key={s.id}
              onClick={() => setActive(s.id)}
              style={{
                flexShrink: 0,
                padding: "8px 14px",
                borderRadius: 8,
                border: active === s.id ? "1px solid #475569" : "1px solid transparent",
                background: active === s.id ? "#1e293b" : "transparent",
                color: active === s.id ? "#e2e8f0" : "#64748b",
                fontSize: 13,
                fontWeight: active === s.id ? 600 : 400,
                cursor: "pointer",
                transition: "all 0.15s ease",
                fontFamily: "inherit",
              }}
            >
              {s.title}
            </button>
          ))}
        </div>

        {/* Content */}
        <div style={{ minHeight: 400 }}>
          {renderSection()}
        </div>

        {/* Footer summary */}
        <div style={{
          marginTop: 32, padding: 20,
          background: "linear-gradient(135deg, #0c1929 0%, #0f2a12 50%, #1a1525 100%)",
          border: "1px solid #334155",
          borderRadius: 12,
        }}>
          <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 15, marginBottom: 10 }}>
            TL;DR — The Final Answer
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            <strong style={{ color: "#7dd3fc" }}>Agno</strong> = brain (thinks, remembers, digital tools, orchestrates).
            {" "}<strong style={{ color: "#86efac" }}>OM1</strong> = body (sees, hears, moves, reacts fast).
            {" "}<strong style={{ color: "#c4b5fd" }}>NATS</strong> = nervous system connecting them.
            {" "}<strong style={{ color: "#fbbf24" }}>Two LLMs</strong> — one for thinking (slow, powerful), one for reflexes (fast, local).
            {" "}Agno agents are <strong style={{ color: "#e2e8f0" }}>reactive</strong> (no heartbeat needed).
            {" "}OM1 runs a <strong style={{ color: "#e2e8f0" }}>constant loop</strong> (always perceiving).
            {" "}One unified personality shared across both.
          </div>
        </div>
      </div>
    </div>
  );
}
