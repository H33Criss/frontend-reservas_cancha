import 'package:go_router/go_router.dart';
import 'package:pobla_app/src/pages/pages.dart';

final mainRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/calendario-reservas',
      builder: (context, state) => const CalendarioReservas(),
    ),
  ],
);
