import 'package:flutter/material.dart';
import 'package:pobla_app/src/helpers/forms/validators_form.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ShadInputPassword extends StatefulWidget {
  final TextEditingController controllerPassword;
  const ShadInputPassword({super.key, required this.controllerPassword});

  @override
  State<ShadInputPassword> createState() => _ShadInputPasswordState();
}

class _ShadInputPasswordState extends State<ShadInputPassword> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    return ShadInputFormField(
      id: 'password',
      style: textStyles.titleMedium,
      controller: widget.controllerPassword,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      placeholder: const Text('Password'),
      obscureText: obscure,
      prefix: const Padding(
        padding: EdgeInsets.all(4.0),
        child: ShadImage.square(size: 16, LucideIcons.lock),
      ),
      validator: (value) {
        if (ValidatorsForm.isPasswordDefined(value!)) {
          return 'Debes ingresar una contraseña';
        }
        return null;
      },
      suffix: ShadButton(
        width: 24,
        height: 24,
        padding: EdgeInsets.zero,
        decoration: const ShadDecoration(
          secondaryBorder: ShadBorder.none,
          secondaryFocusedBorder: ShadBorder.none,
        ),
        icon: ShadImage.square(
          size: 16,
          obscure ? LucideIcons.eyeOff : LucideIcons.eye,
        ),
        onPressed: () {
          setState(() => obscure = !obscure);
        },
      ),
    );
  }
}
