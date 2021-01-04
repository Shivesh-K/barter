import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestListItem extends StatefulWidget {
  final DocumentSnapshot snap;

  const RequestListItem({Key key, @required this.snap}) : super(key: key);

  @override
  _RequestListItemState createState() => _RequestListItemState();
}

class _RequestListItemState extends State<RequestListItem> {
  final _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  DocumentSnapshot _forSnap;

  @override
  void initState() {
    (() async {
      _forSnap =
          await (widget.snap.data()['for']['ref'] as DocumentReference).get();
      setState(() {
        _isLoading = false;
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(),
      );
    else {
      if (!_forSnap.exists)
        return Container(
          height: 60,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.green[100],
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Center(
            child: Text(
              "You deleted the bart this requested.",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        );

      final _data = _forSnap.data();
      return InkWell(
        onTap: widget.snap.data()['from']['id'] != _auth.currentUser.uid
            ? () => Navigator.of(context).pushNamed(
                  '/details/request',
                  arguments: {
                    'reqSnap': widget.snap,
                    'forSnap': _forSnap,
                  },
                )
            : null,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 60),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green[100],
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 220,
                            child: Text(
                              _data['title'],
                              style: Theme.of(context).textTheme.headline6,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: Text(
                              _data['description'],
                              style: Theme.of(context).textTheme.bodyText2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              Container(
                height: 80,
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _data['photoUrls'][0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
