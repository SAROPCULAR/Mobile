import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';




class WMSLayerPage extends StatelessWidget {
  static const String route = '/wms_layer';
  final String selectedMapDisplayUrl;
  WMSLayerPage(this.selectedMapDisplayUrl);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(39.93094480417436, 32.8305895893693),
          initialZoom: 10,

        ),
        children: [
          TileLayer(
            subdomains: ["a", "b", "c", "d", "e", "f", "g", "h"],
            urlTemplate: selectedMapDisplayUrl.replaceFirst(
                'localhost', '192.168.56.1'),


            /**    wmsOptions: WMSTileLayerOptions(
                baseUrl: 'http://192.168.56.1:8080/geoserver/ecwflutterdeneme/wms?',
                layers: ['ecwflutterdeneme:g_h29a1'],
                format: 'image/jpeg',
                transparent: true,
                crs: Epsg4326(),


                ),
             */

            // Diğer tilelayer seçenekleri
          ),


        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );


  }

}