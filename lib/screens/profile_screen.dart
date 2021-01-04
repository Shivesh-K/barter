import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:barter/services/auth.dart';
import 'package:barter/widgets/profile_pill.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  Map<String, dynamic> _userData;

  @override
  void initState() {
    (() async {
      _userData =
          (await _db.collection('users').doc(_auth.currentUser.uid).get())
              .data();
      setState(() {
        _isLoading = false;
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Profile",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      )),
      body: Container(
        margin: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green[100],
                          offset: Offset(0, 2),
                          spreadRadius: 1,
                          blurRadius: 8,
                        )
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            _userData['photoURL'] ??
                                "https://picsum.photos/id/237/24/24",
                          ),
                          radius: 48,
                        ),
                        SizedBox(width: 32),
                        Flexible(
                          child: Text(
                            _userData['displayName'],
                            style: Theme.of(context).textTheme.headline6,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 32),
            GridView(
              shrinkWrap: true,
              padding: EdgeInsets.all(16),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              children: [
                ProfilePill(
                  text: "Barter History",
                  icon: Icons.compare_arrows,
                  onTap: () => Navigator.of(context).pushNamed('/user/barters'),
                ),
                ProfilePill(
                  text: "My Barts",
                  icon: Icons.apps,
                  onTap: () => Navigator.of(context).pushNamed('/user/barts'),
                ),
                ProfilePill(
                  text: "My Requests",
                  icon: Icons.forward,
                  onTap: () =>
                      Navigator.of(context).pushNamed('/user/requests'),
                ),
                ProfilePill(
                  text: "Logout",
                  icon: Icons.exit_to_app,
                  onTap: _signOut,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await authService.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
