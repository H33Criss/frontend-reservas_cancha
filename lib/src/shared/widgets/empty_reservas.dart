import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmptyReservas extends StatelessWidget {
  final String message;
  const EmptyReservas({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    return ShadCard(
      backgroundColor: colors.accent.withOpacity(.3),
      border: Border.all(color: colors.primary.withOpacity(.05)),
      content: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
            ),
            AnimateIcon(
              color: colors.accent,
              iconType: IconType.continueAnimation,
              animateIcon: AnimateIcons.list,
              onTap: () {},
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              message,
              style: textStyles.small
                  .copyWith(color: colors.primary.withOpacity(.3)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }
}
