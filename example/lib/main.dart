import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_screenshot/native_screenshot.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _images = <ScreenshotConfig, Uint8List?>{
    ScreenshotConfig.png: null,
    const ScreenshotConfig(quality: 100): null,
    const ScreenshotConfig(quality: 50): null,
    const ScreenshotConfig(quality: 0): null,
  };
  bool _screenshotsInProgress = false;
  bool get imagesNotReady => _images.values.every((e) => e == null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: _images.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text('NativeScreenshot Example'),
            bottom: imagesNotReady
                ? null
                : TabBar(
                    tabs: _images.keys
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                '${e.format.toStringX()} ${e.quality}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ))
                        .toList()),
          ),
          bottomNavigationBar: Builder(
            builder: (context) => _screenshotsInProgress
                ? Container()
                : SizedBox(
                    height: 72,
                    child: ElevatedButton(
                      child: Text('Press to capture screenshot'),
                      onPressed: () async {
                        setState(() => _screenshotsInProgress = true);

                        // skip frame to screenshot an image
                        await Future.delayed(Duration.zero);
                        final futures = _images.keys.map((config) async {
                          _images[config] = await _takeScreenshotMeasured(config);
                          _maybeShowErrorSnackbar(context, _images[config], config);
                        });

                        await Future.wait(futures);

                        setState(() => _screenshotsInProgress = false);
                      },
                    ),
                  ),
          ),
          body: imagesNotReady || _screenshotsInProgress
              ? Image.asset('assets/landscape.jpeg')
              : TabBarView(
                  children: _images.values.map((image) {
                    if (image == null) return Icon(Icons.image, size: 200);
                    return Center(child: Image.memory(image));
                  }).toList(),
                ),
        ),
      ),
    );
  }

  Future<Uint8List?> _takeScreenshotMeasured(ScreenshotConfig config) async {
    final stopwatch = Stopwatch()..start();
    Uint8List? image = await NativeScreenshot.takeScreenshot(config: config);
    print(
      '[${config.format}] [quality ${config.quality}%] '
      ' Screenshot taken in ${stopwatch.elapsedMilliseconds} ms',
    );
    return image;
  }

  Future? _snackBarFuture;
  void _maybeShowErrorSnackbar(BuildContext context, Object? image, ScreenshotConfig config) async {
    // wait previous snack bars to close
    while (_snackBarFuture != null) {
      await _snackBarFuture;
    }

    if (image == null) {
      _snackBarFuture = ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text('[${config.format}] [quality ${config.quality}%] Failed.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 1, milliseconds: 500),
            ),
          )
          .closed;
      _snackBarFuture!.then((value) => _snackBarFuture = null);
    }
  }
}
