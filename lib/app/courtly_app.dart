import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class CourtlyApp extends StatelessWidget {
  const CourtlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courtly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      //initialRoute: AppRoutes.courts,
      initialRoute: AppRoutes.signIn,
      routes: AppRoutes.routes,
    );
  }
}