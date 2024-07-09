import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; 
import 'myprofile.dart'; 
import 'food_corner.dart'; 
import 'service_corner.dart'; 
import 'gits_zone.dart'; 
import 'package:apptweetgits/Pages/git_post.dart';
import 'package:intl/intl.dart';  


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _profileImageUrl = 'https://example.com/default_profile_image.jpg';
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = getPostsStream();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    ).then((result) => result ?? false);
  }

  Future<void> addGit(String content) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String userEmail = FirebaseAuth.instance.currentUser!.email ?? "No email";
      await FirebaseFirestore.instance.collection('gits').add({
        'content': content,
        'authorId': userId,
        'email': userEmail, // Changed key to 'email'
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding git: $e");
    }
  }

  Stream<QuerySnapshot> getPostsStream() {
    if (_searchQuery.isEmpty) {
      return FirebaseFirestore.instance.collection('gits').orderBy('timestamp', descending: true).snapshots();
    } else {
      // This returns all posts and will filter in the builder
      return FirebaseFirestore.instance.collection('gits').snapshots();
    }
  }

  void handleMenuClick(int item, QueryDocumentSnapshot git) {
    String currentUserEmail = FirebaseAuth.instance.currentUser!.email ?? "";
    bool canDelete = currentUserEmail == "ashish.csa2125@saintgits.org" || FirebaseAuth.instance.currentUser!.uid == git['authorId'];

    switch (item) {
      case 0: // Delete the post
        if (canDelete) {
          FirebaseFirestore.instance.collection('gits').doc(git.id).delete();
        } else {
          print("You do not have permission to delete this post.");
        }
        break;
    }
  }

  Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _postsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docs = snapshot.data!.docs;

          if (_searchQuery.isNotEmpty) {
            docs = docs.where((doc) {
              final contentMatches = doc['content'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
              final userMatches = ((doc.data() as Map<String, dynamic>).containsKey('name') ? doc['name'] : '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
              return contentMatches || userMatches;
            }).toList();
          }

          return ListView.separated(
            controller: _scrollController,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var git = docs[index];
              var timestamp = git['timestamp'];
              var formattedDate = timestamp != null
                ? DateFormat('dd MMM yyyy hh:mm a').format((timestamp as Timestamp).toDate())
                : 'Date not available';

              return FutureBuilder<DocumentSnapshot>(
                future: getUserDetails(git['email']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                    var user = userSnapshot.data!.data() as Map<String, dynamic>;
                    String currentUserEmail = FirebaseAuth.instance.currentUser!.email ?? "";
                    bool canDelete = currentUserEmail == "ashish.csa2125@saintgits.org" || FirebaseAuth.instance.currentUser!.uid == git['authorId'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['profileImage']),
                          ),
                          title: Text(
                            user['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            git['content'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                          trailing: canDelete ? PopupMenuButton<int>(
                            onSelected: (item) => handleMenuClick(item, git),
                            itemBuilder: (context) => [
                              PopupMenuItem<int>(value: 0, child: Text('Delete')),
                            ],
                          ) : null,
                          isThreeLine: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                        ),
                        if (git['imageUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
                            child: Image.network(
                              git['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 72),
                          child: Text(
                            'Posted on $formattedDate',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              );
            },
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> _handleRefresh() async {
    // Perform necessary data fetch operations
    setState(() {
      // Optionally update the state that affects the stream
    });
  }

  @override
  Widget build(BuildContext context) {
    var bottomInset = MediaQuery.of(context).viewInsets.bottom; // Get the current bottom inset of the media query, which indicates the height of the keyboard.
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: FutureBuilder<String>(
                  future: getUserProfileImage(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: Image.network(
                              snapshot.data!,
                              fit: BoxFit.contain,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        );
                      } else {
                        return Icon(Icons.account_circle, color: Colors.white); // Fallback icon
                      }
                    } else {
                      return CircularProgressIndicator(); // Loading indicator
                    }
                  },
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          title: const Text(
            'TWEETGITS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 0.05,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF0066FF)), // Changed color to 0xFF0066FF
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        drawer: Drawer(
          backgroundColor: Colors.black, // Set the drawer background color to black
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: FutureBuilder<String>(
                        future: getUserProfileImage(),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {
                              return CircleAvatar(
                                radius: 75,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                    width: 150,
                                    height: 150,
                                  ),
                                ),
                              );
                            } else {
                              return CircleAvatar(
                                radius: 75,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: Image.network(
                                    _profileImageUrl, // Use _profileImageUrl as fallback
                                    fit: BoxFit.contain,
                                    width: 150,
                                    height: 150,
                                  ),
                                ),
                              );
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text('My profile', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProfilePage(
                              onProfileImageUpdated: (newImageUrl) {
                                setState(() {
                                  _profileImageUrl = newImageUrl;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_dining, color: Colors.white),
                      title: const Text('Food corner', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FoodCornerPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.handyman, color: Colors.white),
                      title: const Text('Service corner', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ServiceCornerPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.business_center, color: Colors.white),
                      title: const Text('Gits Zone', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GitsZonePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                tileColor: Colors.black, // Ensure the tile color matches the drawer
                title: const Text(
                  'LOG OUT',
                  textAlign: TextAlign.left, // Change
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: _buildPostList(),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: bottomInset), // Adjust padding based on keyboard visibility
          child: BottomAppBar(
            color: Colors.black,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home, color: Color(0xFF0066FF)),
                  iconSize: 30,
                  onPressed: () {
                    setState(() {});
                  },
                ),
                Container(
                  width: 140,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF0066FF), width: 2),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Color(0xFF0066FF)),
                      hintText: 'Search',
                      hintStyle: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.5)),
                      contentPadding: EdgeInsets.only(bottom: 11), // Adjust padding to move text downward
                    ),
                    style: TextStyle(color: Colors.white),
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0066FF)),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GitPostPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(GitPost post) {
    switch (post.type) {
      case 'text':
        return ListTile(
          subtitle: Text('Posted on ${post.timestamp}'),
        );
      default:
        return SizedBox.shrink(); // For unrecognized types
    }
  }

  Future<String> getUserProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        final email = user.email!;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          final userData = userDoc.docs.first.data();
          return userData['profileImage'] ?? _profileImageUrl; // Use _profileImageUrl as default
        } else {
          return _profileImageUrl; // Default image if no user document is found
        }
      } catch (e) {
        print("Failed to get image URL: $e");
        return _profileImageUrl; // Default image if an error occurs
      }
    }
    return _profileImageUrl; // Default image
  }

  Future<DocumentSnapshot> getUserDetails(String email) async {
    return await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get().then(
      (snapshot) => snapshot.docs.first,
    );
  }
}

