import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barter/services/bart.dart';
import 'package:barter/widgets/author_box.dart';

class BartDetailsScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  final DocumentSnapshot docSnap;

  BartDetailsScreen({@required this.docSnap});

  @override
  Widget build(BuildContext context) {
    final data = docSnap.data();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.white,
            floating: true,
            shadowColor: Colors.green[200],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Details",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .merge(TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(height: 8),
                  Text(
                    data['description'],
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data['photoUrls'].length,
                      itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            data['photoUrls'][index],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  AuthorBox(authorRef: data['author']['ref']),
                  SizedBox(height: 16),
                  data['status'] == BartStatus.BARTED.index
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green[100],
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    )
                                  ]),
                              child: Text(
                                "Already Barted",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : data['author']['uid'] != _auth.currentUser.uid
                          ? Container(
                              alignment: Alignment.topRight,
                              child: RaisedButton(
                                onPressed: () => _createRequest(context),
                                child: Text(
                                  "Send Request",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                              ),
                            )
                          : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createRequest(BuildContext context) {
    Navigator.of(context).pushNamed('/new/request', arguments: docSnap);
  }
}
