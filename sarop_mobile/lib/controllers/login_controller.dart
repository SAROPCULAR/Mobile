import 'dart:convert';
import 'dart:io'; // SocketException için eklenmesi gereken import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sarop_mobile/screens/dropdownpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/api_endpoints.dart';
import '../screens/home.dart';

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
      http.Response response = await http.post(url, body: jbody, headers: headers);
      print("bij son");

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final json = jsonDecode(response.body);
            var accessToken = json['access_token'];
            print(accessToken);
            var refreshToken = json['refresh_token'];
            if (accessToken != null && refreshToken != null) {
              final SharedPreferences? prefs = await _prefs;
              await prefs?.setString('access_token', accessToken);
              await prefs?.setString('refresh_token', refreshToken);

              emailController.clear();
              passwordController.clear();
              Get.off(MyApp());
            } else {
              throw "Access token or refresh token is missing in the response";
            }
          } catch (e) {
            showErrorDialog("Failed to parse server response. Please try again.");
          }
        } else {
          showErrorDialog("Server response is empty. Please try again.");
        }
      } else {
        var errorMessage = jsonDecode(response.body)["message"] ?? "Unknown Error Occurred";
        showErrorDialog(errorMessage);
      }
    } catch (error) {
      if (error is SocketException) {
        showErrorDialog("No internet connection. Please try again.");
      } else if (error is FormatException) {
        showErrorDialog("Unexpected format or wrong email-password. Please try again.");
      } else {
        showErrorDialog(error.toString());
      }
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> getAccessToken() async {
    final SharedPreferences? prefs = await _prefs;
    return prefs?.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    final SharedPreferences? prefs = await _prefs;
    return prefs?.getString('refresh_token');
  }
}
