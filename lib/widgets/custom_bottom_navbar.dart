import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatefulWidget {
  final List<Function> onTaps;

  const CustomBottomNavbar({Key key, this.onTaps}) : super(key: key);

  @override
  _CustomBottomNavbarState createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      // color: Colors.red,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.lightGreen[100],
                      Colors.green[400]
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                alignment: Alignment.bottomCenter,
              ),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.home),
              Icon(Icons.compare_arrows),
              Icon(Icons.add),
              Icon(Icons.forum),
              Icon(Icons.person),
            ],
          ),
        ],
      ),
    );
  }
}
