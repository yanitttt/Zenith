import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // 1. Création de l'instance du plugin (Singleton pour n'en avoir qu'un seul)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 2. Initialisation du service (à lancer au démarrage de l'app)
  Future<void> init() async {
    // 1. Config Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // 2. Init du plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification cliquée : ${details.payload}");
      },
    );

    // 3. DEMANDE DE PERMISSION (Spécial Android 13+)
    final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // 3. LA fonction simple pour afficher une notif
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Détails techniques pour Android (obligatoire depuis Android 8.0)
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'main_channel', // ID du canal (invisible pour l'user)
      'Notifications Principales', // Nom du canal (visible dans les paramètres)
      channelDescription: 'Canal pour les notifications classiques',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // On affiche la notif
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}