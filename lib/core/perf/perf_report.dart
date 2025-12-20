import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'perf_service.dart';

class PerfReport {
  static Future<void> generateAndShare(String scenarioName) async {
    final stats = PerfService().getStats();

    final deviceDocs = await _getDeviceInfo();
    final appDocs = await _getAppInfo();

    final report = {
      'scenario': scenarioName,
      'timestamp': DateTime.now().toIso8601String(),
      'device': deviceDocs,
      'app': appDocs,
      'metrics': stats,
    };

    final jsonString = jsonEncode(report);
    final fileName =
        'perf_report_${DateTime.now().millisecondsSinceEpoch}.json';

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString);

      debugPrint('📂 Rapport sauvegardé: ${file.path}');

      // Partager le fichier
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Rapport Performance: $scenarioName');
    } catch (e) {
      debugPrint('❌ Erreur export rapport: $e');
    }
  }

  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return {
        'os': 'Android',
        'p': android.version.sdkInt, // API Level
        'brand': android.brand,
        'model': android.model,
        'hardware': android.hardware,
      };
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return {
        'os': 'iOS',
        'name': ios.name,
        'model': ios.model,
        'systemName': ios.systemName,
        'systemVersion': ios.systemVersion,
      };
    }
    return {'os': Platform.operatingSystem};
  }

  static Future<Map<String, dynamic>> _getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }
}
