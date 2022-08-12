import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surf_practice_chat_flutter/features/auth/features/login/presentation/login_screen.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/l10n/app_localizations.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/themes.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    runApp(const App());
  }, (error, stack) {
    dev.log('Unhandled exception in runZonedGuarded', error: error, stackTrace: stack);
  });
}

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telebum',
      theme: Themes.defaultTheme,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const LoginScreen(),
    );
  }
}
