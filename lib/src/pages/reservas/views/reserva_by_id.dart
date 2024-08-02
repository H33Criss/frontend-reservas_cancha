import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/helpers/reservas/reserva_step_helper.dart';
import 'package:pobla_app/src/helpers/reservas/reserva_time_helper.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket_reserva_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReservaById extends StatefulWidget {
  final String reservaId;
  const ReservaById({super.key, required this.reservaId});

  @override
  State<ReservaById> createState() => _ReservaByIdState();
}

class _ReservaByIdState extends State<ReservaById> {
  late ReservaProvider _reservaProvider;

  @override
  void initState() {
    super.initState();
    _setReserva();
  }

  Future<void> _setReserva() async {
    _reservaProvider = context.read<ReservaProvider>();
    await _reservaProvider.findReservaById(widget.reservaId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final reservaProvider = context.watch<ReservaProvider>();
    final textStyles = ShadTheme.of(context).textTheme;

    //MediaQuery's
    double top = MediaQuery.of(context).viewPadding.top;
    double bottom = MediaQuery.of(context).viewPadding.bottom;
    Size size = MediaQuery.of(context).size;
    double perfectH = (size.height) - (top + bottom);

    return Scaffold(
      appBar: AppBar(
        actions: [
          ShadBadge.outline(
            text: Row(
              children: [
                AnimateIcon(
                  onTap: () {},
                  iconType: IconType.continueAnimation,
                  animateIcon: AnimateIcons.downArrow,
                  width: 24,
                  height: 24,
                  color: colors.primary,
                ),
                Text(
                  'Detalles',
                  style: textStyles.large,
                ),
              ],
            ),
          )
        ],
        title: Text(
          'Reserva',
          style: textStyles.h3,
        ),
      ),
      body: reservaProvider.loadingReserva
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : _MainContent(
              reservaProvider: reservaProvider,
              perfectH: perfectH,
              reserva: reservaProvider.reservaOnDetail!,
            ),
    );
  }
}

class _MainContent extends StatefulWidget {
  final ReservaProvider reservaProvider;
  final double perfectH;
  final ReservaModel reserva;
  const _MainContent({
    required this.perfectH,
    required this.reserva,
    required this.reservaProvider,
  });

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  Timer? _timer;
  int _currentStep = 0;

  @override
  void initState() {
    widget.reservaProvider.getReservaFromApi(widget.reserva.id);
    _initConnectionSocket(false);
    super.initState();
  }

  void _startTimer(String horaInicio, String horaFin, DateTime fechaReserva) {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        _currentStep =
            StepHelper.calculateCurrentStep(horaInicio, horaFin, fechaReserva);
      });
    });
  }

  void _initConnectionSocket(bool renew) {
    if (renew) {
      widget.reservaProvider.disconnect([
        ReservasEvent.specificReserva,
      ], reservaIds: [
        widget.reserva.id
      ]);
    }
    widget.reservaProvider.connect([
      ReservasEvent.specificReserva,
    ], reservaIds: [
      widget.reserva.id
    ]);
  }

  @override
  void dispose() {
    widget.reservaProvider.disconnect([
      ReservasEvent.specificReserva,
    ], reservaIds: [
      widget.reserva.id
    ]);
    widget.reservaProvider.clearReservaOnDetail();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (_timer == null || !_timer!.isActive) {
      _startTimer(widget.reserva.horaInicio, widget.reserva.horaFin,
          widget.reserva.fechaReserva);
    }

    _currentStep = StepHelper.calculateCurrentStep(widget.reserva.horaInicio,
        widget.reserva.horaFin, widget.reserva.fechaReserva);
    return SizedBox(
      width: size.width,
      height: widget.perfectH,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: widget.perfectH * 0.02),
                width: size.width * 0.15,
                height: widget.perfectH * 0.76,
                child: _StepWidget(
                  currentStep: _currentStep,
                  heightAvailable:
                      (widget.perfectH * 0.9) - (widget.perfectH * 0.04),
                ),
              ),
              SizedBox(width: size.width * 0.05),
              Container(
                padding: EdgeInsets.symmetric(vertical: widget.perfectH * 0.02),
                width: size.width * 0.8,
                height: widget.perfectH * 0.76,
                child: _ActivityStep(
                  costo: widget.reserva.coste,
                  horaInicio: widget.reserva.horaInicio,
                  horaFin: widget.reserva.horaFin,
                  currentStep: _currentStep,
                ),
              ),
            ],
          ),
          Expanded(
            child: _PagoReserva(pagada: widget.reserva.pagada),
          ),
        ],
      ),
    );
  }
}

