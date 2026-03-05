import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = 'admin@rosterradar.com';
    _passwordController.text = 'admin123';
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ROSTER',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'RADAR',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: AppColors.gray,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Login Form Card
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your credentials to access the admin panel',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Message
                        Obx(() {
                          if (_authController.errorMessage.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _authController.errorMessage.value,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Email Field
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: 'admin@rosterradar.com',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.gray),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gray),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.gray,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Login Button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _authController.isLoading.value ? null : _handleLogin,
                            child: _authController.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  )
                                : const Text('Sign In'),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Text(
                  '2026 Roster Radar. All rights reserved.',
                  style: TextStyle(
                    color: AppColors.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
