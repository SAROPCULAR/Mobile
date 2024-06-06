import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sarop_mobile/controllers/login_controller.dart';
import 'package:sarop_mobile/utils/api_endpoints.dart';
class WMSLayerPage extends StatefulWidget {
  static const String route = '/wms_layer';
  final String selectedMapDisplayUrl;
  final String selectedMapDisplayID;
  WMSLayerPage(this.selectedMapDisplayUrl, this.selectedMapDisplayID);

  @override
  _WMSLayerPageState createState() => _WMSLayerPageState();
}

class _WMSLayerPageState extends State<WMSLayerPage> {
  bool _showOpenStreetMap = false;
  MapController _mapController = MapController();

  List<List<LatLng>> polygons = [];
  List<Marker> markers = [];

  Future<void> _fetchCoordinates() async {
    final accessToken = await LoginController().getAccessToken();
    final response = await http.get(Uri.parse(ApiEndPoints.baseUrl+"polygon/"+widget.selectedMapDisplayID),   headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },);
    if (response.statusCode == 200) {

      final List<dynamic> data = json.decode(response.body);
      setState(() {
        polygons.clear();
        for (var item in data) {
          List<LatLng> polygonCoords = [];
          for (var coord in item['coordinates']) {
            polygonCoords.add(LatLng(coord['x'], coord['y']));
          }
          polygons.add(polygonCoords);
        }
      });
    } else {
      print('HTTP Error: ${response.statusCode}');
    }
  }


    Future<void> _fetchNotest() async {
    final accessToken = await LoginController().getAccessToken();
    final response = await http.get(Uri.parse(ApiEndPoints.baseUrl+"note/"+widget.selectedMapDisplayID),   headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        markers.clear();
        for (var item in data) {
          final comment = item['comment'];
          final x = item['coordinate']['y'];
          final y = item['coordinate']['x'];

          markers.add(
            Marker(
              width: 120.0,
              height: 120.0,
              point: LatLng(y, x),

                child: Column(
                  children: [
                    Icon(
                      Icons.comment,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text(comment, style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

          );
        }
      });
    } else {
      // Handle error
      print("Failed to load notes");
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
    _fetchNotest();
  }
  @override
  Widget build(BuildContext context) {
    List<Polygon> polygonLayers = [];


    polygons.forEach((polygonCoords) {
      polygonLayers.add(Polygon(
        points: polygonCoords,
        color: Colors.blue,
        isFilled: true,
      ));
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('WMS Layer', style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.indigo,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(39.93094480417436, 32.8305895893693),
          initialZoom: 10,
        ),
        children: [
          if (_showOpenStreetMap)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            )

          else

            TileLayer(
              urlTemplate: widget.selectedMapDisplayUrl.replaceFirst(
                'localhost',
                '192.168.56.1',
              ),



              subdomains: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
            ),
            PolygonLayer(
              polygons: polygonLayers,
            ),
            MarkerLayer(markers:markers,) ],

      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _mapController.move(_mapController.center, _mapController.zoom + 1);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _mapController.move(_mapController.center, _mapController.zoom - 1);
            },
            child: Icon(Icons.remove),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showOpenStreetMap = !_showOpenStreetMap;
              });
            },
            child: Icon(_showOpenStreetMap ? Icons.layers : Icons.map),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
