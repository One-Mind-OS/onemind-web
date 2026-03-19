# OneMind OS - UI Wireframes & Screen Specifications

## Overview

This document provides detailed wireframe specifications for all major screens in OneMind OS - your personal AI command center. Each screen is designed using the OneMind OS Design System tokens (`OS*` classes) and follows mobile-first principles.

**Design System Import:**
```dart
import 'package:onemind/shared/theme/os.dart';
```

---

## Personal App Philosophy

OneMind OS is designed as a **deeply personal** app - not a business tool or enterprise platform. Every design decision prioritizes:

### Design Principles for Personal Use

| Principle | Implementation |
|-----------|----------------|
| **Your Space** | The app feels like your personal command center, not a shared workspace |
| **Intimate Scale** | UI elements sized for personal use, not boardroom presentations |
| **Your Agents** | Agents are YOUR assistants, customized to YOUR workflows |
| **Private First** | No team features, no sharing dialogs - this is your private space |
| **Individual Focus** | Optimized for one user's productivity, not collaboration |
| **Personal Memory** | The app remembers YOUR preferences, YOUR context, YOUR patterns |

### Personal vs Enterprise Comparison

```
Personal App (OneMind)              Enterprise Tool
─────────────────────────────────   ─────────────────────────────────
"My Agents"                         "Team Agents"
"Your daily insights"               "Team analytics dashboard"
Single user workspace               Multi-user collaboration
Personal memory & context           Shared knowledge base
Your conversation history           Team conversation logs
Custom agents for you               Admin-managed agent library
```

### UI Tone Guidelines

- Use "you/your" language, not "users" or "teams"
- Greeting: "Good morning, Zeus" not "Welcome back, user"
- Empty states: "Create your first agent" not "No agents found"
- Privacy-first defaults, no sharing prompts
- Personal metrics: "Your productivity" not "Team performance"

---

## 1. Hub - Agent Library

The Agent Library shows your personal agents and provides access to the Agent Builder.

### 1.1 Agent Library - Browse View

```
┌─────────────────────────────────────────────┐
│ ← Hub                              🔍  ⚙️  │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  🔍 Search your agents...           │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Categories                                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐      │
│  │ 💻 │ │ 🎨 │ │ 📊 │ │ ✍️ │ │ 🏠 │      │
│  │Code│ │Crtv│ │Prod│ │Life│ │Home│      │
│  └────┘ └────┘ └────┘ └────┘ └────┘      │
│                                             │
│  Your Agents                          +Add  │
│  ┌─────────────┐ ┌─────────────┐           │
│  │   ┌───┐     │ │   ┌───┐     │           │
│  │   │🤖│     │ │   │🎯│     │           │
│  │   └───┘     │ │   └───┘     │           │
│  │ CodeHelper  │ │ TaskPilot   │           │
│  │ Coding      │ │ Productivity│           │
│  │ Claude Opus │ │ GPT-4o      │           │
│  │ [Chat] [⚙️]  │ │ [Chat] [⚙️]  │           │
│  └─────────────┘ └─────────────┘           │
│                                             │
│  Built-in Agents                      More  │
│  ┌─────────────┐ ┌─────────────┐           │
│  │   ┌───┐     │ │   ┌───┐     │           │
│  │   │📝│     │ │   │🔍│     │           │
│  │   └───┘     │ │   └───┘     │           │
│  │ Legacy      │ │ ResearchBot │           │
│  │ General     │ │ Research    │           │
│  │ Auto        │ │ Claude      │           │
│  │ [Primary]   │ │ [Chat]      │           │
│  └─────────────┘ └─────────────┘           │
│                                             │
│  Your Installed Agents (4)           Manage │
│  ┌──────────────────────────────────────┐  │
│  │ 🤖 CodeMaster      Active    ●●●○○   │  │
│  │ 🎯 TaskPilot       Idle      ●●○○○   │  │
│  │ 📊 DataViz         Disabled  ●●●●○   │  │
│  │ ✨ CreativeAI      Active    ●○○○○   │  │
│  └──────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 1.2 Agent Detail View

```
┌─────────────────────────────────────────────┐
│ ← Back                                  ⋮   │
├─────────────────────────────────────────────┤
│                                             │
│         ┌───────────────────┐               │
│         │                   │               │
│         │       🤖          │               │
│         │    CodeMaster     │               │
│         │                   │               │
│         └───────────────────┘               │
│                                             │
│    ⭐ 4.9  │  2.1k installs  │  by @agno   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │          [ Install Agent ]           │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌──────┐ ┌──────┐ ┌──────┐               │
│  │ 💻   │ │ 🔧   │ │ 📦   │               │
│  │Coding│ │Debug │ │Build │               │
│  └──────┘ └──────┘ └──────┘               │
│                                             │
│  ─────────────────────────────────────────  │
│                                             │
│  Description                                │
│  Expert Python & TypeScript developer.      │
│  Writes clean, tested, production-ready     │
│  code with best practices built-in.         │
│                                             │
│  Capabilities                               │
│  ├─ Write & refactor code                   │
│  ├─ Debug complex issues                    │
│  ├─ Code review & suggestions               │
│  ├─ Generate unit tests                     │
│  └─ Explain code patterns                   │
│                                             │
│  Skills Used (3)                            │
│  ┌────────────┐ ┌────────────┐             │
│  │ 🔗 GitHub  │ │ 📁 Files   │             │
│  └────────────┘ └────────────┘             │
│  ┌────────────┐                             │
│  │ 🖥️ Terminal│                             │
│  └────────────┘                             │
│                                             │
│  Reviews                             See all│
│  ┌──────────────────────────────────────┐  │
│  │ ⭐⭐⭐⭐⭐                              │  │
│  │ "Best coding assistant I've used!"    │  │
│  │ - @developer123, 2 days ago           │  │
│  └──────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

