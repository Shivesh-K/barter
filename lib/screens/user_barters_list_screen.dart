import 'package:barter/widgets/custom_sliver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barter/widgets/user_barter_list_item.dart';

class UserBartersListScreen extends StatefulWidget {
  @override
  _UserBartersListScreenState createState() => _UserBartersListScreenState();
}

class _UserBartersListScreenState extends State<UserBartersListScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<DocumentSnapshot> _barters;

  @override
  void initState() {
    (() async {
      final x = await _db
          .collection('barters')
          .where('first.authorId', isEqualTo: _auth.currentUser.uid)
          .get();
      final y = await _db
          .collection('barters')
          .where('second.authorId', isEqualTo: _auth.currentUser.uid)
          .get();
      x.docs.addAll(y.docs);
      setState(() {
        _barters = x.docs;
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
          CustomSliverAppBar(title: "My Barters"),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return UserBarterListItem(barterSnap: _barters[index]);
                    },
                    childCount: _barters.length,
                  ),
                )
        ],
      ),
    );
  }
}
