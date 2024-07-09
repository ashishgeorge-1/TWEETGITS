import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '▷ Collection of Information: We collect personal data to provide and enhance the services we offer. '
          'This includes using data to improve service delivery, process transactions, and communicate with you effectively.'
          '\n\n▷ Use of Information: Your personal data is used to help us personalize and continually improve your experience. '
          'We also use your information to provide targeted advertisements and promotions that may be of interest to you.'
          '\n\n▷ Sharing of Information: We may share your personal data with third parties in order to provide the services requested by you, '
          'comply with legal obligations, or protect the rights and safety of our users and the public.'
          '\n\n▷ Your Rights: You have the right to access, correct, or delete your personal data. We also respect your right to object to certain processing activities. '
          'Please contact us to exercise these rights.'
          '\n\n▷ Consent: By using our services, you consent to the collection, use, and sharing of your personal data as outlined in this privacy policy. '
          'We encourage you to review this policy periodically to stay informed of any updates.',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
    );
  }
}
