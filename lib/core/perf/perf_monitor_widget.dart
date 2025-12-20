import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Widget wrapper capable de mesurer le temps de rendu (Layout + Paint) et de Build de son enfant.
/// Utile pour profiler des composants UI spécifiques.
class PerfMonitorWidget extends StatefulWidget {
  final String label;
  final Widget child;
  final bool logOnBuild;
  final bool logOnRender;

  const PerfMonitorWidget({
    super.key,
    required this.label,
    required this.child,
    this.logOnBuild = true,
    this.logOnRender = true,
  });

  @override
  State<PerfMonitorWidget> createState() => _PerfMonitorWidgetState();
}

class _PerfMonitorWidgetState extends State<PerfMonitorWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.logOnBuild) {
      final stopwatch = Stopwatch()..start();
      // On diffère le log pour ne pas inclure le log lui-même (négligeable mais propre)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        stopwatch.stop();
        debugPrint(
          '🏗️ [${widget.label}] Build time: ${stopwatch.elapsedMicroseconds} µs (approx)',
        );
      });
    }

    return _RenderTimingWrapper(
      label: widget.label,
      logRender: widget.logOnRender,
      child: widget.child,
    );
  }
}

class _RenderTimingWrapper extends SingleChildRenderObjectWidget {
  final String label;
  final bool logRender;

  const _RenderTimingWrapper({
    required this.label,
    required Widget child,
    this.logRender = true,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTimingBox(label: label, logRender: logRender);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderTimingBox renderObject,
  ) {
    renderObject
      ..label = label
      ..logRender = logRender;
  }
}

class _RenderTimingBox extends RenderProxyBox {
  String label;
  bool logRender;

  _RenderTimingBox({
    required this.label,
    required this.logRender,
    RenderBox? child,
  }) : super(child);

  @override
  void performLayout() {
    if (!logRender) {
      super.performLayout();
      return;
    }

    final stopwatch = Stopwatch()..start();
    super.performLayout();
    stopwatch.stop();
    debugPrint('📐 [${label}] Layout: ${stopwatch.elapsedMicroseconds} µs');
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!logRender) {
      super.paint(context, offset);
      return;
    }

    final stopwatch = Stopwatch()..start();
    super.paint(context, offset);
    stopwatch.stop();
    debugPrint('🎨 [${label}] Paint: ${stopwatch.elapsedMicroseconds} µs');
  }
}
