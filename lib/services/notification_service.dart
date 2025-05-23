import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../services/api_services.dart';
import 'dart:async';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static Timer? _webNotificationTimer;

  // Initialize notification service
  static Future<void> initialize() async {
    // Initialize timezone (needed for both platforms for scheduling)
    tz.initializeTimeZones();
    
    // Initialize local notifications (not supported on web)
    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }
    
    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();
    
    // Schedule daily notifications (only on mobile platforms)
    if (!kIsWeb) {
      await scheduleDailyJokeNotification();
    } else {
      print('Local notifications not supported on web platform - using Firebase messaging only');
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) return; // Skip on web
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Initialize Firebase messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      
      // Save token to preferences for potential server use
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
      
      // Subscribe to daily jokes topic only on mobile platforms
      // Web platforms don't support topic subscriptions
      if (!kIsWeb) {
        await subscribeToJokeTopic();
      } else {
        print('Topic subscriptions not supported on web platform');
      }
    } else {
      print('User declined or has not accepted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kIsWeb) {
        _showWebNotification(
          title: message.notification?.title ?? 'Joke App',
          body: message.notification?.body ?? 'Check out today\'s joke!',
        );
      } else {
        _showLocalNotification(
          title: message.notification?.title ?? 'Joke App',
          body: message.notification?.body ?? 'Check out today\'s joke!',
        );
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap();
    });

    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap();
    }
  }

  // Schedule daily joke notification at 9:00 AM
  static Future<void> scheduleDailyJokeNotification() async {
    if (kIsWeb) {
      print('Local notification scheduling not supported on web platform');
      return;
    }
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_joke_channel',
      'Daily Joke Reminders',
      channelDescription: 'Daily reminders to check out the joke of the day',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Daily Joke Reminder',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Schedule notification for 9:00 AM daily
    await _notificationsPlugin.zonedSchedule(
      0, // notification id
      '🎭 Joke of the Day!',
      'Ready for your daily dose of laughter? Tap to see today\'s hilarious joke!',
      _nextInstanceOf9AM(),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Daily joke notification scheduled for 9:00 AM');
  }

  // Get next 9:00 AM
  static tz.TZDateTime _nextInstanceOf9AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Show local notification (mobile platforms)
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      _showWebNotification(title: title, body: body);
      return;
    }
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_joke_channel',
      'Instant Joke Notifications',
      channelDescription: 'Instant joke notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'New Joke Available',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Show web notification using browser's native API
  static void _showWebNotification({
    required String title,
    required String body,
  }) {
    if (!kIsWeb) return;
    
    // For now, just show a simple alert on web
    // In a real implementation, you would use js package or platform channels
    print('Web notification would show: $title - $body');
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    _handleNotificationTap();
  }

  static void _handleNotificationTap() {
    // Navigate to random joke screen when notification is tapped
    if (_navigatorKey?.currentState != null) {
      _navigatorKey?.currentState?.pushNamed('/random-joke');
    }
    print('Notification tapped - navigating to random joke');
  }

  // Add navigator key reference
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // Send a test notification
  static Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: '🎭 Test Joke Notification',
      body: 'This is a test! Your daily joke notifications are working perfectly!',
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    if (kIsWeb) {
      // Cancel any pending web timers
      _webNotificationTimer?.cancel();
      _webNotificationTimer = null;
      print('Web notification timers cancelled');
      return;
    }
    
    await _notificationsPlugin.cancelAll();
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) {
      // For web, we'll just return true since we can't easily check without dart:html
      return true;
    }
    
    if (Platform.isAndroid) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return result ?? false;
    } else if (Platform.isIOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to topic (for sending notifications to all users)
  static Future<void> subscribeToJokeTopic() async {
    if (kIsWeb) {
      print('Topic subscriptions are not supported on web platform');
      return;
    }
    
    await _messaging.subscribeToTopic('daily_jokes');
    print('Subscribed to daily_jokes topic');
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromJokeTopic() async {
    if (kIsWeb) {
      print('Topic subscriptions are not supported on web platform');
      return;
    }
    
    await _messaging.unsubscribeFromTopic('daily_jokes');
    print('Unsubscribed from daily_jokes topic');
  }

  // Schedule a notification at a specific time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    String? payload,
  }) async {
    if (kIsWeb) {
      // Use Timer for web scheduling
      final now = tz.TZDateTime.now(tz.local);
      final delay = scheduledTime.difference(now);
      
      if (delay.isNegative) {
        print('Cannot schedule notification in the past');
        return;
      }
      
      print('Scheduling web notification in ${delay.inSeconds} seconds');
      
      _webNotificationTimer?.cancel(); // Cancel any existing timer
      _webNotificationTimer = Timer(delay, () {
        _showWebNotification(title: title, body: body);
        print('Web notification triggered: $title - $body');
      });
      
      return;
    }
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'scheduled_notification_channel',
      'Scheduled Notifications',
      channelDescription: 'Notifications scheduled for specific times',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Scheduled Notification',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    print('Notification scheduled for ${scheduledTime.toString()}');
  }
} 