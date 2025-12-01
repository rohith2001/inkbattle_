import 'package:flutter/material.dart';

class CustomCircularProgressIndidator extends StatefulWidget {
  const CustomCircularProgressIndidator({super.key});

  @override
  State<CustomCircularProgressIndidator> createState() => _CustomCircularProgressIndidatorState();
}

class _CustomCircularProgressIndidatorState extends State<CustomCircularProgressIndidator> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        backgroundColor: Colors.black26,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white,
        ),
      ),
    );
  }
}
