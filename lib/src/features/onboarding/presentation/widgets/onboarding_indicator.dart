import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    required this.length,
    required this.index,
    super.key,
  });

  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Row(
      children: List.generate(length, (itemIndex) {
        final isActive = itemIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isActive ? 28.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.only(right: 7.w),
          decoration: BoxDecoration(
            color: isActive
                ? color
                : Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(99.r),
          ),
        );
      }),
    );
  }
}
