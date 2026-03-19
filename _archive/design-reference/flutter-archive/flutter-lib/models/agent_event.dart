/// Represents events from agent execution
class AgentEvent {
  final AgentEventType type;
  final String? content;
  final String? toolName;
  final String? agentName;
  final DateTime timestamp;

  AgentEvent({
    required this.type,
    this.content,
    this.toolName,
    this.agentName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum AgentEventType {
  content,        // Regular content output
  toolCall,       // Tool is being called
  toolResult,     // Tool returned result
  agentStart,     // Agent started working
  agentComplete,  // Agent finished
  teamCoordination, // Team coordination message
}
