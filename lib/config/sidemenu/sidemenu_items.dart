import 'package:animated_icon/animated_icon.dart';

class MenuItem {
  final String title;
  final String subTitle;
  final String? link;
  final AnimateIcons icon;

  const MenuItem({
    required this.title,
    required this.subTitle,
    required this.icon,
    this.link,
  });
}

const List<MenuItem> sidemenuItems = [
  MenuItem(
    title: 'Horario',
    subTitle: 'Horario de la cancha.',
    link: '/horario-reservas',
    icon: AnimateIcons.calendar,
  ),
  MenuItem(
    title: 'Tus Reservas',
    subTitle: 'Reservas que has realizado.',
    link: '/reservas',
    icon: AnimateIcons.list,
  ),
  MenuItem(
    title: 'Cerrar Sesión',
    subTitle: 'Salir de la cuenta actual.',
    icon: AnimateIcons.clearSymbol,
  ),
];
