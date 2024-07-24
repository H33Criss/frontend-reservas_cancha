import 'package:flutter/material.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BienvenidaWidget extends StatelessWidget {
  const BienvenidaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final textStyles = ShadTheme.of(context).textTheme;
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'Bienvenido, ',
          style: textStyles.h2.copyWith(fontWeight: FontWeight.normal),
        ),
        TextSpan(
          text: userProvider.user?.fullName ?? 'Desconocido',
          style: textStyles.h2,
        ),
        TextSpan(
          text: '!',
          style: textStyles.h2,
        ),
      ]),
    );
  }
}
