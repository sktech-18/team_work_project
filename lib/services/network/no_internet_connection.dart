import 'package:flutter/material.dart';

import '../constants/assets_handler.dart';



class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key, required this.restartApp});
  final bool restartApp;

  @override
  State<StatefulWidget> createState() {
    return NoInternetConnectionState();
  }
}

class NoInternetConnectionState extends State<NoInternetConnection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white70,

      body: Center(
        child: Container(
          margin: EdgeInsets.only(
              top: screenWidth * 0.10
          ),
          width: screenWidth * 0.9,
          height: screenWidth * 1.15,
          child:   Image.asset(
            AssetsHandler.noInternet,
            // Replace with your image path
            fit: BoxFit.fill,
          ),
        ),

      )
    );
  }
}
