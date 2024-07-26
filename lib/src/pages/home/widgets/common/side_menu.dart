import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final profile = [
  (title: 'Name', value: 'Alexandru'),
  (title: 'Username', value: 'nank1ro'),
];

class SideMenu extends StatelessWidget {
  const SideMenu({super.key, required this.side});

  final ShadSheetSide side;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    return SafeArea(
      child: ShadSheet(
        removeBorderRadiusWhenTiny: false,
        radius: const BorderRadius.only(
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
        scrollable: false,
        // backgroundColor: theme.colorScheme.secondary.withOpacity(.9),
        border: Border.all(
          color: Colors.transparent,
        ),
        constraints: side == ShadSheetSide.left || side == ShadSheetSide.right
            ? BoxConstraints(maxWidth: size.width * 0.7)
            : null,
        title: const Text('Edit Profile'),
        description: const Text(
            "Make changes to your profile here. Click save when you're done"),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [],
          ),
        ),
        actions: [
          ShadButton(
            onPressed: () async {
              if (userProvider.user != null) {
                await authProvider.signOutUser().then((value) {
                  context.pop();
                });
              }
            },
            text: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