---

## 2. Hub - Skill Store

The Skill Store is where users discover and install MCP tools/skills that agents can use.

### 2.1 Skill Store - Browse View

```
┌─────────────────────────────────────────────┐
│ ← Hub                              🔍  ⚙️  │
├─────────────────────────────────────────────┤
│                                             │
│  ┌────────────────────────────────────┐    │
│  │ Agents │ [Skills] │ Workforces     │    │
│  └────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  🔍 Search skills & tools...        │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Categories                                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐      │
│  │ 🌐 │ │ 📁 │ │ 🔗 │ │ 🗄️ │ │ 🏠 │      │
│  │Web │ │File│ │API │ │ DB │ │Home│      │
│  └────┘ └────┘ └────┘ └────┘ └────┘      │
│                                             │
│  Installed Skills (6)                       │
│  ┌──────────────────────────────────────┐  │
│  │ ● GitHub         ● Filesystem        │  │
│  │ ● Web Search     ● Calendar          │  │
│  │ ● Memory         ● Home Assistant    │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Recommended for You                 See all│
│  ┌─────────────┐ ┌─────────────┐           │
│  │   ┌───┐     │ │   ┌───┐     │           │
│  │   │📧│     │ │   │📊│     │           │
│  │   └───┘     │ │   └───┘     │           │
│  │ Gmail MCP   │ │ Notion MCP  │           │
│  │ Email tools │ │ Docs & DBs  │           │
│  │ [Install]   │ │ [Install]   │           │
│  └─────────────┘ └─────────────┘           │
│                                             │
│  All Skills                        Filter ▼│
│  ┌──────────────────────────────────────┐  │
│  │ 🔗 Slack MCP                          │  │
│  │    Send messages, read channels       │  │
│  │    ★★★★☆ 4.2  •  1.2k installs       │  │
│  ├──────────────────────────────────────┤  │
│  │ 🗄️ PostgreSQL MCP                     │  │
│  │    Query and manage databases         │  │
│  │    ★★★★★ 4.8  •  3.4k installs       │  │
│  ├──────────────────────────────────────┤  │
│  │ 🌐 Puppeteer MCP                      │  │
│  │    Browser automation & scraping      │  │
│  │    ★★★★☆ 4.1  •  890 installs        │  │
│  └──────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 2.2 Skill Detail View

```
┌─────────────────────────────────────────────┐
│ ← Back                                  ⋮   │
├─────────────────────────────────────────────┤
│                                             │
│         ┌───────────────────┐               │
│         │       🔗          │               │
│         │    GitHub MCP     │               │
│         │   by @modelcontextprotocol       │
│         └───────────────────┘               │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │        [ ✓ Installed ]               │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Tools Provided (12)                        │
│  ┌──────────────────────────────────────┐  │
│  │ create_repository                     │  │
│  │ Create a new GitHub repository        │  │
│  ├──────────────────────────────────────┤  │
│  │ create_issue                          │  │
│  │ Create an issue in a repository       │  │
│  ├──────────────────────────────────────┤  │
│  │ create_pull_request                   │  │
│  │ Create a new pull request             │  │
│  ├──────────────────────────────────────┤  │
│  │ search_repositories                   │  │
│  │ Search for GitHub repositories        │  │
│  ├──────────────────────────────────────┤  │
│  │ + 8 more tools...                     │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Configuration                              │
│  ┌──────────────────────────────────────┐  │
│  │ GITHUB_TOKEN                          │  │
│  │ ┌────────────────────────────────┐   │  │
│  │ │ ghp_xxxx...xxxx            [👁️]│   │  │
│  │ └────────────────────────────────┘   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Used By Agents (3)                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐      │
│  │🤖 Code  │ │🔍 Review│ │📝 Docs  │      │
│  │ Master  │ │   Bot   │ │  Writer │      │
│  └─────────┘ └─────────┘ └─────────┘      │
│                                             │
│  [ Uninstall ]    [ Configure ]            │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

