import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:team_work_project/services/local-storage/shared_prefs_services.dart';
import 'package:team_work_project/ui/bloc/auth_bloc.dart';
import 'package:team_work_project/ui/bloc/auth_event_state.dart';
import 'package:team_work_project/ui/bloc/theme_bloc.dart';
import 'package:team_work_project/ui/page/login_screen.dart';

class FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  FakeAuthBloc() : super(AuthInitial());

  @override
  bool get isLoggedIn => false;
}

void main() {
  setUp(() async {
    final locator = GetIt.instance;
    await locator.reset();

    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    locator.registerSingleton<SharedPrefsService>(
      SharedPrefsService(sharedPrefs),
    );

    locator.registerFactory<ThemeBloc>(
      () => ThemeBloc(sharedPrefs: locator<SharedPrefsService>()),
    );
  });

  testWidgets('LoginScreen displays sign-in form elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (_) => GetIt.instance<ThemeBloc>()..add(LoadThemeEvent()),
          ),
          BlocProvider<AuthBloc>(
            create: (_) => FakeAuthBloc(),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, screenType) {
            return const MaterialApp(
              home: LoginScreen(),
            );
          },
        ),
      ),
    );

    await tester.pump();

    // Verify Title
    expect(find.text("Welcome Back"), findsOneWidget);
    expect(find.text("Sign in to continue to your workspace"), findsOneWidget);

    // Verify Form Fields
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
    expect(find.text("SIGN IN"), findsOneWidget);
  });
}
