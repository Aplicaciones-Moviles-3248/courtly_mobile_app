import 'package:flutter/material.dart';

import '../contexts/iam/presentation/screens/session_gate_screen.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class CourtlyApp extends StatelessWidget {
  const CourtlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRoutes.navigatorKey,
      title: 'Courtly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // El SessionGate decide si arranca en autenticación o en el perfil
      // según exista una sesión persistida.
      home: const SessionGateScreen(),
      routes: AppRoutes.routes,
    );
  }
}