---

## 3. Agent Builder

The Agent Builder allows users to create custom agents with a visual no-code interface or advanced YAML/Python editing.

### 3.1 Agent Builder - List View

```
┌─────────────────────────────────────────────┐
│ Agent Builder                     [+ New]   │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  🔍 Search your agents...           │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Your Agents (3)                            │
│  ┌──────────────────────────────────────┐  │
│  │ ┌────┐                               │  │
│  │ │ 🏠 │  Home Automator               │  │
│  │ └────┘  Controls smart home devices  │  │
│  │         Skills: 2  •  Draft          │  │
│  │                          [Edit] [···]│  │
│  ├──────────────────────────────────────┤  │
│  │ ┌────┐                               │  │
│  │ │ 📧 │  Email Assistant              │  │
│  │ └────┘  Manages inbox & drafts       │  │
│  │         Skills: 3  •  Published      │  │
│  │                          [Edit] [···]│  │
│  ├──────────────────────────────────────┤  │
│  │ ┌────┐                               │  │
│  │ │ 📊 │  Report Generator             │  │
│  │ └────┘  Creates weekly reports       │  │
│  │         Skills: 4  •  Published      │  │
│  │                          [Edit] [···]│  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Templates                           See all│
│  ┌─────────────┐ ┌─────────────┐           │
│  │ 📝          │ │ 🔬          │           │
│  │ Writing     │ │ Research    │           │
│  │ Assistant   │ │ Assistant   │           │
│  │ [Use]       │ │ [Use]       │           │
│  └─────────────┘ └─────────────┘           │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 3.2 Agent Builder - Edit View

```
┌─────────────────────────────────────────────┐
│ ← Back           Home Automator    [Save]   │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ [Basic] │ Skills │ Prompts │ Test   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Agent Identity                             │
│  ┌──────────────────────────────────────┐  │
│  │         ┌────────┐                   │  │
│  │         │  🏠    │  [Change Icon]    │  │
│  │         └────────┘                   │  │
│  │                                      │  │
│  │ Name                                 │  │
│  │ ┌────────────────────────────────┐  │  │
│  │ │ Home Automator                 │  │  │
│  │ └────────────────────────────────┘  │  │
│  │                                      │  │
│  │ Description                          │  │
│  │ ┌────────────────────────────────┐  │  │
│  │ │ Controls smart home devices    │  │  │
│  │ │ based on voice commands        │  │  │
│  │ └────────────────────────────────┘  │  │
│  │                                      │  │
│  │ Category                             │  │
│  │ ┌────────────────────────────────┐  │  │
│  │ │ Home Automation            ▼   │  │  │
│  │ └────────────────────────────────┘  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Model Configuration                        │
│  ┌──────────────────────────────────────┐  │
│  │ Base Model                           │  │
│  │ ┌────────────────────────────────┐  │  │
│  │ │ Claude Sonnet 4            ▼   │  │  │
│  │ └────────────────────────────────┘  │  │
│  │                                      │  │
│  │ Temperature        [========●==] 0.7│  │
│  │ Max Tokens         [====●======] 4096│  │
│  │                                      │  │
│  │ ☑️ Enable extended thinking          │  │
│  │ ☐ Enable tool streaming              │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ Delete Agent ]                           │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 3.3 Agent Builder - Skills Tab

