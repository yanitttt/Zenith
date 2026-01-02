import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({bool isBackground = false}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _loadSettings();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification cliquée : ${details.payload}");
      },
    );

    final androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    // On ne demande la permission que si on est au premier plan (pas en background)
    if (androidImplementation != null && !isBackground) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // Paramètres de notification
  bool _soundEnabled = true;
  String? _soundName;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
    _soundName = prefs.getString('notification_sound_name');
  }

  Future<void> updateSettings({bool? soundEnabled, String? soundName}) async {
    final prefs = await SharedPreferences.getInstance();
    if (soundEnabled != null) {
      _soundEnabled = soundEnabled;
      await prefs.setBool('notification_sound_enabled', soundEnabled);
    }
    if (soundName != null) {
      if (soundName.isEmpty) {
        _soundName = null;
        await prefs.remove('notification_sound_name');
      } else {
        _soundName = soundName;
        await prefs.setString('notification_sound_name', soundName);
      }
    }
  }

  String _getChannelId() {
    if (!_soundEnabled) return 'main_channel_silent';
    if (_soundName != null && _soundName!.isNotEmpty) {
      // Les IDs de channel doivent être uniques par configuration
      return 'main_channel_${_soundName!.replaceAll('.', '_')}';
    }
    return 'main_channel_default';
  }

  String _getChannelName() {
    if (!_soundEnabled) return 'Notifications Silencieuses';
    if (_soundName != null && _soundName!.isNotEmpty) {
      return 'Notifications - $_soundName';
    }
    return 'Notifications Principales';
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final String channelId = _getChannelId();
    final String channelName = _getChannelName();

    AndroidNotificationDetails androidPlatformChannelSpecifics;

    if (!_soundEnabled) {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Notifications sans son',
        importance: Importance.max,
        priority: Priority.high,
        playSound: false,
        showWhen: true,
      );
    } else {
      // Nettoyage du nom du son (retirer l'extension si présente)
      String? soundRes = _soundName;
      if (soundRes != null && soundRes.contains('.')) {
        soundRes = soundRes.split('.').first;
      }

      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription:
            'Canal pour les notifications avec son personnalisé',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound:
            soundRes != null
                ? RawResourceAndroidNotificationSound(soundRes)
                : null,
        showWhen: true,
      );
    }

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
