import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'create_account.dart';
import 'home_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showSignInButton = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSignInButton = true;
        });
      }
    });

    // Check if a user is already signed in
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // Navigate to the HomePage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    try {
      // Sign out before signing in
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if the email domain is saintgits.org
        String domain = user.email!.split('@').last;
        if (domain == 'saintgits.org') {
          // Perform your logic here after successful sign in
          if (kDebugMode) {
            print('Signed in as ${user.displayName}');
          }

          // Check if the user is new or not
          if (userCredential.additionalUserInfo!.isNewUser) {
            // Navigate to the create_account.dart page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAccountPage(email: user.email!),
              ),
            );
          } else {
            // Navigate to the HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          }
        } else {
          // Sign out the user and show an error message
          await _auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only saintgits.org users are allowed to sign in.'),
            ),
          );
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error signing in: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            width: 375,
            height: 812,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: _animation,
                    child: const Text(
                      'TWEETGITS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 0.03,
                      ),
                    ),
                  ),
                ),
                if (_showSignInButton)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Column(
                            children: [
                              SizedBox(height: 2),
                              Text(
                                'Welcome! Sign in using your',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF797C7B),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                  letterSpacing: 0.10,
                                ),
                              ),
                              SizedBox(
                                  height:
                                      14), // Adjust this value to create the desired amount of space
                              Text(
                                'saintgits email to continue us',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF797C7B),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  20), // Add some space between the text and the button
                          GestureDetector(
                            onTap: () async {
                              await _handleSignIn();
                            },
                            child: Container(
                              width: 335,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'lib/assets/google.png',
                                      height: 22,
                                      width: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'SIGN IN WITH GOOGLE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}