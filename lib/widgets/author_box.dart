import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barter/services/chat.dart';

class AuthorBox extends StatefulWidget {
  final DocumentReference authorRef;

  const AuthorBox({Key key, this.authorRef}) : super(key: key);

  @override
  _AuthorBoxState createState() => _AuthorBoxState();
}

class _AuthorBoxState extends State<AuthorBox> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  DocumentSnapshot _author;

  @override
  void initState() {
    (() async {
      final x = await widget.authorRef.get();
      setState(() {
        _author = x;
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]),
      ),
      child: _author == null
          ? SizedBox(height: 64)
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(_author.data()['photoURL']),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 200,
                      child: Text(
                        _author.data()['displayName'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.message, color: Colors.green),
                  onPressed: _chat,
                )
              ],
            ),
    );
  }

  void _chat() async {
    String id1 = _author.id;
    String id2 = _auth.currentUser.uid;

    // If the chat does not already exist, create one
    if (!(await Chat.exists(id1, id2))) await Chat.create(id1, id2);

    // Get the snapshot of chat details from the current user document
    final snap = await _db
        .collection('users')
        .doc(id2)
        .collection('chats')
        .doc(id1.compareTo(id2) < 0 ? '$id1-$id2' : '$id2-$id1')
        .get();
    final chatSnap = await snap.data()['ref'].get();
    final peerSnap = await snap.data()['peerRef'].get();

    // If any of the snapshots is null, we need cannot go to the chat page.
    if (chatSnap == null || peerSnap == null) return;

    Navigator.of(context).pushNamed('/chat', arguments: {
      'chatSnap': chatSnap,
      'peerSnap': peerSnap,
    });
  }
}
