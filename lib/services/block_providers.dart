import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_work_project/services/services_handle.dart';

import '../ui/bloc/splash_bloc.dart';
import '../ui/bloc/task_bloc.dart';
import '../ui/bloc/theme_bloc.dart';

class BlockProviders {
  static getProviders() => [
    BlocProvider<SplashBloc>(
      create: (_) => locator<SplashBloc>(),
    ),
    BlocProvider<TaskBloc>(
      create: (_) => locator<TaskBloc>(),
    ),
    BlocProvider<ThemeBloc>(
      create: (_) => locator<ThemeBloc>()..add(LoadThemeEvent()),
    ),
  ];
}
