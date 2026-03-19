# 🌱 Solarpunk Tech Additions for OneMind OS

> Real, modern-day technology to deepen OneMind OS's solarpunk alignment.
> Every addition publishes to NATS using the existing `Hardware → Python Driver → NATS Topic → OneMind Consumers` pattern.

**Created:** 2026-02-16
**Status:** Planning / Reference Guide

---

## How OneMind OS Is Already Solarpunk

OneMind OS isn't just _themed_ as solarpunk — it's **architecturally** solarpunk. The philosophy runs through the architecture, the design language, the feature set, and the long-term vision.

### 1. Sovereignty & Decentralization — _"Technology Serves Humanity"_

> Solarpunk: Decentralization, community control, rejecting corporate gatekeeping.

OneMind OS is the **anti-ChatGPT**. Where every major AI platform is corporate-controlled, surveillance-laden, and subscription-gated, OneMind OS is:

- **Fully self-hosted** — The entire stack (FastAPI, PostgreSQL, NATS, Flutter) runs on _your_ hardware
- **No third-party platform dependency** — You own your data, your memories, your agent configurations
- **Multi-model sovereignty** — Choose between Claude, GPT-4, Gemini, Llama, or Groq. No vendor lock-in

From `SOUL.md`:

```markdown
## Values

- Privacy and sovereignty
- Technology serves humanity
```

This is the **first principle of solarpunk tech**: the tools you depend on should be tools _you control_.

### 2. Harmony Between Nature & Technology — _The Farm Automation Vision_

> Solarpunk: Not escaping nature, but redesigning civilization to work WITH nature.

OneMind OS isn't just a chat interface. It's a **unified operating system for a regenerative compound**:

```python
# From oneintel/context.py — the ACTUAL default context:
"Home: Family compound with garden, workshop, smart home systems"
"Interests: Robotics, autonomous farming, AI systems, solar punk living"
```

Active projects:

| Project             | What It IS                                  | Solarpunk Alignment                               |
| ------------------- | ------------------------------------------- | ------------------------------------------------- |
| **OneMind OS**      | AI life operating system                    | Sovereign, self-hosted intelligence               |
| **Farm Automation** | Autonomous garden with FarmBot + Eden robot | AI-guided regenerative agriculture                |
| **Home Security**   | Scout robot + drone patrol                  | Community protection, not surveillance capitalism |

NATS topics in the integration vision:

```
sensor.{device}.reading    ← IoT plant/environment sensors
gesture.body               ← Human-in-the-loop embodied interaction
robotics.{robot}.command   ← Physical world automation
fabrication.print.status   ← 3D printing / local manufacturing
```

This is **solarpunk infrastructure**: AI that tends gardens, monitors soil, automates farming, and manufactures locally — not AI that generates ads or surveils consumers.

### 3. One Soul, Multiple Bodies — _Regenerative Technology_

> Solarpunk: Technology that is alive, symbiotic, organic.

The **Agno + OM1 architecture** is the most deeply solarpunk part of the stack. From `docs/architecture/PERSONALITY.md`:

```markdown
# Unified Personality — One Soul

Legacy speaks with one voice across all channels and modalities.
Whether chatting via voice on their phone or hearing the robot speak
in the living room, it's the same personality — Legacy.
```

A single AI consciousness (`Legacy`) expressed through:

- **Digital body**: Chat, email, calendar, research, code generation
- **Physical body**: Robot (Eden) that tends the garden, greets guests, patrols the property
- **Wearable body**: ESP32 smartwatch with heart rate, motion, LiveKit voice

Connected through a **"nervous system"** (NATS JetStream):

```
om1.commands.{agent_id}        ← Brain → Body commands
agno.events.physical.*         ← Body → Brain experiences
personality.sync               ← Soul broadcast to all bodies
heartbeat.{agent_id}           ← Health checks
```

With **shared cross-domain memory**:

> "When the robot shakes someone's hand (physical, via OM1), that interaction is published to NATS, captured by Agno's memory system, and stored as a persistent user memory. Later, when sending that person an email (digital, via Agno), the agent recalls the handshake."

