import 'package:connectivity_plus/connectivity_plus.dart';

class AppConfig {
  static final AppConfig shared = AppConfig._internal();
  ConnectivityResult _connectionStatus = ConnectivityResult.mobile;

  AppConfig._internal();

  void setConnection(ConnectivityResult status) {
    _connectionStatus = status;
  }

  ConnectivityResult getConnectionStatus() {
    return _connectionStatus;
  }
}
