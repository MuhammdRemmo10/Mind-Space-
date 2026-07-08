import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../entities/onboarding_slide.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({required this.slide, super.key});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          constraints: BoxConstraints(maxWidth: 360.w, maxHeight: 360.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 42.w,
                top: 54.h,
                child: _SoftTile(
                  icon: slide.icon,
                  color: slide.color,
                  size: 82,
                ),
              ),
              Positioned(
                right: 44.w,
                top: 86.h,
                child: _LineCard(color: AppColors.amber, width: 104),
              ),
              Positioned(
                left: 52.w,
                bottom: 72.h,
                child: _LineCard(color: AppColors.blue, width: 132),
              ),
              Positioned(
                right: 58.w,
                bottom: 52.h,
                child: _SoftTile(
                  icon: Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 70,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 92.w,
                  height: 92.w,
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: slide.color.withValues(alpha: 0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Icon(slide.icon, color: slide.color, size: 42.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftTile extends StatelessWidget {
  const _SoftTile({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
      ),
      child: Icon(icon, color: color, size: 28.sp),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: 64.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: width.w * 0.52, height: 6.h, color: color),
          SizedBox(height: 10.h),
          Container(
            width: width.w * 0.72,
            height: 5.h,
            color: color.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
