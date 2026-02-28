import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'controllers/auth_controller.dart';

Future<void> _seedAdminCred() async {
  final collection = FirebaseFirestore.instance.collection('admin-cred');
  final snapshot = await collection.limit(1).get();

  if (snapshot.docs.isEmpty) {
    await collection.add({
      'name': 'Super Admin',
      'email': 'admin@rosterradar.com',
      'password': 'admin123',
      'role': 'super_admin',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
    debugPrint('Seeded default admin-cred document.');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await _seedAdminCred();
  //
  Get.put(AuthController());

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
