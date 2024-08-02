import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pobla_app/src/pages/home/widgets/home_view/bienvenida_widget.dart';
import 'package:pobla_app/src/pages/home/widgets/home_view/horario_widget.dart';
import 'package:pobla_app/src/pages/home/widgets/home_view/proximas_reservas_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07, vertical: size.height * 0.03),
            child: const BienvenidaWidget(),
          ),
          SizedBox(height: size.height * 0.025),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
            child: const HorarioWidget(),
          ),
          SizedBox(height: size.height * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
            child: Row(
              children: [
                Text('Reservas próximas', style: textStyles.h4),
                const Spacer(),
                ShadButton(
                  onPressed: () => context.push('/reservas'),
                  size: ShadButtonSize.sm,
                  icon: Icon(MdiIcons.arrowCollapseAll),
                  text: const Text('Ver Reservas'),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Padding(
            padding: EdgeInsets.only(left: size.width * 0.07),
            child: const ProximasReservasWidget(),
          )
        ],
      ),
    );
  }
}