```
┌─────────────────────────────────────────────┐
│ ← Back           Home Automator    [Save]   │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ Basic │ [Skills] │ Prompts │ Test   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Assigned Skills (2)                        │
│  ┌──────────────────────────────────────┐  │
│  │ 🏠 Home Assistant MCP         [✕]    │  │
│  │    Lights, climate, sensors          │  │
│  │    ┌──────────────────────────┐      │  │
│  │    │ Enabled tools: 8/12      │      │  │
│  │    │ [Configure Permissions]  │      │  │
│  │    └──────────────────────────┘      │  │
│  ├──────────────────────────────────────┤  │
│  │ 📅 Calendar MCP               [✕]    │  │
│  │    Schedule, events, reminders       │  │
│  │    ┌──────────────────────────┐      │  │
│  │    │ Enabled tools: 5/5       │      │  │
│  │    │ [Configure Permissions]  │      │  │
│  │    └──────────────────────────┘      │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ + Add Skill ]                            │
│                                             │
│  Available Skills                           │
│  ┌──────────────────────────────────────┐  │
│  │ 🌐 Web Search      [ + Add ]         │  │
│  │ 📁 Filesystem      [ + Add ]         │  │
│  │ 🔔 Notifications   [ + Add ]         │  │
│  │ 💾 Memory          [ + Add ]         │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  💡 Tip: Only assign skills this agent     │
│     actually needs. Fewer skills = faster  │
│     responses and lower token usage.       │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 3.4 Agent Builder - Prompts Tab

```
┌─────────────────────────────────────────────┐
│ ← Back           Home Automator    [Save]   │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ Basic │ Skills │ [Prompts] │ Test   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  System Prompt                              │
│  ┌──────────────────────────────────────┐  │
│  │ You are a smart home automation      │  │
│  │ assistant. You help users control    │  │
│  │ their home devices using natural     │  │
│  │ language commands.                   │  │
│  │                                      │  │
│  │ Guidelines:                          │  │
│  │ - Always confirm before executing    │  │
│  │   potentially disruptive actions     │  │
│  │ - Provide status updates             │  │
│  │ - Suggest automations based on       │  │
│  │   usage patterns                     │  │
│  │                                      │  │
│  │                              ▼ More  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ 🪄 Generate with AI ]                   │
│                                             │
│  Example Conversations (2)                  │
│  ┌──────────────────────────────────────┐  │
│  │ 👤 "Turn off all the lights"         │  │
│  │ 🤖 "I'll turn off all lights now..." │  │
│  │                          [Edit] [✕]  │  │
│  ├──────────────────────────────────────┤  │
│  │ 👤 "Set thermostat to 72°"           │  │
│  │ 🤖 "Setting the thermostat to 72°F"  │  │
│  │                          [Edit] [✕]  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ + Add Example ]                          │
│                                             │
│  Variables                                  │
│  ┌──────────────────────────────────────┐  │
│  │ {{user_name}}     Your name          │  │
│  │ {{home_name}}     Home nickname      │  │
│  │ {{timezone}}      Local timezone     │  │
│  │                     [ + Add Variable]│  │
│  └──────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

---

## 4. Enhanced Chat Screen

The main chat interface with @mentions, model routing, extended thinking, and tool card rendering.

### Key Features
- **@Mentions**: Type `@` to mention and switch agents mid-conversation
- **Model Router**: Select AI model (Claude, GPT-4, etc.) per message
- **Tool Cards**: Rich UI for tool execution results
- **Reasoning Steps**: Collapsible thinking display
- **HITL**: Human-in-the-loop approval for sensitive actions

### 4.1 Chat - Conversation View

