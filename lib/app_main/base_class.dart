import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';


import '../services/block_providers.dart';
import '../services/constants/app_router.dart';
import '../ui/page/splash_screen.dart';


GlobalKey<NavigatorState> mainNavKey = GlobalKey<NavigatorState>();

class MainBaseClass extends StatelessWidget {
  const MainBaseClass({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
        providers: BlockProviders.getProviders(),
        child: Sizer(builder: (context, orientation, screenType){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TeamWork',
            navigatorKey: mainNavKey,
            routes: AppRouter.getAppRoutes(),
            home: SplashScreen(),
          );
        }));
  }}
