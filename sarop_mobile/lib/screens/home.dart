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
          initialCenter: LatLng(39.93094480417436, 32.8305895893693),
          initialZoom: 13,

        ),
        children: [
          TileLayer(
            subdomains: ["a","b","c","d","e","f","g","h"],

            wmsOptions: WMSTileLayerOptions(
              baseUrl: 'http://192.168.56.1:8080/geoserver/datar/wms?',
              layers: ['datar:datar'],
              format: 'image/png',
              transparent: true,
              crs: Epsg4326(),



            ),

            // Diğer tilelayer seçenekleri
          ),


        ],
      ),

    );

  }

}