import { useState } from "react";

function Code({ children }) {
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

function Card({ border, bg, children, style }) {
  return (
    <div style={{
      background: bg || "#0f172a", border: `1px solid ${border || "#334155"}`,
      borderRadius: 12, padding: 20, ...style,
    }}>{children}</div>
  );
}

export default function UnifiedSession() {
  const [tab, setTab] = useState("problem");

  const tabs = [
    { id: "problem", label: "The Problem" },
    { id: "solution", label: "The Solution" },
    { id: "flow", label: "How It Works" },
    { id: "code", label: "Code Pattern" },
  ];

  return (
    <div style={{
      minHeight: "100vh", background: "#020617", color: "#e2e8f0",
      fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
      padding: "24px 16px",
    }}>
      <div style={{ maxWidth: 760, margin: "0 auto" }}>
        <div style={{ marginBottom: 20 }}>
          <span style={{ color: "#64748b", fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: "uppercase" }}>
            One Mind OS
          </span>
          <h1 style={{
            fontSize: 24, fontWeight: 800, margin: "4px 0 0",
            background: "linear-gradient(135deg, #fbbf24, #7dd3fc)",
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent",
          }}>Unified Session Without LiveKit</h1>
        </div>

        <div style={{ display: "flex", gap: 6, marginBottom: 24, overflowX: "auto" }}>
          {tabs.map(t => (
            <button key={t.id} onClick={() => setTab(t.id)} style={{
              flexShrink: 0, padding: "8px 14px", borderRadius: 8,
              border: tab === t.id ? "1px solid #475569" : "1px solid transparent",
              background: tab === t.id ? "#1e293b" : "transparent",
              color: tab === t.id ? "#e2e8f0" : "#64748b",
              fontSize: 13, fontWeight: tab === t.id ? 600 : 400,
              cursor: "pointer", fontFamily: "inherit",
            }}>{t.label}</button>
          ))}
        </div>

        {tab === "problem" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
            <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
              LiveKit rooms solve one thing: <strong style={{ color: "#e2e8f0" }}>keeping everyone in the same conversation</strong>.
              You talk via voice, the robot hears via mic, text comes from Flutter — and LiveKit's "room" ties them all together
              as one session. Without it, each channel creates its own isolated conversation. The robot doesn't know what you
              said on your phone. Your phone doesn't know what the robot saw.
            </p>

            <Card border="#ef4444" bg="#1a0a0a">
              <div style={{ color: "#ef4444", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
                ❌ Without session binding — what breaks
              </div>
              <Code>{`You (voice, phone):  "Check my email"
  → Agno creates Session A → checks email → responds

Robot (mic, heard you): "Check my email"  
  → Agno creates Session B → checks email AGAIN → separate memory

You (Flutter chat):  "What did you find?"
  → Agno creates Session C → "Find what? I have no context"

Three channels. Three sessions. Three separate conversations.
The "one mind" illusion is broken.`}</Code>
            </Card>

            <Card border="#854d0e" bg="#1a1207">
              <div style={{ color: "#fbbf24", fontWeight: 600, fontSize: 14, marginBottom: 8 }}>
                What LiveKit rooms gave you
              </div>
              <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.7 }}>
                A shared room ID that all participants join. Voice, video, text all flow through
                one room → one context → one conversation. But LiveKit is heavyweight for this.
                It's a full WebRTC media server with SFU routing, TURN servers, codec negotiation —
                infrastructure you don't need for a personal AI assistant.
              </div>
            </Card>
          </div>
        )}

        {tab === "solution" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
            <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
              The solution is simpler than you think. You just need <strong style={{ color: "#e2e8f0" }}>one shared session ID</strong> across
              all channels. Agno already supports this natively.
            </p>

            <Card border="#22c55e" bg="#091c09">
              <div style={{ color: "#86efac", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
                ✅ The fix: ONE session_id rules them all
              </div>
              <Code>{`You (voice, phone):  "Check my email"
  → Gateway sends to Agno with session_id="master-delacruz-main"
  → Agno checks email, stores in session memory

Robot (mic, heard you):  
  → Gateway DEDUPLICATES (same utterance, skip)
  → OR if robot heard something NEW:
  → Gateway sends to Agno with session_id="master-delacruz-main"
  → SAME session, SAME memory, SAME context

You (Flutter chat):  "What did you find?"
  → Gateway sends to Agno with session_id="master-delacruz-main"
  → Agno sees full history: "You asked me to check email. Found 3 new..."

One session ID. One conversation. All channels.`}</Code>
            </Card>

            <Card border="#1e3a5f" bg="#0c1929">
              <div style={{ color: "#7dd3fc", fontWeight: 700, fontSize: 16, marginBottom: 14 }}>
                What replaces each LiveKit feature
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                {[
                  {
                    livekit: "Room (shared context)",
                    replacement: "Agno session_id — all channels send the same ID",
                  },
                  {
                    livekit: "Audio transport (voice)",
                    replacement: "Gemini Live API WebSocket (STT/TTS)",
                  },
                  {
                    livekit: "Video transport (camera)",
                    replacement: "OM1 VLM → text via NATS (no video needed)",
                  },
                  {
                    livekit: "Participant tracking",
                    replacement: "NATS subjects per robot + Gateway channel registry",
                  },
                  {
                    livekit: "Data channel (text)",
                    replacement: "Agno AgentOS REST API + WebSocket SSE",
                  },
                  {
                    livekit: "Recording / playback",
                    replacement: "Agno session storage in PostgreSQL (full history)",
                  },
                ].map((row, i) => (
                  <div key={i} style={{
                    display: "flex", gap: 8, alignItems: "flex-start",
                    padding: "8px 12px", background: "#0a1420", borderRadius: 8,
                  }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ color: "#64748b", fontSize: 10, fontWeight: 600, textTransform: "uppercase" }}>LiveKit</div>
                      <div style={{ color: "#94a3b8", fontSize: 12 }}>{row.livekit}</div>
                    </div>
                    <div style={{ color: "#334155", fontSize: 16, flexShrink: 0, paddingTop: 6 }}>→</div>
                    <div style={{ flex: 1.5 }}>
                      <div style={{ color: "#64748b", fontSize: 10, fontWeight: 600, textTransform: "uppercase" }}>One Mind OS</div>
                      <div style={{ color: "#7dd3fc", fontSize: 12 }}>{row.replacement}</div>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          </div>
        )}

        {tab === "flow" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
            <Card border="#334155">
              <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 14, marginBottom: 14, textAlign: "center" }}>
                How the Interaction Gateway Manages One Session
              </div>
              <Code>{`
┌──────────────────────────────────────────────────────────┐
│              INTERACTION GATEWAY                          │
│         (the thing that replaces LiveKit)                  │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │              SESSION ROUTER                          │ │
│  │                                                      │ │
│  │  user_id: "master-delacruz"                          │ │
│  │  active_session: "master-delacruz-main"              │ │
│  │  active_channels: [voice, flutter, robot1, robot2]   │ │
│  │  dedup_window: 3 seconds (prevents echo)             │ │
│  │  response_targets: [voice_ws, flutter_ws]            │ │
│  │                                                      │ │
│  └─────────────────┬────────────────────────────────────┘ │
│                    │                                      │
│  INPUTS:           │  ALL → same session_id               │
│  ┌─────────┐       │                                      │
│  │ Voice   │───────┤  1. STT via Gemini Live              │
│  │ (mic)   │       │  2. Dedup check (was this already    │
│  └─────────┘       │     heard from another channel?)     │
│  ┌─────────┐       │  3. POST /teams/onemind/runs         │
│  │ Flutter │───────┤     body: { message, session_id }    │
│  │ (text)  │       │  4. Stream response back via SSE     │
│  └─────────┘       │  5. Send response to ALL active      │
│  ┌─────────┐       │     output channels:                 │
│  │Telegram │───────┤     - TTS → voice speaker            │
│  │WhatsApp │       │     - Text → Flutter UI              │
│  └─────────┘       │     - Text → Telegram (if active)    │
│  ┌─────────┐       │                                      │
│  │Robot mic│───────┤                                      │
│  │(via NATS│       │                                      │
│  └─────────┘       │                                      │
│  ┌─────────┐       │                                      │
│  │AR Glass │───────┘                                      │
│  │(Frame)  │                                              │
│  └─────────┘                                              │
│                                                           │
│  OUTPUTS: Response goes to ALL connected channels         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │Voice TTS│ │Flutter  │ │Telegram │ │Robot    │        │
│  │(speaker)│ │(screen) │ │(message)│ │(speak)  │        │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
└──────────────────────────────────────────────────────────┘`}</Code>
            </Card>

            <Card border="#854d0e" bg="#1a1207">
              <div style={{ color: "#fbbf24", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
                ⚡ The Deduplication Problem (and how to solve it)
              </div>
              <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.8 }}>
                If you're in the same room as the robot and you say "check my email" —
                both your phone mic AND the robot's mic hear it. Without dedup, Agno gets
                the same message twice.<br/><br/>

                <strong>Fix:</strong> The Gateway keeps a 3-second sliding window of incoming messages.
                If two messages from different channels arrive within 3 seconds and are semantically
                similar (fuzzy match or embedding similarity {">"} 0.9), the Gateway drops the duplicate
                and only forwards one to Agno. Simple, effective, no LiveKit needed.
              </div>
            </Card>

            <Card border="#3b2d5e" bg="#1a1525">
              <div style={{ color: "#c4b5fd", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
                🔗 What about the robot seeing something while you're talking?
              </div>
              <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.8 }}>
                This happens OUTSIDE the voice session — through NATS. While you're chatting with
                Legacy via voice, OM1 is running its own heartbeat. If the robot sees something
                important, it publishes to NATS. The Gateway's NATS listener can inject this as
                a system event into your active Agno session:<br/><br/>

                <code style={{ color: "#c4b5fd", fontSize: 12 }}>
                  [SYSTEM EVENT] Robot 1 detected: unknown person at front door
                </code><br/><br/>

                Agno now has this context in the SAME session. Next time you ask "what's going on?"
                it knows about the person at the door because it's all in one session history.
              </div>
            </Card>
          </div>
        )}

        {tab === "code" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
            <p style={{ color: "#94a3b8", fontSize: 15, lineHeight: 1.7, margin: 0 }}>
              Here's the minimal Gateway pattern that replaces LiveKit rooms.
              It's a FastAPI service with WebSocket support — about 150 lines of core logic.
            </p>

            <Card border="#334155">
              <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 13, marginBottom: 10 }}>
                gateway/session_router.py — the core session binding
              </div>
              <Code>{`import asyncio, hashlib, time, httpx, nats
from fastapi import FastAPI, WebSocket

app = FastAPI()

# ━━━ SESSION STATE ━━━
# One user = one active session. All channels share it.
active_sessions = {}  # user_id → session_id
connected_channels = {}  # user_id → [websocket1, ws2, ...]
dedup_cache = {}  # hash → timestamp (3 sec window)

AGNO_URL = "http://localhost:7777"  # AgentOS
NATS_URL = "nats://localhost:4222"

def get_session_id(user_id: str) -> str:
    """Same user always gets same session — that's the whole trick."""
    if user_id not in active_sessions:
        active_sessions[user_id] = f"{user_id}-main"
    return active_sessions[user_id]

def is_duplicate(text: str) -> bool:
    """Drop if same message arrived from another channel within 3 sec."""
    h = hashlib.md5(text.lower().strip().encode()).hexdigest()
    now = time.time()
    if h in dedup_cache and now - dedup_cache[h] < 3.0:
        return True  # duplicate — skip
    dedup_cache[h] = now
    return False

async def send_to_agno(user_id: str, message: str) -> str:
    """Send message to Agno team with the SHARED session_id."""
    session_id = get_session_id(user_id)
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            f"{AGNO_URL}/teams/onemind/runs",
            json={
                "message": message,
                "session_id": session_id,  # ← THIS IS THE KEY
                "user_id": user_id,
                "stream": False,
            }
        )
        return resp.json()["content"]

async def broadcast(user_id: str, response: str):
    """Send response to ALL connected channels for this user."""
    for ws in connected_channels.get(user_id, []):
        try:
            await ws.send_json({"type": "response", "text": response})
        except:
            pass  # channel disconnected, clean up later`}</Code>
            </Card>

            <Card border="#334155">
              <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 13, marginBottom: 10 }}>
                gateway/channels.py — voice, text, and robot all use same session
              </div>
              <Code>{`# ━━━ VOICE CHANNEL (Gemini Live API) ━━━
@app.websocket("/voice/{user_id}")
async def voice_channel(ws: WebSocket, user_id: str):
    await ws.accept()
    connected_channels.setdefault(user_id, []).append(ws)
    try:
        while True:
            audio_data = await ws.receive_bytes()
            text = await gemini_stt(audio_data)  # STT
            if is_duplicate(text):
                continue
            response = await send_to_agno(user_id, text)
            audio_out = await gemini_tts(response)  # TTS
            await ws.send_bytes(audio_out)
            await broadcast(user_id, response)  # also send text
    finally:
        connected_channels[user_id].remove(ws)

# ━━━ TEXT CHANNEL (Flutter / Web) ━━━
@app.websocket("/chat/{user_id}")
async def chat_channel(ws: WebSocket, user_id: str):
    await ws.accept()
    connected_channels.setdefault(user_id, []).append(ws)
    try:
        while True:
            data = await ws.receive_json()
            if is_duplicate(data["text"]):
                continue
            response = await send_to_agno(user_id, data["text"])
            await broadcast(user_id, response)
    finally:
        connected_channels[user_id].remove(ws)

# ━━━ NATS LISTENER (robot events + sensor data) ━━━
async def start_nats_listener():
    nc = await nats.connect(NATS_URL)

    async def on_robot_event(msg):
        """Robot detected something → inject into user's session."""
        event = msg.data.decode()
        user_id = "master-delacruz"  # or parse from subject
        if not is_duplicate(event):
            response = await send_to_agno(
                user_id,
                f"[ROBOT EVENT] {event}"
            )
            await broadcast(user_id, response)

    await nc.subscribe("onemind.vision.*", cb=on_robot_event)
    await nc.subscribe("onemind.audio.*", cb=on_robot_event)`}</Code>
            </Card>

            <Card border="#334155">
              <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 13, marginBottom: 10 }}>
                The key insight — Agno does the hard work
              </div>
              <Code>{`# What Agno handles automatically when you use session_id:

session_id = "master-delacruz-main"

✅ Chat history — all messages from all channels in order
✅ Memory — "user prefers morning emails" persists forever
✅ Knowledge — RAG searches use session context
✅ Team state — if a task is mid-flight, it continues
✅ User memories — extracted facts carry across sessions

# What the Gateway handles:
✅ Channel routing — voice/text/telegram/robot → one endpoint
✅ Deduplication — prevent echo when multiple mics hear you
✅ Response broadcasting — send reply to all connected channels
✅ STT/TTS — convert voice ↔ text at the edge
✅ NATS bridge — inject robot events into the session

# What you DON'T need:
❌ LiveKit — no SFU, no TURN, no codec negotiation
❌ WebRTC between channels — channels don't talk to each other
❌ Room management — session_id IS your room
❌ Media mixing — each channel handles its own audio/video`}</Code>
            </Card>

            <Card border="#854d0e" bg="#1a1207">
              <div style={{ color: "#fbbf24", fontWeight: 700, fontSize: 14, marginBottom: 10 }}>
                When WOULD you need LiveKit?
              </div>
              <div style={{ color: "#cbd5e1", fontSize: 13, lineHeight: 1.7 }}>
                Only if you wanted <strong>multi-party video conferencing</strong> — like a family Zoom call
                where the robot is also a participant with a live video feed. For a personal AI assistant
                where YOU talk to ONE entity across multiple channels, a session_id + WebSocket gateway
                is all you need. Way less infrastructure, way less cost, way less complexity.
              </div>
            </Card>
          </div>
        )}

        {/* Bottom summary */}
        <Card border="#334155" style={{ marginTop: 28 }}>
          <div style={{ color: "#e2e8f0", fontWeight: 700, fontSize: 15, marginBottom: 10 }}>
            Bottom Line
          </div>
          <div style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.9 }}>
            <strong style={{ color: "#fbbf24" }}>LiveKit room</strong> = replaced by <strong style={{ color: "#7dd3fc" }}>Agno session_id</strong>.
            Same concept, zero infrastructure.
            Every channel sends the same <code style={{ color: "#7dd3fc" }}>session_id</code> to Agno →
            one conversation, one memory, one context.<br/>

            <strong style={{ color: "#fbbf24" }}>LiveKit audio</strong> = replaced by <strong style={{ color: "#7dd3fc" }}>Gemini Live API</strong> WebSocket
            for voice STT/TTS.<br/>

            <strong style={{ color: "#fbbf24" }}>LiveKit video</strong> = replaced by <strong style={{ color: "#86efac" }}>OM1 VLM → NATS text</strong>.
            Agno doesn't need pixels, it needs sentences.<br/>

            <strong style={{ color: "#fbbf24" }}>LiveKit data channel</strong> = replaced by <strong style={{ color: "#c4b5fd" }}>Gateway WebSocket</strong> for
            Flutter/web text chat.<br/><br/>

            The Gateway is ~200 lines of FastAPI. LiveKit is an entire media server cluster.
            For One Mind OS, the Gateway wins.
          </div>
        </Card>
      </div>
    </div>
  );
}
