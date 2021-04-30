import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_screenshot/native_screenshot.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('NativeScreenshot Example'),
        ),
        bottomNavigationBar: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Press to capture screenshot'),
              onPressed: () async {
                final quality = 60;
                final stopwatch = Stopwatch()..start();
                Uint8List? image = await NativeScreenshot.takeScreenshot(quality: quality);
                print('Screenshot with quality $quality% taken in ${stopwatch.elapsed.inMilliseconds} ms');
                setState(() => _imageData = image);

                if (image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error taking the screenshot :('),
                      backgroundColor: Colors.red,
                    ),
                  ); // showSnackBar()

                  return;
                } // if error

                setState(() {});
              },
            )
          ],
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          child: _imageData != null ? Center(child: Image.memory(_imageData!)) : Center(child: Icon(Icons.image)),
        ),
      ),
    );
  } // build()
} // _MyAppState
