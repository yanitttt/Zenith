class UIMetric {
  final String label;
  final int buildTimeMicros;
  final int layoutTimeMicros;
  final int paintTimeMicros;
  final String timestamp;

  UIMetric({
    required this.label,
    required this.buildTimeMicros,
    this.layoutTimeMicros = 0,
    this.paintTimeMicros = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'build_us': buildTimeMicros,
      'layout_us': layoutTimeMicros,
      'paint_us': paintTimeMicros,
      't': timestamp,
    };
  }
}
