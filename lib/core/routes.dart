import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/report_requests_screen.dart';
import '../screens/pitcher_report_form_screen.dart';
import '../screens/hitter_report_form_screen.dart';
import '../screens/reports_list_screen.dart';
import '../screens/players_screen.dart';
import '../screens/users_screen.dart';

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
        GetPage(name: dashboard, page: () => const DashboardScreen()),
        GetPage(name: reportRequests, page: () => const ReportRequestsScreen()),
        GetPage(name: pitcherReportForm, page: () => const PitcherReportFormScreen()),
        GetPage(name: hitterReportForm, page: () => const HitterReportFormScreen()),
        GetPage(name: reportsList, page: () => const ReportsListScreen()),
        GetPage(name: players, page: () => const PlayersScreen()),
        GetPage(name: users, page: () => const UsersScreen()),
      ];
}
