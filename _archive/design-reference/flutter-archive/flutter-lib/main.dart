import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/inbox_screen.dart';
// chat_screen.dart — ARCHIVED (see screens/archive/)
import 'screens/universal_chat_screen.dart';
import 'screens/agents_screen.dart';
import 'screens/agent_form_screen.dart';
import 'screens/teams_screen.dart';
import 'screens/team_form_screen.dart';
import 'screens/knowledge_screen.dart';
import 'screens/sessions_screen.dart';

import 'screens/workflows_screen.dart';
import 'screens/evaluations_screen.dart';

import 'screens/analytics_screen.dart';
import 'screens/events_screen.dart';
import 'screens/systems_screen.dart';
import 'screens/asset_map_screen.dart';
import 'screens/task_board_screen.dart';
import 'screens/activity_feed_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/documents_screen.dart';
// import 'screens/sheets_screen.dart';  // REMOVED — archived
import 'screens/nats_control_screen.dart';
import 'screens/workflow_builder_screen.dart';
import 'screens/quest_board_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/skill_tree_screen.dart';
import 'screens/habitica_hq_screen.dart';
import 'screens/tactical_base_screen.dart';
import 'screens/entity_roster_screen.dart';
import 'screens/world_map_screen.dart';
import 'screens/wearables_screen.dart';
import 'screens/builder_screen.dart';

import 'screens/cortex_screen.dart';
import 'screens/nexus_screen.dart';
import 'screens/machines_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/assets_browser_screen.dart';
import 'screens/tools_screen.dart';

import 'screens/sensors_screen.dart';
import 'screens/briefing_screen.dart';
import 'screens/integrations_screen.dart';
import 'screens/api_keys_screen.dart';
import 'game/game_screen.dart';
import 'widgets/app_shell.dart';
import 'models/agent_model.dart';
import 'models/team_model.dart';
import 'providers/theme_provider.dart';
import 'config/tactical_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: OneMindApp(),
    ),
  );
}

// ─── ANIMATED PAGE BUILDER ───
// Adds a smooth fade+slide transition to every route.
CustomTransitionPage _animatedPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnim = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slideAnim = Tween<Offset>(
        begin: const Offset(0.02, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: child,
        ),
      );
    },
  );
}

