import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final DocumentSnapshot chatSnap, peerSnap;

  const ChatScreen({
    Key key,
    @required this.chatSnap,
    @required this.peerSnap,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  List<DocumentSnapshot> _messages;
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).primaryColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.peerSnap.data()['photoURL']),
            ),
            SizedBox(width: 8),
            Text(
              widget.peerSnap.data()['displayName'],
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: widget.chatSnap.reference
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text("There was some error :("),
            );

          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          _messages = snapshot.data.docs;
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 72),
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    bool isSenderCurrUser =
                        message.data()['senderId'] == _auth.currentUser.uid;
                    return Container(
                      margin: EdgeInsets.only(
                        left: isSenderCurrUser ? 40 : 0,
                        right: isSenderCurrUser ? 0 : 40,
                        top: 4,
                      ),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isSenderCurrUser
                            ? Colors.grey[300]
                            : Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        _messages[index].data()['text'],
                        style: TextStyle(
                          fontSize: 16,
                          color: isSenderCurrUser ? Colors.black : Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 56,
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: EdgeInsets.only(left: 16, right: 8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green[100],
                        spreadRadius: 1,
                        blurRadius: 8,
                      )
                    ],
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(fontSize: 18),
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Type something here...",
                          border: InputBorder.none,
                        ),
                        autocorrect: true,
                        autofocus: true,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _send,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _send() async {
    if (_textController.text.trim() == '') return;

    await widget.chatSnap.reference.collection('messages').add({
      'text': _textController.text,
      'senderId': _auth.currentUser.uid,
      'timestamp': Timestamp.now(),
    });
    _textController.clear();
  }
}
