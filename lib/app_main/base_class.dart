import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../services/block_providers.dart';
import '../services/constants/app_router.dart';
import '../ui/bloc/theme_bloc.dart';
import '../ui/page/splash_screen.dart';

GlobalKey<NavigatorState> mainNavKey = GlobalKey<NavigatorState>();

class MainBaseClass extends StatelessWidget {
  const MainBaseClass({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlockProviders.getProviders(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Sizer(
            builder: (context, orientation, screenType) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'TeamWork',
                navigatorKey: mainNavKey,
                themeMode: state.themeMode,
                theme: ThemeData(
                  brightness: Brightness.light,
                  primaryColor: const Color(0xFF00B4DB),
                  scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Soft light background
                  cardColor: Colors.white,
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF00B4DB),
                    brightness: Brightness.light,
                    background: const Color(0xFFF5F7FA),
                    surface: Colors.white,
                  ),
                  dropdownMenuTheme: DropdownMenuThemeData(
                    menuStyle: MenuStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  primaryColor: const Color(0xFF00B4DB),
                  scaffoldBackgroundColor: const Color(0xFF0F2027), // Deep space dark background
                  cardColor: const Color(0xFF14262F),
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF00B4DB),
                    brightness: Brightness.dark,
                    background: const Color(0xFF0F2027),
                    surface: const Color(0xFF14262F),
                  ),
                  dropdownMenuTheme: DropdownMenuThemeData(
                    menuStyle: MenuStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF14262F)),
                    ),
                  ),
                ),
                routes: AppRouter.getAppRoutes(),
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
