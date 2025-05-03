import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journal_25_app/screens/auth/login_screen.dart';
import 'package:journal_25_app/screens/auth/register_screen.dart';
import 'package:journal_25_app/screens/home/home_screen.dart';
import 'package:journal_25_app/screens/journal/journal_detail_screen.dart';
import 'package:journal_25_app/screens/article/article_detail_screen.dart';
import 'package:journal_25_app/screens/profile/profile_screen.dart';
import 'package:journal_25_app/screens/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'journal/:journalId',
          builder: (context, state) => JournalDetailScreen(
            journalId: int.parse(state.pathParameters['journalId']!),
          ),
        ),
        GoRoute(
          path: 'article/:articleId',
          builder: (context, state) => ArticleDetailScreen(
            articleId: int.parse(state.pathParameters['articleId']!),
          ),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
); 