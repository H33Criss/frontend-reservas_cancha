import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/data/hours_definitions.dart';
import 'package:pobla_app/src/helpers/reservas/reserva_time_helper.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket/socket_reserva_provider.dart';
import 'package:pobla_app/src/shared/shared.dart';
import 'package:pobla_app/src/shared/widgets/connection_timeout.dart';
import 'package:pobla_app/src/shared/widgets/minute_update.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class ProximasReservasWidget extends StatefulWidget {
  const ProximasReservasWidget({super.key});

  @override
  State<ProximasReservasWidget> createState() => _ProximasReservasWidgetState();
}

class _ProximasReservasWidgetState extends State<ProximasReservasWidget> {
  late ReservaProvider _reservaProvider;
  @override
  void initState() {
    super.initState();
    _reservaProvider = context.read<ReservaProvider>();
    _initSocketConnection(false);
  }

  @override
  void dispose() {
    _reservaProvider.disconnect([
      ReservasEvent.reservasProximas,
      ReservasEvent.newReservaProxima,
    ]);
    super.dispose();
  }

  void _initSocketConnection(bool renew) {
    if (renew) {
      _reservaProvider.disconnect([
        ReservasEvent.reservasProximas,
        ReservasEvent.newReservaProxima,
      ]);
    }
    _reservaProvider.connect([
      ReservasEvent.reservasProximas,
      ReservasEvent.newReservaProxima,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    final reservaProvider = context.watch<ReservaProvider>();
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.29,
      child: Skeleton(
        isLoading: reservaProvider.loadingReservasProximas,
        skeleton: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SkeletonAvatar(
              style: SkeletonAvatarStyle(
                borderRadius: BorderRadius.circular(30),
                width: size.width * 0.45,
                height: double.infinity,
              ),
            ),
            const SizedBox(width: 10),
            SkeletonAvatar(
              style: SkeletonAvatarStyle(
                borderRadius: BorderRadius.circular(30),
                width: size.width * 0.45,
                height: double.infinity,
              ),
            ),
          ],
        ),
        child:
            reservaProvider.connectionTimeouts[ReservasEvent.reservasProximas]!
                ? ConnectionTimeoutWidget(
                    tryAgainFunction: _initSocketConnection,
                    topSeparation: size.height * 0.05,
                  )
                : reservaProvider.reservasProximas.isEmpty
                    ? Container(
                        alignment: Alignment.centerLeft,
                        width: size.width * 0.86,
                        child: FadeIn(
                          duration: const Duration(milliseconds: 1500),
                          child: const EmptyReservas(
                            message: 'No tienes reservas próximas',
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: reservaProvider.reservasProximas.length,
                        itemBuilder: (context, i) {
                          final reserva = reservaProvider.reservasProximas[i];
                          return _CardProximaReserva(
                            reserva: reserva,
                            colors: colors,
                            size: size,
                            textStyles: textStyles,
                          );
                        },
                      ),
      ),
    );
  }
}

class _CardProximaReserva extends StatelessWidget {
  const _CardProximaReserva({
    required this.reserva,
    required this.colors,
    required this.size,
    required this.textStyles,
  });

  final ReservaModel reserva;
  final ShadColorScheme colors;
  final Size size;
  final ShadTextTheme textStyles;

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      child: InkResponse(
        borderRadius: BorderRadius.circular(30),
        radius: 50,
        onTap: () => context.push('/reservas/${reserva.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: colors.primaryForeground,
            borderRadius: BorderRadius.circular(30),
          ),
          width: size.width * 0.48,
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                ..._BackgroundCircles._buildCircles(context),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: MinuteUpdater(builder: (context) {
                    String timeUntil = ReservaTimeHelper.timeUntil(
                      reserva.fechaReserva,
                      reserva.horaInicio,
                      horaFin: reserva.horaFin,
                    );

                    final status = ReservaTimeHelper.getReservaStatus(
                        reserva.fechaReserva,
                        reserva.horaInicio,
                        reserva.horaFin);
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: AnimateIcon(
                                  key: UniqueKey(),
                                  onTap: () {},
                                  iconType: IconType.continueAnimation,
                                  height: 20,
                                  width: 20,
                                  color: colors.primary,
                                  animateIcon: status ==
                                          ReservaStatus.faltaTiempo
                                      ? AnimateIcons.bell
                                      : status == ReservaStatus.tiempoAcabado
                                          ? AnimateIcons.checkbox
                                          : AnimateIcons.playStop,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text('Reserva', style: textStyles.h4),
                            ],
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            '${weekDayNames[reserva.fechaReserva.weekday - 1]} ${reserva.fechaReserva.day} de ${monthNames[reserva.fechaReserva.month - 1]}',
                            style: textStyles.small
                                .copyWith(color: colors.primary),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: reserva.horaInicio,
                                style: textStyles.h4,
                              ),
                              TextSpan(
                                text: ' - ',
                                style: textStyles.h4,
                              ),
                              TextSpan(
                                text: reserva.horaFin,
                                style: textStyles.h4,
                              ),
                            ]),
                          ),
                          SizedBox(height: size.height * 0.01),
                          RippleAnimation(
                            color: colors.muted.withOpacity(.5),
                            delay: const Duration(milliseconds: 300),
                            repeat: true,
                            minRadius:
                                status == ReservaStatus.faltaTiempo ? 30 : 18,
                            ripplesCount: 1,
                            duration: Duration(
                                milliseconds:
                                    status == ReservaStatus.faltaTiempo
                                        ? 6 * 300
                                        : 12 * 300),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: status == ReservaStatus.faltaTiempo
                                    ? colors.muted.withOpacity(.5)
                                    : colors.muted.withOpacity(.2),
                              ),
                              width: size.height * 0.07,
                              height: size.height * 0.07,
                              child: Center(
                                child: AnimateIcon(
                                  width: 24,
                                  height: 24,
                                  onTap: () {},
                                  color: colors.primary,
                                  iconType: IconType.continueAnimation,
                                  animateIcon: status ==
                                          ReservaStatus.faltaTiempo
                                      ? AnimateIcons.hourglass
                                      : status == ReservaStatus.tiempoAcabado
                                          ? AnimateIcons.fogWeather
                                          : AnimateIcons.loading4,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          status == ReservaStatus.faltaTiempo
                              ? RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Quedan ',
                                        style: textStyles.small),
                                    TextSpan(
                                      text: timeUntil,
                                      style: textStyles.small,
                                    ),
                                  ]),
                                )
                              : Text(
                                  timeUntil,
                                  style: textStyles.small,
                                ),
                        ],
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundCircles {
  static List<Widget> _buildCircles(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    return [
      Positioned(
        top: 0,
        right: -size.height * 0.06,
        child: Container(
          width: size.height * 0.18,
          height: size.height * 0.18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(.06),
          ),
        ),
      ),
      Positioned(
        top: 10,
        left: size.width * 0.16,
        child: Container(
          width: size.height * 0.02,
          height: size.height * 0.02,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(.06),
          ),
        ),
      ),
      Positioned(
        bottom: 10,
        left: size.width * 0.03,
        child: Container(
          width: size.height * 0.06,
          height: size.height * 0.06,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(.06),
          ),
        ),
      ),
    ];
  }
}