```
┌─────────────────────────────────────────────┐
│ ┌────┐                                      │
│ │ 🤖 │ CodeMaster              ▼    ⋮      │
│ └────┘ Claude Sonnet 4                      │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │                           2:34 PM     │  │
│  │  Can you help me write a function    │  │
│  │  to validate email addresses?        │  │
│  │                                  👤  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │ 🤖                          2:34 PM  │  │
│  │                                      │  │
│  │  ┌────────────────────────────────┐ │  │
│  │  │ 💭 Thinking...                 │ │  │
│  │  │ ├─ Considering regex patterns  │ │  │
│  │  │ ├─ Evaluating RFC compliance   │ │  │
│  │  │ └─ Checking edge cases...      │ │  │
│  │  └────────────────────────────────┘ │  │
│  │                                      │  │
│  │  I'll create an email validator.    │  │
│  │                                      │  │
│  │  ┌────────────────────────────────┐ │  │
│  │  │ 📄 email_validator.py          │ │  │
│  │  │ ─────────────────────────────  │ │  │
│  │  │ import re                      │ │  │
│  │  │                                │ │  │
│  │  │ def validate_email(email):     │ │  │
│  │  │     pattern = r'^[a-zA-Z0...   │ │  │
│  │  │                                │ │  │
│  │  │ [Copy] [Apply] [Run]           │ │  │
│  │  └────────────────────────────────┘ │  │
│  │                                      │  │
│  │  [👍] [👎] [📋] [↩️] [🔀]          │  │
│  └──────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │
│  │ Ask CodeMaster anything...       📎 │   │
│  │                                  🎤 │   │
│  │                              [Send] │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  🧠 Claude Sonnet 4  │  🔧 3 tools  │  💬  │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 4.2 Chat - Agent Switcher

```
┌─────────────────────────────────────────────┐
│ Select Agent                          [✕]  │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  🔍 Search agents...                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Recently Used                              │
│  ┌──────────────────────────────────────┐  │
│  │ 🤖 CodeMaster            ● Active    │  │
│  │    Expert Python & TypeScript dev    │  │
│  ├──────────────────────────────────────┤  │
│  │ 🎯 TaskPilot                         │  │
│  │    Task management & planning        │  │
│  ├──────────────────────────────────────┤  │
│  │ ✨ CreativeAI                        │  │
│  │    Writing & content creation        │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  All Agents                                 │
│  ┌──────────────────────────────────────┐  │
│  │ 📊 DataViz                           │  │
│  │    Data visualization expert         │  │
│  ├──────────────────────────────────────┤  │
│  │ 🏠 Home Automator                    │  │
│  │    Smart home control                │  │
│  ├──────────────────────────────────────┤  │
│  │ 📧 Email Assistant                   │  │
│  │    Inbox management                  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ + Create New Agent ]                     │
│                                             │
└─────────────────────────────────────────────┘
```

### 4.3 Chat - Tool Execution Card

```
┌──────────────────────────────────────┐
│ 🔧 Executing: search_repositories    │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░  70%    │ │
│  └────────────────────────────────┘ │
│                                      │
│  Parameters:                         │
│  ├─ query: "flutter state mgmt"      │
│  ├─ sort: "stars"                    │
│  └─ limit: 10                        │
│                                      │
│  [ Cancel ]                          │
│                                      │
└──────────────────────────────────────┘
```

### 4.4 Chat - Tool Result Card (Expandable)

```
┌──────────────────────────────────────┐
│ ✅ search_repositories        [▼]   │
├──────────────────────────────────────┤
│                                      │
│ Found 10 repositories:               │
│                                      │
│ ┌────────────────────────────────┐  │
│ │ ⭐ 15.2k  flutter/riverpod     │  │
│ │ Reactive state management      │  │
│ ├────────────────────────────────┤  │
│ │ ⭐ 11.8k  flutter/bloc         │  │
│ │ BLoC pattern implementation    │  │
│ ├────────────────────────────────┤  │
│ │ ⭐ 8.4k   getx/getx            │  │
│ │ Simplified state management    │  │
│ └────────────────────────────────┘  │
│                                      │
│ [View All] [Open in GitHub]          │
│                                      │
└──────────────────────────────────────┘
```

### 4.5 Chat - Human-in-the-Loop Approval

```
┌──────────────────────────────────────┐
│ ⚠️ Approval Required                 │
├──────────────────────────────────────┤
│                                      │
│ The agent wants to execute:          │
│                                      │
│ ┌────────────────────────────────┐  │
│ │ 🗑️ delete_file                 │  │
│ │                                │  │
│ │ Path: /src/legacy/old_api.ts  │  │
│ │                                │  │
│ │ This will permanently delete   │  │
│ │ the file. This action cannot   │  │
│ │ be undone.                     │  │
│ └────────────────────────────────┘  │
│                                      │
│ [ Deny ]              [ Approve ]    │
│                                      │
│ ☐ Always allow for this session     │
│                                      │
└──────────────────────────────────────┘
```

---

## 5. Workforce Manager

Manage multi-agent teams that work together on complex tasks.

### 5.1 Workforce - List View

```
┌─────────────────────────────────────────────┐
│ Workforces                        [+ New]   │
├─────────────────────────────────────────────┤
│                                             │
│  Active Workforces                          │
│  ┌──────────────────────────────────────┐  │
│  │ 🏗️ Project Setup Team                │  │
│  │    ┌───┐ ┌───┐ ┌───┐                │  │
│  │    │🤖│→│📝│→│🧪│                │  │
│  │    └───┘ └───┘ └───┘                │  │
│  │    Code → Docs → Tests               │  │
│  │    Status: ●●●○○ 60% complete        │  │
│  │                              [View]  │  │
│  ├──────────────────────────────────────┤  │
│  │ 📊 Data Pipeline                     │  │
│  │    ┌───┐   ┌───┐                     │  │
│  │    │📥│ ⇉ │📈│                     │  │
│  │    └───┘   └───┘                     │  │
│  │    Ingest ∥ Analyze (parallel)       │  │
│  │    Status: ●○○○○ Running...          │  │
│  │                              [View]  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Saved Workforces                           │
│  ┌──────────────────────────────────────┐  │
│  │ 🔄 Code Review Pipeline              │  │
│  │    Review → Security → Style         │  │
│  │    Last run: 2 days ago              │  │
│  ├──────────────────────────────────────┤  │
│  │ 📝 Content Creation Flow             │  │
│  │    Research → Write → Edit           │  │
│  │    Last run: 5 days ago              │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Templates                                  │
│  ┌─────────────┐ ┌─────────────┐           │
│  │ 🧪 Testing  │ │ 📖 Docs     │           │
│  │   Pipeline  │ │  Generator  │           │
│  │ [Use]       │ │ [Use]       │           │
│  └─────────────┘ └─────────────┘           │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 5.2 Workforce - Builder View

