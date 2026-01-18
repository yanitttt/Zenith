import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Constantes
  static const String motivationChannelId = 'zenith_motivation_channel';
  static const String motivationChannelName = 'Motivation & Rappels';
  static const String motivationDescription =
      'Canal pour les rappels de motivation';
  static const String motivationSoundName =
      'alert_motivation'; // Sans extension pour Android

  // Canal Badges
  static const String badgeChannelId = 'zenith_badge_channel';
  static const String badgeChannelName = 'Badges & Succès';
  static const String badgeDescription = 'Notifications de déblocage de badges';

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
    // On ne demande la permission que si on est au premier plan (pas en background)
    if (androidImplementation != null) {
      // Configuration du canal de motivation
      AndroidNotificationChannel motivationChannel = AndroidNotificationChannel(
        motivationChannelId,
        motivationChannelName,
        description: motivationDescription,
        importance: Importance.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(motivationSoundName),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([
          0,
          200,
          100,
          200,
        ]), // Heartbeat pattern
      );

      // Configuration du canal badges (Heads-up garanti)
      AndroidNotificationChannel badgeChannel =
          const AndroidNotificationChannel(
            badgeChannelId,
            badgeChannelName,
            description: badgeDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

      // Création des canaux
      await androidImplementation.createNotificationChannel(motivationChannel);
      await androidImplementation.createNotificationChannel(badgeChannel);

      if (!isBackground) {
        await androidImplementation.requestNotificationsPermission();
      }
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
    String? channelId, // Paramètre optionnel pour choisir le canal
  }) async {
    // Si un channelId spécifique est fourni, on l'utilise
    // Sinon, on utilise la logique par défaut
    String effectiveChannelId = channelId ?? _getChannelId();
    String effectiveChannelName =
        channelId == motivationChannelId
            ? motivationChannelName
            : _getChannelName();

    AndroidNotificationDetails androidPlatformChannelSpecifics;

    if (channelId == motivationChannelId) {
      // Configuration spécifique pour le canal motivation (redondance pour garantir l'envoi correct)
      // Note: La plupart des params sont définis par le channel lui-même sur Android 8+
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        motivationChannelId,
        motivationChannelName,
        channelDescription: motivationDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(motivationSoundName),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 200, 100, 200]),
      );
    } else if (channelId == badgeChannelId) {
      androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        badgeChannelId,
        badgeChannelName,
        channelDescription: badgeDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
    } else if (!_soundEnabled) {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        effectiveChannelId,
        effectiveChannelName,
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
        effectiveChannelId,
        effectiveChannelName,
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
