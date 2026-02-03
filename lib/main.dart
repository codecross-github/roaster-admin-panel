import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme.dart';
import 'core/routes.dart';

void main() {
  runApp(const RosterRadarAdminApp());
}

class RosterRadarAdminApp extends StatelessWidget {
  const RosterRadarAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Roster Radar Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
    );
  }
}
