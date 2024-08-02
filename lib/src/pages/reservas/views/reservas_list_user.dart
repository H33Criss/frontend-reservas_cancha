import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReservasListUser extends StatelessWidget {
  const ReservasListUser({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Historial de Reservas',
            style: textStyles.h4,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 15, horizontal: size.width * 0.07),
                child: ShadCard(
                  backgroundColor: colors.primaryForeground,
                  width: size.width,
                  height: size.height * 0.2,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                child: ShadTabs(
                  decoration: ShadDecoration(
                    color: colors.primaryForeground,
                  ),
                  defaultValue: 'Proximas',
                  tabs: [
                    ShadTab(
                      value: 'Proximas',
                      text: const Text('Proximas'),
                      content: ShadCard(
                        title: const Text('Proximas'),
                        description: const Text(
                            "Make changes to your account here. Click save when you're done."),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            ShadInputFormField(
                              label: const Text('Name'),
                              initialValue: 'Ale',
                            ),
                            const SizedBox(height: 8),
                            ShadInputFormField(
                              label: const Text('Username'),
                              initialValue: 'nank1ro',
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        footer: const ShadButton(text: Text('Save changes')),
                      ),
                    ),
                    ShadTab(
                      value: 'Todas',
                      text: const Text('Todas'),
                      content: ShadCard(
                        title: const Text('Todas'),
                        description: const Text(
                            "Change your password here. After saving, you'll be logged out."),
                        content: Column(
                          children: [
                            const SizedBox(height: 16),
                            ShadInputFormField(
                              label: const Text('Current password'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 8),
                            ShadInputFormField(
                              label: const Text('New password'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        footer: const ShadButton(text: Text('Save password')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
