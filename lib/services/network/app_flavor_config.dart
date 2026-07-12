import 'package:flutter/material.dart';

// 1
enum Environment { dev, prod }

// 2
class AppFlavorConfig {
  String appName = "";
  String baseUrl = "";
  String wssUrl = "";
  String qrCodeUrl = "";
  String pbBaseUrl = "";
  MaterialColor primaryColor = Colors.blue;
  Environment flavor = Environment.dev;

  static AppFlavorConfig shared = AppFlavorConfig.create();

  factory AppFlavorConfig.create({
    String appName = "",
    String baseUrl = "",
    String wssUrl = "",
    String qrCodeUrl = "",
    String pbBaseUrl = "",
    MaterialColor primaryColor = Colors.blue,
    Environment flavor = Environment.dev,
  }) {
    return shared = AppFlavorConfig(appName,baseUrl, wssUrl, qrCodeUrl,pbBaseUrl,primaryColor, flavor);
  }

  AppFlavorConfig(this.appName,this.baseUrl,this.wssUrl,this.qrCodeUrl,this.pbBaseUrl,this.primaryColor, this.flavor);
}
