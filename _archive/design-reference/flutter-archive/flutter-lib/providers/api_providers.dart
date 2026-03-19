import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent_model.dart';
import '../models/team_model.dart';
import '../models/model_info.dart';
import '../models/memory_model.dart';
import '../models/session_model.dart';
import '../models/knowledge_model.dart';
import '../models/workflow_model.dart';
import '../models/approval_model.dart';
import '../models/run_model.dart';
import '../models/evaluation_model.dart';
import '../services/api_service.dart';

// =============================================================================
// Agent Providers
// =============================================================================

/// Agents list provider - fetches from API
final agentsProvider = FutureProvider<List<AgentModel>>((ref) async {
  return await ApiService.listAgents();
});

/// Specific agent provider
final agentProvider = FutureProvider.family<AgentModel, String>((ref, agentId) async {
  return await ApiService.getAgent(agentId);
});

/// Agent mutations provider
final agentMutationsProvider = Provider((ref) => AgentMutations(ref));

class AgentMutations {
  final Ref ref;

  AgentMutations(this.ref);

  Future<AgentModel> createAgent(AgentModel agent) async {
    final newAgent = await ApiService.createAgent(agent);
    // Invalidate agents list to refresh
    ref.invalidate(agentsProvider);
    return newAgent;
  }

  Future<AgentModel> updateAgent(String agentId, AgentModel agent) async {
    final updatedAgent = await ApiService.updateAgent(agentId, agent);
    // Invalidate both list and specific agent
    ref.invalidate(agentsProvider);
    ref.invalidate(agentProvider(agentId));
    return updatedAgent;
  }

  Future<void> deleteAgent(String agentId) async {
    await ApiService.deleteAgent(agentId);
    // Invalidate agents list
    ref.invalidate(agentsProvider);
  }

  Future<Map<String, dynamic>> reloadAgentConfigs() async {
    final result = await ApiService.reloadAgentConfigs();
    // Invalidate agents list to refresh
    ref.invalidate(agentsProvider);
    return result;
  }
}

// =============================================================================
// Agent Execution Providers
// =============================================================================

/// Agent run mutations provider
final agentRunMutationsProvider = Provider((ref) => AgentRunMutations(ref));

class AgentRunMutations {
  final Ref ref;

  AgentRunMutations(this.ref);

  Future<AgentRunModel> runAgent(
    String agentId,
    String message, {
    String? sessionId,
  }) async {
    final result = await ApiService.runAgent(
      agentId,
      message: message,
      sessionId: sessionId,
    );
    // Invalidate sessions to refresh after run
    ref.invalidate(sessionsProvider);
    return result;
  }

  Future<void> cancelRun(String agentId, String runId) async {
    await ApiService.cancelAgentRun(agentId, runId);
  }

  Future<void> continueRun(
    String agentId,
    String runId, {
    bool approved = true,
    Map<String, dynamic>? input,
  }) async {
    await ApiService.continueAgentRun(
      agentId,
      runId,
      approved: approved,
      input: input,
    );
  }
}

// =============================================================================
// Team Providers
// =============================================================================

/// Teams list provider - fetches from API
final teamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  return await ApiService.listTeams();
});

/// Specific team provider
final teamProvider = FutureProvider.family<TeamModel, String>((ref, teamId) async {
  return await ApiService.getTeam(teamId);
});

/// Team mutations provider
final teamMutationsProvider = Provider((ref) => TeamMutations(ref));

class TeamMutations {
  final Ref ref;

  TeamMutations(this.ref);

  Future<TeamModel> createTeam(TeamModel team) async {
    final newTeam = await ApiService.createTeam(team);
    ref.invalidate(teamsProvider);
    return newTeam;
  }

  Future<TeamModel> updateTeam(String teamId, TeamModel team) async {
    final updatedTeam = await ApiService.updateTeam(teamId, team);
    ref.invalidate(teamsProvider);
    ref.invalidate(teamProvider(teamId));
    return updatedTeam;
  }

  Future<void> deleteTeam(String teamId) async {
    await ApiService.deleteTeam(teamId);
    ref.invalidate(teamsProvider);
  }

  Future<Map<String, dynamic>> reloadTeamConfigs() async {
    final result = await ApiService.reloadTeamConfigs();
    // Invalidate teams list to refresh
    ref.invalidate(teamsProvider);
    return result;
  }
}

// =============================================================================
// Team Execution Providers
// =============================================================================

/// Team run mutations provider
final teamRunMutationsProvider = Provider((ref) => TeamRunMutations(ref));

class TeamRunMutations {
  final Ref ref;

  TeamRunMutations(this.ref);

  Future<TeamRunModel> runTeam(
    String teamId,
    String message, {
    String? sessionId,
  }) async {
    final result = await ApiService.runTeam(
      teamId,
      message: message,
      sessionId: sessionId,
    );
    // Invalidate sessions to refresh after run
    ref.invalidate(sessionsProvider);
    return result;
  }

