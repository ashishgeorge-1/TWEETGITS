import 'package:flutter/material.dart';
import 'privacy.dart'; // Make sure to import the privacy.dart file
import 'help.dart'; // Make sure to import the help.dart file
import 'contactus.dart'; // Make sure to import the contactus.dart file
import 'aboutus.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.white),
            title: const Text('Help', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_page, color: Colors.white),
            title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsPage()),
              );
            },
          ),
           ListTile(
  leading: const Icon(Icons.info, color: Colors.white),
  title: const Text('About Us', style: TextStyle(color: Colors.white)),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutUsPage()),
    );
  },
)
        ],
      ),
    );
  }
}