import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 1, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'Allow Notifications',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
            Transform.scale(
              scale: 1.5,
              child: Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                thumbColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
