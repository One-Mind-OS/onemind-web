# OneMind OS - Agno Backend Integration

> How the OneMind OS UI connects to the Agno agent framework.

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Frontend                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Chat Screen │  │ Agent Store │  │ Workforce Manager   │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                     │             │
│         └────────────────┼─────────────────────┘             │
│                          │                                   │
│                    ┌─────▼─────┐                             │
│                    │  Riverpod │  (State Management)         │
│                    │ Providers │                             │
│                    └─────┬─────┘                             │
└──────────────────────────┼───────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   FastAPI   │  (API Gateway)
                    │   /api/v1   │
                    └──────┬──────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    ┌────▼────┐      ┌─────▼─────┐     ┌─────▼─────┐
    │  Agno   │      │  Memory   │     │   MCP     │
    │ Agents  │      │  (SQLite) │     │  Servers  │
    └─────────┘      └───────────┘     └───────────┘
```

---

## 2. API Endpoints

### 2.1 Agent Management

```
GET    /api/v1/agents              # List your agents
POST   /api/v1/agents              # Create new agent
GET    /api/v1/agents/{id}         # Get agent details
PUT    /api/v1/agents/{id}         # Update agent config
DELETE /api/v1/agents/{id}         # Delete agent

GET    /api/v1/agents/{id}/runs    # Agent run history
POST   /api/v1/agents/{id}/run     # Execute agent (non-streaming)
```

### 2.2 Chat / Conversations

```
GET    /api/v1/conversations                    # List conversations
POST   /api/v1/conversations                    # Create conversation
GET    /api/v1/conversations/{id}               # Get with messages
DELETE /api/v1/conversations/{id}               # Delete conversation

POST   /api/v1/conversations/{id}/messages      # Send message
GET    /api/v1/conversations/{id}/messages      # Get message history
POST   /api/v1/conversations/{id}/branch/{msg}  # Branch from message
```

### 2.3 Streaming (AG-UI Protocol)

```
WebSocket /api/v1/ws/chat/{conversation_id}

# Events (Server → Client)
- TEXT_MESSAGE_START
- TEXT_MESSAGE_CONTENT
- TEXT_MESSAGE_END
- TOOL_CALL_START
- TOOL_CALL_ARGS
- TOOL_CALL_END
- STATE_SNAPSHOT
- STATE_DELTA
- RUN_STARTED
- RUN_FINISHED
- RUN_ERROR

# Events (Client → Server)
- USER_MESSAGE
- TOOL_APPROVAL (HITL)
- CANCEL_RUN
```

### 2.4 Tools / MCP

```
GET    /api/v1/tools                    # List available tools
GET    /api/v1/tools/{id}               # Tool details
POST   /api/v1/tools/{id}/execute       # Manual tool execution

GET    /api/v1/mcp/servers              # List MCP servers
POST   /api/v1/mcp/servers              # Add MCP server
DELETE /api/v1/mcp/servers/{id}         # Remove MCP server
GET    /api/v1/mcp/servers/{id}/tools   # Tools from server
```

### 2.5 Memory / Context

```
GET    /api/v1/memory                   # Get memory summary
POST   /api/v1/memory/add               # Add memory entry
GET    /api/v1/memory/search?q=         # Search memories
DELETE /api/v1/memory/{id}              # Delete memory entry
```

---

## 3. Data Models

### 3.1 Agent

```python
class Agent(BaseModel):
    id: str
    name: str
    description: str | None
    avatar_url: str | None
    category: Literal["coding", "research", "creative", "productivity", "lifeos", "home"]

    # Agno config
    model: str  # e.g., "gpt-4o", "claude-sonnet"
    instructions: str
    tools: list[str]  # Tool IDs
    mcp_servers: list[str]  # MCP server IDs

    # Behavior
    requires_approval: bool  # HITL for tool calls
    max_iterations: int
    temperature: float

    # Stats
    total_runs: int
    last_used_at: datetime | None
    created_at: datetime
```

### 3.2 Conversation

```python
class Conversation(BaseModel):
    id: str
    title: str
    agent_id: str | None  # None = multi-agent / router

    # Tree structure
    messages: list[Message]
    active_branch: str  # Current branch path

    created_at: datetime
    updated_at: datetime
