import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:team_work_project/services/constants/app_router.dart';
import 'package:team_work_project/ui/bloc/splash_bloc.dart';
import 'package:team_work_project/ui/bloc/auth_bloc.dart';
import 'package:team_work_project/services/local-storage/shared_prefs_services.dart';
import 'package:team_work_project/services/services_handle.dart';

import '../bloc/splash_event_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch the timer event to trigger the 3-second splash delay.
    context.read<SplashBloc>().add(const StartSplashTimer());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToLogin) {
            // Check if user session is persisted via AuthBloc
            final isLoggedIn = context.read<AuthBloc>().isLoggedIn;
            if (isLoggedIn) {
              debugPrint("[SplashScreen] User session found. Navigating to Dashboard.");
              Navigator.pushReplacementNamed(context, AppRouter.dashboard);
            } else {
              debugPrint("[SplashScreen] No user session. Navigating to Login.");
              Navigator.pushReplacementNamed(context, AppRouter.loginPage);
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top-right subtle glowing orb
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00B4DB).withOpacity(0.08),
                    ),
                  ),
                ),
                // Bottom-left subtle glowing orb
                Positioned(
                  bottom: -150,
                  left: -150,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0083B0).withOpacity(0.08),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Branding Logo / Glassmorphic Panel
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Icon placeholder container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00B4DB).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.group_work_rounded,
                              size: 40.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Brand Name
                          Text(
                            "TEAMWORK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          // Subtitle/Mantra
                          Text(
                            "Collaborate & Achieve",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Activity Indicator
                    const CupertinoActivityIndicator(
                      color: Colors.white70,
                      radius: 12,
                    ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
