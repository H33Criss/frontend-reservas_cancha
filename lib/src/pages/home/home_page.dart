import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pobla_app/src/pages/home/widgets/menu_desplegable.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: const [
          MenuDesplegable(),
        ],
      ),
      body: Center(
        child: ShadButton(
          text: const Text('Ir ca Calendario'),
          onPressed: () => context.push('/calendario-reservas'),
        ),
      ),
    );
  }
}
