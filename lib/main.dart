import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surf_practice_chat_flutter/features/auth/screens/auth_screen.dart';
import 'package:surf_practice_chat_flutter/features/core/l10n/app_localizations.dart';

// TODO: кэширование токена
// TODO: проработать навигацию и сделать выход из аккаунта
// TODO: добавить сплэш на стороне флаттера и читать кэш
// TODO: добавить кнопку скролла чата вниз, когда проскроллено вверх и начался скролл вниз
// TODO: на экране авторизации сделать переходы по полям через фокус
// TODO: доработать все текстовые поля для более удобного ввода
// TODO: не забыть прогреть шейдеры
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
      title: 'Surf Chat',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AuthScreen(),
    );
  }
}
