import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  final Widget content;
  final Color backgroundColor;

  const CustomSnackbar({Key key, this.content, this.backgroundColor})
      : super(
          key: key,
          content: content,
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        );
}
