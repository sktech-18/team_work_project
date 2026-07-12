
import 'package:flutter/cupertino.dart';
import 'package:team_work_project/ui/page/dashboard_screen.dart';
import 'package:team_work_project/ui/page/login_screen.dart';
import 'package:team_work_project/ui/page/signup_screen.dart';

import '../../ui/page/splash_screen.dart';

abstract class AppRouter {


  static String initRoute = "/splash";
  static String loginPage = "/login_page";
  static String signup = "/signup";
  static String dashboard = "/dashboard";

  static Map<String, WidgetBuilder> getAppRoutes() {
    return {
      initRoute: (ctx) => SplashScreen(),
      loginPage: (ctx) => LoginScreen(),
      signup: (ctx) => SignUpScreen(),
      dashboard: (ctx) => DashboardScreen(),
    };
  }
}