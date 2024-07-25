import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/config/router/main_router.dart';
import 'package:pobla_app/config/theme/app_theme.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  await Environment.initEnvironment();
  Intl.defaultLocale = 'es_ES';
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..renewUser()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BloqueosProvider()..initSocket()),
        ChangeNotifierProvider(create: (_) => ReservaProvider()..initialize()),
      ],
      child: ShadApp.router(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('es', 'ES'), // Spanish
        ],
        theme: AppTheme.getShadTheme(size),
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.getDarkShadTheme(size),
        locale: const Locale('es', 'ES'),
        routerConfig: mainRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
