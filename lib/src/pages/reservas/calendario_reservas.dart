import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:horizontal_week_calendar/horizontal_week_calendar.dart';
import 'package:pobla_app/src/data/hours_definitions.dart';
import 'package:pobla_app/src/pages/reservas/widgets/card_reserva.dart';
import 'package:pobla_app/src/pages/reservas/widgets/card_reserva_skeleton.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket_reserva_provider.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CalendarioReservas extends StatefulWidget {
  const CalendarioReservas({super.key});

  @override
  State<CalendarioReservas> createState() => _CalendarioReservasState();
}

class _CalendarioReservasState extends State<CalendarioReservas> {
  late ReservaProvider _reservaProvider;
  late BloqueosProvider _bloqueosProvider;
  late PageController _pageController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _reservaProvider = context.read<ReservaProvider>();
    _bloqueosProvider = context.read<BloqueosProvider>();
    _initConnectionSocket(false);
    _pageController = PageController(initialPage: _selectedDate.weekday - 1);
  }

  @override
  void dispose() {
    _reservaProvider.disconnect([
      ReservasEvent.reservasOfAny,
      ReservasEvent.newReservaOfAny,
    ]);
    _bloqueosProvider.disconnect();
    _pageController.dispose();
    super.dispose();
  }

  void _initConnectionSocket(bool renew) {
    if (renew) {
      _reservaProvider.disconnect([
        ReservasEvent.reservasOfAny,
        ReservasEvent.newReservaOfAny,
      ]);
      _bloqueosProvider.disconnect();
    }
    _reservaProvider.connect([
      ReservasEvent.reservasOfAny,
      ReservasEvent.newReservaOfAny,
    ]);
    _bloqueosProvider.connect();
  }

  void _onDateChange(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _pageController.animateToPage(
      date.weekday - 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final theme = ShadTheme.of(context);
    final bloqueosProvider = context.watch<BloqueosProvider>();
    final reservaProvider = context.watch<ReservaProvider>();
    final weekData = WeekCalculator.getWeekDates();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario'),
        actions: [
          ShadBadge.outline(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            text: Text(monthNames[DateTime.now().month - 1],
                style: textStyles.headlineSmall),
          ),
        ],
      ),
      body: Column(
        children: [
          HorizontalWeekCalendar(
            onDateChange: (date) {
              DateTime adjustedDate = date.add(const Duration(hours: 1));
              _onDateChange(adjustedDate);
            },
            scrollPhysics: const NeverScrollableScrollPhysics(),
            inactiveTextColor: Colors.grey,
            minDate: weekData.firstDayOfWeek,
            maxDate: weekData.lastDayOfWeek,
            initialDate: _selectedDate,
            showNavigationButtons: false,
            activeBackgroundColor: theme.colorScheme.muted,
            showTopNavbar: false,
            borderRadius: BorderRadius.circular(10),
            inactiveBackgroundColor: theme.colorScheme.muted.withOpacity(.1),
          ),
          Expanded(
            child: Skeleton(
              isLoading: reservaProvider.loadingReservas ||
                  bloqueosProvider.loadingBloqueos,
              skeleton: const CardReservaSkeleton(),
              child: reservaProvider.connectionTimeOut
                  ? Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.2,
                        ),
                        AnimateIcon(
                          key: UniqueKey(),
                          onTap: () {},
                          iconType: IconType.continueAnimation,
                          height: 50,
                          width: 50,
                          color: theme.colorScheme.primary,
                          animateIcon: AnimateIcons.error,
                        ),
                        Text('Ocurrio un error', style: theme.textTheme.h3),
                        ShadButton(
                          text: const Text('Intentar de nuevo'),
                          onPressed: () {
                            _initConnectionSocket(true);
                          },
                        ),
                      ],
                    )
                  : PageView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      itemCount: 7, // Número de días en la semana
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: ListView.builder(
                            itemCount: hoursDefinitions.length,
                            itemBuilder: (context, i) {
                              final hour = hoursDefinitions[i];
                              return CardReserva(
                                hour: hour,
                                index: i,
                                selectedDate: _selectedDate,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
