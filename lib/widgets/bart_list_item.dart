import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barter/services/chat.dart';
import 'package:barter/services/bart.dart';

class BartListItem extends StatefulWidget {
  final DocumentSnapshot docSnap;

  BartListItem({@required this.docSnap});

  @override
  _BartListItemState createState() => _BartListItemState();
}

class _BartListItemState extends State<BartListItem> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String _title = '';
  String _description = '';
  String _authorName = '';
  String _image;
  int _status;

  @override
  void initState() {
    final data = widget.docSnap.data();
    _title = data['title'];
    _description = data['description'];
    _authorName = data['author']['name'];
    _image = data['photoUrls'][0];
    _status = data['status'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToDetails,
      child: Container(
        margin: EdgeInsets.all(16),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 170,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 24),
                          spreadRadius: 6,
                          blurRadius: 32,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.24),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                          _authorName,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Container(
                          height: 50,
                          child: Text(
                            _description ?? "No description given.",
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            widget.docSnap.data()['author']['uid'] == _auth.currentUser.uid
                ? Container(
                    margin: EdgeInsets.fromLTRB(260, 160, 0, 0),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _status == BartStatus.ACTIVE.index
                          ? Colors.grey[50]
                          : Colors.green,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      _status == BartStatus.ACTIVE.index ? "Active" : "Barted",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _status == BartStatus.ACTIVE.index
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 146),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          child: Icon(Icons.message),
                          onPressed: _chat,
                          backgroundColor: Colors.green,
                          heroTag: null,
                        ),
                        SizedBox(width: 16),
                        FloatingActionButton(
                          child: Icon(Icons.forward),
                          onPressed: _createRequest,
                          backgroundColor: Colors.green,
                          heroTag: null,
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _goToDetails() {
    Navigator.of(context).pushNamed('/details/bart', arguments: widget.docSnap);
  }

  void _chat() async {
    String id1 = widget.docSnap.data()['author']['uid'];
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

  void _createRequest() {
    Navigator.of(context).pushNamed('/new/request', arguments: widget.docSnap);
  }
}
