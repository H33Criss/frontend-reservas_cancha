import 'package:go_router/go_router.dart';
import 'package:pobla_app/src/pages/pages.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket_reserva_provider.dart';
import 'package:provider/provider.dart';

UserProvider _userProvider = UserProvider();

final mainRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _userProvider.userListener,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/calendario-reservas',
      builder: (context, state) => const CalendarioReservas(),
    ),
  ],
  redirect: (context, state) {
    final isGoingTo = state.matchedLocation;
    final user = _userProvider.userListener.value;

    if (user == null) {
      if (isGoingTo == '/login') return null;

      return '/login';
    }

    if (isGoingTo == '/login')
    // isGoingTo == '/register' ||
    // isGoingTo == '/splash')
    {
      return '/';
    }
    return null;
  },
);
