import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Tactical screens
import '../screens/tactical_shell.dart';
import '../screens/command_screen.dart';
import '../screens/tactical_map_screen.dart';
import '../screens/sitreps_screen.dart';
import '../screens/missions_screen.dart';
import '../screens/more_screen.dart';

// Existing screens (reused with tactical styling)
import '../../agno/chat/screens/enhanced_chat_screen.dart';
import '../../agno/agents/screens/agents_screen.dart';
import '../../agno/teams/screens/teams_screen.dart';
import '../../agno/workflows/screens/workflows_screen.dart';
import '../../agno/memory/screens/memory_screen.dart';
import '../../agno/knowledge/screens/knowledge_screen.dart';
import '../../agno/tools/screens/tools_screen.dart';
import '../../agno/models/screens/models_screen.dart';
import '../../agno/approvals/screens/approvals_screen.dart';
import '../../integrations/mcp/screens/mcp_screen.dart';
import '../../safety/metrics/screens/metrics_screen.dart';
import '../../safety/metrics/screens/traces_screen.dart';
import '../../shared/settings/screens/unified_settings_screen.dart';
import '../../integrations/sessions/screens/sessions_screen.dart';

// Hardware screens
import '../screens/hardware/watch_screen.dart';
import '../screens/hardware/frame_screen.dart';
import '../screens/hardware/robotics_screen.dart';
import '../screens/hardware/drones_screen.dart';

// Operator screens
import '../screens/operator/presence_screen.dart';
import '../screens/operator/biometrics_screen.dart';

// Surveillance screens
import '../screens/surveillance/eagle_eye_screen.dart';

// Assets screens
import '../screens/assets/vehicles_screen.dart';

// Operator screens (additional)
import '../screens/operator/health_screen.dart';

