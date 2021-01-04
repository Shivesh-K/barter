import 'package:barter/services/request.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barter/widgets/request_list_item.dart';
import 'package:barter/widgets/custom_sliver_appbar.dart';

class RequestsListScreen extends StatelessWidget {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(title: "Requests"),
          StreamBuilder(
            stream: _db
                .collection('requests')
                .where('to.id', isEqualTo: _auth.currentUser.uid)
                .where('status', isEqualTo: RequestStatus.WAITING.index)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );

              if (snapshot.hasError)
                return SliverFillRemaining(
                  child: Center(
                    child: Text("There was an error :("),
                  ),
                );

              if (!snapshot.hasError) {
                final docSnaps = snapshot.data.docs;

                if (docSnaps.length == 0)
                  return SliverFillRemaining(
                    child: Center(
                      child: Text("No requests"),
                    ),
                  );

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RequestListItem(snap: docSnaps[index]),
                    childCount: docSnaps.length,
                  ),
                );
              } else {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
