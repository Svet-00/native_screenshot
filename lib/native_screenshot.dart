import 'dart:async';
import 'dart:developer';
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
  static Future<Uint8List?> takeScreenshot({
    ScreenshotConfig config = ScreenshotConfig.png,
  }) async {
    if (config.format == ScreenshotFormat.png && config.quality != 100) {
      log('[NativeScreenshot] WARNING compressionQuality has no effect when screenshotFormat is png.');
    }

    final Uint8List? image = await _channel.invokeMethod(
      'takeScreenshot',
      <String, dynamic>{
        'quality': config.quality,
        'format': config.format.toStringX(),
      },
    );

    return image;
  } // takeScreenshot()
} // NativeScreenshot

class ScreenshotConfig {
  const ScreenshotConfig({
    this.quality = 100,
    this.format = ScreenshotFormat.jpeg,
  })  : assert(quality >= 0, 'Compression quality can\'t be negative.'),
        assert(quality <= 100, 'Compression quality can\'t be greater than 100.');

  /// Compression quality in percents. Valid range is 0 - 100.
  ///
  /// This Only have impact when [format] is [ScreenshotFormat.jpeg]
  final int quality;

  /// Format used for encoding image data.
  final ScreenshotFormat format;

  static const png = ScreenshotConfig(quality: 100, format: ScreenshotFormat.png);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScreenshotConfig && other.quality == quality && other.format == format;
  }

  @override
  int get hashCode => quality.hashCode ^ format.hashCode;
}

enum ScreenshotFormat { png, jpeg }

extension ScreenshotFormatX on ScreenshotFormat {
  String toStringX() {
    switch (this) {
      case ScreenshotFormat.png:
        return 'png';
      case ScreenshotFormat.jpeg:
        return 'jpeg';
    }
  }
}
