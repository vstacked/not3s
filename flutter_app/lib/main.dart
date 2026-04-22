import 'package:flutter/material.dart';
import 'package:not3s/core/router/router.dart';
import 'package:not3s/core/styles/app_theme.dart';
import 'package:not3s/core/utils/injections.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjections();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'not3s',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
