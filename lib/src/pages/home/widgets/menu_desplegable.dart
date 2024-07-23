import 'package:flutter/material.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MenuDesplegable extends StatefulWidget {
  const MenuDesplegable({super.key});

  @override
  State<MenuDesplegable> createState() => _MenuDesplegableState();
}

class _MenuDesplegableState extends State<MenuDesplegable> {
  final popoverController = ShadPopoverController();
  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: colors.primary.withOpacity(.1),
      ),

      child: ShadPopover(
        closeOnTapOutside: true,
        controller: popoverController,
        popover: (context) => SizedBox(
          width: size.width * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: colors.primary,
                  ),
                  SizedBox(width: size.width * 0.02),
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      if (userProvider.user != null) {
                        await authProvider.signOutUser();
                      }
                    },
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    text: const Text(
                      'Cerrar Sesión',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        child: ShadButton.ghost(
          text: Row(
            children: [
              Icon(
                Icons.person,
                color: colors.primary,
              ),
              const SizedBox(width: 5),
              Text(userProvider.user?.email ?? 'Error :(',
                  style: textStyles.labelMedium)
            ],
          ),
          onPressed: popoverController.toggle,
        ),
      ),
      // child: PopupMenuButton(
      //   // color: colors.primary,
      //   tooltip: 'Opciones',
      //   offset: const Offset(0, 40),
      //   icon: Row(
      //     children: [
      //       Icon(
      //         Icons.person,
      //         color: colors.primary,
      //       ),
      //       const SizedBox(width: 5),
      //       Text(userProvider.user?.email ?? 'Error :(',
      //           style: textStyles.labelMedium)
      //     ],
      //   ),
      //   onSelected: (value) async {
      //     if (value == 'logout' &&
      //         authProvider.status.value == AuthStatus.authenticated) {
      //       await authProvider.signOutUser();
      //     }
      //   },
      //   itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      //     const PopupMenuItem(
      //       value: 'logout',
      //       child: Text('Cerrar sesión'),
      //     ),
      //   ],
      // ),
    );
  }
}
