import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journal_25_app/screens/auth/login_screen.dart';
import 'package:journal_25_app/screens/auth/register_screen.dart';
import 'package:journal_25_app/screens/home/home_screen.dart';
import 'package:journal_25_app/screens/journal/journal_detail_screen.dart';
import 'package:journal_25_app/screens/article/article_detail_screen.dart';
import 'package:journal_25_app/screens/profile/profile_screen.dart';
import 'package:journal_25_app/screens/splash_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Router logger
void _routeLogger(String message) {
  debugPrint('ROUTING: $message');
}

// Create the router
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/splash',
  observers: [
    GoRouterObserver(),
  ],
  routes: <RouteBase>[
    GoRoute(
      name: 'splash',
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        _routeLogger('Building Splash Screen');
        return const SplashScreen();
      },
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        _routeLogger('Building Login Screen');
        return const LoginScreen();
      },
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        _routeLogger('Building Register Screen');
        return const RegisterScreen();
      },
    ),
    GoRoute(
      name: 'home',
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        _routeLogger('Building Home Screen');
        return const HomeScreen();
      },
    ),
    GoRoute(
      name: 'journal_detail',
      path: '/journal/:journalId',
      builder: (BuildContext context, GoRouterState state) {
        _routeLogger('Building Journal Detail Screen');
        final journalId = int.parse(state.pathParameters['journalId']!);
        return JournalDetailScreen(journalId: journalId);
      },
    ),
    GoRoute(
      name: 'article_detail',
      path: '/article/:articleId',
      builder: (BuildContext context, GoRouterState state) {
        _routeLogger('Building Article Detail Screen');
        final articleId = int.parse(state.pathParameters['articleId']!);
        return ArticleDetailScreen(articleId: articleId);
      },
    ),
    GoRoute(
      name: 'profile',
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        _routeLogger('Building Profile Screen');
        return const ProfileScreen();
      },
    ),
  ],
  errorBuilder: (context, state) {
    _routeLogger('ERROR: No route found for ${state.uri}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No route found for "${state.uri}"',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  },
);

// Custom observer to log routing events
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeLogger('didPush: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeLogger('didPop: ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeLogger('didRemove: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _routeLogger('didReplace: ${newRoute?.settings.name}');
  }
} 