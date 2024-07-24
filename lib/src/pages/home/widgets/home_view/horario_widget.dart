import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HorarioWidget extends StatelessWidget {
  const HorarioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: size.height * 0.3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/waterball.png'),
          fit: BoxFit.fitHeight,
          alignment: Alignment.centerRight,
          colorFilter: ColorFilter.mode(
            // Colors.white30,
            Colors.white.withOpacity(.1),
            BlendMode.dstIn,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.muted.withOpacity(.4),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            colors.muted.withBlue(300),
            colors.muted,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsetsDirectional.all(20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reservas',
            style: textStyles.h4.copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            'Cancha de futból',
            style: textStyles.h4.copyWith(fontWeight: FontWeight.normal),
          ),
          SizedBox(height: size.height * 0.025),
          Text(
            'Mira el horario de la cancha',
            style: textStyles.list.copyWith(
              fontWeight: FontWeight.normal,
              color: Colors.white54,
            ),
          ),
          Text(
            'y reserva tu hora.',
            style: textStyles.list
                .copyWith(fontWeight: FontWeight.normal, color: Colors.white54),
          ),
          SizedBox(height: size.height * 0.03),
          ShadButton(
            decoration: ShadDecoration(
              border: ShadBorder(radius: BorderRadius.circular(20)),
            ),
            size: ShadButtonSize.sm,
            icon: const Icon(LucideIcons.arrowRight),
            text: const Text('Ir al Horario'),
            onPressed: () => context.push('/calendario-reservas'),
          ),
        ],
      ),
    );
  }
}
