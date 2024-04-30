import '/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/screens/initial/initial-map.dart';

main() async {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapPage(),
  ));
}