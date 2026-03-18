import { useState } from "react";

const tabs = [
  { id: "voice", label: "Voice Interface", icon: "🎙️" },
  { id: "vision", label: "Shared Vision", icon: "👁️" },
  { id: "heartbeat", label: "Unified Heartbeat", icon: "💓" },
  { id: "architecture", label: "Full Architecture", icon: "🏗️" },
];

function Badge({ color, children }) {
  return (
    <span style={{
      display: "inline-block", background: color, color: "#000",
      fontWeight: 800, fontSize: 10, padding: "2px 8px", borderRadius: 5,
      letterSpacing: 0.5, textTransform: "uppercase", verticalAlign: "middle",
    }}>{children}</span>
  );
}

function Card({ border, bg, children, style }) {
  return (
    <div style={{
      background: bg || "#0f172a", border: `1px solid ${border || "#334155"}`,
      borderRadius: 12, padding: 20, ...style,
    }}>{children}</div>
  );
}

function CodeBlock({ children }) {
  return (
    <div style={{
      fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
      fontSize: 11, color: "#94a3b8", lineHeight: 2,
      whiteSpace: "pre-wrap", overflow: "auto",
      background: "#0a0f1a", borderRadius: 8, padding: 16,
      border: "1px solid #1e293b",
    }}>{children}</div>
  );
}