A **symbiotic intelligence** that isn't a cold corporate tool but a _presence_ in your life. An entity with a soul file. It remembers your handshakes. It tends your garden. It speaks with warmth.

### 4. The Visual Language — _Solarpunk Green, Not Cyberpunk Neon_

> Solarpunk: Bright, hopeful colors. Greens, golds, blues. Vibrant and alive.

The codebase annotates nearly every screen with `/// Solar Punk Tactical Theme`. The Flame game engine renders the system heartbeat in:

```dart
color: const Color(0xFF4ADE80), // Solarpunk green
..color = const Color(0xFF0A1A0A) // Dark solarpunk green
```

The design system (`TacticalColors`) uses:

- **Greens** for success/operational (`#22C55E`)
- **Cyan/teal** for information and accent (`#00D9FF`)
- **Amber/gold** for warnings (`#F59E0B`)
- **Red** only for critical/danger

Agent categories are color-coded organically:

```dart
categoryProductivity = Color(0xFF10B981); // Green
categoryIoT = Color(0xFF06B6D4);          // Cyan
categoryResearch = Color(0xFF8B5CF6);     // Purple (natural)
```

The interface feels like a **living control room for a botanical garden**, not a corporate dashboard.

### 5. DIY/Maker Culture — _Open Source Tools, Local Manufacturing_

> Solarpunk: Community workshops, repair cafes, open-source tech, maker culture.

The `roadmap/` folder (210 files!) is a maker's dream:

| Component                  | What                                 | Solarpunk Value                      |
| -------------------------- | ------------------------------------ | ------------------------------------ |
| **ESP32 Watch firmware**   | Working smartwatch code (PlatformIO) | DIY wearable — don't buy Apple Watch |
| **3D CAD Agent**           | AI-generated 3D models (build123d)   | Local digital fabrication            |
| **3D Printer Control**     | Creality/Bambu printer integration   | Make what you need, don't consume    |
| **MediaPipe Gestures**     | Webcam-based gesture control         | Embodied human-computer interaction  |
| **Kinect + TouchDesigner** | Depth camera → particle systems      | Art-technology fusion                |
| **Smart Glasses**          | Brilliant Labs Frame + ESP32 DIY     | Open wearable AR                     |

These aren't corporate products. They're **open-source tools you build yourself** — an ESP32 watch with firmware you flash, a CAD agent that generates STL files for your printer, gesture systems that use your webcam. This is solarpunk maker culture encoded in software.

### 6. The Event Gateway — _Connecting Everything Without a Corporation_

> Solarpunk: Community-driven infrastructure, shared resources, interconnection.

The **Event Gateway** architecture unifies your entire digital life without relying on any single platform:

```python
class EventSource(str, Enum):
    GITHUB = "github"
    CLICKUP = "clickup"
    CALENDAR = "calendar"
    GMAIL = "gmail"
    HOME_ASSISTANT = "homeassistant"  # ← Open source smart home
    SYSTEM = "system"
    WEBHOOK = "webhook"
    MANUAL = "manual"
```

All events are **normalized** into a common schema, published to NATS, and available to your agents. You're building your own **interoperability layer** — the thing big tech refuses to build because walled gardens are more profitable.

The **Nango integration** (supporting 600+ APIs) lets you connect to external services **through your own OAuth proxy** — you hold the tokens, you control the access.

### 7. The Legacy Codex — _Generational Thinking_

> Solarpunk: Post-scarcity thinking, building for future generations.

The `OneMind-Codex/` folder is organized around four pillars:

```
00-24 UI (Unified Intelligence)
25-49 HP (Holistic Performance)
50-74 LE (Legacy Evolution)
75-99 GE (Generational Entrepreneurship)
```

