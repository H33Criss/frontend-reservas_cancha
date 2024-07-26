import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

import '../../../../providers/providers.dart';

class ButtonNormalLogin extends StatelessWidget {
  final TextEditingController email;
  final TextEditingController password;
  final GlobalKey<ShadFormState> formKey;
  const ButtonNormalLogin({
    super.key,
    required this.email,
    required this.password,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final authProvider = context.watch<AuthProvider>();
    Size size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          ShadButton(
            enabled: !authProvider.authenticating,
            width: double.infinity,
            icon: !authProvider.inProgressEmailAndPassword
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
            shadows: [
              BoxShadow(
                color: theme.colorScheme.muted.withOpacity(.4),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                theme.colorScheme.muted.withBlue(300),
                theme.colorScheme.muted,
              ],
            ),
            size: ShadButtonSize.lg,
            backgroundColor: theme.colorScheme.muted,
            text: authProvider.inProgressEmailAndPassword
                ? const Text('Cargando...')
                : const Text(
                    'INICIAR',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(5),
            rippleColor: Colors.white60,
            onTap: () async {
              FocusScope.of(context).unfocus();
              if (!formKey.currentState!.saveAndValidate()) {
                return;
              }

              try {
                await authProvider.loginWithEmailAndPassword(
                    email.text, password.text);
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
            child: SizedBox(
              width: double.infinity,
              height: size.height * 0.07,
            ),
          ),
        ],
      ),
    );
  }
}