// ─── VOICE ───
function VoiceSection() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        The interaction layer sits <strong style={{ color: "#e2e8f0" }}>ABOVE everything</strong> — above Agno, above OM1, above NATS.
        It's the gateway that accepts voice, text, or any input and routes it down to the brain.
      </p>

      {/* The Stack */}
      <Card border="#334155">
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 16, textAlign: "center" }}>
          Where Voice Fits in the Stack
        </div>
        <CodeBlock>{`YOU (voice, text, chat, AR glasses)
 │
 ▼
┌─────────────────────────────────────────────────┐
│         INTERACTION GATEWAY                      │
│  ┌──────────┬──────────┬──────────┬───────────┐ │
│  │  Voice   │   Chat   │  Flutter │  Channel  │ │
│  │(Gemini   │  (Web /  │   App    │ Adapters  │ │
│  │ Live API)│  WebSocket│ (mobile) │(Telegram, │ │
│  │          │          │          │ WhatsApp, │ │
│  │          │          │          │ Slack...) │ │
│  └────┬─────┴────┬─────┴────┬─────┴─────┬─────┘ │
│       └──────────┼──────────┼───────────┘       │
│                  ▼                               │
│         Unified Input Handler                    │
│    (converts ALL inputs to text messages)        │
└──────────────────┬──────────────────────────────┘
                   │ text message
                   ▼
┌──────────────────────────────────────────────────┐
│              AGNO (Brain)                         │
│         AgentOS REST API / SSE                    │
│    POST /agents/{id}/runs + streaming             │
└──────────────────────────────────────────────────┘
                   │
            (NATS if physical)
                   ▼
┌──────────────────────────────────────────────────┐
│              OM1 (Body)                           │
└──────────────────────────────────────────────────┘`}</CodeBlock>
      </Card>

      {/* Voice specifically */}
      <Card border="#1e3a5f" bg="#0c1929">
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
          <span style={{ fontSize: 22 }}>🎙️</span>
          <div>
            <div style={{ color: "#7dd3fc", fontWeight: 700, fontSize: 16 }}>Voice: How It Actually Works</div>
            <div style={{ color: "#64748b", fontSize: 12 }}>Your primary interaction mode</div>
          </div>
        </div>
        <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.9 }}>
          <strong style={{ color: "#e2e8f0" }}>Option A: Gemini Live API (your current direction)</strong><br/>
          You speak → Gemini Live does real-time STT → text goes to Agno → Agno responds →
          text goes to Gemini/ElevenLabs TTS → you hear the response.
          Gemini Live handles the <em>conversation flow</em> (interruption, turn-taking, VAD).
          Agno handles the <em>thinking</em> (knowledge, memory, tools, delegation).<br/><br/>

          <strong style={{ color: "#e2e8f0" }}>Option B: Agno's native audio (limited today)</strong><br/>
          Agno supports audio input/output via OpenAI's audio models, but real-time
          streaming voice (like a phone call) is still a feature request.
          It works for "process this audio clip" but NOT for live conversation.<br/><br/>

          <strong style={{ color: "#e2e8f0" }}>Option C: OpenClaw-style channel adapters</strong><br/>
          Use the same pattern from those screenshots — a gateway that accepts
          voice from WhatsApp, Telegram voice messages, phone calls via Twilio,
          or your Flutter app mic. Each adapter converts to text and forwards to Agno.
        </div>
      </Card>

      {/* The recommendation */}
      <Card border="#854d0e" bg="#1a1207">
        <div style={{ color: "#fbbf24", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
          ⚡ What I Recommend for One Mind OS
        </div>
        <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.8 }}>
          Build the <strong>Interaction Gateway</strong> as its own service — separate from both Agno and OM1.
          It's a thin Python/FastAPI layer that:<br/><br/>

          1. <strong style={{ color: "#7dd3fc" }}>Accepts voice</strong> via Gemini Live API WebSocket (real-time, low latency)<br/>
          2. <strong style={{ color: "#86efac" }}>Accepts text</strong> via Flutter app WebSocket, web UI, or REST<br/>
          3. <strong style={{ color: "#c4b5fd" }}>Accepts channel messages</strong> via Telegram/WhatsApp/Slack bots<br/>
          4. <strong style={{ color: "#fbbf24" }}>Accepts OM1 speech</strong> — robot's mic feeds through here too<br/><br/>

          ALL inputs become a text message → forwarded to <strong>Agno AgentOS</strong> via REST.
          Response comes back → Gateway converts to voice (TTS) or text for the right channel.<br/><br/>

          This means you can talk to Legacy from <em>anywhere</em> — phone, laptop, AR glasses,
          robot mic, Telegram — and it all hits the same brain with the same memory.
        </div>
      </Card>

      {/* Voice flow diagram */}
      <Card border="#334155">
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 12, textAlign: "center" }}>
          Example: You say "Hey Legacy, check my email and walk to the kitchen"
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          {[
            { sys: "GATEWAY", color: "#fbbf24", text: "Gemini Live captures your voice → STT → text" },
            { sys: "GATEWAY", color: "#fbbf24", text: "Sends to Agno: POST /teams/onemind/runs with message text" },
            { sys: "AGNO", color: "#7dd3fc", text: "LLM #1 reasons: 2 tasks — digital (email) + physical (walk)" },
            { sys: "AGNO", color: "#7dd3fc", text: "Digital agent checks email via Gmail MCP tool" },
            { sys: "AGNO", color: "#7dd3fc", text: "Physical agent publishes 'walk to kitchen' → NATS" },
            { sys: "OM1", color: "#86efac", text: "LLM #2 plans path to kitchen, starts walking" },
            { sys: "AGNO", color: "#7dd3fc", text: "Returns response: 'You have 3 new emails. Walking to kitchen now.'" },
            { sys: "GATEWAY", color: "#fbbf24", text: "TTS converts response to speech → you hear it" },
          ].map((step, i) => (
            <div key={i} style={{
              display: "flex", alignItems: "flex-start", gap: 10,
              padding: "6px 10px", borderLeft: `3px solid ${step.color}`,
              borderRadius: "0 6px 6px 0",
            }}>
              <span style={{
                color: step.color, fontSize: 10, fontWeight: 800,
                fontFamily: "monospace", flexShrink: 0, paddingTop: 2,
                minWidth: 60,
              }}>{step.sys}</span>
              <span style={{ color: "#cbd5e1", fontSize: 12.5 }}>{step.text}</span>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}

// ─── SHARED VISION ───
function VisionSection() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        If you have multiple robots, they each have their own OM1 instance running their own sensors.
        The question is: how do they <strong style={{ color: "#e2e8f0" }}>share what they see</strong> so
        Agno has a unified picture of the physical world?
      </p>

      <Card border="#334155">
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 16, textAlign: "center" }}>
          Multi-Robot Shared Vision via NATS
        </div>
        <CodeBlock>{`┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ ROBOT 1     │  │ ROBOT 2     │  │ ROBOT 3     │
│ (Unitree G1)│  │ (Unitree Go2│  │ (TurtleBot) │
│             │  │             │  │             │
│ OM1 runtime │  │ OM1 runtime │  │ OM1 runtime │
│ Camera → VLM│  │ Camera → VLM│  │ Camera → VLM│
│ LiDAR       │  │ LiDAR       │  │             │
│ Mic → ASR   │  │ Mic → ASR   │  │ Mic → ASR   │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       │ publishes       │ publishes       │ publishes
       ▼                ▼                ▼
┌──────────────────────────────────────────────────┐
│                   NATS SERVER                     │
│                                                   │
│  onemind.vision.robot1 → "person in living room"  │
│  onemind.vision.robot2 → "empty hallway"          │
│  onemind.vision.robot3 → "package at front door"  │
│                                                   │
│  onemind.audio.robot1  → "doorbell rang"           │
│  onemind.status.robot2 → "battery 30%, charging"   │
└──────────────────────┬───────────────────────────┘
                       │ subscribes to ALL
                       ▼
┌──────────────────────────────────────────────────┐
│           AGNO CONTEXT AGGREGATOR                 │
│                                                   │
│  Subscribes to onemind.vision.*                   │
│  Subscribes to onemind.audio.*                    │
│  Subscribes to onemind.status.*                   │
│                                                   │
│  Builds UNIFIED WORLD STATE:                      │
│  {                                                │
│    "living_room": "person detected (robot1)",     │
│    "hallway": "clear (robot2)",                   │
│    "front_door": "package waiting (robot3)",      │
│    "alerts": ["doorbell rang"],                   │
│    "fleet": [                                     │
│      {"id": "robot1", "battery": 80, "status": "patrolling"},│
│      {"id": "robot2", "battery": 30, "status": "charging"}, │
│      {"id": "robot3", "battery": 95, "status": "idle"}      │
│    ]                                              │
│  }                                                │
│                                                   │
│  This state is injected into Agno agent context   │
│  on every request + every heartbeat cycle         │
└──────────────────────────────────────────────────┘`}</CodeBlock>
      </Card>

      <Card border="#1a3d1f" bg="#091c09">
        <div style={{ color: "#86efac", fontWeight: 700, fontSize: 15, marginBottom: 12 }}>
          How OM1 Already Does This
        </div>
        <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
          Each OM1 instance already converts camera feeds into <strong style={{ color: "#e2e8f0" }}>natural language descriptions</strong> via
          its VLM (Vision Language Model) captioning layer. So what flows through NATS is NOT raw video —
          it's text like "adult male standing near couch, holding phone."<br/><br/>

          This is the magic of OM1's NLDB architecture: by the time sensor data reaches the bus,
          it's already human-readable text. Agno doesn't need to process images — it just reads
          sentences from all robots and builds a world map.<br/><br/>

          <strong style={{ color: "#86efac" }}>If you need actual video sharing</strong> (e.g., for security cameras
          or AR glasses), you'd use a separate media streaming layer (WebRTC or RTSP) alongside NATS.
          NATS carries the descriptions; the video stream carries the pixels. Agno only needs the descriptions.
        </div>
      </Card>

      <Card border="#854d0e" bg="#1a1207">
        <div style={{ color: "#fbbf24", fontWeight: 600, fontSize: 14, marginBottom: 8 }}>
          💡 The robots also see each other's context
        </div>
        <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.7 }}>
          Each OM1 instance can ALSO subscribe to <code style={{ color: "#fbbf24" }}>onemind.vision.*</code> — so Robot 1 knows
          what Robot 2 sees. This enables coordinated behavior: "Robot 2 is already covering the hallway,
          so I'll focus on the kitchen." This is built into the custom NATS input plugin — each robot
          gets a fused view of the entire fleet's perception.
        </div>
      </Card>
    </div>
  );
}

