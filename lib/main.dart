import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme/app_theme.dart';
import 'services/local_storage.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o idioma português do Brasil
  await initializeDateFormatting('pt_BR', null);

  // Inicializa o armazenamento local
  await LocalStorage.init();

  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProxyProvider<AuthService, DataService>(
          create: (ctx) => DataService(
            ctx.read<AuthService>(),
          ),
          update: (_, auth, previous) =>
          previous ?? DataService(auth),
        ),
      ],
      child: MaterialApp(
        title: 'StudyFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('pt', 'BR'),
        home: const SplashScreen(),
      ),
    );
  }
}