import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/screens/home/home_screen.dart';
import 'package:nexo/presentation/screens/add_habit/add_habit_screen.dart';
import 'package:nexo/presentation/screens/edit_habit/edit_habit_screen.dart';
import 'package:nexo/presentation/screens/habit_detail/habit_detail_screen.dart';
import 'package:nexo/presentation/screens/history/history_screen.dart';
import 'package:nexo/presentation/screens/settings/settings_screen.dart';
import 'package:nexo/presentation/screens/about/about_screen.dart';
import 'package:nexo/presentation/screens/all_habits/all_habits_screen.dart';
import 'package:nexo/presentation/screens/splash/splash_screen.dart';
import 'package:nexo/presentation/screens/privacy/privacy_screen.dart';

// rotas nomeadas - facilita navegar sem decorar paths
class AppRoutes {
  static const splash = 'splash';
  static const home = 'home';
  static const addHabit = 'add-habit';
  static const habitDetail = 'habit-detail';
  static const editHabit = 'edit-habit';
  static const history = 'history';
  static const settings = 'settings';
  static const about = 'about';
  static const allHabits = 'all-habits';
  static const privacy = 'privacy';
}

Page<void> _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: AppRoutes.splash,
      pageBuilder: (context, state) => _fadeSlide(state, const SplashScreen()),
    ),
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
    GoRoute(
      path: '/habit/:id',
      name: AppRoutes.habitDetail,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _fadeSlide(state, HabitDetailScreen(habitId: id));
      },
    ),
    GoRoute(
      path: '/habit/:id/edit',
      name: AppRoutes.editHabit,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _fadeSlide(
          state,
          Consumer(
            builder: (context, ref, _) {
              final habitsAsync = ref.watch(habitsProvider);
              return habitsAsync.when(
                loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator())),
                error: (e, _) =>
                    Scaffold(body: Center(child: Text('Erro: $e'))),
                data: (habits) {
                  final habit =
                      habits.where((h) => h.id == id).firstOrNull;
                  if (habit == null) {
                    return const Scaffold(
                        body: Center(child: Text('Hábito não encontrado.')));
                  }
                  return EditHabitScreen(habit: habit);
                },
              );
            },
          ),
        );
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
    GoRoute(
      path: '/about',
      name: AppRoutes.about,
      pageBuilder: (context, state) =>
          _fadeSlide(state, const AboutScreen()),
    ),
    GoRoute(
      path: '/all-habits',
      name: AppRoutes.allHabits,
      pageBuilder: (context, state) =>
          _fadeSlide(state, const AllHabitsScreen()),
    ),
    GoRoute(
      path: '/privacy',
      name: AppRoutes.privacy,
      pageBuilder: (context, state) =>
          _fadeSlide(state, const PrivacyScreen()),
    ),
  ],
);
