import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

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
        title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // ignore: deprecated_member_use
                launch('mailto:tweetgits@gmail.com');
              },
              child: const Row(
                children: [
                  Icon(Icons.email, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'tweetgits@gmail.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Phone:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // ignore: deprecated_member_use
                launch('tel:+919496034529');
              },
              child: const Row(
                children: [
                  Icon(Icons.phone, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    '+91946034529',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}