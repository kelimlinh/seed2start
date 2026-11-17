import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/ai/data/ai_launch_context.dart';
import '../../features/ai/presentation/ai_launch_scope.dart';
import '../../features/ai/presentation/ai_page.dart';
import '../../features/authentication/presentation/auth_gate.dart';
import '../../features/authentication/presentation/login_page.dart';
import '../../features/authentication/presentation/register_page.dart';
import '../../features/gamification/presentation/gamification_page.dart';
import '../../features/goals/presentation/goals_page.dart';
import '../../features/home/presentation/app_shell.dart';
import '../../features/journey/presentation/journey_page.dart';
import '../../features/reflection/presentation/reflection_page.dart';
import '../../features/workbook/presentation/access_code_page.dart';
import '../../features/workbook/presentation/workbook_lesson_page.dart';
import '../../features/workbook/presentation/workbook_page.dart';
import '../../features/workbook/presentation/workbook_public_resource_page.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Widget _requireAuth({
    required Widget page,
    required String returnRoute,
  }) {
    if (FirebaseAuth.instance.currentUser == null) {
      return LoginPage(returnRoute: returnRoute);
    }
    return page;
  }

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    final routeName =
        initialRoute.trim().isEmpty ? AppRoutes.root : initialRoute;

    // Flutter's default initial-route generator may build intermediate routes
    // such as "/" before a web deep link. In PsyCapNote, "/" is AuthGate and
    // can redirect to Home before a public /r/... or /access/... route opens.
    // Generate only the exact browser route instead.
    return <Route<dynamic>>[
      onGenerateRoute(RouteSettings(name: routeName)),
    ];
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? AppRoutes.root;
    final returnRoute =
        settings.arguments is String ? settings.arguments as String : null;
    final aiLaunchContext = settings.arguments is AiLaunchContext
        ? settings.arguments as AiLaunchContext
        : null;

    assert(() {
      if (aiLaunchContext?.isContextual == true) {
        debugPrint(
          'Mầm contextual launch: ${aiLaunchContext!.debugSummary}',
        );
      }
      return true;
    }());

    Widget page;

    // Public QR route. Published resources can be read without authentication.
    if (name.startsWith('${AppRoutes.resource}/')) {
      final resourceId = Uri.decodeComponent(
        name.substring('${AppRoutes.resource}/'.length),
      );
      page = WorkbookPublicResourcePage(resourceId: resourceId);
    } else if (name == AppRoutes.access ||
        name.startsWith('${AppRoutes.access}/')) {
      final initialCode = name == AppRoutes.access
          ? null
          : Uri.decodeComponent(name.substring('${AppRoutes.access}/'.length));
      page = AccessCodePage(initialCode: initialCode);
    } else if (name.startsWith('${AppRoutes.workbook}/')) {
      final lessonId = name.substring('${AppRoutes.workbook}/'.length);
      page = _requireAuth(
        page: WorkbookLessonPage(lessonId: lessonId),
        returnRoute: name,
      );
    } else {
      page = switch (name) {
        AppRoutes.root => const AuthGate(),
        AppRoutes.login => LoginPage(returnRoute: returnRoute),
        AppRoutes.register => RegisterPage(returnRoute: returnRoute),
        AppRoutes.home => _requireAuth(
            page: const AppShell(),
            returnRoute: AppRoutes.home,
          ),
        AppRoutes.goals => _requireAuth(
            page: const GoalsPage(),
            returnRoute: AppRoutes.goals,
          ),
        AppRoutes.progress => _requireAuth(
            page: const GamificationPage(),
            returnRoute: AppRoutes.progress,
          ),
        AppRoutes.ai => _requireAuth(
            page: AiLaunchScope(
              launchContext: aiLaunchContext,
              child: const AiPage(),
            ),
            returnRoute: AppRoutes.ai,
          ),
        AppRoutes.journey => _requireAuth(
            page: const JourneyPage(),
            returnRoute: AppRoutes.journey,
          ),
        AppRoutes.reflection => _requireAuth(
            page: const ReflectionPage(),
            returnRoute: AppRoutes.reflection,
          ),
        AppRoutes.workbook => _requireAuth(
            page: const WorkbookPage(),
            returnRoute: AppRoutes.workbook,
          ),
        _ => const AuthGate(),
      };
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => page,
    );
  }
}