// ─── HEARTBEAT ───
function HeartbeatSection() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        You're right to want a heartbeat for Agno. The OpenClaw model is the right pattern to adopt.
        But it should NOT be the same heartbeat as OM1. Here's why and exactly how to structure it:
      </p>

      {/* Two heartbeats */}
      <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
        <Card border="#1a3d1f" bg="#091c09" style={{ flex: 1, minWidth: 280 }}>
          <Badge color="#22c55e">FAST HEARTBEAT</Badge>
          <div style={{ color: "#86efac", fontWeight: 700, fontSize: 16, marginTop: 8, marginBottom: 10 }}>
            OM1: Every 0.5–2 seconds
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            <strong style={{ color: "#e2e8f0" }}>Purpose:</strong> Physical survival<br/>
            "Am I about to hit a wall?"<br/>
            "Is someone in front of me?"<br/>
            "Should I keep walking?"<br/><br/>
            <strong style={{ color: "#e2e8f0" }}>Cost:</strong> Uses LLM #2 (fast, cheap/local)<br/>
            <strong style={{ color: "#e2e8f0" }}>If nothing:</strong> Keeps doing what it's doing<br/>
            <strong style={{ color: "#86efac" }}>This is NOT optional.</strong> The robot dies without it.
          </div>
        </Card>

        <Card border="#1e3a5f" bg="#0c1929" style={{ flex: 1, minWidth: 280 }}>
          <Badge color="#0ea5e9">SLOW HEARTBEAT</Badge>
          <div style={{ color: "#7dd3fc", fontWeight: 700, fontSize: 16, marginTop: 8, marginBottom: 10 }}>
            Agno: Every 5–30 minutes
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
            <strong style={{ color: "#e2e8f0" }}>Purpose:</strong> Proactive awareness<br/>
            "Any new emails from VIPs?"<br/>
            "Upcoming meeting I should prep for?"<br/>
            "Robot fleet status — anything wrong?"<br/>
            "Any NATS events I missed?"<br/><br/>
            <strong style={{ color: "#e2e8f0" }}>Cost:</strong> Uses LLM #1 (powerful, costs tokens)<br/>
            <strong style={{ color: "#e2e8f0" }}>If nothing:</strong> Returns HEARTBEAT_OK (no notification)<br/>
            <strong style={{ color: "#7dd3fc" }}>Exactly the OpenClaw pattern.</strong>
          </div>
        </Card>
      </div>

      {/* Why not combined */}
      <Card border="#854d0e" bg="#1a1207">
        <div style={{ color: "#fbbf24", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
          Why NOT unify them into one heartbeat?
        </div>
        <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.8 }}>
          <strong>Speed difference:</strong> OM1 needs a response in 200ms. Agno's heartbeat takes 3–10 seconds
          (it's checking email, calendar, databases). You can't have the robot freeze for 10 seconds every cycle.<br/><br/>

          <strong>Cost difference:</strong> OM1's loop runs 1-2 times per SECOND. That's 3,600+ LLM calls per hour.
          If you ran GPT-4.1 that often, you'd spend hundreds of dollars per day. OM1 uses a tiny fast model for this.
          Agno's heartbeat runs maybe 2-3 times per hour with a powerful model.<br/><br/>

          <strong>Failure isolation:</strong> If Agno's heartbeat crashes while checking your calendar API,
          the robot should NOT stop walking. They must be independent loops.
        </div>
      </Card>

      {/* The OpenClaw Pattern for Agno */}
      <Card border="#1e3a5f" bg="#0c1929">
        <div style={{ color: "#7dd3fc", fontWeight: 700, fontSize: 16, marginBottom: 14 }}>
          Your Agno Heartbeat — OpenClaw Pattern Adapted
        </div>
        <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8, marginBottom: 16 }}>
          Here's the exact system, inspired by OpenClaw's HEARTBEAT.md concept
          but built natively into Agno with your NATS + OM1 context:
        </div>
        <CodeBlock>{`AGNO HEARTBEAT LOOP (runs every 15 minutes)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: GATHER CONTEXT (Python, no LLM needed)
  ├─ Check Gmail API → new emails?
  ├─ Check Calendar API → upcoming events?
  ├─ Check ClickUp API → overdue tasks?
  ├─ Read NATS → latest robot fleet status
  ├─ Read NATS → any physical events since last heartbeat
  └─ Read Flock Safety → any camera alerts?

Step 2: BUILD HEARTBEAT PROMPT
  ├─ Load HEARTBEAT.md (your checklist of what to monitor)
  ├─ Inject gathered context as structured data
  └─ Send to Agno agent as a "heartbeat run"

Step 3: LLM #1 REASONS
  ├─ "3 new emails — 1 from important contact → notify"
  ├─ "Meeting in 20 min, no prep doc → notify"
  ├─ "Robot 2 battery at 15% → send it to charge"
  ├─ "Nothing else urgent → HEARTBEAT_OK"
  └─ Returns structured actions

Step 4: EXECUTE ACTIONS
  ├─ Send you notification via preferred channel
  ├─ Publish "go charge" command to robot2 via NATS
  └─ Log heartbeat result

Step 5: SLEEP until next cycle
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`}</CodeBlock>
      </Card>

      {/* HEARTBEAT.md example */}
      <Card border="#334155">
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 12 }}>
          Your HEARTBEAT.md (stored in Agno workspace)
        </div>
        <CodeBlock>{`# One Mind OS Heartbeat Checklist

## Digital Checks
- Scan inbox for emails from family or business contacts
- Check calendar for events in next 2 hours
- Review ClickUp for overdue or blocked tasks
- Check Slack/Discord for unread @mentions

## Physical Checks (via NATS)
- Robot fleet battery levels — alert if any below 20%
- Unusual sensor events (unknown person, loud noise)
- Any robot errors or connectivity issues

## Proactive Actions
- If meeting in < 30 min with no prep: remind me
- If VIP email unanswered > 2 hours: nudge me
- If all clear: return HEARTBEAT_OK (silent)

## Rules
- Never notify between 10 PM and 7 AM unless urgent
- Max 3 notifications per heartbeat cycle
- Always include actionable next step in notifications`}</CodeBlock>
      </Card>

      {/* Timeline comparison */}
      <Card border="#334155">
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 14, textAlign: "center" }}>
          Two Heartbeats Running Side by Side
        </div>
        <CodeBlock>{`TIME ─────>  0s    1s    2s    3s    4s    5s   ...  15 min
             │     │     │     │     │     │          │
OM1 HEART    💚💚  💚💚  💚💚  💚💚  💚💚  💚💚  ...  💚💚
(0.5-2s)     see   walk  see   walk  see   walk      see
             fast  fast  fast  fast  fast  fast       fast

AGNO HEART   ░░░░  ░░░░  ░░░░  ░░░░  ░░░░  ░░░░ ...  💙💙💙💙
(15 min)     sleeping...                              check email
             zero cost...                             check calendar
                                                      check robots
                                                      → notify or OK

OM1 = continuous physical awareness (survival)
AGNO = periodic digital awareness (proactive intelligence)

They DON'T interfere with each other.
They share context through NATS.`}</CodeBlock>
      </Card>

      {/* But they feed each other */}
      <Card border="#3b2d5e" bg="#1a1525">
        <div style={{ color: "#c4b5fd", fontWeight: 700, fontSize: 15, marginBottom: 10 }}>
          🔗 But They Feed Each Other
        </div>
        <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.8 }}>
          Even though they're separate loops, they share information:<br/><br/>

          <strong style={{ color: "#86efac" }}>OM1 → Agno:</strong> Every OM1 heartbeat publishes sensor summaries to NATS.
          When Agno's heartbeat fires, it reads the latest robot context before reasoning.
          "Robot saw unknown person 5 minutes ago" becomes part of Agno's heartbeat prompt.<br/><br/>

          <strong style={{ color: "#7dd3fc" }}>Agno → OM1:</strong> When Agno's heartbeat decides "send Robot 2 to charge,"
          it publishes a command to NATS. OM1's next fast heartbeat cycle picks it up and acts.<br/><br/>

          <strong style={{ color: "#fbbf24" }}>You → Both:</strong> When you chat with Legacy (via voice or text),
          that's a third trigger — reactive, not heartbeat. It hits Agno immediately,
          which can then command OM1 via NATS.
        </div>
      </Card>
    </div>
  );
}

