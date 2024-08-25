import 'package:chat/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/screens/chatscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  final User? loggedInUser = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Chat"),
        actions: [
          IconButton(
            onPressed: () async {
              await UserService().logout().then((value) =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false));
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for chats ..',
                hintStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: Colors.black,
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 15.0,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .where('email', isNotEqualTo: loggedInUser!.email) // Exclude logged-in user
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No users found.'));
                  }

                  var users = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('user_status')
                            .doc(user['uid'])
                            .get(),
                        builder: (context, statusSnapshot) {
                          if (statusSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text(user['name']),
                              leading: CircleAvatar(
                                child: Text(user['name'][0]),
                                backgroundColor: Colors.grey, // Default color while loading
                              ),
                              subtitle: Text('Loading status...'),
                            );
                          }

                          if (statusSnapshot.hasError) {
                            return ListTile(
                              title: Text(user['name']),
                              leading: CircleAvatar(
                                child: Text(user['name'][0]),
                                backgroundColor: Colors.grey, // Default color on error
                              ),
                              subtitle: Text('Error loading status'),
                            );
                          }

                          var status = statusSnapshot.data?.data() as Map<String, dynamic>?;
                          bool isOnline = status?['online'] ?? false;

                          return ListTile(
                            title: Text(user['name']),
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  child: Text(user['name'][0]),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: isOnline ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white, // Border color for the dot
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverId: user['uid'],
                                    receiverName: user['name'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