```
┌─────────────────────────────────────────────┐
│ ← Back     Project Setup Team      [Save]   │
├─────────────────────────────────────────────┤
│                                             │
│  Execution Mode                             │
│  ┌──────────────────────────────────────┐  │
│  │ [Sequential]  Parallel   Adaptive    │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Agent Pipeline                             │
│  ┌──────────────────────────────────────┐  │
│  │                                      │  │
│  │   ┌────────────┐                     │  │
│  │   │     🤖     │                     │  │
│  │   │ CodeMaster │                     │  │
│  │   │ Step 1     │                     │  │
│  │   └─────┬──────┘                     │  │
│  │         │                            │  │
│  │         ▼                            │  │
│  │   ┌────────────┐                     │  │
│  │   │     📝     │                     │  │
│  │   │ DocWriter  │                     │  │
│  │   │ Step 2     │                     │  │
│  │   └─────┬──────┘                     │  │
│  │         │                            │  │
│  │         ▼                            │  │
│  │   ┌────────────┐                     │  │
│  │   │     🧪     │                     │  │
│  │   │ TestRunner │                     │  │
│  │   │ Step 3     │                     │  │
│  │   └────────────┘                     │  │
│  │                                      │  │
│  │         [ + Add Agent ]              │  │
│  │                                      │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Handoff Rules                              │
│  ┌──────────────────────────────────────┐  │
│  │ Step 1 → Step 2                      │  │
│  │ Pass: code files, summary            │  │
│  │ Condition: code compiles             │  │
│  │                         [Edit]       │  │
│  ├──────────────────────────────────────┤  │
│  │ Step 2 → Step 3                      │  │
│  │ Pass: docs, code files               │  │
│  │ Condition: always                    │  │
│  │                         [Edit]       │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ Test Run ]            [ Deploy ]         │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

---

## 6. Conversation Management

### 6.1 Conversation List / History

```
┌─────────────────────────────────────────────┐
│ Conversations                     [+ New]   │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  🔍 Search conversations...         │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Today                                      │
│  ┌──────────────────────────────────────┐  │
│  │ 🤖 Email validator function          │  │
│  │    CodeMaster • 2:34 PM • 4 msgs     │  │
│  ├──────────────────────────────────────┤  │
│  │ 🎯 Weekly planning session           │  │
│  │    TaskPilot • 10:15 AM • 12 msgs    │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Yesterday                                  │
│  ┌──────────────────────────────────────┐  │
│  │ ✨ Blog post draft review            │  │
│  │    CreativeAI • 4:20 PM • 8 msgs     │  │
│  ├──────────────────────────────────────┤  │
│  │ 🏠 Automation debugging              │  │
│  │    Home Automator • 11:30 AM • 6 msgs│  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Last 7 Days                                │
│  ┌──────────────────────────────────────┐  │
│  │ 📊 Quarterly report analysis         │  │
│  │    DataViz • Mon • 15 msgs           │  │
│  ├──────────────────────────────────────┤  │
│  │ 🤖 API refactoring discussion        │  │
│  │    CodeMaster • Sun • 22 msgs        │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ Load More ]                              │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 6.2 Conversation Branch View

