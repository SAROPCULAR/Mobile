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
      var url = Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.registerEmail);
      Map body = {
        'name': nameController.text,
        'email': emailController.text.trim(),
        'password': passwordController.text
      };

      http.Response response = await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['access_token'] != null) {
          var accessToken = json['access_token'];
          var refreshToken = json['refresh_token'];
          if (accessToken != null && refreshToken != null) {
            final SharedPreferences prefs = await _prefs;
            await prefs.setString('access_token', accessToken);
            await prefs.setString('refresh_token', refreshToken);

            nameController.clear();
            emailController.clear();
            passwordController.clear();

            // Showing success dialog using GetX
            Get.dialog(
              AlertDialog(
                title: Text('Kayıt Başarılı'),
                content: Text('Başarıyla kayıt olundu. Lütfen admin onayını bekleyin.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('Tamam'),
                  ),
                ],
              ),
            );
          } else {
            throw "Access token or refresh token is missing in the response";
          }
        } else {
          throw jsonDecode(response.body)["access_token"] ?? "Unknown Error Occurred";
        }
      } else {
        throw jsonDecode(response.body)["error"] ?? "Unknown Error Occurred";
      }
    } catch (e) {
      // Handle error and show dialog using GetX
      Get.back();
      Get.dialog(
        SimpleDialog(
          title: Text('Error'),
          contentPadding: EdgeInsets.all(20),
          children: [Text(e.toString())],
        ),
      );
    }
  }
}

// Example usage of RegisterationController in a widget
class MyRegisterPage extends StatelessWidget {
  final RegisterationController _controller = Get.put(RegisterationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller.nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _controller.emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _controller.passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _controller.registerWithEmail,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}


