import 'dart:convert';

import '/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> loginWithEmail() async {
    var headers = {'Content-Type': 'application/json'};
    try {
      var url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.loginEmail);
      Map body = {
        "email": emailController.text.trim(),
        "password": passwordController.text
      };
      String jbody = jsonEncode(body);
      http.Response response =
      await http.post(url, body: jbody, headers: headers);
      print("bij son");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        var accessToken = json['access_token'];
        var refreshToken = json['refresh_token'];
        if (accessToken != null && refreshToken != null) {
          final SharedPreferences? prefs = await _prefs;
          await prefs?.setString('access_token', accessToken);
          await prefs?.setString('refresh_token', refreshToken);

          emailController.clear();
          passwordController.clear();
          Get.off(WMSLayerPage());
        } else {
          throw "Access token or refresh token is missing in the response";
        }
      } else {
        throw jsonDecode(response.body)["message"] ?? "Unknown Error Occurred";
      }
    }

    catch (error) {
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: Text('Error'),
              contentPadding: EdgeInsets.all(20),
              children: [Text(error.toString())],
            );
          });
    }
  }
}