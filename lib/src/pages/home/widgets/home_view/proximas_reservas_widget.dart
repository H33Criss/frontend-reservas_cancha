import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:pobla_app/src/data/hours_definitions.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket_reserva_provider.dart';
import 'package:pobla_app/src/utils/datetime_utility.dart';
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
    _reservaProvider.connect([
      ReservasEvent.reservasOfUser,
      ReservasEvent.newReservaOfUser,
    ]);
  }

  @override
  void dispose() {
    print('dispose PROXIMAS_RESERVAS');
    _reservaProvider.disconnect([
      ReservasEvent.reservasOfUser,
      ReservasEvent.newReservaOfUser,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    final reservaProvider = context.watch<ReservaProvider>();
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.28,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: reservaProvider.reservasOfUser.length,
        itemBuilder: (context, i) {
          final reserva = reservaProvider.reservasOfUser[i];
          return Container(
            decoration: BoxDecoration(
              color: colors.border,
              // color: Colors.blue[900],
              borderRadius: BorderRadius.circular(30),
            ),
            width: size.width * 0.45,
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
                    child: Container(
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
                                  animateIcon: AnimateIcons.bell,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text('Reserva', style: textStyles.h4),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
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
                          const Spacer(),
                          RippleAnimation(
                              color: colors.muted.withOpacity(.5),
                              delay: const Duration(milliseconds: 300),
                              repeat: true,
                              minRadius: 30,
                              ripplesCount: 1,
                              duration: const Duration(milliseconds: 6 * 300),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.muted.withOpacity(.5),
                                ),
                                width: size.height * 0.1,
                                height: size.height * 0.1,
                                child: Column(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.03,
                                    ),
                                    Text(
                                      'Faltan',
                                      style: textStyles.small,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      DateTimeUtility.timeUntilReservation(
                                          reserva.fechaReserva,
                                          reserva.horaInicio),
                                      style: textStyles.small,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )),
                          const Spacer(),
                          Text(
                            '${weekDayNames[reserva.fechaReserva.weekday - 1]} ${reserva.fechaReserva.day} de ${monthNames[reserva.fechaReserva.month - 1]}',
                            style: textStyles.small
                                .copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundCircles {
  static List<Widget> _buildCircles(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return [
      Positioned(
        top: 0,
        right: -size.height * 0.06,
        child: Container(
          width: size.height * 0.18,
          height: size.height * 0.18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(.06),
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
            color: Colors.white.withOpacity(.06),
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
            color: Colors.white.withOpacity(.06),
          ),
        ),
      ),
    ];
  }
}
