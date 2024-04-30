import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';


class WMSLayerPage extends StatelessWidget {
  static const String route = '/wms_layer';

  const WMSLayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(39,32.83),
          zoom: 1,

        ),
        children: [
          TileLayer(
subdomains: ["a","b","c","d","e","f","g","h"],

            wmsOptions: WMSTileLayerOptions(
              baseUrl: 'http://192.168.56.1:8080/geoserver/tiger/wms?',
              layers: ['tiger:tiger_roads'],
              format: 'image/png',
              transparent: true,


            ),
            // Diğer tilelayer seçenekleri
          ),


        ],
      ),

    );
  }
}