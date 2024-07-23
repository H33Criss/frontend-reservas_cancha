import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pobla_app/src/data/hours_definitions.dart';
import 'package:pobla_app/src/pages/reservas/widgets/menu_confirmacion.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/utils/managment_card_reserva.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CardReserva extends StatelessWidget {
  final int index;
  final HourDifinition hour;
  final DateTime selectedDate;
  const CardReserva(
      {super.key,
      required this.hour,
      required this.index,
      required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final theme = ShadTheme.of(context);
    Size size = MediaQuery.of(context).size;
    final bloqueosProvider = context.watch<BloqueosProvider>();
    final reservaProvider = context.watch<ReservaProvider>();
    final userProvider = context.watch<UserProvider>();

    Widget canchaWidget;

    if (ManagementCardReserva.isBlocked(
        selectedDate, hour, bloqueosProvider.bloqueos)) {
      canchaWidget = Cancha(
        tooltipText: 'La cancha no abre este día.',
        selectedDate: selectedDate,
        hour: hour,
        title: 'Bloqueada',
        titleColor: Colors.white,
        badgeColor: Colors.orange[600],
        backgroundImage: 'assets/images/cancha-bloqueada.jpg',
        gradientColors: [
          Colors.orange.withOpacity(.9),
          Colors.orange.withOpacity(.5),
        ],
        badgeIcon: Icons.lock_outline_rounded,
        bottomBadge: const ShadBadge.outline(
          text: Text('Hora inactiva'),
        ),
      );
    } else if (ManagementCardReserva.isOwnReservationPast(
        selectedDate, hour, reservaProvider.reservas, userProvider.userId)) {
      canchaWidget = Cancha(
        tooltipText: 'Esta fue una de tus reservas.',
        selectedDate: selectedDate,
        hour: hour,
        title: 'Reservaste aquí',
        titleColor: Colors.white,
        badgeColor: Colors.green.withOpacity(.5),
        backgroundImage: 'assets/images/cancha-propia.jpg',
        gradientColors: [
          Colors.grey.withOpacity(.9),
          Colors.grey.withOpacity(.5),
        ],
        badgeIcon: Icons.check_circle_outline,
        bottomBadge: const ShadBadge(
          text: Text('Una de tus reservas anteriores.'),
        ),
      );
    } else if (ManagementCardReserva.isOwnReservation(
        selectedDate, hour, reservaProvider.reservas, userProvider.userId)) {
      canchaWidget = Cancha(
        tooltipText: 'Haz reservado esta hora.',
        selectedDate: selectedDate,
        hour: hour,
        title: 'Reservada',
        titleColor: Colors.white,
        badgeColor: Colors.green,
        backgroundImage: 'assets/images/cancha-propia.jpg',
        gradientColors: [
          theme.colorScheme.muted.withOpacity(.9),
          theme.colorScheme.muted.withOpacity(.5),
        ],
        badgeIcon: Icons.check_circle_outline,
        bottomBadge: const ShadBadge(
          text: Text('!Has reservado aquí!'),
        ),
      );
    } else if (ManagementCardReserva.isTaken(
        selectedDate, hour, reservaProvider.reservas)) {
      canchaWidget = Cancha(
        tooltipText: 'Horario reservado para otro usuario.',
        selectedDate: selectedDate,
        hour: hour,
        title: 'Tomada',
        titleColor: Colors.white,
        badgeColor: theme.colorScheme.destructive,
        backgroundImage: 'assets/images/cancha-tomada.png',
        gradientColors: [
          theme.colorScheme.destructive.withOpacity(.9),
          theme.colorScheme.destructive.withOpacity(.5),
        ],
        badgeIcon: Icons.lock_person_outlined,
        bottomBadge: const ShadBadge.secondary(
          text: Text('Reserva tomada por otra persona.'),
        ),
      );
    } else if (ManagementCardReserva.isPast(selectedDate)) {
      canchaWidget = Cancha(
        tooltipText: 'Esta hora esta caducada.',
        selectedDate: selectedDate,
        hour: hour,
        title: 'Hora pasada',
        titleColor: Colors.white,
        badgeColor: Colors.grey,
        badgeIcon: Icons.phonelink_lock_outlined,
        backgroundImage: 'assets/images/cancha.png',
        gradientColors: [
          Colors.grey.withOpacity(.9),
          Colors.grey.withOpacity(.5),
        ],
        bottomBadge: const ShadBadge.outline(
          text: Row(
            children: [
              Text(
                'No se puede reservar.',
              ),
            ],
          ),
        ),
      );
    } else if (ManagementCardReserva.hasReservationOnDate(
        selectedDate, reservaProvider.reservas, userProvider.userId)) {
      canchaWidget = Cancha(
        tooltipText: 'Solo se permite 1 reserva diaria.',
        selectedDate: selectedDate,
        hour: hour,
        title: 'No permitido',
        titleColor: Colors.white,
        badgeColor: Colors.grey.withOpacity(.5),
        badgeIcon: Icons.phonelink_lock_outlined,
        backgroundImage: 'assets/images/cancha.png',
        gradientColors: [
          theme.colorScheme.muted.withOpacity(.9),
          theme.colorScheme.muted.withOpacity(.5),
        ],
        bottomBadge: const ShadBadge.outline(
          text: Row(
            children: [
              Text(
                'Reservas 1 por día.',
              ),
            ],
          ),
        ),
      );
    } else {
      canchaWidget = Cancha(
        tooltipText: '',
        selectedDate: selectedDate,
        allowReserva: true,
        hour: hour,
        title: 'Disponible',
        titleColor: Colors.white,
        badgeColor: Colors.blue,
        backgroundImage: 'assets/images/cancha.png',
        gradientColors: [
          theme.colorScheme.muted.withOpacity(.9),
          theme.colorScheme.muted.withOpacity(.5),
        ],
        bottomBadge: ShadBadge(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          text: Row(
            children: [
              const Text(
                '\$10.000',
              ),
              const SizedBox(width: 7),
              Icon(MdiIcons.cashFast),
            ],
          ),
        ),
      );
    }
    return FadeInRight(
      duration: const Duration(milliseconds: 200),
      delay: Duration(milliseconds: (0 + index * 50)),
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 20,
        ),
        width: size.width,
        height: size.height * 0.2,
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: size.width * 0.2,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(MdiIcons.clock),
                  SizedBox(
                    width: size.width * 0.1,
                    height: size.width * 0.1,
                    child: Image.asset('assets/images/clock2.gif'),
                  ),
                  Text(
                    hour.horaInicio,
                    style: textStyles.headlineSmall,
                  ),
                  const SizedBox(
                    height: 20,
                    child: Text('-'),
                  ),
                  Text(
                    hour.horaFin,
                    style: textStyles.headlineSmall,
                  ),
                ],
              ),
            ),
            canchaWidget,
          ],
        ),
      ),
    );
  }
}

