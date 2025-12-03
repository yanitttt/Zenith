import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late final double _screenWidth;
  late final double _screenHeight;

  // Design baseline (iPhone X/11 Pro dimensions)
  static const double _baselineWidth = 375.0;
  static const double _baselineHeight = 812.0;

  Responsive(this.context) {
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  /// Relative Width: Scales based on screen width
  double rw(double val) {
    return val * (_screenWidth / _baselineWidth);
  }

  /// Relative Height: Scales based on screen height
  double rh(double val) {
    return val * (_screenHeight / _baselineHeight);
  }

  /// Relative Scalable Pixel: Scales font size based on width (usually better for text)
  double rsp(double val) {
    return val * (_screenWidth / _baselineWidth);
  }
}
