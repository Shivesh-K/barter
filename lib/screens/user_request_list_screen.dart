import 'package:barter/widgets/request_list_item.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:barter/widgets/custom_sliver_appbar.dart';

class UserRequestListScreen extends StatefulWidget {
  @override
  _UserRequestListScreenState createState() => _UserRequestListScreenState();
}

class _UserRequestListScreenState extends State<UserRequestListScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _isLoading = true;
  String _id;
  List<DocumentSnapshot> _requests;

  @override
  void initState() {
    _id = _auth.currentUser.uid;
    (() async {
      _requests = (await _db
              .collection('requests')
              .where('from.id', isEqualTo: _id)
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
        slivers: [
          CustomSliverAppBar(title: "My Requests"),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RequestListItem(snap: _requests[index]),
                    childCount: _requests.length,
                  ),
                )
        ],
      ),
    );
  }
}