class Cancha extends StatelessWidget {
  const Cancha({
    super.key,
    required this.title,
    required this.titleColor,
    required this.badgeColor,
    required this.backgroundImage,
    required this.gradientColors,
    this.badgeIcon,
    required this.bottomBadge,
    required this.hour,
    this.allowReserva = false,
    required this.selectedDate,
    required this.tooltipText,
  });

  final String title;
  final Color titleColor;
  final Color? badgeColor;
  final String backgroundImage;
  final List<Color> gradientColors;
  final IconData? badgeIcon;
  final Widget bottomBadge;
  final HourDifinition hour;
  final bool allowReserva;
  final DateTime selectedDate;
  final String tooltipText;
  // final String price;
  // final TextDecoration? priceDecoration;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Widget cancha = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      width: size.width * 0.78,
      height: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: badgeColor!.withOpacity(.4),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.1),
            BlendMode.dstATop,
          ),
        ),
        gradient: LinearGradient(
          end: Alignment.topLeft,
          begin: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: ShadBadge(
              padding: badgeIcon != null
                  ? null
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              backgroundColor: badgeColor,
              text: Row(
                children: [
                  if (badgeIcon != null) Icon(badgeIcon),
                  if (badgeIcon != null) const SizedBox(width: 5),
                  Text(
                    title,
                    style: TextStyle(color: titleColor),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: bottomBadge,
          ),
        ],
      ),
    );
    return InkResponse(
      onTap: !allowReserva
          ? null
          : () => showShadSheet(
                side: ShadSheetSide.bottom,
                context: context,
                builder: (context) => MenuConfirmacion(
                  hour: hour,
                  selectedDate: selectedDate,
                ),
              ),
      child: allowReserva
          ? cancha
          : ShadTooltip(
              showDuration: const Duration(seconds: 1),
              longPressDuration: const Duration(microseconds: 1),
              builder: (context) {
                return Text(tooltipText);
              },
              child: cancha,
            ),
    );
  }
}
