import 'package:flutter/material.dart';

import 'package:barter/screens/login_screen.dart';
import 'package:barter/screens/root.dart';
import 'package:barter/screens/splash_screen.dart';
import 'package:barter/screens/bart_details_screen.dart';
import 'package:barter/screens/new_request_screen.dart';
import 'package:barter/screens/request_details_screen.dart';
import 'package:barter/screens/chat_screen.dart';
import 'package:barter/screens/user_bart_list_screen.dart';
import 'package:barter/screens/user_request_list_screen.dart';
import 'package:barter/screens/user_barters_list_screen.dart';
import 'package:barter/screens/error_404_screen.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final dynamic args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Root());
      case '/splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/details/bart':
        return MaterialPageRoute(
            builder: (_) => BartDetailsScreen(docSnap: args));
      case '/new/request':
        return MaterialPageRoute(
            builder: (_) => NewRequestScreen(docSnap: args));
      case '/details/request':
        return MaterialPageRoute(
          builder: (_) => RequestDetailsScreen(
            reqSnap: args['reqSnap'],
            forSnap: args['forSnap'],
          ),
        );
      case '/user/barters':
        return MaterialPageRoute(builder: (_) => UserBartersListScreen());
      case '/user/barts':
        return MaterialPageRoute(builder: (_) => UserBartListScreen());
      case '/user/requests':
        return MaterialPageRoute(builder: (_) => UserRequestListScreen());
      case '/chat':
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatSnap: args['chatSnap'],
            peerSnap: args['peerSnap'],
          ),
        );
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(builder: (_) => Error404Screen());
    }
  }
}