This isn't just personal productivity software. It's a **generational knowledge system**. The "Legacy" in Legacy Codex (and in the AI persona's name) refers to building something that outlasts you — knowledge, systems, values passed down. That's profoundly solarpunk: building infrastructure for abundance that serves communities across time.

### 8. The Two-Tier LLM Architecture — _Appropriate Technology_

> Solarpunk: Right-sized solutions. Not maximum technology, but appropriate technology.

The integration architecture makes a deeply solarpunk choice:

| Tier               | Model          | Latency     | Purpose                                          |
| ------------------ | -------------- | ----------- | ------------------------------------------------ |
| **Tier A (Cloud)** | GPT-4 / Claude | 2-5 seconds | Complex reasoning, research, analysis            |
| **Tier B (Local)** | Qwen3-30B      | <300ms      | Fast physical actions, safety-critical responses |

Safety-critical robot decisions stay **local** — they don't depend on cloud connectivity or corporate APIs. The complex thinking uses cloud models. This is the solarpunk principle of **appropriate technology**: use the big tool when needed, but keep the critical path local and autonomous.

### Solarpunk Alignment Summary

| Solarpunk Principle  | OneMind OS Implementation                                   |
| -------------------- | ----------------------------------------------------------- |
| **Sovereignty**      | Fully self-hosted, no platform dependencies                 |
| **Nature + Tech**    | Farm automation, IoT sensors, plant monitoring              |
| **Decentralization** | NATS mesh networking, leaf nodes for remote sites           |
| **Maker Culture**    | ESP32 watches, 3D printing, gesture control, DIY wearables  |
| **Appropriate Tech** | Two-tier LLM (cloud for thinking, local for action)         |
| **Community Values** | Open-source tools, knowledge codex, generational thinking   |
| **Living Systems**   | One Soul/Multiple Bodies, cross-domain memory, symbiotic AI |
| **Visual Language**  | Solarpunk greens, organic UI, Flame engine visualization    |
| **Regenerative**     | Garden robots, environmental sensors, autonomous farming    |

**Cyberpunk says** _"high tech, low life."_
**OneMind OS says** _"high tech, good life — and the tech works for you, not the other way around."_

---

## New Solarpunk Tech Additions

The following sections describe real, purchasable, implementable technology that can deepen OneMind OS's solarpunk alignment. Every addition integrates via NATS.

---

## 1. ⚡ Energy Monitoring & Management — _The "Solar" in Solarpunk_

**The most glaring gap.** The asset tracking system tracks machines, sensors, and humans — but nothing about **energy generation, consumption, or storage**.

### Real Hardware to Integrate

| Device                                               | Price            | What It Does                            | Integration                                     |
| ---------------------------------------------------- | ---------------- | --------------------------------------- | ----------------------------------------------- |
| **[Emporia Vue](https://www.emporiaenergy.com/)**    | $50-150          | Whole-home energy monitor (per-circuit) | REST API → NATS `energy.consumption.{circuit}`  |
| **[Enphase Envoy](https://enphase.com/)**            | Bundled w/ solar | Solar panel production monitor          | REST API → NATS `energy.production.solar`       |
| **[Sense Energy Monitor](https://sense.com/)**       | $300             | AI-powered device detection             | WebSocket API → NATS `energy.device.{name}`     |
| **[Shelly EM](https://www.shelly.com/)**             | $30              | Per-outlet energy monitoring            | MQTT → NATS bridge (MQTT already on port 1883!) |
| **[Victron Energy](https://www.victronenergy.com/)** | Varies           | Battery, inverter, MPPT controllers     | MQTT → NATS `energy.battery.{id}`               |

### What This Enables in OneMind

- **Energy Dashboard Screen** — Real-time solar production vs. consumption, battery state-of-charge
- **AI Energy Advisor Agent** — "Legacy, should I run the 3D printer now or wait for peak solar?" → Agent checks production forecast
- **Carbon Footprint Tracking** — Log kWh consumed vs. generated, show net carbon status per day
- **Smart Load Shifting** — NATS rule: when `energy.production.solar > 3kW`, trigger: start water heater, charge EVs, run compute jobs
- **Time-of-Use Optimization** — NATS topic: `energy.grid.price` → track time-of-use rates, automate usage around cheap/green periods

### NATS Topics

```
energy.solar.production_w          ← Real-time watts from panels
energy.consumption.{circuit}       ← Per-circuit usage
energy.consumption.total_w         ← Total compound load
energy.battery.soc                 ← State of charge (0-100%)
energy.battery.voltage             ← Battery voltage
energy.battery.time_remaining_h    ← Hours of autonomy left
energy.grid.connected              ← Boolean: are we on grid?
energy.grid.price                  ← Time-of-use rate
energy.device.{name}               ← AI-detected device consumption
energy.mode                        ← "solar" | "battery" | "generator" | "grid"
energy.carbon.daily_net_kg         ← Net carbon for the day
```

**This is the single most impactful addition. If OneMind is solarpunk, it should know how much sun you're harvesting.**

---

## 2. 🌱 Agricultural Intelligence — _Beyond FarmBot_

"Farm Automation" is listed as a project, but no actual soil/plant/weather sensors are wired in yet.

### Real Hardware

| Device                                                      | Price        | What It Does                                         |
| ----------------------------------------------------------- | ------------ | ---------------------------------------------------- |
| **[Ecowitt WS3900](https://www.ecowitt.com/)**              | $200         | Full weather station (rain, wind, UV, soil moisture) |
| **[Ecowitt Soil Sensors](https://www.ecowitt.com/)**        | $20-30 each  | Soil moisture + temperature per bed                  |
| **[FarmBot Genesis](https://farm.bot/)**                    | $1,500-4,000 | CNC garden robot (plant, water, weed, monitor)       |
| **[Atlas Scientific pH/EC](https://atlas-scientific.com/)** | $50-80       | Water quality sensors for hydroponics                |
| **[PurpleAir](https://www2.purpleair.com/)**                | $230         | Hyper-local air quality monitor                      |
| **[OpenSprinkler](https://opensprinkler.com/)**             | $170         | Open-source smart irrigation controller              |

### Integration Architecture

```
Ecowitt Station → Ecowitt API → Python Driver → NATS
  ├── weather.temperature
  ├── weather.humidity
  ├── weather.rain.rate
  ├── weather.uv.index
  ├── soil.moisture.{bed_id}
  └── soil.temperature.{bed_id}

FarmBot → FarmBot API → Python Driver → NATS
  ├── farm.action.water.{bed_id}
  ├── farm.action.seed.{plant_type}
  └── farm.status.{bot_id}
```

### What This Enables

- **Garden Intelligence Screen** — Soil moisture per bed, rain forecast, watering schedule
- **AI Gardening Agent** — "Bed 3 soil moisture dropped below 30% and no rain expected for 48 hours. Triggering irrigation."
- **Seasonal Planning** — Track growing data across seasons in TimescaleDB, use AI to optimize planting schedules
- **Food Production Metrics** — Track what you grow, estimate calories produced, measure food sovereignty

---

## 3. 💧 Water Management — _Regenerative Infrastructure_

### Real Hardware

| Device                                                 | Price | What It Does                                            |
| ------------------------------------------------------ | ----- | ------------------------------------------------------- |
| **[Flume Water Monitor](https://www.flumewater.com/)** | $200  | Whole-home water usage (non-invasive, clamps to meter)  |
| **[Rachio Smart Sprinkler](https://rachio.com/)**      | $200  | Weather-aware irrigation with API                       |
| **[RainMachine](https://www.rainmachine.com/)**        | $250  | Open-API irrigation controller with weather integration |

### NATS Topics

```
water.consumption.total           ← gallons/day
water.consumption.irrigation      ← garden usage
water.harvested.rain              ← rainwater collection tank level
water.quality.ph                  ← water quality monitoring
```

Pairs beautifully with the energy monitoring — **track your resource flows holistically**.

---

## 4. 🏠 Passive Building Intelligence — _Living Architecture_

### Real Hardware

| Device                                                     | Price    | What It Does                                            |
| ---------------------------------------------------------- | -------- | ------------------------------------------------------- |
| **[Aranet4](https://aranet.com/)**                         | $200     | CO₂, temperature, humidity, barometric pressure         |
| **[AirGradient Open Air](https://www.airgradient.com/)**   | $100-150 | Open-source indoor/outdoor AQI monitor                  |
| **[Switchbot Curtain/Blind](https://www.switch-bot.com/)** | $70      | Automated window coverings for passive solar management |
| **[Airthings Wave Plus](https://www.airthings.com/)**      | $230     | Radon, VOC, CO₂, humidity, temperature                  |
| **[Mysa Smart Thermostat](https://getmysa.com/)**          | $130     | Smart baseboard/in-floor heat control                   |

### What This Enables

- **Indoor Air Quality Dashboard** — CO₂ levels, VOCs, humidity per room
- **Passive Climate Agent** — "CO₂ in office is 1200 ppm. Opening blinds for cross-ventilation and turning off AC. Solar gain will heat the room naturally."
- **Building Health Score** — A daily metric: How well is your home breathing?

Solarpunk architecture isn't just green roofs — it's **buildings that are aware of themselves**.

---

## 5. 🔋 Compute Sustainability — _Green AI_

Track the environmental cost of your own AI usage.

### LLM Carbon Footprint Tracker

Already tracking token usage/cost in `run_details.py`. Add carbon estimates:

```python
# Estimated CO₂ per 1M tokens (grams)
CARBON_PER_MILLION_TOKENS = {
    "gpt-4o": 7.2,       # OpenAI (estimated from data center PUE)
    "claude-sonnet": 4.8,  # AWS us-east-1 (partial renewable)
    "gemini-pro": 3.1,     # Google (90%+ renewable data centers)
    "llama-3-local": 0.5,  # Local GPU (depends on your energy source)
}
```

### Green Compute Routing

If your solar panels are producing excess energy, route inference to **local models (Ollama)**. If cloudy, use efficient cloud models (Gemini on Google's renewable-powered data centers).

```
NATS Rule:
  IF energy.production.solar > energy.consumption.home + 500W
  THEN agent.model.preference = "local-llama"
  ELSE agent.model.preference = "gemini-flash"
```

**Your AI runs on sunlight when the sun is out.**

---

## 6. 🚲 Transportation & Mobility

| Device/Service                                                      | What It Does                                     |
| ------------------------------------------------------------------- | ------------------------------------------------ |
| **[Lectric eBike](https://lectricebikes.com/) + GPS tracker**       | Track e-bike trips, estimate CO₂ avoided vs. car |
| **[OVMS (Open Vehicle Monitoring)](https://www.openvehicles.com/)** | Open-source EV monitoring (SoC, range, charging) |
| **[Chargie](https://chargie.org/)**                                 | Open EV charging network data                    |

### NATS Topics

```
transport.ev.{id}.soc              ← Battery state of charge
transport.ev.{id}.charging         ← Charging state + power source
transport.trip.{id}.co2_saved      ← CO₂ avoided vs. ICE vehicle
transport.ebike.{id}.trip          ← Trip data
```

### What This Enables

- **Mobility Carbon Score** — "This month you avoided 340 lbs of CO₂ by biking/EV instead of driving"
- **Smart Charging** — Charge EV only during solar peak or off-peak grid hours

---

## 7. 🍄 Composting & Waste Intelligence

| Device                                                                                                        | Price               | What It Does                         |
| ------------------------------------------------------------------------------------------------------------- | ------------------- | ------------------------------------ |
| **[Lomi Composter](https://lomi.com/)** or **[FoodCycler](https://www.vitamix.com/us/en_us/shop/foodcycler)** | $300-500            | Electric composting with tracking    |
| **[Mill Food Recycler](https://mill.com/)**                                                                   | $33/mo subscription | AI-tracked food waste with analytics |
| **Custom ESP32 + load cell**                                                                                  | $15                 | Track compost bin weight over time   |

### NATS Topics

```
waste.compost.{bin_id}.weight    ← Track compost volume over time
waste.compost.{bin_id}.temp      ← Composting temperature (activity indicator)
waste.food.daily_kg              ← Food waste tracking
```

### What This Enables

- **Waste-to-Resource Dashboard** — Track how much food waste becomes garden compost
- **Circular Economy Score** — "78% of your organic waste was composted this month"

---

## 8. 🧬 Biodiversity & Ecology Monitoring

| Device                                                              | Price                        | What It Does                            |
| ------------------------------------------------------------------- | ---------------------------- | --------------------------------------- |
| **[BirdNET-Pi](https://www.birdweather.com/birdnetpi)**             | $50 (Raspberry Pi + USB mic) | AI bird species identification by sound |
| **[Wildlife Camera (Browning)](https://browningtrailcameras.com/)** | $80-200                      | Motion-triggered wildlife photos        |
| **[iNaturalist API](https://www.inaturalist.org/)**                 | Free                         | Species identification from photos      |

### NATS Topics

```
ecology.bird.detected              ← {species, confidence, timestamp}
ecology.wildlife.sighting          ← {species, image_url, location}
ecology.biodiversity.score         ← Daily species diversity index
```

### What This Enables

- **Biodiversity Dashboard** — "Your property hosts 47 bird species. Up 12% from last year."
- **Ecological Impact Score** — Measure whether your land management is _increasing_ or decreasing biodiversity
- **Legacy agent insight**: "I heard a Barred Owl last night at 2:14 AM — first detection this season."

**Profoundly solarpunk** — your AI doesn't just manage your productivity, it _listens to the ecosystem around you_.

---

## 9. 🏡 The Compound Dashboard — _Where It All Comes Together_

All of these feed into a **Solarpunk Compound Score** — a single daily metric:

```python
compound_score = {
    "energy": {
        "solar_production_kwh": 42.3,
        "grid_consumption_kwh": 8.1,
        "self_sufficiency": "84%",
    },
    "water": {
        "consumed_gallons": 120,
        "rainwater_harvested_gallons": 45,
        "irrigation_efficiency": "92%",
    },
    "food": {
        "garden_harvest_lbs": 3.2,
        "composted_lbs": 1.8,
        "food_sovereignty": "12%",
    },
    "mobility": {
        "ev_miles": 28,
        "bike_miles": 6,
        "co2_avoided_lbs": 34,
    },
    "ecology": {
        "bird_species_today": 12,
        "biodiversity_index": 0.73,
    },
    "compute": {
        "ai_tokens_used": 45000,
        "solar_powered_inference": "67%",
        "carbon_grams": 18,
    },
    "overall_solarpunk_score": "B+"  # AI-generated holistic grade
}
```

Published to `onemind.compound.daily_score` on NATS. Visualized on a new **Compound Dashboard Screen** in Flutter. Tracked over time in TimescaleDB.

---

## Priority Ranking

| Addition                                    | Cost       | Effort | Solarpunk Impact | Priority                                 |
| ------------------------------------------- | ---------- | ------ | ---------------- | ---------------------------------------- |
| **Energy Monitoring** (Emporia/Shelly)      | $50-150    | Low    | 🌟🌟🌟🌟🌟       | **P0** — The name is SOLAR punk          |
| **Weather/Soil Sensors** (Ecowitt)          | $200-300   | Low    | 🌟🌟🌟🌟         | **P1**                                   |
| **Indoor Air Quality** (Aranet4)            | $200       | Low    | 🌟🌟🌟           | **P1**                                   |
| **BirdNET-Pi**                              | $50        | Low    | 🌟🌟🌟🌟         | **P1** — Incredibly cool, cheap          |
| **Water Monitoring** (Flume)                | $200       | Low    | 🌟🌟🌟           | **P2**                                   |
| **Green Compute Routing**                   | $0         | Medium | 🌟🌟🌟🌟         | **P2** — Already have the infrastructure |
| **Smart Irrigation** (Rachio/OpenSprinkler) | $170-200   | Low    | 🌟🌟🌟           | **P2**                                   |
| **EV Monitoring** (OVMS)                    | $150       | Medium | 🌟🌟🌟           | **P3**                                   |
| **Composting Tracking**                     | $15-50 DIY | Low    | 🌟🌟             | **P3**                                   |
| **Carbon Footprint Tracker**                | $0         | Low    | 🌟🌟🌟           | **P2** — Pure software                   |

---

## The Common Thread

Every one of these publishes to NATS using the existing pattern:

```
Hardware → Python Driver → NATS Topic → OneMind Consumers
```

The architecture is already built for this. The nervous system is ready — it just needs more senses.

The solarpunk question isn't "can my AI chat well?" It's **"does my AI know how much rain fell today, how many watts my panels made, how many bird species visited, and whether my garden needs water?"** That's what makes it a _living system_ instead of a productivity tool.

---

_Updated: 2026-02-16_
_Based on: Full codebase review + solarpunk technology analysis_
