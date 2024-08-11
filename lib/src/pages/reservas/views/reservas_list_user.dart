import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/data/hours_definitions.dart';
import 'package:pobla_app/src/helpers/reservas/reserva_time_helper.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket/socket_reserva_provider.dart';
import 'package:pobla_app/src/shared/shared.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class ReservasListUser extends StatefulWidget {
  const ReservasListUser({super.key});

  @override
  State<ReservasListUser> createState() => _ReservasListUserState();
}

class _ReservasListUserState extends State<ReservasListUser> {
  late ReservaProvider _reservaProvider;

  @override
  void initState() {
    super.initState();
    _reservaProvider = context.read<ReservaProvider>();
    _initSocketConnection(false);
  }

  void _initSocketConnection(bool renew) {
    if (renew) {
      _reservaProvider.disconnect([
        ReservasEvent.reservasTotales,
        ReservasEvent.newReserva,
      ]);
    }
    _reservaProvider.connect([
      ReservasEvent.reservasTotales,
      ReservasEvent.newReserva,
    ]);
  }

  @override
  void dispose() {
    _reservaProvider.disconnect([
      ReservasEvent.reservasTotales,
      ReservasEvent.newReserva,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;

    final reservaProvider = context.watch<ReservaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de Reservas',
          style: textStyles.h4,
        ),
      ),
      body: SingleChildScrollView(
        child: MinuteUpdater(
          builder: (context) {
            //Se excluyen las reservas proximas
            final reservasTotales = ReservaTimeHelper.filtrarReservasViejas(
              reservaProvider.reservasProximas,
              reservaProvider.reservasTotales,
            );
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 15, horizontal: size.width * 0.07),
                  child: _CardStatsReserva(
                    reservasTotales: reservaProvider.reservasTotales,
                    reservasViejas: reservasTotales,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                  child: ShadTabs(
                    decoration: ShadDecoration(
                      color: colors.primaryForeground,
                    ),
                    defaultValue: 'Proximas',
                    tabs: [
                      ShadTab(
                        value: 'Proximas',
                        text: const Text('Proximas'),
                        content: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          width: size.width,
                          height: size.height * 0.45,
                          child: reservaProvider.loadingReservasProximas
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : reservaProvider.reservasProximas.isEmpty
                                  ? const EmptyReservas(
                                      message: 'No tienes reservas próximas.')
                                  : ListView.builder(
                                      itemCount: reservaProvider
                                          .reservasProximas.length,
                                      itemBuilder: (context, i) {
                                        final reserva =
                                            reservaProvider.reservasProximas[i];
                                        return _ReservaItem(
                                          index: i,
                                          size: size,
                                          colors: colors,
                                          reserva: reserva,
                                          textStyles: textStyles,
                                        );
                                      },
                                    ),
                        ),
                      ),
                      ShadTab(
                        value: 'Todas',
                        text: const Text('Todas'),
                        content: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          width: size.width,
                          height: size.height * 0.45,
                          child: reservaProvider.loadingReservasTotales
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : reservaProvider.connectionTimeouts[
                                      ReservasEvent.reservasTotales]!
                                  ? ConnectionTimeoutWidget(
                                      tryAgainFunction: _initSocketConnection,
                                      topSeparation: size.height * 0.1,
                                    )
                                  : reservasTotales.isEmpty
                                      ? const EmptyReservas(
                                          message:
                                              'No tienes reservas historicas.')
                                      : ListView.builder(
                                          itemCount: reservasTotales.length,
                                          itemBuilder: (context, i) {
                                            final reserva = reservasTotales[i];
                                            return _ReservaItem(
                                              index: i,
                                              size: size,
                                              colors: colors,
                                              reserva: reserva,
                                              textStyles: textStyles,
                                            );
                                          },
                                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardStatsReserva extends StatelessWidget {
  final List<ReservaModel> reservasTotales;
  final List<ReservaModel> reservasViejas;

  const _CardStatsReserva(
      {required this.reservasTotales, required this.reservasViejas});

  @override
  Widget build(BuildContext context) {
    final reservaProvider = context.watch<ReservaProvider>();
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    // Calcular estadísticas
    int totalReservas = reservasTotales.length;
    int reservasPagadas =
        reservasTotales.where((reserva) => reserva.pagada).length;
    int reservasPendientes =
        reservasTotales.where((reserva) => !reserva.pagada).length;
    int horasTotalesReservadas = reservasViejas.fold(0, (sum, reserva) {
      List<String> inicioParts = reserva.horaInicio.split(':');
      List<String> finParts = reserva.horaFin.split(':');
      DateTime inicio = DateTime(
        reserva.fechaReserva.year,
        reserva.fechaReserva.month,
        reserva.fechaReserva.day,
        int.parse(inicioParts[0]),
        int.parse(inicioParts[1]),
      );
      DateTime fin = DateTime(
        reserva.fechaReserva.year,
        reserva.fechaReserva.month,
        reserva.fechaReserva.day,
        int.parse(finParts[0]),
        int.parse(finParts[1]),
      );
      return sum + fin.difference(inicio).inHours;
    });

    Widget buildStatRow(
        String text, String subtitle, int value, AnimateIcons iconData) {
      return Row(
        children: [
          AnimateIcon(
            width: 24,
            height: 24,
            color: colors.muted,
            onTap: () {},
            iconType: IconType.continueAnimation,
            animateIcon: iconData,
          ),
          SizedBox(width: size.width * 0.065),
          _CustomSkeletonZoomIn(
            text: '$value $text',
            subtitle: subtitle,
          ),
        ],
      );
    }

    return ShadCard(
      padding: const EdgeInsets.only(left: 30),
      backgroundColor: colors.primaryForeground,
      width: double.infinity,
      height: size.height * 0.33,
      content: Expanded(
        child: Column(
          children: [
            SizedBox(width: size.width),
            SizedBox(height: size.height * 0.02),
            buildStatRow(
              'reservas',
              'Estas son todas tus reservas totales',
              totalReservas,
              AnimateIcons.calendar,
            ),
            SizedBox(height: size.height * 0.02),
            buildStatRow(
              'pendientes',
              'Reservas en espera de pago',
              reservasPendientes,
              AnimateIcons.loading3,
            ),
            SizedBox(height: size.height * 0.02),
            buildStatRow(
              'pagadas',
              'Reservas pagadas confirmadas',
              reservasPagadas,
              AnimateIcons.checkbox,
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: size.height * 0.025,
                      left: size.width * 0.13,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Jugado',
                            style: reservaProvider.connectionTimeouts[
                                        ReservasEvent.reservasTotales]! &&
                                    !reservaProvider.loadingReservasTotales
                                ? textStyles.large.copyWith(
                                    color: Colors.red[800]!.withOpacity(.7))
                                : textStyles.large,
                          ),
                          Text(
                            'El tiempo jugado en la cancha',
                            style: textStyles.small.copyWith(
                                color: colors.primary.withOpacity(.7)),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.02,
                      left: -size.width * 0.045,
                      child: Container(
                        padding: EdgeInsets.all(
                            reservaProvider.loadingReservasTotales ? 20 : 0),
                        width: size.height * 0.07,
                        height: size.height * 0.07,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: reservaProvider.connectionTimeouts[
                                      ReservasEvent.reservasTotales]! &&
                                  !reservaProvider.loadingReservasTotales
                              ? Colors.red[800]!.withOpacity(.4)
                              : colors.muted.withOpacity(.4),
                        ),
                        alignment: Alignment.center,
                        child: reservaProvider.loadingReservasTotales
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                              )
                            : Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: 5,
                                    child: reservaProvider.connectionTimeouts[
                                            ReservasEvent.reservasTotales]!
                                        ? Text(
                                            '??',
                                            style: textStyles.large,
                                          )
                                        : Text(
                                            '$horasTotalesReservadas',
                                            style: textStyles.large,
                                          ),
                                  ),
                                  Positioned(
                                    top: size.height * 0.035,
                                    child: Text(
                                      'horas',
                                      style: textStyles.small,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CustomSkeletonZoomIn extends StatelessWidget {
  const _CustomSkeletonZoomIn({
    required this.text,
    required this.subtitle,
  });

  final String text;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final reservaProvider = context.watch<ReservaProvider>();
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    return Skeleton(
      duration: const Duration(milliseconds: 1300),
      darkShimmerGradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          colors.card.withOpacity(.7),
          colors.primaryForeground,
          colors.card,
        ],
      ),
      isLoading: reservaProvider.loadingReservasTotales,
      skeleton: FadeIn(
        duration: const Duration(milliseconds: 400),
        child: SkeletonAvatar(
          style: SkeletonAvatarStyle(
            width: size.width * 0.6,
            height: size.height * 0.054,
          ),
        ),
      ),
      child: ZoomIn(
        duration: const Duration(milliseconds: 200),
        child:
            reservaProvider.connectionTimeouts[ReservasEvent.reservasTotales]!
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '??  ${text.split(' ')[1]} ',
                        style: textStyles.h4
                            .copyWith(color: Colors.red[800]!.withOpacity(.7)),
                      ),
                      Text(
                        subtitle,
                        style: textStyles.small.copyWith(
                          color: colors.primary.withOpacity(.7),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: textStyles.h4,
                      ),
                      Text(
                        subtitle,
                        style: textStyles.small.copyWith(
                          color: colors.primary.withOpacity(.7),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ReservaItem extends StatelessWidget {
  const _ReservaItem({
    required this.size,
    required this.colors,
    required this.reserva,
    required this.textStyles,
    required this.index,
  });

  final Size size;
  final int index;
  final ShadColorScheme colors;
  final ReservaModel reserva;
  final ShadTextTheme textStyles;

  @override
  Widget build(BuildContext context) {
    final status = ReservaTimeHelper.getReservaStatus(
      reserva.fechaReserva,
      reserva.horaInicio,
      reserva.horaFin,
    );
    return Container(
        padding: const EdgeInsets.all(10),
        margin: EdgeInsets.only(
            bottom: size.height * 0.03,
            top: index == 0 ? size.height * 0.02 : 0),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(5),
        ),
        height: size.height * 0.1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -(size.height * 0.03),
              left: -(size.width * 0.01),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      bottom: size.height * 0.005,
                      top: size.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topCenter,
                        colors: [colors.muted, colors.muted.withGreen(120)],
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimateIcon(
                          onTap: () {},
                          width: 15,
                          height: 15,
                          color: Colors.white,
                          iconType: IconType.continueAnimation,
                          animateIcon: AnimateIcons.calendar,
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        Text(
                          '${reserva.fechaReserva.year}',
                          style: textStyles.small.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: status == ReservaStatus.faltaTiempo
                              ? size.width * 0.005
                              : size.width * 0.055,
                        ),
                        if (status == ReservaStatus.faltaTiempo)
                          Flash(
                            infinite: true,
                            curve: Curves.decelerate,
                            duration: const Duration(seconds: 6),
                            child: RippleAnimation(
                              repeat: true,
                              minRadius: 10,
                              color: colors.primary.withOpacity(.6),
                              duration: const Duration(milliseconds: 6 * 300),
                              ripplesCount: 1,
                              child: AnimateIcon(
                                width: 15,
                                height: 15,
                                color: colors.primary,
                                onTap: () {},
                                iconType: IconType.continueAnimation,
                                animateIcon: AnimateIcons.hourglass,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: status == ReservaStatus.faltaTiempo
                              ? size.width * 0.01
                              : 0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.025,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: reserva.horaInicio,
                            style: textStyles.p,
                          ),
                          TextSpan(
                            text: ' - ',
                            style: textStyles.p,
                          ),
                          TextSpan(
                            text: reserva.horaFin,
                            style: textStyles.p,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    if (status == ReservaStatus.enCurso ||
                        status == ReservaStatus.faltaTiempo)
                      ShadBadge(
                        text: Text(
                          ReservaTimeHelper.getReservaRelativeTime(
                              reserva.fechaReserva,
                              reserva.horaInicio,
                              reserva.horaFin),
                        ),
                      ),
                    const Spacer(),
                    reserva.pagada
                        ? ShadBadge(
                            backgroundColor: colors.muted,
                            text: Row(
                              children: [
                                AnimateIcon(
                                  color: Colors.white,
                                  width: 10,
                                  height: 10,
                                  onTap: () {},
                                  iconType: IconType.continueAnimation,
                                  animateIcon: AnimateIcons.checkmarkOk,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Pagada',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        : ShadBadge(
                            backgroundColor: colors.muted.withOpacity(.3),
                            text: Row(
                              children: [
                                AnimateIcon(
                                  color: Colors.white,
                                  width: 10,
                                  height: 10,
                                  onTap: () {},
                                  iconType: IconType.continueAnimation,
                                  animateIcon: AnimateIcons.loading3,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Por pagar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${weekDayNames[reserva.fechaReserva.weekday - 1]} ${reserva.fechaReserva.day} de ${monthNames[reserva.fechaReserva.month - 1]}',
                      style: textStyles.large.copyWith(
                        color: colors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Text(
                      '\$${reserva.coste}',
                      style: textStyles.large.copyWith(
                        decoration: reserva.pagada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: reserva.pagada
                            ? colors.primary.withOpacity(.5)
                            : colors.primary,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
