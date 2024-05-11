import 'dart:convert';

import '../screens/home.dart';
import '/utils/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegisterationController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> registerWithEmail() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.registerEmail);
      Map body = {
        'name': nameController.text,
        'email': emailController.text.trim(),
        'password': passwordController.text
      };

      http.Response response =
      await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['code'] == 0) {
          var accessToken = json['access_token'];
          var refreshToken = json['refresh_token'];
          if (accessToken != null && refreshToken != null) {
            final SharedPreferences? prefs = await _prefs;
            await prefs?.setString('access_token', accessToken);
            await prefs?.setString('refresh_token', refreshToken);
          nameController.clear();
          emailController.clear();
          passwordController.clear();

        } else {
            throw "Access token or refresh token is missing in the response";
        }
      } else {
          throw jsonDecode(response.body)["message"] ?? "Unknown Error Occurred";
      }
    } }catch (e) {
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: Text('Error'),
              contentPadding: EdgeInsets.all(20),
              children: [Text(e.toString())],
            );
          });
    }
  }
}