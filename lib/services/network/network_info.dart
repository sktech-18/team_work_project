import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';



abstract class NetworkInfo {
  StreamController? streamController;
  Future<bool> isConnected();
  void connectionStreamer();
  void dispose();
}

class NetworkInfoImplWithConnectivityPlus implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImplWithConnectivityPlus(this.connectivity);
  @override
  // TODO: implement isConnected
  Future<bool> isConnected() async {
    List<ConnectivityResult> connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.wifi ||
        connectivityResult[0] == ConnectivityResult.mobile) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void connectionStreamer() {
    streamController = StreamController();
    Connectivity().onConnectivityChanged.listen((event) {
      streamController!.add(
        event,
      );
    });
  }

  @override
  StreamController? streamController;

  @override
  void dispose() {
    streamController!.close();
  }
}
