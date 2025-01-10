import 'package:flutter/material.dart';

CustomSnackBar(BuildContext context, Widget content,
    {SnackBarAction? snackBarAction, Color backgroundColor = Colors.green}) {
  final SnackBar snackBar = SnackBar(
      action: snackBarAction,
      backgroundColor: backgroundColor,
      content: content,
      behavior: SnackBarBehavior.floating);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
