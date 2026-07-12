import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:get_it/get_it.dart';
import 'package:team_work_project/ui/page/splash_screen.dart';
import 'package:team_work_project/ui/bloc/splash_bloc.dart';
import 'package:team_work_project/ui/bloc/auth_bloc.dart';
import 'package:team_work_project/ui/bloc/auth_event_state.dart';
import 'package:team_work_project/services/local-storage/shared_prefs_services.dart';

class FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  FakeAuthBloc() : super(AuthInitial());

  @override
  bool get isLoggedIn => false;
}

void main() {
  setUp(() async {
    final locator = GetIt.instance;
    await locator.reset();
    
    // Setup Mock Shared Preferences
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    locator.registerSingleton<SharedPrefsService>(
      SharedPrefsService(sharedPrefs),
    );
    
    locator.registerLazySingleton<SplashBloc>(() => SplashBloc());
  });

  testWidgets('SplashScreen displays title, logo, and navigates to login after 3 seconds', (WidgetTester tester) async {
    final routes = {
      '/': (context) => const SplashScreen(),
      '/login_page': (context) => const Scaffold(body: Text('Login Screen Mock')),
    };

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SplashBloc>(
            create: (_) => GetIt.instance<SplashBloc>(),
          ),
          BlocProvider<AuthBloc>(
            create: (_) => FakeAuthBloc(),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, screenType) {
            return MaterialApp(
              initialRoute: '/',
              routes: routes,
            );
          },
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Expect to find "TEAMWORK" brand name and logo icon
    expect(find.text('TEAMWORK'), findsOneWidget);
    expect(find.byIcon(Icons.group_work_rounded), findsOneWidget);

    // Advance duration by 3 seconds to complete the splash bloc timer helper.
    await tester.pump(const Duration(seconds: 3));
    // Settle the navigation transition frame (timed pump instead of pumpAndSettle due to infinite CupertinoActivityIndicator)
    await tester.pump(const Duration(milliseconds: 500));

    // Verify successful auto-redirection to the Login screen
    expect(find.text('Login Screen Mock'), findsOneWidget);
  });
}
