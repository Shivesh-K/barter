import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barter/services/request.dart';

class NewRequestScreen extends StatefulWidget {
  final DocumentSnapshot docSnap;

  NewRequestScreen({@required this.docSnap});

  @override
  _NewRequestScreenState createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  List<QueryDocumentSnapshot> snaps;
  Set<DocumentSnapshot> _selectedSnaps = {};
  List<bool> _selected;

  @override
  void initState() {
    (() async {
      final x = await _db
          .collection('barts')
          .where('author.uid', isEqualTo: _auth.currentUser.uid)
          .where('status', isEqualTo: 1)
          .get();
      setState(() {
        snaps = x.docs;
        _selected = List(snaps.length);
        _selected.fillRange(0, snaps.length, false);
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
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.white,
            floating: true,
            shadowColor: Colors.green[200],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "New Request",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .merge(TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.docSnap.data()['title'],
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: ClipRRect(
                      child:
                          Image.network(widget.docSnap.data()['photoUrls'][0]),
                    ),
                  ),
                  SizedBox(height: 48),
                  Text(
                    "Choose your offerings",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(width: 32),
                ],
              ),
            ),
          ),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : snaps == null
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Icon(Icons.error_outline, size: 24),
                      ),
                    )
                  : snaps.length == 0
                      ? SliverToBoxAdapter(
                          child: Center(
                              child: Text("You have no barts to choose from!")),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, index) {
                              final data = snaps[index].data();
                              return GestureDetector(
                                onTap: () => Navigator.of(context).pushNamed(
                                  '/details/bart',
                                  arguments: snaps[index],
                                ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 60,
                                        width: 40,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                            border: Border.all(
                                              color: Colors.green[100],
                                            ),
                                            borderRadius:
                                                BorderRadius.horizontal(
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
                                              Checkbox(
                                                  tristate: false,
                                                  value: _selected[index],
                                                  onChanged: (value) {
                                                    if (value)
                                                      _selectedSnaps
                                                          .add(snaps[index]);
                                                    else
                                                      _selectedSnaps
                                                          .removeWhere((e) =>
                                                              e.id ==
                                                              snaps[index].id);
                                                    setState(() {
                                                      _selected[index] = value;
                                                    });
                                                  }),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: snaps.length,
                          ),
                        ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RaisedButton(
                    onPressed: _submit,
                    child: Text(
                      "Send Request",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _submit() async {
    if (_selectedSnaps.isEmpty) return;

    final DocumentReference toRef =
        await widget.docSnap.data()['author']['ref'];
    final DocumentReference fromRef =
        await _selectedSnaps.first?.data()['author']['ref'];

    if (await Request.createRequest(
          forSnap: widget.docSnap,
          selectedSnaps: _selectedSnaps,
          fromRef: fromRef,
          toRef: toRef,
        ) ==
        null) return;

    Navigator.of(context).pop();
  }
}
