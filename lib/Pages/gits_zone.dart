import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Import DateFormat

class GitsZonePage extends StatelessWidget {
  const GitsZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('gits')
            .where('category', isEqualTo: 'Gits Zone')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              return ListView.separated(
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  DocumentSnapshot document = snapshot.data!.docs[index];
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  DateTime date = (data['timestamp'] as Timestamp).toDate();
                  String formattedDate = DateFormat('dd MMM yyyy hh:mm a').format(date);
                  return ListTile(
                    title: Text(data['content'], style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data['imageUrl'] != null)
                          Image.network(data['imageUrl']),
                        Text(formattedDate, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
