import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';

import 'package:barter/services/location.dart';
import 'package:barter/widgets/bart_list_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _geo = Geoflutterfire();

  ScrollController _controller;
  bool _isLoading = true;
  LocationData _currentLocation;
  dynamic _bartRefsStream;
  bool _appbarOnHeader = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    (() async {
      _currentLocation = await LocationService.getCurrentLocation();
      GeoFirePoint center = _geo.point(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
      );

      final collectionReference =
          _db.collection('barts').where('status', isEqualTo: 1);

      setState(() {
        _bartRefsStream =
            _geo.collection(collectionRef: collectionReference).within(
                  center: center,
                  radius: 10,
                  field: 'location',
                );
        _isLoading = false;
        _controller = ScrollController(initialScrollOffset: 0);
        _controller.addListener(() => setState(() {
              _appbarOnHeader = _controller.offset <= 200;
            }));
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            leading: Icon(
              Icons.compare_arrows,
              color: _appbarOnHeader
                  ? Colors.white
                  : Theme.of(context).primaryColor,
            ),
            title: Text(
              "Barter",
              style: TextStyle(
                color: _appbarOnHeader
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
            ),
            backgroundColor:
                _appbarOnHeader ? Theme.of(context).primaryColor : Colors.white,
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Container(
                height: 200,
                color: Theme.of(context).primaryColor,
                child: Text(
                  "Good Morning, ${_auth.currentUser.displayName.split(' ')[0]}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      .copyWith(color: Colors.white),
                ),
              ),
              Container(
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.white,
                ),
              ),
            ]),
          ),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : StreamBuilder(
                  stream: _bartRefsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return Center(
                        child: Text("Error"),
                      );

                    if (!snapshot.hasData)
                      return SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                    final data = snapshot.data
                        .where((DocumentSnapshot docSnap) =>
                            docSnap.data()['author']['uid'] !=
                            _auth.currentUser.uid)
                        .toList();

                    if (data.length < 1)
                      return SliverFillRemaining(
                        child: Center(
                          child: Text("No barters!"),
                        ),
                      );

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => BartListItem(docSnap: data[index]),
                        childCount: data.length,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
