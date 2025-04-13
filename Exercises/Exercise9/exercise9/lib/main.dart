import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initLocalNotification();
  runApp(const MyApp());
}

Future<void> _initLocalNotification() async {
  const iosSettings = DarwinInitializationSettings();

  const initSettings = InitializationSettings(iOS: iosSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseRemoteConfig _remoteConfig;
  Timer? _notificationTimer;
  int _intervalSeconds = 0;

  @override
  void initState() {
    super.initState();
    _setupRemoteConfig();
  }

  Future<void> _setupRemoteConfig() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 10),
      ),
    );

    await _remoteConfig.setDefaults(<String, dynamic>{
      'periodic_local_notification': 15, // fallback
    });

    await _fetchRemoteConfig();
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
      int interval = _remoteConfig.getInt('periodic_local_notification');
      setState(() {
        _intervalSeconds = interval;
      });
      _startPeriodicNotification(Duration(seconds: interval));
    } catch (e) {
      debugPrint("Remote config fetch failed: $e");
    }
  }

  void _startPeriodicNotification(Duration interval) {
    _showNotification(); // 启动时立即通知一次
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(interval, (timer) {
      _showNotification();
    });
  }

  Future<void> _showNotification() async {
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      iOS: iosDetails,
      android: AndroidNotificationDetails(
        'periodic_channel_id',
        'Periodic Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Warning',
      'This is a periodic（Every $_intervalSeconds seconds）',
      details,
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Config + Local Notification',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Remote Config Example'),
        ),
        body: Center(
          child: Text(
            'interval：$_intervalSeconds seconds',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
