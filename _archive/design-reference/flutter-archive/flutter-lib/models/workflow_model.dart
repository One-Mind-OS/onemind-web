/// Workflow models with JSON serialization for Agno-native workflows
///
/// Supports Agno step types: step, steps, parallel, condition, loop, router
/// with proper nesting for control flow constructs.
library;

class WorkflowModel {
  final String? id;
  final String name;
  final String? description;
  final List<WorkflowStep> steps;
  final String? schedule; // Optional cron schedule
  final String status; // active, paused, archived
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkflowModel({
    this.id,
    required this.name,
    this.description,
    this.steps = const [],
    this.schedule,
    this.status = 'active',
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with modified fields
  WorkflowModel copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkflowStep>? steps,
    String? schedule,
    String? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkflowModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      schedule: schedule ?? this.schedule,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from JSON
  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((step) => WorkflowStep.fromJson(step as Map<String, dynamic>))
              .toList() ??
          [],
      schedule: json['schedule'] as String?,
      status: json['status'] as String? ?? 'active',
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert to JSON (Agno-compatible format)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'steps': steps.map((step) => step.toJson()).toList(),
      if (schedule != null) 'schedule': schedule,
      'status': status,
      if (userId != null) 'user_id': userId,
    };
  }

  /// Get total step count (including nested)
  int get totalStepCount {
    int count = 0;
    for (final step in steps) {
      count += step.totalCount;
    }
    return count;
  }

  @override
  String toString() {
    return 'WorkflowModel(id: $id, name: $name, steps: ${steps.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowModel &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description);
  }
}

/// Agno-native workflow step model
///
/// Step types:
/// - step: Single executor (email_send, github_action, etc.) or agent
/// - steps: Sequential step group
/// - parallel: Concurrent execution
/// - condition: If/else branching
/// - loop: Repeat until condition
/// - router: Select path based on expression
/// - agent: Run an Agno agent
class WorkflowStep {
  final String name;
  final String? description;
  final String type; // step, steps, parallel, condition, loop, router, agent

  // For 'step' type
  final String? executor; // email_send, github_action, etc.
  final Map<String, dynamic> config;

  // For 'agent' type
  final String? agentId;

  // For control flow types (condition, loop, router)
  final String? expression; // Evaluation expression
  final int? maxIterations; // For loop
  final String? endCondition; // For loop

  // Nested steps (for steps, parallel, condition, loop)
  final List<WorkflowStep>? steps;

  // Router choices
  final List<WorkflowStep>? choices;

  WorkflowStep({
    required this.name,
    this.description,
    required this.type,
    this.executor,
    this.config = const {},
    this.agentId,
    this.expression,
    this.maxIterations,
    this.endCondition,
    this.steps,
    this.choices,
  });

  /// Create a copy with modified fields
  WorkflowStep copyWith({
    String? name,
    String? description,
    String? type,
    String? executor,
    Map<String, dynamic>? config,
    String? agentId,
    String? expression,
    int? maxIterations,
    String? endCondition,
    List<WorkflowStep>? steps,
    List<WorkflowStep>? choices,
  }) {
    return WorkflowStep(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      executor: executor ?? this.executor,
      config: config ?? this.config,
      agentId: agentId ?? this.agentId,
      expression: expression ?? this.expression,
      maxIterations: maxIterations ?? this.maxIterations,
      endCondition: endCondition ?? this.endCondition,
      steps: steps ?? this.steps,
      choices: choices ?? this.choices,
    );
  }

  /// Create from JSON
  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      name: json['name'] as String? ?? 'Unnamed Step',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'step',
      executor: json['executor'] as String?,
      config: json['config'] as Map<String, dynamic>? ?? {},
      agentId: json['agent_id'] as String?,
      expression: json['expression'] as String?,
      maxIterations: json['max_iterations'] as int?,
      endCondition: json['end_condition'] as String?,
      steps: (json['steps'] as List<dynamic>?)
          ?.map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      choices: (json['choices'] as List<dynamic>?)
          ?.map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to JSON (Agno-compatible)
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'name': name,
    };

    if (description != null) json['description'] = description;
    if (executor != null) json['executor'] = executor;
    if (config.isNotEmpty) json['config'] = config;
    if (agentId != null) json['agent_id'] = agentId;
    if (expression != null) json['expression'] = expression;
    if (maxIterations != null) json['max_iterations'] = maxIterations;
    if (endCondition != null) json['end_condition'] = endCondition;
    if (steps != null) {
      json['steps'] = steps!.map((s) => s.toJson()).toList();
    }
    if (choices != null) {
      json['choices'] = choices!.map((s) => s.toJson()).toList();
    }

    return json;
  }

  /// Check if this is a control flow step
  bool get isControlFlow => ['steps', 'parallel', 'condition', 'loop', 'router'].contains(type);

  /// Check if this step can have nested steps
  bool get canHaveNestedSteps => ['steps', 'parallel', 'condition', 'loop'].contains(type);

  /// Check if this is a router step
  bool get isRouter => type == 'router';

  /// Get total count including nested steps
  int get totalCount {
    int count = 1;
    if (steps != null) {
      for (final nested in steps!) {
        count += nested.totalCount;
      }
    }
    if (choices != null) {
      for (final choice in choices!) {
        count += choice.totalCount;
      }
    }
    return count;
  }

  @override
  String toString() {
    return 'WorkflowStep(name: $name, type: $type, executor: $executor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowStep &&
        other.name == name &&
        other.type == type &&
        other.executor == executor;
  }

  @override
  int get hashCode {
    return Object.hash(name, type, executor);
  }
}

/// Workflow run model for execution results
class WorkflowRunModel {
  final String? id;
  final String workflowId;
  final String? sessionId;
  final String status; // 'running', 'completed', 'failed'
  final dynamic input;
  final dynamic output;
  final String? error;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMs;

  WorkflowRunModel({
    this.id,
    required this.workflowId,
    this.sessionId,
    required this.status,
    this.input,
    this.output,
    this.error,
    DateTime? startedAt,
    this.completedAt,
    this.durationMs,
  }) : startedAt = startedAt ?? DateTime.now();

  /// Create from JSON
  factory WorkflowRunModel.fromJson(Map<String, dynamic> json) {
    return WorkflowRunModel(
      id: json['id'] as String?,
      workflowId: json['workflow_id'] as String,
      sessionId: json['session_id'] as String?,
      status: json['status'] as String,
      input: json['input'],
      output: json['output'],
      error: json['error'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      durationMs: json['duration_ms'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'workflow_id': workflowId,
      if (sessionId != null) 'session_id': sessionId,
      'status': status,
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (error != null) 'error': error,
      'started_at': startedAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (durationMs != null) 'duration_ms': durationMs,
    };
  }

  /// Calculate duration if completed
  Duration? get duration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    if (durationMs != null) {
      return Duration(milliseconds: durationMs!);
    }
    return null;
  }

  @override
  String toString() {
    return 'WorkflowRunModel(id: $id, workflowId: $workflowId, status: $status)';
  }
}

/// Node type information from backend
class NodeTypeInfo {
  final String type;
  final String name;
  final String description;
  final String category;
  final Map<String, dynamic> configSchema;

  NodeTypeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.category,
    required this.configSchema,
  });

  factory NodeTypeInfo.fromJson(Map<String, dynamic> json) {
    return NodeTypeInfo(
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      configSchema: json['config_schema'] as Map<String, dynamic>? ?? {},
    );
  }
}