```

### 3.3 Message

```python
class Message(BaseModel):
    id: str
    conversation_id: str
    parent_id: str | None  # For branching

    role: Literal["user", "assistant", "system", "tool"]
    content: str

    # For assistant messages
    agent_id: str | None
    model: str | None

    # Tool calls
    tool_calls: list[ToolCall] | None
    tool_results: list[ToolResult] | None

    # Metadata
    tokens_used: int | None
    latency_ms: int | None
    created_at: datetime
```

### 3.4 ToolCall / ToolResult

```python
class ToolCall(BaseModel):
    id: str
    name: str
    arguments: dict
    status: Literal["pending", "approved", "rejected", "running", "completed", "failed"]

class ToolResult(BaseModel):
    tool_call_id: str
    output: Any
    error: str | None
    duration_ms: int
```

---

## 4. Agno Integration Points

### 4.1 Agent Creation → Agno Agent

```python
# backend/agents/factory.py
from agno import Agent, Tool

def create_agno_agent(agent_config: Agent) -> AgnoAgent:
    """Convert our Agent model to Agno Agent instance."""

    # Load tools
    tools = [load_tool(t) for t in agent_config.tools]

    # Load MCP servers
    for server_id in agent_config.mcp_servers:
        server = get_mcp_server(server_id)
        tools.extend(server.get_tools())

    return AgnoAgent(
        name=agent_config.name,
        model=agent_config.model,
        instructions=agent_config.instructions,
        tools=tools,
        show_tool_calls=True,
        markdown=True,
    )
```

### 4.2 Chat → Agno Run

```python
# backend/agents/runner.py
async def run_agent_stream(
    agent_id: str,
    conversation_id: str,
    user_message: str,
    websocket: WebSocket,
):
    """Stream agent response via WebSocket."""

    agent_config = get_agent(agent_id)
    agno_agent = create_agno_agent(agent_config)

    # Build message history
    messages = get_conversation_messages(conversation_id)

    # Stream response
    async for event in agno_agent.astream(
        message=user_message,
        messages=messages,
    ):
        # Convert to AG-UI event format
        ui_event = convert_to_agui_event(event)
        await websocket.send_json(ui_event.dict())
```

### 4.3 HITL (Tool Approval)

```python
# backend/agents/hitl.py
async def handle_tool_approval(
    websocket: WebSocket,
    tool_call: ToolCall,
    agent_config: Agent,
) -> bool:
    """Request user approval for tool execution."""

    if not agent_config.requires_approval:
        return True

    # Send approval request
    await websocket.send_json({
        "type": "TOOL_APPROVAL_REQUEST",
        "tool_call": tool_call.dict(),
    })

    # Wait for response
    response = await websocket.receive_json()

    if response["type"] == "TOOL_APPROVED":
        return True
    elif response["type"] == "TOOL_REJECTED":
        return False
```

---

## 5. Frontend Providers

### 5.1 Agent Provider

```dart
// frontend/lib/providers/agents_provider.dart

@riverpod
class AgentsNotifier extends _$AgentsNotifier {
  @override
  Future<List<Agent>> build() async {
    return await ref.read(apiProvider).getAgents();
  }

  Future<Agent> createAgent(CreateAgentRequest request) async {
    final agent = await ref.read(apiProvider).createAgent(request);
    ref.invalidateSelf();
    return agent;
  }

  Future<void> deleteAgent(String id) async {
    await ref.read(apiProvider).deleteAgent(id);
    ref.invalidateSelf();
  }
}
```

### 5.2 Chat Provider (Streaming)

```dart
// frontend/lib/providers/chat_provider.dart

@riverpod
class ChatNotifier extends _$ChatNotifier {
  WebSocketChannel? _channel;

  @override
  ChatState build(String conversationId) {
    ref.onDispose(() => _channel?.sink.close());
    return ChatState.initial();
  }

  Future<void> connect() async {
    final wsUrl = 'ws://api/v1/ws/chat/${arg}';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel!.stream.listen((event) {
      final data = jsonDecode(event);
      _handleEvent(data);
    });
  }

