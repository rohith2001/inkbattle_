import 'package:flutter/material.dart';

class KeyBoardUtils {
  static void hideKeyBoard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
