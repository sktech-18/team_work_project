import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:team_work_project/services/constants/end_points.dart';
import 'package:team_work_project/services/network/app_flavor_config.dart';
import 'package:team_work_project/services/services_handle.dart';

import 'app_main/base_class.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  /// Share Preferences Init function
  await setupLocator();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Configure app flavor settings
  AppFlavorConfig.create(
    appName: "TEAMWORK",
    baseUrl: EndPoints.devBaseUrl, // Use production URL for production environment
    flavor: Environment.dev,
  );


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MainBaseClass());
  } );
  // Run the app

}
