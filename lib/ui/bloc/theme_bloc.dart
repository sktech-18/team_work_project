import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/local-storage/shared_prefs_services.dart';

// --- EVENTS ---

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

// --- STATES ---

class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  List<Object?> get props => [isDarkMode];
}

// --- BLOC ---

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPrefsService sharedPrefs;

  ThemeBloc({required this.sharedPrefs}) : super(const ThemeState(isDarkMode: true)) {
    on<LoadThemeEvent>((event, emit) {
      final isDark = sharedPrefs.getIsDarkMode();
      emit(ThemeState(isDarkMode: isDark));
    });

    on<ToggleThemeEvent>((event, emit) async {
      final newDarkVal = !state.isDarkMode;
      await sharedPrefs.setDarkMode(newDarkVal);
      emit(ThemeState(isDarkMode: newDarkVal));
    });
  }
}