// ─── FULL ARCHITECTURE ───
function ArchitectureSection() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
        Here's the complete One Mind OS architecture with all four layers:
        Interaction Gateway, Agno Brain (with heartbeat), NATS Bus, and OM1 Body (with heartbeat).
      </p>

      <Card border="#334155">
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 16, textAlign: "center" }}>
          Complete One Mind OS Architecture
        </div>
        <CodeBlock>{`
═══════════════════════════════════════════════════════════
  LAYER 0: INTERACTION GATEWAY  (you talk to this)
═══════════════════════════════════════════════════════════
  🎙️ Voice (Gemini Live API / ElevenLabs TTS)
  💬 Chat (Flutter app / Web UI via WebSocket)
  📱 Channels (Telegram, WhatsApp, Slack, iMessage)
  🤖 Robot mic (OM1 speech-to-text)
  🕶️ AR Glasses (Brilliant Labs Frame)
     │
     │  ALL inputs become text → POST to Agno AgentOS
     │  ALL outputs get converted back (TTS, text, etc.)
     ▼
═══════════════════════════════════════════════════════════
  LAYER 1: AGNO BRAIN  (thinks, remembers, coordinates)
═══════════════════════════════════════════════════════════
  🧠 LLM #1: GPT-4.1 / Claude (powerful, 1-5 sec)
  │
  ├── 📚 Knowledge (PgVector RAG — your documents, Legacy Codex)
  ├── 💾 Memory (PostgreSQL — 3-layer, cross-session)
  ├── 🔌 MCP Tools (Gmail, Calendar, ClickUp, etc.)
  ├── 👥 Teams: UI Team, GE Team, HP Team, LE Team
  │      └── Physical Agent (has NATS robot tools)
  │      └── Digital Agent (has email/slack/web tools)
  │
  ├── 💓 AGNO HEARTBEAT (every 15 min)
  │      Step 1: Python gathers data (Gmail, Calendar, NATS)
  │      Step 2: Reads HEARTBEAT.md checklist
  │      Step 3: LLM #1 reasons over gathered data
  │      Step 4: Notify you OR HEARTBEAT_OK (silent)
  │
  ├── ⚡ REACTIVE (instant — when you chat or event arrives)
  │      You speak → Gateway → Agno → responds immediately
  │      Webhook fires → Agno → reasons → acts
  │      OM1 event → NATS → Agno → reasons → acts
  │
  └── 🌐 AgentOS API
         REST endpoints + SSE streaming
         POST /agents/{id}/runs
         POST /teams/{id}/runs
     │
     │ publishes commands / subscribes to events
     ▼
═══════════════════════════════════════════════════════════
  LAYER 2: NATS MESSAGE BUS  (nervous system)
═══════════════════════════════════════════════════════════
  Subjects:
    onemind.commands.{robot_id}    (Agno → OM1)
    onemind.vision.{robot_id}      (OM1 → Agno)
    onemind.audio.{robot_id}       (OM1 → Agno)
    onemind.status.{robot_id}      (OM1 → Agno)
    onemind.personality             (Agno → OM1)
    onemind.fleet.worldstate        (aggregated view)
     │
     │ subscribes to commands / publishes sensors
     ▼
═══════════════════════════════════════════════════════════
  LAYER 3: OM1 BODY × N ROBOTS  (sees, moves, reacts)
═══════════════════════════════════════════════════════════
  ⚡ LLM #2: Qwen3-30B local (fast, 200ms)
  │
  ├── 👁️ Camera → VLM → text descriptions
  ├── 👂 Mic → ASR → text transcripts
  ├── 📡 LiDAR / IMU → spatial awareness
  ├── 🦿 HAL → ROS2 → motors (walk, wave, sit)
  ├── 🗣️ TTS → speaker (robot speaks)
  │
  └── 💚 OM1 HEARTBEAT (every 0.5-2 sec — NEVER stops)
         Step 1: Read ALL sensors
         Step 2: Convert to natural language (NLDB)
         Step 3: Fuse with any Agno commands from NATS
         Step 4: LLM #2 decides: move? speak? wait?
         Step 5: Execute action via HAL
         Step 6: Publish sensor summary to NATS
         Step 7: Repeat immediately
`}</CodeBlock>
      </Card>

      {/* Three triggers */}
      <Card border="#334155">
        <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 15, marginBottom: 14, textAlign: "center" }}>
          Three Ways Legacy Activates
        </div>
        <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
          {[
            {
              title: "1. You Talk To It",
              subtitle: "REACTIVE (instant)",
              color: "#fbbf24",
              bg: "#1a1207",
              border: "#854d0e",
              desc: "Voice or text → Gateway → Agno → response in 2-5 sec. This is your primary interaction. No heartbeat needed — it responds the moment you speak.",
            },
            {
              title: "2. Agno Heartbeat",
              subtitle: "PROACTIVE (every 15 min)",
              color: "#7dd3fc",
              bg: "#0c1929",
              border: "#1e3a5f",
              desc: "Agno wakes up, checks email/calendar/robots, reasons about what needs attention. Notifies you only if something matters. OpenClaw pattern.",
            },
            {
              title: "3. OM1 Heartbeat",
              subtitle: "CONTINUOUS (every 0.5 sec)",
              color: "#86efac",
              bg: "#091c09",
              border: "#1a3d1f",
              desc: "Robot's survival loop. Always perceiving, always reacting. Publishes events to NATS which can trigger Agno reactively (e.g., 'unknown person detected').",
            },
          ].map((item, i) => (
            <Card key={i} border={item.border} bg={item.bg} style={{ flex: 1, minWidth: 200 }}>
              <div style={{ color: item.color, fontWeight: 700, fontSize: 14 }}>{item.title}</div>
              <div style={{ color: "#64748b", fontSize: 11, marginBottom: 8 }}>{item.subtitle}</div>
              <div style={{ color: "#94a3b8", fontSize: 12, lineHeight: 1.7 }}>{item.desc}</div>
            </Card>
          ))}
        </div>
      </Card>

      {/* Summary */}
      <Card border="#334155" bg="linear-gradient(135deg, #0c1929 0%, #091c09 50%, #1a1525 100%)">
        <div style={{
          background: "linear-gradient(135deg, #0c1929 0%, #091c09 50%, #1a1525 100%)",
          borderRadius: 8, padding: 20,
        }}>
          <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 16, marginBottom: 12 }}>
            TL;DR — Your Three Questions Answered
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 2 }}>
            <strong style={{ color: "#fbbf24" }}>Voice:</strong> Build an Interaction Gateway above Agno.
            Gemini Live API for real-time voice. All inputs (voice, chat, Telegram, robot mic, AR glasses)
            converge to Agno's REST API as text. One brain, many mouths.<br/>

            <strong style={{ color: "#86efac" }}>Shared Vision:</strong> Each OM1 publishes text descriptions
            of what it sees to NATS. Agno subscribes to all robots' feeds and builds a unified world state.
            No raw video needed — OM1 already converts to text via its VLM layer.<br/>

            <strong style={{ color: "#c4b5fd" }}>Heartbeat:</strong> Two separate heartbeats.
            OM1 fast loop (0.5s, physical survival, LLM #2).
            Agno slow loop (15 min, digital awareness, LLM #1, OpenClaw pattern).
            They feed each other through NATS but run independently.
            If one crashes, the other keeps going.
          </div>
        </div>
      </Card>
    </div>
  );
}

