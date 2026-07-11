import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_work_project/services/services_handle.dart';

import '../ui/bloc/splash_bloc.dart';



class BlockProviders {
  static getProviders() => [
    BlocProvider<SplashBloc>(
      create: (_) => locator<SplashBloc>(),
    ),
  ];
}
