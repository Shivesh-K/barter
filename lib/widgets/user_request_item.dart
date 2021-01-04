import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestItem extends StatefulWidget {
  final DocumentSnapshot reqSnap;

  const UserRequestItem({Key key, this.reqSnap}) : super(key: key);

  @override
  _UserRequestItemState createState() => _UserRequestItemState();
}

class _UserRequestItemState extends State<UserRequestItem> {
  bool _isLoading = true;
  DocumentSnapshot forSnap;

  @override
  void initState() {
    (() async {
      forSnap = await widget.reqSnap.data()['for']['ref'].get();
      setState(() {
        _isLoading = false;
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : ListTile(
            leading: CircleAvatar(
              child: Image.network(forSnap.data()['photoUrls'][0]),
            ),
            title: Text(forSnap.data()['title']),
            subtitle: Text(forSnap.data()['author']['name']),
          );
  }
}
