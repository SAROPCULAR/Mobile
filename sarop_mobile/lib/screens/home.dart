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
  List<List<Map<String, double>>> polygons = [];
  List<Marker> markers = [];

  Future<void> _fetchCoordinates() async {
    final accessToken = await LoginController().getAccessToken();
    final response = await http.get(Uri.parse(ApiEndPoints.baseUrl+"polygon/"+widget.selectedMapDisplayID),   headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },);
    if (response.statusCode == 200) {

      final List<dynamic> data = json.decode(response.body);

      data.forEach((polygonData) {
        List<Map<String, double>> coordinates = [];
        if (polygonData is Map && polygonData.containsKey('coordinates')) {

          polygonData['coordinates'].forEach((coord) {
            if (coord is Map && coord.containsKey('x') && coord.containsKey('y')) {
              coordinates.add({'x': coord['x'], 'y': coord['y']});
            }
          });
          polygons.add(coordinates);
        }

        if (polygonData is Map && polygonData.containsKey('map') && polygonData['map'] is Map && polygonData['map'].containsKey('polygons')) {
          polygonData['map']['polygons'].forEach((polygon) {
            if (polygon is Map && polygon.containsKey('coordinates')) {

              List<Map<String, double>> mapCoordinates = [];
              polygon['coordinates'].forEach((coord) {
                if (coord is Map && coord.containsKey('x') && coord.containsKey('y')) {
                  mapCoordinates.add({'x': coord['x'], 'y': coord['y']});
                }
              });
              polygons.add(mapCoordinates);
            }
          });
        }
      });
      setState(() {

      });
    } else {

      print('HTTP Error: ${response.statusCode}');
    }
  }  Future<void> _fetchNotest() async {
    final accessToken = await LoginController().getAccessToken();
    final response = await http.get(Uri.parse(ApiEndPoints.baseUrl+"note/"+widget.selectedMapDisplayID),   headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final mockdata = data[0];
      final notes = mockdata['user']['notes'];

      List<Marker> tempMarkers = [];

      for (var note in notes) {
        if (note is Map<String, dynamic>) {
          String comment = note['comment'];
          double x = note['coordinate']['x'];
          double y = note['coordinate']['y'];

          tempMarkers.add(
            Marker(
              width: 10.0,
              height: 10.0,
              point: LatLng(y, x),

                child: Text(comment),

            ),
          );

          // Map içindeki notes'u da işlemek için:
          if (note.containsKey('map') && note['map'].containsKey('notes')) {
            var mapNotes = note['map']['notes'];
            for (var mapNote in mapNotes) {
              if (mapNote is Map<String, dynamic>) {
                String mapComment = mapNote['comment'];
                double mapX = mapNote['coordinate']['x'];
                double mapY = mapNote['coordinate']['y'];

                tempMarkers.add(
                  Marker(
                    width: 400.0,
                    height: 400.0,

                    point: LatLng(mapY, mapX),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.comment,),
                        SizedBox(width:20),
                        Text(mapComment, style:TextStyle(color: Colors.indigo,fontWeight: FontWeight.bold) ,),
                      ],
                    ),

                  ),
                );
              }
            }
          }
        }
      }

      setState(() {
        markers = tempMarkers;
      });
    } else {
      throw Exception('Failed to load data');
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
      List<LatLng> points = [];
      polygonCoords.forEach((coord) {
        points.add(LatLng(coord['y']!, coord['x']!));
      });
      polygonLayers.add(Polygon(
        points: points,
        color: Colors.blue,
        isFilled: true,
      ));
    });
    return Scaffold(
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
