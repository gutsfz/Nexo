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

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-habit',
      name: AppRoutes.addHabit,
      builder: (context, state) => const AddHabitScreen(),
    ),
    // parâmetro de rota: /habit/:id
    GoRoute(
      path: '/habit/:id',
      name: AppRoutes.habitDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return HabitDetailScreen(habitId: id);
      },
    ),
    GoRoute(
      path: '/history',
      name: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);