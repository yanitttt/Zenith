import 'package:flutter/material.dart';
import 'perf_config.dart';
import '../../ui/performance/performance_lab_screen.dart';
import 'perf_session_manager.dart';

/// Widget wrapper qui ajoute un point d'entrée vers le Performance Lab
/// si le mode Performance est actif.
class PerfEntryWrapper extends StatelessWidget {
  final Widget child;

  const PerfEntryWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!PerfConfig.isPerfMode) {
      return child;
    }

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        Positioned(
          bottom: 100,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: PerfSessionManager(),
              builder: (context, _) {
                final isRecording = PerfSessionManager().isRecording;
                return FloatingActionButton(
                  mini: true,
                  backgroundColor:
                      isRecording ? Colors.red : Colors.purpleAccent,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PerformanceLabScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    isRecording ? Icons.fiber_manual_record : Icons.speed,
                    size: 20,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
