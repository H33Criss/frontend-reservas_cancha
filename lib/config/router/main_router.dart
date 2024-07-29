import 'package:go_router/go_router.dart';
import 'package:pobla_app/src/pages/pages.dart';
import 'package:pobla_app/src/providers/providers.dart';

UserProvider _userProvider = UserProvider();

final mainRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _userProvider.userListener,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/reserva/:id',
      builder: (context, state) {
        final reservaId = state.pathParameters['id'] ?? '';
        return ReservaById(reservaId: reservaId);
      },
    ),
    GoRoute(
      path: '/horario-reservas',
      builder: (context, state) => const HorarioReservas(),
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
