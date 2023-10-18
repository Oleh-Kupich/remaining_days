import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:remaining_days/home_page.dart';
import 'package:remaining_days/widgets/bottom_bar_widget/controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('uk')],
        path: 'resources/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: const RemainingDaysApp(),
    ),
  );
}

class RemainingDaysApp extends StatelessWidget {
  const RemainingDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.orangeAccent);
    return MaterialApp(
      title: 'Remaining Days',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        useMaterial3: true,
      ),
      home: const DefaultBottomBarController(
        child: HomePage(),
      ),
    );
  }
}
