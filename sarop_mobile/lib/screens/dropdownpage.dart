import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sarop_mobile/controllers/login_controller.dart';
import 'package:sarop_mobile/screens/home.dart';
import 'package:sarop_mobile/utils/api_endpoints.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select Your Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> workspaceNames = [];
  String? selectedWorkspace;
  List<Map<String, dynamic>> maps = [];
  String? selectedMap;
  String? selectedMapDisplayUrl;

  @override
  void initState() {
    super.initState();
    fetchWorkspaces();
  }

  Future<void> fetchWorkspaces() async {
    final accessToken = await LoginController().getAccessToken();
    final response = await http.get(
      Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.workspaceEndPoints.getWorkspace),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        List<Map<String, dynamic>> workspaces = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        workspaceNames = List<String>.from(workspaces.map((workspace) => workspace['name']));
      });
    } else {
      throw Exception('Failed to load workspaces');
    }
  }

  Future<void> fetchMaps(String workspaceId) async {
    final accessToken = await LoginController().getAccessToken();
    final response = await http.get(
      Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.workspaceEndPoints.getWorkspace + "/$workspaceId/layers"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        maps = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        selectedMap = null;
      });
    } else {
      throw Exception('Failed to load maps');
    }
  }

  void setSelectedMap(String mapName) {
    final selected = maps.firstWhere((map) => map['mapName'] == mapName);
    setState(() {
      selectedMap = mapName;
      selectedMapDisplayUrl = selected['displayUrl'];
    });
  }

  void onSubmit() {
    if (selectedMapDisplayUrl != null) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WMSLayerPage(selectedMapDisplayUrl!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Map'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              hint: Text('Select Workspace', style: TextStyle(color: Colors.indigo)),
              value: selectedWorkspace,
              onChanged: (String? newValue) {
                setState(() {
                  selectedWorkspace = newValue!;
                  fetchMaps(newValue!);
                });
              },
              items: workspaceNames.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text('Select Map', style: TextStyle(color: Colors.indigo)),
              value: selectedMap,
              onChanged: (String? newValue) {
                setSelectedMap(newValue!);
              },
              items: maps.map((map) {
                return DropdownMenuItem<String>(
                  value: map['mapName'],
                  child: Text(map['mapName']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text('Submit' ,style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
