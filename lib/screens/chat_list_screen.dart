import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:barter/widgets/chat_list_item.dart';
import 'package:barter/widgets/custom_sliver_appbar.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<DocumentSnapshot> _chats;

  @override
  void initState() {
    (() async {
      _chats = (await _db
              .collection('users')
              .doc(_auth.currentUser.uid)
              .collection('chats')
              .get())
          .docs;
      setState(() {
        _isLoading = false;
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(title: "Chats"),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ChatListItem(
                      chatSnap: _chats[index],
                    ),
                    childCount: _chats.length,
                  ),
                ),
        ],
      ),
    );
  }
}