// Operations screens
import '../screens/operations/notifications_screen.dart';
import '../screens/operations/activity_screen.dart';
import '../screens/operations/edge_ai_screen.dart';
import '../screens/operations/vision_pipeline_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Tactical Router
/// ATOC-inspired navigation with 5 primary tabs:
/// - COMMAND (Dashboard)
/// - MAP (Geographic view)
/// - SITREPS (Activity/notifications)
/// - MISSIONS (Active runs/sessions)
/// - MORE (Assets, Team, Protocols, Intel, Terminal)
final tacticalRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/command',
  routes: [
    // Shell route wraps all screens with tactical bottom navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => TacticalShell(child: child),
      routes: [
        // ==================== PRIMARY TABS ====================

        // COMMAND - Dashboard home
        GoRoute(
          path: '/command',
          name: 'command',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CommandScreen(),
          ),
        ),

        // Root redirects to command
        GoRoute(
          path: '/',
          redirect: (context, state) => '/command',
        ),

        // MAP - Geographic asset view (Tactical Map)
        GoRoute(
          path: '/map',
          name: 'map',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TacticalMapScreen(),
          ),
        ),

        // SITREPS - Situation reports / Activity feed
        GoRoute(
          path: '/sitreps',
          name: 'sitreps',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SitrepsScreen(),
          ),
        ),

        // MISSIONS - Active operations
        GoRoute(
          path: '/missions',
          name: 'missions',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MissionsScreen(),
          ),
        ),

        // MORE - Overflow menu
        GoRoute(
          path: '/more',
          name: 'more',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MoreScreen(),
          ),
        ),

        // ==================== MORE SUBROUTES ====================
        // Original screen names preserved, tactical sections in menu only

        // ASSETS section → Agents, Tools
        GoRoute(
          path: '/agents',
          name: 'agents',
          builder: (context, state) => const AgentsScreen(),
        ),

        // TEAM section → Teams
        GoRoute(
          path: '/teams',
          name: 'teams',
          builder: (context, state) => const TeamsScreen(),
        ),

        // PROTOCOLS section → Skills, Workflows
        GoRoute(
          path: '/skills',
          name: 'skills',
          builder: (context, state) => const WorkflowsScreen(), // TODO: Create SkillsScreen
        ),
        GoRoute(
          path: '/workflows',
          name: 'workflows',
          builder: (context, state) => const WorkflowsScreen(),
        ),

        // VAULT section → Knowledge
        GoRoute(
          path: '/knowledge',
          name: 'knowledge',
          builder: (context, state) => const KnowledgeScreen(),
        ),

        // INTEL section → Memory
        GoRoute(
          path: '/memory',
          name: 'memory',
          builder: (context, state) => const MemoryScreen(),
        ),

        // TERMINAL section → Chat
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const EnhancedChatScreen(),
        ),

        // VOICE - Redirect to chat (voice integrated via inline overlay)
        GoRoute(
          path: '/voice',
          name: 'voice',
          redirect: (context, state) => '/chat',
        ),

        // ==================== SYSTEM ====================

        // Tools
        GoRoute(
          path: '/tools',
          name: 'tools',
          builder: (context, state) => const ToolsScreen(),
        ),

        // Models
        GoRoute(
          path: '/models',
          name: 'models',
          builder: (context, state) => const ModelsScreen(),
        ),

        // MCP Servers
        GoRoute(
          path: '/mcp',
          name: 'mcp',
          builder: (context, state) => const MCPScreen(),
        ),

        // Approvals
        GoRoute(
          path: '/approvals',
          name: 'approvals',
          builder: (context, state) => const ApprovalsScreen(),
        ),

        // Metrics
        GoRoute(
          path: '/metrics',
          name: 'metrics',
          builder: (context, state) => const MetricsScreen(),
        ),

        // Traces (observability)
        GoRoute(
          path: '/traces',
          name: 'traces',
          builder: (context, state) => const TracesScreen(),
        ),

        // Evaluations (redirect to metrics - evals are part of metrics system)
        GoRoute(
          path: '/evaluations',
          name: 'evaluations',
          redirect: (context, state) => '/metrics',
        ),

        // Sessions (OPERATIONS section)
        GoRoute(
          path: '/sessions',
          name: 'sessions',
          builder: (context, state) => const SessionsScreen(),
        ),

        // Settings
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const UnifiedSettingsScreen(),
        ),

        // ==================== HARDWARE ====================

        // Watch (wearables)
        GoRoute(
          path: '/watch',
          name: 'watch',
          builder: (context, state) => const WatchScreen(),
        ),

        // Frame (AR glasses)
        GoRoute(
          path: '/frame',
          name: 'frame',
          builder: (context, state) => const FrameScreen(),
        ),

        // Robotics
        GoRoute(
          path: '/robotics',
          name: 'robotics',
          builder: (context, state) => const RoboticsScreen(),
        ),

        // Drones
        GoRoute(
          path: '/drones',
          name: 'drones',
          builder: (context, state) => const DronesScreen(),
        ),

        // ==================== OPERATOR ====================

        // Presence (location & status)
        GoRoute(
          path: '/presence',
          name: 'presence',
          builder: (context, state) => const PresenceScreen(),
        ),

        // Biometrics (health telemetry)
        GoRoute(
          path: '/biometrics',
          name: 'biometrics',
          builder: (context, state) => const BiometricsScreen(),
        ),

        // ==================== SURVEILLANCE ====================

        // Eagle Eye (camera surveillance)
        GoRoute(
          path: '/eagle-eye',
          name: 'eagle-eye',
          builder: (context, state) => const EagleEyeScreen(),
        ),

        // ==================== ASSETS (Additional) ====================

        // Vehicles (fleet management)
        GoRoute(
          path: '/vehicles',
          name: 'vehicles',
          builder: (context, state) => const VehiclesScreen(),
        ),

        // ==================== OPERATOR (Additional) ====================

        // Health (unified health intel)
        GoRoute(
          path: '/health',
          name: 'health',
          builder: (context, state) => const HealthScreen(),
        ),

        // ==================== OPERATIONS (Additional) ====================

        // Notifications
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),

        // Activity feed
        GoRoute(
          path: '/activity',
          name: 'activity',
          builder: (context, state) => const ActivityScreen(),
        ),

        // Edge AI
        GoRoute(
          path: '/edge-ai',
          name: 'edge-ai',
          builder: (context, state) => const EdgeAIScreen(),
        ),

        // Vision Pipeline
        GoRoute(
          path: '/vision-pipeline',
          name: 'vision-pipeline',
          builder: (context, state) => const VisionPipelineScreen(),
        ),

        // ==================== LEGACY REDIRECTS ====================

        GoRoute(
          path: '/home',
          redirect: (context, state) => '/command',
        ),
        GoRoute(
          path: '/dashboard',
          redirect: (context, state) => '/command',
        ),
        GoRoute(
          path: '/inbox',
          redirect: (context, state) => '/sitreps',
        ),
        GoRoute(
          path: '/awareness',
          redirect: (context, state) => '/command',
        ),
      ],
    ),
  ],
);

/// Tactical Menu Sections (original routes preserved):
///
/// | Section      | Contains                                                          | Routes                                                                   |
/// |--------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|
/// | ASSETS       | Agents, Teams, Models, Tools, MCP, Robotics, Drones, Vehicles     | /agents, /teams, /models, /tools, /mcp, /robotics, /drones, /vehicles    |
/// | PROTOCOLS    | Skills, Workflows                                                 | /skills, /workflows                                                      |
/// | VAULT        | Knowledge                                                         | /knowledge                                                               |
/// | INTEL        | Memory                                                            | /memory                                                                  |
/// | OPERATIONS   | Sessions, Approvals, Metrics, Traces, Notifications, Activity,   | /sessions, /approvals, /metrics, /traces, /notifications, /activity,     |
/// |              | Edge AI, Vision Pipeline                                          | /edge-ai, /vision-pipeline                                               |
/// | OPERATOR     | Health, Presence, Biometrics                                      | /health, /presence, /biometrics                                          |
/// | SURVEILLANCE | Eagle Eye                                                         | /eagle-eye                                                               |
/// | HARDWARE     | Watch, Frame                                                      | /watch, /frame                                                           |
/// | COMMS        | Terminal                                                          | /chat                                                                    |
/// | Settings     | (bottom, always accessible)                                       | /settings                                                                |
///
/// Bottom Nav Tabs:
/// | Tab          | Route        | Screen              |
/// |--------------|--------------|---------------------|
/// | Dashboard    | /command     | CommandScreen       |
/// | Map          | /map         | MapScreen           |
/// | SITREPs      | /sitreps     | SitrepsScreen       |
/// | Missions     | /missions    | MissionsScreen      |
/// | More         | /more        | MoreScreen          |
