import 'package:flutter/material.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({
    super.key,
    required this.context,
  });

  final BuildContext context;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              color: const Color(0XFF767AE6),
              child: Center(
                child: TextWidget(
                  text: "b",
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(
              width: 3,
            ),
            Container(
              width: 30,
              height: 40,
              color: const Color(0XFFB6D06A),
              child: Center(
                child: TextWidget(
                  text: "a",
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 40,
              color: const Color(0XFFE376A3),
              child: Center(
                child: TextWidget(
                  text: "a",
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(
              width: 3,
            ),
            Container(
              width: 40,
              height: 40,
              color: const Color(0XFF2D8C8C),
              child: Center(
                child: TextWidget(
                  text: "p",
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
