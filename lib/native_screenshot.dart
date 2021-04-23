import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Class to capture screenshots with native code working on background
class NativeScreenshot {
  /// Comunication property to talk to the native background code.
  static const MethodChannel _channel = const MethodChannel('native_screenshot');

  /// Captures everything as is shown in user's device.
  ///
  /// Returns [null] if an error occurs.
  /// Returns a [Uint8List] with the image data.
  static Future<Uint8List?> takeScreenshot() async {
    final Uint8List? image = await _channel.invokeMethod('takeScreenshot');

    return image;
  } // takeScreenshot()
} // NativeScreenshot
