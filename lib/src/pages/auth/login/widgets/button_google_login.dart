import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../providers/providers.dart';

class ButtonGoogleLogin extends StatelessWidget {
  const ButtonGoogleLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();
    return ShadButton(
      enabled: !authProvider.authenticating,
      onPressed: () async {
        try {
          await authProvider.loginWithGoogle();
        } catch (e) {
          if (!context.mounted) return;
          ShadToaster.of(context).show(
            ShadToast.destructive(
              duration: const Duration(milliseconds: 1500),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded),
                  const SizedBox(width: 10),
                  Text(
                    e.toString().split(':')[1],
                    style: textStyles.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }
      },
      size: ShadButtonSize.lg,
      icon: authProvider.inProgressGoogle
          ? const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          : null,
      text: Row(
        children: [
          if (!authProvider.inProgressGoogle)
            Image.asset(
              'assets/images/google.webp',
              width: 20,
              height: 20,
            ),
          const SizedBox(width: 10),
          if (!authProvider.inProgressGoogle)
            const Text('Continuar con Google'),
          if (authProvider.inProgressGoogle) const Text('Cargando...'),
        ],
      ),
      // icon: Image.asset(
      //   'assets/images/google.webp',
      //   width: 20,
      //   height: 20,
      // ),
    );
  }
}
