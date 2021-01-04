import 'package:barter/widgets/custom_sliver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:barter/widgets/bart_list_item.dart';

class UserBartListScreen extends StatefulWidget {
  @override
  _UserBartListScreenState createState() => _UserBartListScreenState();
}

class _UserBartListScreenState extends State<UserBartListScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _isLoading = true;
  String _id;
  List<DocumentSnapshot> _barts;

  @override
  void initState() {
    _id = _auth.currentUser.uid;
    (() async {
      _barts = (await _db
              .collection('barts')
              .where('author.uid', isEqualTo: _id)
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
          CustomSliverAppBar(title: "My Barts"),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BartListItem(docSnap: _barts[index]),
                    childCount: _barts.length,
                  ),
                ),
        ],
      ),
    );
  }
}
