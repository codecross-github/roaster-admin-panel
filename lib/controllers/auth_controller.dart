import 'package:get/get.dart';
import '../models/admin_cred_model.dart';
import '../services/auth_service.dart';
import '../core/routes.dart';

class AuthController extends GetxController {
  final _authService = AuthService();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final Rxn<AdminCredModel> currentAdmin = Rxn<AdminCredModel>();

  bool get isLoggedIn => currentAdmin.value != null;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final admin = await _authService.login(email, password);

      if (admin != null) {
        currentAdmin.value = admin;
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        errorMessage.value = 'Invalid email or password';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    currentAdmin.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