  Future<void> cancelRun(String teamId, String runId) async {
    await ApiService.cancelTeamRun(teamId, runId);
  }
}

// =============================================================================
// Tool Providers
// =============================================================================

// =============================================================================
// Tools Providers - REMOVED
// =============================================================================
// AgentOS does not expose /tools endpoint publicly.
// Tools are pre-configured per agent and not exposed via REST API.

// =============================================================================
// Model Providers
// =============================================================================

/// Models list provider - fetches from API
final modelsProvider = FutureProvider<List<ModelInfo>>((ref) async {
  return await ApiService.listModels();
});

/// Models by provider filter
final modelsByProviderProvider = FutureProvider.family<List<ModelInfo>, String?>((ref, provider) async {
  return await ApiService.listModels(provider: provider);
});

/// Model providers list
final modelProvidersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await ApiService.listProviders();
});

/// Specific model provider
final modelProvider = FutureProvider.family<ModelInfo, String>((ref, modelId) async {
  return await ApiService.getModel(modelId);
});

// =============================================================================
// Memory Providers
// =============================================================================

/// Memories list provider - fetches from API
final memoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  return await ApiService.listMemories();
});

/// Specific memory provider
final memoryProvider = FutureProvider.family<MemoryModel, String>((ref, memoryId) async {
  return await ApiService.getMemory(memoryId);
});

/// Memory mutations provider
final memoryMutationsProvider = Provider((ref) => MemoryMutations(ref));

class MemoryMutations {
  final Ref ref;

  MemoryMutations(this.ref);

  Future<MemoryModel> createMemory(MemoryModel memory) async {
    final newMemory = await ApiService.createMemory(memory);
    // Invalidate memories list to refresh
    ref.invalidate(memoriesProvider);
    return newMemory;
  }

  Future<void> deleteMemory(String memoryId) async {
    await ApiService.deleteMemory(memoryId);
    // Invalidate memories list
    ref.invalidate(memoriesProvider);
  }
}

// =============================================================================
// Session Providers
// =============================================================================

/// Sessions list provider - fetches from API
final sessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  return await ApiService.listSessions();
});

/// Sessions by agent filter
final sessionsByAgentProvider = FutureProvider.family<List<SessionModel>, String?>((ref, agentId) async {
  return await ApiService.listSessions(agentId: agentId);
});

/// Specific session provider
final sessionProvider = FutureProvider.family<SessionModel, String>((ref, sessionId) async {
  return await ApiService.getSession(sessionId);
});

/// Session mutations provider
final sessionMutationsProvider = Provider((ref) => SessionMutations(ref));

class SessionMutations {
  final Ref ref;

  SessionMutations(this.ref);

  Future<void> deleteSession(String sessionId) async {
    await ApiService.deleteSession(sessionId);
    // Invalidate sessions list
    ref.invalidate(sessionsProvider);
  }
}

// =============================================================================
// Knowledge Base Providers
// =============================================================================

/// Knowledge bases list provider - fetches from API
final knowledgeBasesProvider = FutureProvider<List<KnowledgeBaseModel>>((ref) async {
  return await ApiService.listKnowledgeBases();
});

/// Specific knowledge base provider
final knowledgeBaseProvider = FutureProvider.family<KnowledgeBaseModel, String>((ref, kbId) async {
  return await ApiService.getKnowledgeBase(kbId);
});

// Note: AgentOS knowledge endpoints don't have document sub-resources
// Documents are managed as part of the knowledge content object

/// Knowledge base mutations provider
final knowledgeMutationsProvider = Provider((ref) => KnowledgeMutations(ref));

class KnowledgeMutations {
  final Ref ref;

  KnowledgeMutations(this.ref);

  Future<KnowledgeBaseModel> createKnowledgeBase(KnowledgeBaseModel kb) async {
    final newKb = await ApiService.createKnowledgeBase(kb);
    // Invalidate knowledge bases list to refresh
    ref.invalidate(knowledgeBasesProvider);
    return newKb;
  }

  Future<KnowledgeBaseModel> updateKnowledgeBase(String kbId, KnowledgeBaseModel kb) async {
    final updatedKb = await ApiService.updateKnowledgeBase(kbId, kb);
    // Invalidate both list and specific knowledge base
    ref.invalidate(knowledgeBasesProvider);
    ref.invalidate(knowledgeBaseProvider(kbId));
    return updatedKb;
  }

  Future<void> deleteKnowledgeBase(String kbId) async {
    await ApiService.deleteKnowledgeBase(kbId);
    // Invalidate knowledge bases list
    ref.invalidate(knowledgeBasesProvider);
  }

  // Note: AgentOS knowledge endpoints don't have document sub-resources
  // Documents are managed as part of the knowledge content object
}

// =============================================================================
// Workflow Providers
// =============================================================================

/// Workflows list provider - fetches from AgentOS native API
final workflowsProvider = FutureProvider<List<WorkflowModel>>((ref) async {
  return await ApiService.listWorkflows();
});

