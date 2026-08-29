import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardOpen =
                MediaQuery.of(context).viewInsets.bottom > 0;

            return Stack(
              children: [
                // ==========================================
                // BAGIAN ATAS
                // ==========================================
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,

                  top: keyboardOpen ? 20 : 70,
                  left: 0,
                  right: 0,

                  child: Column(
                    children: [
                      // LOGO
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: 0.785398,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(7),
                              ),
                              child: Transform.rotate(
                                angle: -0.785398,
                                child: const Center(
                                  child: Text(
                                    'B',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'BANDELL',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 3),

                      const Text(
                        'Silakan login untuk melanjutkan',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // FORM LOGIN
                // ==========================================
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,

                  top: keyboardOpen ? 145 : 257,
                  left: 0,
                  right: 0,
                  bottom: 0,

                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      48,
                      20,
                      20,
                    ),

                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),

                    child: SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),

                      child: Column(
                        children: [
                          // ==================================
                          // USERNAME
                          // ==================================
                          _buildTextField(
                            controller:
                                usernameController,
                            label: 'Username',
                            hint: 'Masukkan username',
                            prefixIcon:
                                Icons.person_outline,
                          ),

                          const SizedBox(height: 14),

                          // ==================================
                          // PASSWORD
                          // ==================================
                          _buildTextField(
                            controller:
                                passwordController,
                            label: 'Password',
                            hint: 'Masukkan password',
                            prefixIcon:
                                Icons.lock_outline,
                            obscureText:
                                obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                                color:
                                    AppColors.icon,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ==================================
                          // INGAT SAYA + LUPA PASSWORD
                          // ==================================
                          Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe =
                                          value ?? false;
                                    });
                                  },
                                  activeColor:
                                      AppColors.primary,
                                  side:
                                      const BorderSide(
                                    color:
                                        AppColors.border,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            4),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 5),

                              const Text(
                                'Ingat saya',
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary,
                                  fontSize: 13,
                                ),
                              ),

                              const Spacer(),

                              GestureDetector(
                                onTap: () {
                                  // TODO:
                                  // Halaman lupa password
                                },
                                child: const Text(
                                  'Lupa password?',
                                  style: TextStyle(
                                    color:
                                        AppColors.link,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================
                          // BUTTON LOGIN
                          // ==================================
                          SizedBox(
                            width: double.infinity,
                            height: 43,
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context)
                                    .unfocus();

                                final username =
                                    usernameController
                                        .text
                                        .trim();

                                final password =
                                    passwordController
                                        .text
                                        .trim();

                                debugPrint(
                                  'Username: $username',
                                );

                                debugPrint(
                                  'Password: $password',
                                );

                                // TODO:
                                // Hubungkan ke API
                              },
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary,
                                foregroundColor:
                                    AppColors.white,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 27),

                          // ==================================
                          // HUBUNGI ADMIN
                          // ==================================
                          RichText(
                            text: const TextSpan(
                              text: 'Belum punya akun? ',
                              style: TextStyle(
                                color:
                                    AppColors.textSecondary,
                                fontSize: 12,
                                fontStyle:
                                    FontStyle.italic,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Hubungi Admin',
                                  style: TextStyle(
                                    color:
                                        AppColors.link,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ========================================================
  // TEXT FIELD
  // ========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 50,

      child: TextField(
        controller: controller,
        obscureText: obscureText,

        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),

        decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.icon,
            size: 20,
          ),

          suffixIcon: suffixIcon,

          labelText: label,

          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),

          floatingLabelBehavior:
              FloatingLabelBehavior.always,

          hintText: hint,

          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}