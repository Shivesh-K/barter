import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListItem extends StatefulWidget {
  // This chatSnap is the snapshot of a chat document in the chats
  // sub-collection of the users collection. It has only basic data and is
  // different from the chatSnap in the chats collection.
  final DocumentSnapshot chatSnap;

  const ChatListItem({Key key, this.chatSnap}) : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  final _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  DocumentSnapshot _chatSnap, _peerSnap;
  String _name, _photoUrl;
  Map<String, dynamic> _lastMessage;

  @override
  void initState() {
    (() async {
      final data = widget.chatSnap.data();
      _peerSnap = await data['peerRef'].get();
      _chatSnap = await data['ref'].get(); // this chatSnap is the snapshot of
      // the document in the main chats collection
      setState(() {
        _name = _peerSnap.data()['displayName'];
        _lastMessage = _chatSnap.data()['lastMessage'];
        _photoUrl = _peerSnap.data()['photoURL'];
        _isLoading = false;
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/chat', arguments: {
          'chatSnap': _chatSnap,
          'peerSnap': _peerSnap,
        }),
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isLoading ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.green[100],
                offset: Offset(0, 4),
                spreadRadius: 4,
                blurRadius: 16,
              )
            ],
          ),
          child: _isLoading
              ? Container(height: 60)
              : Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(_photoUrl),
                      radius: 28,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          width: 240,
                          child: Text(
                            _lastMessage == null
                                ? "No messages yet!"
                                : _lastMessage['senderId']
                                            .compareTo(_auth.currentUser.uid) ==
                                        0
                                    ? 'You: ${_lastMessage['text']}'
                                    : '$_name: ${_lastMessage['text']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
