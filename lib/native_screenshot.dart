import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Class to capture screenshots with native code working on background
class NativeScreenshot {
  /// Comunication property to talk to the native background code.
  static const MethodChannel _channel = const MethodChannel('native_screenshot');

  /// Captures everything as is shown in user's device.
  ///
  /// Quality is an int in percent from 1 to 100.
  /// Quality 1 means screenshot will be scaled to 1% of the native resolution.
  ///
  /// Returns [null] if an error occurs.
  /// Returns a [Uint8List] with the image data.
  static Future<Uint8List?> takeScreenshot({int quality = 100}) async {
    assert(quality >= 0, 'Can not take screenshot with negative quality');
    assert(quality <= 100, 'Can not take screenshot with quality greater than 100');
    final Uint8List? image = await _channel.invokeMethod(
      'takeScreenshot',
      <String, dynamic>{
        'quality': quality,
      },
    );

    return image;
  } // takeScreenshot()
} // NativeScreenshot
