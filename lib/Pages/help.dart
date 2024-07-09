import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
        title: const Text('Help', style: TextStyle(color: Colors.white)),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              FAQQuestion(
                question: 'How do I create a new post?',
                answer: 'To create a new post, click on the "+" button at the bottom of the screen and select "Create Post". You can then add text, images, and videos to your post.',
              ),
              FAQQuestion(
                question: 'How do I edit my profile?',
                answer: 'To edit your profile, click on your profile picture at the top of the screen and select "Edit Profile". You can then update your profile picture, name, bio, and other details.',
              ),
              FAQQuestion(
                question: 'How do I delete a post?',
                answer: 'To delete a post, go to the post and click on the three dots at the top right corner. Select "Delete Post" and confirm the action to delete the post.',
              ),
              FAQQuestion(
                question: 'How do I report a user?',
                answer: 'To report a user, go to their profile and click on the three dots at the top right corner. Select "Report User" and follow the prompts to report the user.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQQuestion extends StatelessWidget {
  final String question;
  final String answer;

  const FAQQuestion({
    super.key, 
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            answer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}