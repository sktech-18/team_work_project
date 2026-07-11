import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/bloc/splash_bloc.dart';
import 'local-storage/shared_prefs_services.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();


  locator.registerSingleton<SharedPrefsService>(
    SharedPrefsService(_prefs),
  );


  locator.registerLazySingleton<SplashBloc>(
          () => SplashBloc());



  ///EXTERNAL
  locator.registerLazySingleton<Connectivity>(() => Connectivity());


  locator.registerLazySingleton<Dio>(
        () {
      Dio _dio = Dio()
        ..options.baseUrl = locator.get<SharedPrefsService>().getBaseUrl()!
        ..options.connectTimeout = Duration(seconds: 10)
        ..options.receiveTimeout = Duration(seconds: 10)
        ..httpClientAdapter
        ..options.headers = {
          'Content-Type': 'application/json; charset=UTF-8',
          /// "Authorization":
          /// "Bearer ${locator.get<SharedPrefsService>().valueGetter(StorageKeys.token) == '' ? locator.get<SharedPrefsService>().valueGetter(StorageKeys.token) : locator.get<SharedPrefsService>().valueGetter(StorageKeys.token)}",
        };
      return _dio;
    },
  );
}