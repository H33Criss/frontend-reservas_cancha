import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pobla_app/src/data/hours_definitions.dart';
import 'package:pobla_app/src/providers/reservas/reserva_provider.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MenuConfirmacion extends StatelessWidget {
  final DateTime selectedDate;
  final HourDifinition hour;
  const MenuConfirmacion(
      {super.key, required this.hour, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final theme = ShadTheme.of(context);
    final textStyles = Theme.of(context).textTheme;
    final reservaProvider = context.watch<ReservaProvider>();

    return ShadSheet(
      shadows: [
        BoxShadow(
          color: Colors.white.withOpacity(.4),
          spreadRadius: 4,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.transparent,
      ),
      radius: BorderRadius.circular(5),
      constraints: BoxConstraints(maxHeight: size.height * 0.5),
      title: const Text('Reservación'),
      description: Text(
          'Para el ${weekDayNames[selectedDate.weekday - 1]} ${selectedDate.day} de ${monthNames[selectedDate.month - 1]} de ${selectedDate.year}'),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hora Inicio',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ShadInput(
                    enabled: false,
                    initialValue: hour.horaInicio,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hora Fin',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ShadInput(
                    enabled: false,
                    initialValue: hour.horaFin,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Coste',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  flex: 2,
                  child: ShadInput(
                    enabled: false,
                    initialValue: '\$10.000',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.informationSlabCircleOutline),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Pago en persona o transferencia.',
                  style: textStyles.labelSmall,
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        ShadButton(
          backgroundColor: theme.colorScheme.muted,
          foregroundColor: Colors.white,
          pressedForegroundColor: Colors.white.withOpacity(.7),
          pressedBackgroundColor: theme.colorScheme.muted.withOpacity(.7),
          icon: !reservaProvider.creatingReserva
              ? null
              : const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
          onPressed: () async {
            Map<String, dynamic> reservaData = {
              'diaSemana': weekDayNames[selectedDate.weekday - 1],
              'horaInicio': hour.horaInicio,
              'horaFin': hour.horaFin,
              'fechaReserva': WeekCalculator.formatDate(selectedDate),
              'coste': 10000,
            };
            await reservaProvider.addReserva(reservaData).then((response) {
              context.pop();
              Future.delayed(const Duration(milliseconds: 200), () {
                ShadToaster.of(context).show(
                  ShadToast(
                    radius: BorderRadius.circular(10),
                    duration: const Duration(seconds: 3),
                    title: const Text('Reserva realizada'),
                    description: Text(
                        'Se ha reservado para el ${weekDayNames[selectedDate.weekday - 1]} ${selectedDate.day} de ${monthNames[selectedDate.month - 1]} de ${selectedDate.year}'),
                  ),
                );
              });
            }).catchError((error) {
              print('Ocurrio este error: $error');
            });
          },
          text: const Text('Reservar Hora'),
        ),
      ],
    );
  }
}
