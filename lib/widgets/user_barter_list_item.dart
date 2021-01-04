import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserBarterListItem extends StatefulWidget {
  final DocumentSnapshot barterSnap;

  const UserBarterListItem({Key key, this.barterSnap}) : super(key: key);

  @override
  _UserBarterListItemState createState() => _UserBarterListItemState();
}

class _UserBarterListItemState extends State<UserBarterListItem> {
  bool _isLoading = true;
  DocumentSnapshot first, second;

  @override
  void initState() {
    final data = widget.barterSnap.data();
    Future.wait([
      (data['first']['ref'] as DocumentReference).get(),
      (data['second']['ref'] as DocumentReference).get(),
    ]).then((snaps) {
      first = snaps[0];
      second = snaps[1];
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(8),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green[100],
            offset: Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 4,
          )
        ],
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/details/bart', arguments: first),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        first.data()['photoUrls'][0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.compare_arrows, size: 36, color: Colors.green),
                SizedBox(width: 8),
                Flexible(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/details/bart', arguments: second),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        second.data()['photoUrls'][0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
