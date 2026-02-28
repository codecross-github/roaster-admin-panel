import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/report_requests_screen.dart';
import '../screens/pitcher_report_form_screen.dart';
import '../screens/hitter_report_form_screen.dart';
import '../screens/reports_list_screen.dart';
import '../screens/players_screen.dart';
import '../screens/users_screen.dart';
import '../controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String reportRequests = '/report-requests';
  static const String pitcherReportForm = '/report/pitcher';
  static const String hitterReportForm = '/report/hitter';
  static const String reportsList = '/reports';
  static const String players = '/players';
  static const String users = '/users';

  static List<GetPage> get pages => [
        GetPage(name: login, page: () => const LoginScreen()),
        GetPage(
          name: dashboard,
          page: () => const DashboardScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: reportRequests,
          page: () => const ReportRequestsScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: pitcherReportForm,
          page: () => const PitcherReportFormScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: hitterReportForm,
          page: () => const HitterReportFormScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: reportsList,
          page: () => const ReportsListScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: players,
          page: () => const PlayersScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: users,
          page: () => const UsersScreen(),
          middlewares: [AuthMiddleware()],
        ),
      ];
}
