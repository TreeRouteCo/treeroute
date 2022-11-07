import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandIcon extends StatelessWidget {
  final double width;

  const BrandIcon({this.width = 200, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "logo",
      child: (Theme.of(context).brightness == Brightness.dark)
          ? SvgPicture.asset(
              "assets/icon_dark.svg",
              width: width,
            )
          : SvgPicture.asset(
              "assets/icon_light.svg",
              width: width,
            ),
    );
  }
}
