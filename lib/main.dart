import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apptweetgits/pages/create_account.dart';
import 'pages/login_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyANM5NoQlLcIz97dh2_5_WbyolCHu11ILw",
        appId: "1:168400379388:android:f892762fdd7a0e92052679",
        messagingSenderId: "168400379388",
        projectId: "tweetgits-11233",
        storageBucket: 'gs://tweetgits-11233.appspot.com', 
      ),
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/create_account': (context) => const CreateAccountPage(),
        '/login': (context) => const LoginPage(), // Add this line
      },
    );
  }
}