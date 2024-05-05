import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';




class WMSLayerPage extends StatelessWidget {
  static const String route = '/wms_layer';

  const WMSLayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(40.4375115,32.5624961),
          initialZoom: 1,

        ),
        children: [
          TileLayer(
            subdomains: ["a","b","c","d","e","f","g","h"],

            wmsOptions: WMSTileLayerOptions(
              baseUrl: 'http://192.168.56.1:8080/geoserver/datar/wms?',
              layers: ['datar:output'],
              format: 'image/jpeg',
              transparent: true,




            ),

            // Diğer tilelayer seçenekleri
          ),




        ],
      ),

    );

  }

}