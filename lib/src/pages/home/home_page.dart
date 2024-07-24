import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pobla_app/src/pages/home/views/home_view.dart';
import 'package:pobla_app/src/pages/home/widgets/menu_desplegable.dart';
import 'package:pobla_app/src/pages/home/widgets/side_menu.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: size.width * 0.2,
        leading: ShadButton.ghost(
          text: const Icon(LucideIcons.menu),
          onPressed: () => showShadSheet(
            side: ShadSheetSide.left,
            context: context,
            builder: (context) => const SideMenu(
              side: ShadSheetSide.left,
            ),
          ),
        ),
        actions: [
          // MenuDesplegable(),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: FadeIn(
              child: ShadAvatar(
                userProvider.user?.imageUrl ??
                    'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                placeholder: const SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                      shape: BoxShape.circle, width: 50, height: 50),
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
          )
        ],
      ),
      body: const HomeView(),
    );
  }
}
