import 'package:flutter/material.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';


class SnackBarWidget {
  static void showSnackbar(BuildContext context, String errorMessage,
      {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: color ?? Colors.green,
        content: TextWidget(
          text: errorMessage,
          fontSize: 15,
        ),),);
  }
}