class _StepWidget extends StatelessWidget {
  final double heightAvailable;
  final int currentStep;
  const _StepWidget({required this.heightAvailable, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final heightLine = (size.height * 0.15) + (size.height * 0.032);
    final totalHeightLine = ((size.height * 0.15) + (size.height * 0.03)) * (3);
    return FadeInLeft(
      duration: const Duration(milliseconds: 200),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Linea Gris
          Positioned(
            top: 0,
            right: (size.width * 0.025) - (size.width * 0.015) / 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[600],
              ),
              width: size.width * 0.015,
              height: totalHeightLine + (size.height * 0.01),
            ),
          ),
          // Linea de color
          Positioned(
            top: 1,
            right: (size.width * 0.025) - (size.width * 0.015) / 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1500),
              color: Colors.white,
              width: size.width * 0.015,
              height:
                  ((size.height * 0.15) + (size.height * 0.03)) * (currentStep),
            ),
          ),
          // Circulos
          for (int i = 0; i < 4; i++)
            Positioned(
              top: heightLine * i,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentStep >= i ? colors.primary : Colors.grey[600],
                ),
                height: size.width * 0.05,
                width: size.width * 0.05,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityStep extends StatelessWidget {
  final int currentStep;
  final String horaInicio;
  final String horaFin;
  final int costo;
  const _ActivityStep({
    required this.currentStep,
    required this.horaInicio,
    required this.horaFin,
    required this.costo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;

    List<Map<String, String>> steps = [
      {
        'time': '${ReservaTimeHelper.subtractFiveMinutes(horaInicio)} PM',
        'text':
            '5 minutos antes, debes ir a pagar los \$$costo y obtener las llaves de la cancha.'
      },
      {
        'time': '$horaInicio PM',
        'text':
            'Comienza la hora de la cancha. Tienes 1 hora de tiempo de juego.'
      },
      {
        'time': '$horaFin PM',
        'text':
            'Termino de la hora de la cancha. Asegurate de retirar todas tus pertenencias.'
      },
      {
        'time': '${ReservaTimeHelper.addFiveMinutes(horaFin)} PM',
        'text': 'Dejar cerrada la entrada, si es que nadie mas esta esperando.'
      },
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 3 ? 0 : size.height * 0.03),
          child: FadeInRight(
            duration: const Duration(milliseconds: 200),
            delay: Duration(milliseconds: 500 * index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1500),
              padding: const EdgeInsets.only(left: 0, right: 20),
              width: double.infinity,
              height: size.height * 0.15,
              decoration: currentStep != index
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: colors.primary,
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.1,
                        child: Center(
                          child: currentStep > index
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topCenter,
                                      colors: [
                                        colors.muted,
                                        colors.muted.withGreen(200)
                                      ],
                                    ),
                                  ),
                                  width: size.width * 0.05,
                                  height: size.width * 0.05,
                                  child: AnimateIcon(
                                    onTap: () {},
                                    iconType: IconType.continueAnimation,
                                    height: 20,
                                    width: 20,
                                    color: colors.primary,
                                    animateIcon: AnimateIcons.checkmarkOk,
                                  ),
                                )
                              : currentStep == index
                                  ? AnimateIcon(
                                      onTap: () {},
                                      iconType: IconType.continueAnimation,
                                      height: 26,
                                      width: 26,
                                      color: colors.muted,
                                      animateIcon: AnimateIcons.submitProgress,
                                    )
                                  : Icon(
                                      Icons.check_box_outline_blank_outlined,
                                      color: currentStep >= index
                                          ? colors.muted
                                          : colors.muted.withOpacity(.5),
                                    ),
                        ),
                      ),
                      Text(
                        steps[index]['time']!,
                        style: currentStep != index
                            ? currentStep > index
                                ? textStyles.large
                                : textStyles.large.copyWith(
                                    color: Colors.grey[600],
                                  )
                            : textStyles.large
                                .copyWith(color: colors.secondary),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.1),
                    child: Text(
                      steps[index]['text']!,
                      style: currentStep != index
                          ? currentStep > index
                              ? textStyles.p
                              : textStyles.p.copyWith(
                                  color: Colors.grey[600],
                                )
                          : textStyles.p.copyWith(color: colors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PagoReserva extends StatelessWidget {
  final bool pagada;
  const _PagoReserva({required this.pagada});

  @override
  Widget build(BuildContext context) {
    final reservaProvider = context.watch<ReservaProvider>();
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    return Skeleton(
      isLoading: reservaProvider.loadingPagoReserva,
      skeleton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SkeletonAvatar(
          style: SkeletonAvatarStyle(
            borderRadius: BorderRadius.circular(15),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
      child: ZoomIn(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: pagada
              ? ShadCard(
                  radius: BorderRadius.circular(15),
                  trailing: AnimateIcon(
                    iconType: IconType.continueAnimation,
                    onTap: () {},
                    color: Colors.green[700]!,
                    animateIcon: AnimateIcons.dollar,
                  ),
                  width: double.infinity,
                  title: Text('¡Pago confirmado! 🏐', style: textStyles.h4),
                  description: const Text(
                      'El administrador ha confirmado que has pagado por esta hora.'),
                )
              : ShadCard(
                  radius: BorderRadius.circular(15),
                  trailing: AnimateIcon(
                    iconType: IconType.continueAnimation,
                    onTap: () {},
                    color: colors.muted,
                    animateIcon: AnimateIcons.loading3,
                  ),
                  width: double.infinity,
                  title: Text('Esperando Pago 💳', style: textStyles.h4),
                  description: const Text(
                      'En espera de confirmación de pago, por parte del administrador de la cancha.'),
                ),
        ),
      ),
    );
  }
}
