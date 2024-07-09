import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white), // Customized back button
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'About TWEETGITS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'TWEETGITS is your all-in-one campus companion at Saintgits College. Designed to bridge communication gaps and streamline campus operations, it provides updates on facilities, events, and services—transforming your educational journey into a connected and efficient experience. Stay informed, stay engaged, and make the most of your campus life with TWEETGITS.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Meet the Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Our team is composed of dedicated and passionate individuals who are committed to providing the best experience for our users. We are always working to improve our platform and welcome any feedback or suggestions.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TeamMember(
                    name: 'Ashish George',
                    imagePath: 'lib/assets/ashish.jpg',
                  ),
                  TeamMember(
                    name: 'Adwaith Kishore',
                    imagePath: 'lib/assets/adwaith.jpg',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TeamMember(
                    name: 'A Nishok Perumal',
                    imagePath: 'lib/assets/nishok.jpg',
                  ),
                  TeamMember(
                    name: 'Arun K Philip',
                    imagePath: 'lib/assets/arun.jpg',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMember extends StatelessWidget {
  final String name;
  final String imagePath;

  const TeamMember({
    required this.name,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 75, // Increase the radius to increase the size of the CircleAvatar
          backgroundImage: AssetImage(imagePath), // Replace with your image path
        ),
        const SizedBox(height: 20), // Add space between the CircleAvatar and the Text
        Text(name, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}