```
┌─────────────────────────────────────────────┐
│ ← Back          Branch History         ⋮    │
├─────────────────────────────────────────────┤
│                                             │
│  Email validator function                   │
│  ┌──────────────────────────────────────┐  │
│  │                                      │  │
│  │  [User] Can you help me write...     │  │
│  │         │                            │  │
│  │         ▼                            │  │
│  │  [AI] I'll create an email...        │  │
│  │         │                            │  │
│  │    ┌────┴────┐                       │  │
│  │    ▼         ▼                       │  │
│  │  Branch A   Branch B ← current       │  │
│  │  (regex)    (library)                │  │
│  │    │          │                      │  │
│  │    ▼          ▼                      │  │
│  │  [AI]       [AI]                     │  │
│  │  Here's     Using the                │  │
│  │  regex...   email-validator...       │  │
│  │               │                      │  │
│  │               ▼                      │  │
│  │             [User]                   │  │
│  │             That works!              │  │
│  │                                      │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Branches (2)                               │
│  ┌──────────────────────────────────────┐  │
│  │ ○ Branch A: Regex approach           │  │
│  │   Created at message 2               │  │
│  │                        [Switch To]   │  │
│  ├──────────────────────────────────────┤  │
│  │ ● Branch B: Library approach         │  │
│  │   Created at message 2  (current)    │  │
│  │                        [Continue]    │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [ Create New Branch ]                      │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 7. Settings

### 7.1 Settings - Main View

```
┌─────────────────────────────────────────────┐
│ Settings                                    │
├─────────────────────────────────────────────┤
│                                             │
│  Account                                    │
│  ┌──────────────────────────────────────┐  │
│  │ 👤 Profile & Account             >   │  │
│  │ 🔑 API Keys                      >   │  │
│  │ 💳 Subscription                  >   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Models & Agents                            │
│  ┌──────────────────────────────────────┐  │
│  │ 🧠 Default Model                     │  │
│  │    Claude Sonnet 4                >  │  │
│  │ 🤖 Agent Defaults               >   │  │
│  │ 🔧 Skill Permissions            >   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Interface                                  │
│  ┌──────────────────────────────────────┐  │
│  │ 🎨 Theme                             │  │
│  │    ○ System  ● Dark  ○ Light        │  │
│  │ 🔤 Font Size                         │  │
│  │    [●===|====|====] Medium          │  │
│  │ 💬 Message Display              >   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Privacy & Data                             │
│  ┌──────────────────────────────────────┐  │
│  │ 🧠 Memory Settings              >   │  │
│  │ 📊 Usage Statistics             >   │  │
│  │ 🗑️ Clear Conversations          >   │  │
│  │ 📤 Export Data                  >   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  About                                      │
│  ┌──────────────────────────────────────┐  │
│  │ Version 1.0.0 (build 42)             │  │
│  │ 📜 Terms of Service             >   │  │
│  │ 🔒 Privacy Policy               >   │  │
│  └──────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

### 7.2 Settings - API Keys

```
┌─────────────────────────────────────────────┐
│ ← Settings           API Keys               │
├─────────────────────────────────────────────┤
│                                             │
│  Model Providers                            │
│  ┌──────────────────────────────────────┐  │
│  │ 🟢 Anthropic                         │  │
│  │    sk-ant-...7x9f      [Edit] [Test] │  │
│  ├──────────────────────────────────────┤  │
│  │ 🟢 OpenAI                            │  │
│  │    sk-proj-...3k2m     [Edit] [Test] │  │
│  ├──────────────────────────────────────┤  │
│  │ ○ Google AI                          │  │
│  │    Not configured          [+ Add]   │  │
│  ├──────────────────────────────────────┤  │
│  │ ○ Groq                               │  │
│  │    Not configured          [+ Add]   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Skill Integrations                         │
│  ┌──────────────────────────────────────┐  │
│  │ 🟢 GitHub                            │  │
│  │    ghp_...xxxx         [Edit] [Test] │  │
│  ├──────────────────────────────────────┤  │
│  │ 🟢 Home Assistant                    │  │
│  │    eyJhb...            [Edit] [Test] │  │
│  ├──────────────────────────────────────┤  │
│  │ ○ Slack                              │  │
│  │    Not configured          [+ Add]   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ⚠️ API keys are stored securely and       │
│     encrypted on your device.               │
│                                             │
├─────────────────────────────────────────────┤
│  [Hub]    [Chat]    [Build]    [Settings]  │
└─────────────────────────────────────────────┘
```

---

## 8. Component Specifications

### 8.1 Agent Card Component

```
Dimensions: Full width, 72px height (compact), 120px (expanded)
Padding: 16px horizontal, 12px vertical
Border Radius: 12px
Background: surface (0xFF0A0A0A)
Border: 1px surfaceBorder (0xFF1A1A1A)

┌──────────────────────────────────────────────────┐
│  ┌────┐                                          │
│  │ 🤖 │  Agent Name                              │
│  │    │  Short description text here             │
│  └────┘  ⭐ 4.9 (2.1k)  •  Skills: 3             │
│                                          [Action]│
└──────────────────────────────────────────────────┘

Icon: 40x40px, 8px border radius
Name: 16px, semiBold, textPrimary
Description: 14px, regular, textSecondary
Meta: 12px, regular, textTertiary
Action Button: 32px height, primary color
```

