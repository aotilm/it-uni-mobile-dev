import 'package:flutter/material.dart';
import 'package:test_journal/screens/login_page.dart';
import 'package:test_journal/theme_data.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
    await WindowsSingleInstance.ensureSingleInstance(
        args,
        "custom_identifier",
        onSecondWindow: (args) {
            print(args);
        });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: LoginPage(),
      title: 'Journal',
      theme: AppTheme.themeData,
      locale: const Locale('uk', 'UA'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('uk', 'UA'),
        const Locale('en', 'US'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
      },
    );
  }
}