// ─── MAIN ───
export default function OneMindVoiceVisionHeartbeat() {
  const [active, setActive] = useState("voice");

  const renderSection = () => {
    switch (active) {
      case "voice": return <VoiceSection />;
      case "vision": return <VisionSection />;
      case "heartbeat": return <HeartbeatSection />;
      case "architecture": return <ArchitectureSection />;
      default: return null;
    }
  };

  return (
    <div style={{
      minHeight: "100vh", background: "#020617", color: "#e2e8f0",
      fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
      padding: "24px 16px",
    }}>
      <div style={{ maxWidth: 780, margin: "0 auto" }}>
        {/* Header */}
        <div style={{ marginBottom: 24 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
            <div style={{
              width: 8, height: 8, borderRadius: "50%",
              background: "#22c55e", boxShadow: "0 0 8px #22c55e80",
            }} />
            <span style={{ color: "#64748b", fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: "uppercase" }}>
              One Mind OS — Deep Dive
            </span>
          </div>
          <h1 style={{
            fontSize: 24, fontWeight: 800, margin: 0,
            background: "linear-gradient(135deg, #fbbf24 0%, #7dd3fc 33%, #86efac 66%, #c4b5fd 100%)",
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent",
          }}>
            Voice, Vision & Heartbeat
          </h1>
          <p style={{ color: "#64748b", fontSize: 13, margin: "4px 0 0" }}>
            How you interact, how robots share eyes, and how the system stays proactive.
          </p>
        </div>

        {/* Nav */}
        <div style={{
          display: "flex", gap: 6, marginBottom: 24,
          overflowX: "auto", paddingBottom: 4,
        }}>
          {tabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setActive(t.id)}
              style={{
                flexShrink: 0, padding: "8px 14px",
                borderRadius: 8,
                border: active === t.id ? "1px solid #475569" : "1px solid transparent",
                background: active === t.id ? "#1e293b" : "transparent",
                color: active === t.id ? "#e2e8f0" : "#64748b",
                fontSize: 13, fontWeight: active === t.id ? 600 : 400,
                cursor: "pointer", transition: "all 0.15s ease",
                fontFamily: "inherit",
              }}
            >
              {t.icon} {t.label}
            </button>
          ))}
        </div>

        {renderSection()}
      </div>
    </div>
  );
}
