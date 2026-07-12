import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/bloc/splash_bloc.dart';
import '../ui/bloc/task_bloc.dart';
import '../ui/bloc/theme_bloc.dart';
import '../dependancy/repositories/home_repository.dart';
import '../dependancy/remote/remote_home_data_source.dart';
import '../dependancy/useCases/home_use_case.dart';
import 'local-storage/shared_prefs_services.dart';
import 'network/network_info.dart';
import 'network/app_flavor_config.dart';
import '../ui/bloc/auth_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  locator.registerSingleton<SharedPrefsService>(
    SharedPrefsService(_prefs),
  );

  locator.registerLazySingleton<SplashBloc>(
    () => SplashBloc(),
  );

  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(),
  );

  ///EXTERNAL
  locator.registerLazySingleton<Connectivity>(() => Connectivity());

  locator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImplWithConnectivityPlus(locator<Connectivity>()),
  );

  locator.registerLazySingleton<HomeRepositories>(
    () => HomeDataSourceImp(networkInfo: locator<NetworkInfo>()),
  );

  locator.registerLazySingleton<HomeUseCase>(
    () => HomeUseCase(locator<HomeRepositories>()),
  );

  locator.registerFactory<TaskBloc>(
    () => TaskBloc(useCase: locator<HomeUseCase>(), sharedPrefs: locator<SharedPrefsService>()),
  );

  locator.registerFactory<ThemeBloc>(
    () => ThemeBloc(sharedPrefs: locator<SharedPrefsService>()),
  );

  locator.registerLazySingleton<Dio>(
    () {
      Dio _dio = Dio()
        ..options.baseUrl = locator.get<SharedPrefsService>().getBaseUrl()!
        ..options.connectTimeout = const Duration(seconds: 10)
        ..options.receiveTimeout = const Duration(seconds: 10)
        ..options.headers = {
          'Content-Type': 'application/json; charset=UTF-8',
        };
      return _dio;
    },
  );
}