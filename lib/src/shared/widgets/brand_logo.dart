import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({this.size = 168, this.showWordmark = false, super.key});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.mindSpaceLogo,
      width: size.w,
      height: showWordmark ? null : size.w,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
