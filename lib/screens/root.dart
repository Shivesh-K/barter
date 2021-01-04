import 'package:flutter/material.dart';

import 'package:barter/screens/new_bart_screen.dart';
import 'package:barter/screens/home_screen.dart';
import 'package:barter/screens/requests_list_screen.dart';
import 'package:barter/screens/chat_list_screen.dart';
import 'package:barter/screens/profile_screen.dart';

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: IndexedStack(
            key: ValueKey<int>(_current),
            index: _current,
            children: [
              HomeScreen(),
              RequestsListScreen(),
              NewBartScreen(),
              ChatListScreen(),
              ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current,
        onTap: (value) => setState(() => _current = value),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            title: Text("Requests"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            title: Text("New Bart"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            title: Text("Chats"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
          ),
        ],
      ),
    );
  }
}
