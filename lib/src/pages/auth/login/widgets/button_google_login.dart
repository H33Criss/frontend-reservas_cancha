import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../providers/providers.dart';

class ButtonGoogleLogin extends StatelessWidget {
  const ButtonGoogleLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return ShadButton(
      onPressed: () async {
        await authProvider.loginWithGoogle();
      },
      size: ShadButtonSize.lg,
      icon: authProvider.status.value == AuthStatus.authenticating
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
          Image.asset(
            'assets/images/google.webp',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 10),
          const Text('Continuar con Google'),
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
