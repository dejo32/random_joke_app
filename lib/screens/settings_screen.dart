import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String? _fcmToken;
  bool _isLoading = true;
  bool _isSchedulingTest = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final fcmToken = await NotificationService.getFCMToken();
      
      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _fcmToken = fcmToken;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      if (!kIsWeb) {
        await NotificationService.subscribeToJokeTopic();
      }
      await NotificationService.scheduleDailyJokeNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb 
            ? 'Daily joke reminders enabled! Web notifications will show in console for now.'
            : 'Daily joke reminders enabled! You\'ll get notified at 9:00 AM every day and subscribed to topic notifications.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!kIsWeb) {
        await NotificationService.unsubscribeFromJokeTopic();
      }
      await NotificationService.cancelAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications disabled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.sendTestNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(kIsWeb 
          ? 'Test notification logged to console!' 
          : 'Test notification sent!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _scheduleTestInOneMinute() async {
    setState(() {
      _isSchedulingTest = true;
    });

    try {
      // Schedule notification for 1 minute from now
      final now = DateTime.now();
      final scheduledTime = now.add(Duration(minutes: 1));
      
      // Convert to TZDateTime
      final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);

      await NotificationService.scheduleNotification(
        id: 999,
        title: '🎭 Test Scheduled Notification',
        body: 'This notification was scheduled 1 minute ago!',
        scheduledTime: scheduledTZ,
        payload: 'test_scheduled',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test notification scheduled for ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')} ${kIsWeb ? "(will show in console)" : ""}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSchedulingTest = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue[300],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          SwitchListTile(
                            title: Text('Daily Joke Reminders'),
                            subtitle: Text('Get notified at 9:00 AM every day'),
                            value: _notificationsEnabled,
                            onChanged: _toggleNotifications,
                            activeColor: Colors.blue,
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Test Notification'),
                            subtitle: Text('Send a test notification right now'),
                            trailing: ElevatedButton(
                              onPressed: _testNotification,
                              child: Text('Test Now'),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Test Scheduled Notification'),
                            subtitle: Text('Schedule a test notification in 1 minute'),
                            trailing: _isSchedulingTest
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : ElevatedButton(
                                    onPressed: _scheduleTestInOneMinute,
                                    child: Text('Test in 1 min'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // About Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            title: Text('App Version'),
                            subtitle: Text('1.0.0'),
                            leading: Icon(Icons.info_outline),
                          ),
                          ListTile(
                            title: Text('Notification Status'),
                            subtitle: FutureBuilder<bool>(
                              future: NotificationService.areNotificationsEnabled(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data! ? 'Enabled' : 'Disabled');
                                }
                                return Text('Checking...');
                              },
                            ),
                            leading: Icon(Icons.notifications),
                          ),
                          if (_fcmToken != null)
                            ExpansionTile(
                              title: Text('FCM Token'),
                              subtitle: Text('For push notifications'),
                              leading: Icon(Icons.token),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SelectableText(
                                    _fcmToken!,
                                    style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            title: Text('Reset Notifications'),
                            subtitle: Text('Re-schedule daily reminders'),
                            leading: Icon(Icons.refresh),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await NotificationService.cancelAllNotifications();
                                await NotificationService.scheduleDailyJokeNotification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Notifications reset successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: Text('Reset'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 