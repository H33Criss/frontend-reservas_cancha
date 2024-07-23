import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/config/router/main_router.dart';
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
        ChangeNotifierProvider(create: (_) => ReservaProvider()),
        ChangeNotifierProvider(create: (_) => BloqueosProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
        theme: ShadThemeData(
          brightness: Brightness.dark,
          textTheme: ShadTextTheme(
            family: 'Kanit',
          ),
          colorScheme: const ShadSlateColorScheme.dark(muted: Colors.blue),
        ),
        materialThemeBuilder: (context, theme) {
          return ThemeData(
            fontFamily: 'Kanit',
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue[600],
          );
        },
        darkTheme: ShadThemeData(
          buttonSizesTheme: ShadButtonSizesTheme(
            lg: ShadButtonSizeTheme(
              height: size.height * 0.06,
              padding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
          textTheme: ShadTextTheme(
            family: 'Kanit',
          ),
          brightness: Brightness.dark,
          colorScheme: const ShadSlateColorScheme.dark(muted: Colors.blue),
        ),
        locale: const Locale('es', 'ES'),
        routerConfig: mainRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
