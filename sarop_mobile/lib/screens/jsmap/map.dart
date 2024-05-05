import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class LocalHtmlFromAssets extends StatefulWidget {
  @override
  _LocalHtmlFromAssetsState createState() => _LocalHtmlFromAssetsState();
}

class _LocalHtmlFromAssetsState extends State<LocalHtmlFromAssets> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    loadHtmlFromAssets();
  }

  loadHtmlFromAssets() async {
    String htmlContent = await rootBundle.loadString('assets/map.html');
    String scriptContent = await rootBundle.loadString('assets/L.Geoserver.js');  // Ensure this file path is correct in your assets
    // Inject the script content into the HTML
    String finalHtmlContent = htmlContent.replaceFirst(
        '</body>',
        '<script>$scriptContent</script></body>');
    _controller.future.then((controller) {
      controller.loadUrl(Uri.dataFromString(finalHtmlContent, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: '',
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}