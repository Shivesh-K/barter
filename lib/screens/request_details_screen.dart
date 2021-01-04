import 'package:barter/widgets/custom_sliver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:barter/services/request.dart';
import 'package:barter/services/bart.dart';
import 'package:barter/widgets/author_box.dart';

class RequestDetailsScreen extends StatefulWidget {
  final DocumentSnapshot reqSnap, forSnap;

  const RequestDetailsScreen({Key key, this.reqSnap, this.forSnap})
      : super(key: key);

  @override
  _RequestDetailsScreenState createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  bool _isloading = true;
  List<DocumentSnapshot> _againsts;
  int _radioValue = 0;

  @override
  void initState() {
    (() async {
      final x = widget.reqSnap.data()['against'] as List<dynamic>;
      _againsts = await Future.wait(x.map((e) => e['ref'].get()));
      setState(() {
        _isloading = false;
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.forSnap.data();

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(title: "Details"),
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
                    data['description'].length > 0
                        ? data['description']
                        : "No description provided.",
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
                  Text(
                    "From",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 8),
                  AuthorBox(authorRef: widget.reqSnap.data()['from']['ref']),
                  SizedBox(height: 32),
                  Text(
                    "Choose One",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),
          _isloading
              ? SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = _againsts[index].data();
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          '/details/bart',
                          arguments: _againsts[index],
                        ),
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    data['photoUrls'][0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 46,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.green[100]),
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['title'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(fontSize: 18),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Radio(
                                        value: index,
                                        groupValue: _radioValue,
                                        onChanged: (value) {
                                          setState(() => _radioValue = value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _againsts.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(top: 8, bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: _reject,
                    child: Text(
                      "Reject",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  RaisedButton(
                    onPressed: _accept,
                    child: Text(
                      "Accept",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _accept() async {
    int b1 = (await _againsts[_radioValue].reference.get()).data()['status'];
    int b2 = (await widget.forSnap.reference.get()).data()['status'];

    if (b1 == BartStatus.ACTIVE.index && b2 == BartStatus.ACTIVE.index) {
      final result = await Request.acceptRequest(
          widget.forSnap, _againsts[_radioValue], widget.reqSnap);

      result ? Navigator.of(context).pop() : print("There was some problem!");
    } else {
      print("One of the items is already barted!");
    }
  }

  void _reject() async {
    final result = await Request.rejectRequest(widget.reqSnap);
    result ? Navigator.of(context).pop() : print("There was some problem!");
  }
}