### 8.2 Message Bubble Component

```
User Message:
- Background: primary (0xFFFF0000) at 10% opacity
- Border: 1px primary at 30% opacity
- Border Radius: 16px (8px bottom-right)
- Max Width: 85% of container
- Alignment: Right

Assistant Message:
- Background: surface (0xFF0A0A0A)
- Border: 1px surfaceBorder (0xFF1A1A1A)
- Border Radius: 16px (8px bottom-left)
- Max Width: 85% of container
- Alignment: Left

Content Padding: 16px
Typography: 15px, regular, textPrimary
Timestamp: 11px, regular, textTertiary
```

### 8.3 Tool Card Component

```
Container:
- Background: surfaceElevated (0xFF111111)
- Border: 1px surfaceBorder (0xFF1A1A1A)
- Border Radius: 12px
- Padding: 16px

Header:
- Icon: 20px
- Tool Name: 14px, medium, textPrimary
- Status Badge: 8px dot + 12px text

Progress Bar (when running):
- Height: 4px
- Background: surface
- Fill: primary with glow

Parameters:
- Key: 12px, regular, textTertiary
- Value: 12px, mono, textSecondary

Actions:
- Button Height: 32px
- Spacing: 8px
```

### 8.4 Input Bar Component

```
Container:
- Background: surface (0xFF0A0A0A)
- Border: 1px surfaceBorder (0xFF1A1A1A)
- Border Radius: 24px
- Min Height: 48px
- Max Height: 200px (expandable)
- Padding: 8px 16px

Text Input:
- Typography: 15px, regular, textPrimary
- Placeholder: 15px, regular, textTertiary
- Line Height: 1.5

Buttons:
- Attachment: 24px icon, left side
- Voice: 24px icon, right side
- Send: 36px circular, primary, right side
```

---

## 9. Navigation Structure

```
┌─────────────────────────────────────────────┐
│                    App                       │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │              Hub Tab                 │   │
│  │  ├── Agent Store                     │   │
│  │  │   ├── Browse                      │   │
│  │  │   ├── Search                      │   │
│  │  │   └── Agent Detail                │   │
│  │  ├── Skill Store                     │   │
│  │  │   ├── Browse                      │   │
│  │  │   └── Skill Detail                │   │
│  │  └── Workforce Store                 │   │
│  │      ├── Browse                      │   │
│  │      └── Workforce Detail            │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │              Chat Tab                │   │
│  │  ├── Conversation List               │   │
│  │  ├── Conversation View               │   │
│  │  │   ├── Agent Switcher (modal)      │   │
│  │  │   ├── Branch View (sheet)         │   │
│  │  │   └── HITL Approval (dialog)      │   │
│  │  └── New Conversation                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │              Build Tab               │   │
│  │  ├── Agent Builder                   │   │
│  │  │   ├── List View                   │   │
│  │  │   └── Edit View                   │   │
│  │  │       ├── Basic Tab               │   │
│  │  │       ├── Skills Tab              │   │
│  │  │       ├── Prompts Tab             │   │
│  │  │       └── Test Tab                │   │
│  │  └── Workforce Builder               │   │
│  │      ├── List View                   │   │
│  │      └── Edit View                   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │           Settings Tab               │   │
│  │  ├── Account                         │   │
│  │  ├── Models & Agents                 │   │
│  │  ├── Interface                       │   │
│  │  ├── Privacy & Data                  │   │
│  │  └── About                           │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 10. Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| Mobile | < 600px | Single column, bottom nav |
| Tablet | 600-900px | Two column where applicable, side nav option |
| Desktop | > 900px | Three column, persistent side nav |

### Mobile (Default)
- Bottom navigation bar
- Full-width cards
- Modal sheets for secondary views
- Conversation list is separate screen

### Tablet
- Optional side navigation rail
- Two-column layout for Hub (categories + content)
- Conversation list as sidebar in chat

### Desktop
- Persistent side navigation
- Three-panel layout for chat (conversations, messages, context)
- Multi-window support for agent builder

---

## Implementation Priority

### Phase 1 - Core Chat
1. Enhanced Chat Screen with agent switching
2. Message bubbles with extended thinking
3. Tool card rendering (basic)
4. Human-in-the-loop approval

### Phase 2 - Hub
1. Agent Store browse/search
2. Agent detail view
3. Skill Store browse
4. Installation flow

### Phase 3 - Builder
1. Agent Builder list view
2. Basic/Skills/Prompts tabs
3. Agent testing interface

### Phase 4 - Advanced
1. Workforce Manager
2. Conversation branching
3. Memory management
4. Full settings screens
