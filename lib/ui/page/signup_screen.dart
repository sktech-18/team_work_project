import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:team_work_project/services/constants/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event_state.dart';
import '../bloc/theme_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColors = isDark
        ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
        : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3), const Color(0xFFE0EAFC)];

    final titleColor = isDark ? Colors.white : const Color(0xFF0F2027);
    final subtitleColor = isDark ? Colors.white70 : Colors.black87;
    final cardBgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02);
    final cardBorderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushNamedAndRemoveUntil(context, AppRouter.dashboard, (route) => false);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: bgColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Theme Toggle
                  Positioned(
                    top: 1.h,
                    right: 3.w,
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? Colors.white70 : const Color(0xFF0F2027),
                        size: 22.sp,
                      ),
                      onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
                    ),
                  ),

                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            Text(
                              "Create Account",
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Sign up to get started with TeamWork",
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: cardBorderColor),
                              ),
                              child: Column(
                                children: [
                                  // Full Name
                                  TextFormField(
                                    controller: _nameController,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    textCapitalization: TextCapitalization.words,
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: "Full Name",
                                      icon: Icons.person_outline,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Please enter your full name";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 2.5.h),
                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: "Email Address",
                                      icon: Icons.email_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Please enter your email";
                                      }
                                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                      if (!regex.hasMatch(value.trim())) {
                                        return "Please enter a valid email address";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 2.5.h),
                                  // Password
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: "Password",
                                      icon: Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: isDark ? Colors.white60 : Colors.black54,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Please enter a password";
                                      }
                                      if (value.trim().length < 6) {
                                        return "Password must be at least 6 characters";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 2.5.h),
                                  // Confirm Password
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirm,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: "Confirm Password",
                                      icon: Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: isDark ? Colors.white60 : Colors.black54,
                                        ),
                                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Please confirm your password";
                                      }
                                      if (value.trim() != _passwordController.text.trim()) {
                                        return "Passwords do not match";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 4.h),
                                  // Sign Up Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 6.h,
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!.validate()) {
                                                context.read<AuthBloc>().add(SignUpEvent(
                                                      name: _nameController.text,
                                                      email: _emailController.text,
                                                      password: _passwordController.text,
                                                    ));
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00B4DB),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 5,
                                        shadowColor: const Color(0xFF00B4DB).withOpacity(0.3),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : Text(
                                              "CREATE ACCOUNT",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  // OR Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: cardBorderColor)),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                                        child: Text(
                                          "OR",
                                          style: TextStyle(color: subtitleColor, fontSize: 13.sp),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: cardBorderColor)),
                                    ],
                                  ),
                                  SizedBox(height: 3.h),
                                  // Google Sign In Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 6.h,
                                    child: OutlinedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              context.read<AuthBloc>().add(GoogleSignInEvent());
                                            },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        side: BorderSide(color: cardBorderColor),
                                        backgroundColor: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.g_mobiledata, // Substitute for Google logo
                                            color: isDark ? Colors.white : Colors.black87,
                                            size: 32,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "SIGN UP WITH GOOGLE",
                                            style: TextStyle(
                                              color: titleColor,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            // Sign In Link
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: subtitleColor, fontSize: 14.sp),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: const Color(0xFF00B4DB),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
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
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required bool isDark,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
      prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.black54),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 2.h),
    );
  }
}