  void _handleEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'TEXT_MESSAGE_CONTENT':
        state = state.copyWith(
          streamingContent: state.streamingContent + event['content'],
        );
        break;
      case 'TOOL_CALL_START':
        state = state.copyWith(
          activeToolCalls: [...state.activeToolCalls, ToolCall.fromJson(event)],
        );
        break;
      // ... handle other events
    }
  }

  void sendMessage(String content) {
    _channel?.sink.add(jsonEncode({
      'type': 'USER_MESSAGE',
      'content': content,
    }));
  }

  void approveToolCall(String toolCallId) {
    _channel?.sink.add(jsonEncode({
      'type': 'TOOL_APPROVED',
      'tool_call_id': toolCallId,
    }));
  }
}
```

---

## 6. File Structure

```
backend/
├── agents/
│   ├── __init__.py
│   ├── api.py          # FastAPI routes
│   ├── factory.py      # Agno agent creation
│   ├── runner.py       # Agent execution
│   ├── hitl.py         # Human-in-the-loop
│   └── models.py       # Pydantic models
│
├── conversations/
│   ├── __init__.py
│   ├── api.py
│   ├── branching.py    # Message tree logic
│   └── models.py
│
├── tools/
│   ├── __init__.py
│   ├── api.py
│   ├── registry.py     # Tool registration
│   └── builtin/        # Built-in tools
│
├── mcp/
│   ├── __init__.py
│   ├── api.py
│   ├── client.py       # MCP server connections
│   └── models.py
│
└── memory/
    ├── __init__.py
    ├── api.py
    └── store.py        # SQLite/vector storage
```

---

## 7. Migration Path

### Phase 1: Core APIs
- [x] Agent CRUD endpoints
- [x] Basic conversation endpoints
- [x] Non-streaming chat

### Phase 2: Streaming
- [x] SSE streaming endpoint
- [x] AG-UI event conversion (AGUIEvent.fromLegacy)
- [x] Frontend streaming provider
- [ ] WebSocket endpoint (future)

### Phase 3: Tools & MCP
- [x] Tool registry (ToolCardRegistry)
- [x] Tool card rendering
- [x] HITL flow (HITLState, approval UI)
- [ ] MCP server management UI

### Phase 4: Memory
- [ ] Memory storage
- [ ] Context injection
- [ ] Search/retrieval

---

## 7.1 Implementation Notes (January 2025)

### Frontend Streaming Implementation

The current implementation uses SSE (Server-Sent Events) rather than WebSockets:

```dart
// frontend/lib/agno/services/agno_client.dart
Stream<RunEvent> streamAgentRun({
  required String agentId,
  required String message,
  String? sessionId,
}) async* {
  final response = await dio.post(
    '/api/v1/agents/$agentId/run',
    data: {'message': message, 'session_id': sessionId},
    options: Options(responseType: ResponseType.stream),
  );

  // Parse SSE events
  await for (final event in _parseSSE(response.data.stream)) {
    yield RunEvent.fromJson(event);
  }
}
```

### Key Provider Locations

```
frontend/lib/platform/providers/app_providers.dart
├── currentSessionIdProvider     # Session persistence
├── selectedAgentIdProvider      # Active agent
├── messagesProvider             # Chat messages
├── isStreamingProvider          # Streaming state
├── agentsProvider               # Agent list
├── modelsProvider               # AI models
└── agnoClientProvider           # API client

frontend/lib/agno/chat/providers/enhanced_chat_provider.dart
├── enhancedMessagesProvider     # Enhanced messages with tool results
├── aguiRunStateProvider         # AG-UI run state
└── branchedConversationProvider # Branching support
```

### AG-UI Protocol in Frontend

```dart
// frontend/lib/platform/protocol/agui_protocol.dart
enum AGUIEventType {
  textMessageContent,  // Text streaming
  toolCallStart,       // Tool execution started
  toolCallEnd,         // Tool completed with result
  stepStarted,         // Reasoning step
  runFinished,         // Run complete
  runError,           // Error occurred
}

// Convert legacy backend events to AG-UI
final aguiEvent = AGUIEvent.fromLegacy(runEvent.toJson());
```

---

## 8. Existing Code to Leverage

Current backend has:
- `backend/consciousness/` - Agent/model infrastructure
- `backend/platform/` - Integrations framework
- `backend/lifeos/` - Domain services

Key integration points:
- Reuse existing SQLite storage patterns
- Extend current FastAPI app
- Leverage existing auth/config systems