/// Specific workflow provider
final workflowProvider = FutureProvider.family<WorkflowModel, String>((ref, workflowId) async {
  return await ApiService.getWorkflow(workflowId);
});

/// Workflow mutations provider
final workflowMutationsProvider = Provider((ref) => WorkflowMutations(ref));

class WorkflowMutations {
  final Ref ref;

  WorkflowMutations(this.ref);

  Future<WorkflowModel> createWorkflow(WorkflowModel workflow) async {
    final newWorkflow = await ApiService.createWorkflow(workflow);
    // Invalidate workflows list to refresh
    ref.invalidate(workflowsProvider);
    return newWorkflow;
  }

  Future<WorkflowModel> updateWorkflow(String workflowId, WorkflowModel workflow) async {
    final updatedWorkflow = await ApiService.updateWorkflow(workflowId, workflow);
    // Invalidate both list and specific workflow
    ref.invalidate(workflowsProvider);
    ref.invalidate(workflowProvider(workflowId));
    return updatedWorkflow;
  }

  Future<void> deleteWorkflow(String workflowId) async {
    await ApiService.deleteWorkflow(workflowId);
    // Invalidate workflows list
    ref.invalidate(workflowsProvider);
  }

  Future<WorkflowRunModel> runWorkflow(String workflowId, {Map<String, dynamic>? input}) async {
    return await ApiService.runWorkflow(workflowId, input: input);
  }

  Future<void> cancelWorkflowRun(String workflowId, String runId) async {
    await ApiService.cancelWorkflowRun(workflowId, runId);
  }
}

// =============================================================================
// Approval Providers (HITL)
// =============================================================================

/// Approval requests list provider - fetches from AgentOS native API
final approvalsProvider = FutureProvider<List<ApprovalRequest>>((ref) async {
  return await ApiService.listApprovals();
});

/// Approval mutations provider
final approvalMutationsProvider = Provider((ref) => ApprovalMutations(ref));

class ApprovalMutations {
  final Ref ref;

  ApprovalMutations(this.ref);

  Future<void> approveRequest(String requestId) async {
    await ApiService.approveRequest(requestId);
    // Invalidate approvals list to refresh
    ref.invalidate(approvalsProvider);
  }

  Future<void> rejectRequest(String requestId) async {
    await ApiService.rejectRequest(requestId);
    // Invalidate approvals list to refresh
    ref.invalidate(approvalsProvider);
  }
}

/// Paused runs list provider - fetches from AgentOS native API
final pausedRunsProvider = FutureProvider<List<PausedRun>>((ref) async {
  return await ApiService.listPausedRuns();
});

/// Paused run mutations provider
final pausedRunMutationsProvider = Provider((ref) => PausedRunMutations(ref));

class PausedRunMutations {
  final Ref ref;

  PausedRunMutations(this.ref);

  Future<void> continueRun(String runId) async {
    await ApiService.continueRun(runId);
    // Invalidate paused runs list to refresh
    ref.invalidate(pausedRunsProvider);
  }

  Future<void> cancelRun(String runId) async {
    await ApiService.cancelRun(runId);
    // Invalidate paused runs list to refresh
    ref.invalidate(pausedRunsProvider);
  }
}

// =============================================================================
// Evaluation Providers
// =============================================================================

/// Evaluations list provider - fetches from AgentOS native API
final evaluationsProvider = FutureProvider<List<EvaluationRunModel>>((ref) async {
  return await ApiService.listEvaluations();
});

/// Specific evaluation provider
final evaluationProvider = FutureProvider.family<EvaluationRunModel, String>((ref, evalId) async {
  return await ApiService.getEvaluation(evalId);
});

/// Evaluation mutations provider
final evaluationMutationsProvider = Provider((ref) => EvaluationMutations(ref));

class EvaluationMutations {
  final Ref ref;

  EvaluationMutations(this.ref);

  Future<EvaluationRunModel> createEvaluation(EvaluationRunModel evaluation) async {
    final newEvaluation = await ApiService.createEvaluation(evaluation);
    // Invalidate evaluations list to refresh
    ref.invalidate(evaluationsProvider);
    return newEvaluation;
  }

  Future<EvaluationRunModel> updateEvaluation(String evalId, EvaluationRunModel evaluation) async {
    final updatedEvaluation = await ApiService.updateEvaluation(evalId, evaluation);
    // Invalidate both list and specific evaluation
    ref.invalidate(evaluationsProvider);
    ref.invalidate(evaluationProvider(evalId));
    return updatedEvaluation;
  }

  Future<void> deleteEvaluation(String evalId) async {
    await ApiService.deleteEvaluations([evalId]);
    // Invalidate evaluations list
    ref.invalidate(evaluationsProvider);
  }

  Future<void> deleteEvaluations(List<String> evalIds) async {
    await ApiService.deleteEvaluations(evalIds);
    // Invalidate evaluations list
    ref.invalidate(evaluationsProvider);
  }
}
