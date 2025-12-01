import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inkbattle_frontend/utils/app_utils/app_utils.dart';

import 'text_widget.dart';

class InAppWebViewVidget extends StatefulWidget {
  const InAppWebViewVidget({super.key, this.categoryName, this.url});

  final String? categoryName;
  final String? url;

  @override
  State<InAppWebViewVidget> createState() => _InAppWebViewVidgetState();
}

class _InAppWebViewVidgetState extends State<InAppWebViewVidget> {
  @override
  Widget build(BuildContext context) {
    log(widget.url.toString());
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: systemOverLayStyle,
          surfaceTintColor: Colors.white10,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: TextWidget(
            text: widget.categoryName.toString(),
            color: Colors.black,
            fontSize: 17,
          )),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(widget.url ?? ""),
        ),
        initialOptions:
            // ignore: deprecated_member_use
            InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions()),
      ),
    );
  }
}
