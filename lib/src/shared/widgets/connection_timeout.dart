import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

//Only for socket in this moment
class ConnectionTimeoutWidget extends StatelessWidget {
  //the bool value, represents if you want clear and renew socket events
  final void Function(bool) tryAgainFunction;
  final double topSeparation;
  const ConnectionTimeoutWidget(
      {super.key, required this.tryAgainFunction, this.topSeparation = 0});

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return JelloIn(
      child: Column(
        children: [
          SizedBox(
            height: topSeparation,
          ),
          AnimateIcon(
            key: UniqueKey(),
            onTap: () {},
            iconType: IconType.continueAnimation,
            height: 50,
            width: 50,
            color: colors.primary,
            animateIcon: AnimateIcons.error,
          ),
          Text('Ocurrio un error', style: textStyles.h3),
          ShadButton(
            size: ShadButtonSize.sm,
            text: const Text('Intentar de nuevo'),
            onPressed: () {
              //the "true" value, represents if you want clear and renew socket events
              tryAgainFunction(true);
            },
          ),
        ],
      ),
    );
  }
}
