import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/presentation/screens/home/home_screen.dart';
import 'package:nexo/presentation/screens/add_habit/add_habit_screen.dart';
import 'package:nexo/presentation/screens/habit_detail/habit_detail_screen.dart';
import 'package:nexo/presentation/screens/history/history_screen.dart';
import 'package:nexo/presentation/screens/settings/settings_screen.dart';

// rotas nomeadas - facilita navegar sem decorar paths
class AppRoutes {
  static const home = 'home';
  static const addHabit = 'add-habit';
  static const habitDetail = 'habit-detail';
  static const history = 'history';
  static const settings = 'settings';
}

Page<void> _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AppRoutes.home,
      pageBuilder: (context, state) => _fadeSlide(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/add-habit',
      name: AppRoutes.addHabit,
      pageBuilder: (context, state) =>
          _fadeSlide(state, const AddHabitScreen()),
    ),
    // parâmetro de rota: /habit/:id
    GoRoute(
      path: '/habit/:id',
      name: AppRoutes.habitDetail,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _fadeSlide(state, HabitDetailScreen(habitId: id));
      },
    ),
    GoRoute(
      path: '/history',
      name: AppRoutes.history,
      pageBuilder: (context, state) =>
          _fadeSlide(state, const HistoryScreen()),
    ),
    GoRoute(
      path: '/settings',
      name: AppRoutes.settings,
      pageBuilder: (context, state) =>
          _fadeSlide(state, const SettingsScreen()),
    ),
  ],
);