// Router configuration with ShellRoute for consistent navigation
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _animatedPage(child: const InboxScreen(), state: state),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) => _animatedPage(child: const UniversalChatScreen(), state: state),
        ),
        // /chat/legacy — REMOVED (ChatScreen archived)
        // UniversalChatScreen at /chat is the unified chat interface
        GoRoute(
          path: '/agents',
          pageBuilder: (context, state) => _animatedPage(child: const AgentsScreen(), state: state),
        ),
        GoRoute(
          path: '/agents/create',
          pageBuilder: (context, state) => _animatedPage(child: const AgentFormScreen(), state: state),
        ),
        GoRoute(
          path: '/agents/edit/:id',
          pageBuilder: (context, state) {
            final agent = state.extra as AgentModel?;
            return _animatedPage(child: AgentFormScreen(agent: agent), state: state);
          },
        ),
        GoRoute(
          path: '/teams',
          pageBuilder: (context, state) => _animatedPage(child: const TeamsScreen(), state: state),
        ),
        GoRoute(
          path: '/teams/create',
          pageBuilder: (context, state) => _animatedPage(child: const TeamFormScreen(), state: state),
        ),
        GoRoute(
          path: '/teams/edit/:id',
          pageBuilder: (context, state) {
            final team = state.extra as TeamModel?;
            return _animatedPage(child: TeamFormScreen(team: team), state: state);
          },
        ),
        GoRoute(
          path: '/knowledge',
          pageBuilder: (context, state) => _animatedPage(child: const KnowledgeScreen(), state: state),
        ),
        GoRoute(
          path: '/sessions',
          pageBuilder: (context, state) => _animatedPage(child: const SessionsScreen(), state: state),
        ),
        GoRoute(
          path: '/memories',
          redirect: (context, state) => '/knowledge',
        ),
        GoRoute(
          path: '/workflows',
          pageBuilder: (context, state) => _animatedPage(child: const WorkflowsScreen(), state: state),
        ),
        GoRoute(
          path: '/evaluations',
          pageBuilder: (context, state) => _animatedPage(child: const EvaluationsScreen(), state: state),
        ),
        GoRoute(
          path: '/approvals',
          redirect: (context, state) => '/sessions',
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) => _animatedPage(child: const AnalyticsScreen(), state: state),
        ),
        GoRoute(
          path: '/events',
          pageBuilder: (context, state) => _animatedPage(child: const EventsScreen(), state: state),
        ),
        GoRoute(
          path: '/system',
          pageBuilder: (context, state) => _animatedPage(child: const SystemsScreen(), state: state),
        ),
        GoRoute(
          path: '/topology',
          redirect: (context, state) => '/system',
        ),
        GoRoute(
          path: '/field-assets',
          pageBuilder: (context, state) => _animatedPage(child: const AssetMapScreen(), state: state),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (context, state) => _animatedPage(child: const TaskBoardScreen(), state: state),
        ),
        GoRoute(
          path: '/activity',
          pageBuilder: (context, state) => _animatedPage(child: const ActivityFeedScreen(), state: state),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => _animatedPage(child: const CalendarScreen(), state: state),
        ),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) => _animatedPage(child: const ProjectsScreen(), state: state),
        ),
        GoRoute(
          path: '/documents',
          pageBuilder: (context, state) => _animatedPage(child: const DocumentsScreen(), state: state),
        ),
        // Sheets route — REMOVED (archived)
        GoRoute(
          path: '/nats-control',
          pageBuilder: (context, state) => _animatedPage(child: const NatsControlScreen(), state: state),
        ),
        GoRoute(
          path: '/settings',
          redirect: (context, state) => '/system',
        ),
        GoRoute(
          path: '/workflow-builder',
          pageBuilder: (context, state) => _animatedPage(child: const WorkflowBuilderScreen(), state: state),
        ),
        GoRoute(
          path: '/game',
          pageBuilder: (context, state) => _animatedPage(child: const GameScreen(), state: state),
        ),
        // Game screens
        GoRoute(
          path: '/hq',
          pageBuilder: (context, state) => _animatedPage(child: const HabiticaHQScreen(), state: state),
        ),
        GoRoute(
          path: '/base',
          pageBuilder: (context, state) => _animatedPage(child: const TacticalBaseScreen(), state: state),
        ),
        GoRoute(
          path: '/roster',
          pageBuilder: (context, state) => _animatedPage(child: const EntityRosterScreen(), state: state),
        ),
        GoRoute(
          path: '/quests',
          pageBuilder: (context, state) => _animatedPage(child: const QuestBoardScreen(), state: state),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _animatedPage(child: const PlayerProfileScreen(), state: state),
        ),
        GoRoute(
          path: '/skill-tree',
          pageBuilder: (context, state) => _animatedPage(child: const SkillTreeScreen(), state: state),
        ),
        // New screens - OneMind Expansion
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) => _animatedPage(child: const WorldMapScreen(), state: state),
        ),
        GoRoute(
          path: '/wearables',
          pageBuilder: (context, state) => _animatedPage(child: const WearablesScreen(), state: state),
        ),
        GoRoute(
          path: '/builder',
          pageBuilder: (context, state) => _animatedPage(child: const BuilderScreen(), state: state),
        ),
        GoRoute(
          path: '/capabilities',
          redirect: (context, state) => '/tools',
        ),
        GoRoute(
          path: '/nexus',
          pageBuilder: (context, state) => _animatedPage(child: const NexusScreen(), state: state),
        ),
        GoRoute(
          path: '/cortex',
          pageBuilder: (context, state) => _animatedPage(child: const CortexScreen(), state: state),
        ),
        // Entity & Asset screens
        GoRoute(
          path: '/assets',
          pageBuilder: (context, state) => _animatedPage(child: const AssetsBrowserScreen(), state: state),
        ),
        GoRoute(
          path: '/machines',
          pageBuilder: (context, state) => _animatedPage(child: const MachinesScreen(), state: state),
        ),
        GoRoute(
          path: '/locations',
          pageBuilder: (context, state) => _animatedPage(child: const LocationsScreen(), state: state),
        ),
        // Skills & Tools screens
        GoRoute(
          path: '/tools',
          pageBuilder: (context, state) => _animatedPage(child: const ToolsScreen(), state: state),
        ),
        GoRoute(
          path: '/mcp',
          redirect: (context, state) => '/tools',
        ),
        // Automation & Monitoring screens
        GoRoute(
          path: '/sensors',
          pageBuilder: (context, state) => _animatedPage(child: const SensorsScreen(), state: state),
        ),
        GoRoute(
          path: '/briefing',
          pageBuilder: (context, state) => _animatedPage(child: const BriefingScreen(), state: state),
        ),
        // Integration screens
        GoRoute(
          path: '/integrations',
          pageBuilder: (context, state) => _animatedPage(child: const IntegrationsScreen(), state: state),
        ),
        GoRoute(
          path: '/api-keys',
          pageBuilder: (context, state) => _animatedPage(child: const ApiKeysScreen(), state: state),
        ),
      ],
    ),
  ],
);

class OneMindApp extends ConsumerWidget {
  const OneMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    // Unified color scheme
    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFE63946),
            onPrimary: Colors.white,
            secondary: Color(0xFF00D9FF),
            onSecondary: Colors.black,
            surface: Color(0xFF0A0A0A),
            onSurface: Color(0xFFE5E7EB),
            error: Color(0xFFEF4444),
            outline: Color(0xFF1F2937),
            outlineVariant: Color(0xFF111111),
          )
        : ColorScheme.light(
            primary: const Color(0xFFDC3545),
            onPrimary: Colors.white,
            secondary: const Color(0xFF0891B2),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: const Color(0xFF1A1A1A),
            error: const Color(0xFFDC2626),
            outline: const Color(0xFFE5E7EB),
            outlineVariant: const Color(0xFFF3F4F6),
          );

    return MaterialApp.router(
      title: 'OneMind OS v2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        brightness: brightness,
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
        // AppBar — flat, blends with surface
        appBarTheme: AppBarTheme(
          backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: colorScheme.onSurface, size: 20),
        ),
        // Cards — subtle elevation
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          margin: EdgeInsets.zero,
        ),
        // Dividers
        dividerTheme: DividerThemeData(
          color: colorScheme.outline.withValues(alpha: 0.5),
          thickness: 1,
          space: 1,
        ),
        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
          labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
        ),
        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        // Tabs
        tabBarTheme: TabBarThemeData(
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
          indicatorColor: colorScheme.primary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          dividerHeight: 0,
        ),
        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: colorScheme.surface,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: TextStyle(fontSize: 12, color: colorScheme.onSurface),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        // Dialogs
        dialogTheme: DialogThemeData(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
        // Bottom sheets
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF323232),
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
        // List tile
        listTileTheme: ListTileThemeData(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: VisualDensity.compact,
          titleTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500),
          subtitleTextStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11),
        ),
        // Tooltip
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF323232),
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        // Icon
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 20),
        // Scrollbar
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(colorScheme.onSurface.withValues(alpha: 0.15)),
          thickness: const WidgetStatePropertyAll(4),
          radius: const Radius.circular(2),
        ),
      ),
      routerConfig: _router,
    );
  }
}
