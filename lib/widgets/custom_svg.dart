import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit? boxFit;
  final Color? color;

  final VoidCallback? onTap;

  const CustomSvgImage({
    super.key,
    this.color,
    required this.imageUrl,
    this.height = 40.0,
    this.width = 40.0,
    this.boxFit,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
      child: SvgPicture.asset(
        imageUrl,
        height: height,
        width: width,
        color: color,
        fit: boxFit ?? BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Container(
          height: height,
          width: width,
          color: color,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
