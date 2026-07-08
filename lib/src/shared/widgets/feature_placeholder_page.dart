import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'responsive_page.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.sections,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final List<String> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    color: Colors.white,
                    padding: EdgeInsets.all(18.w),
                    child: Row(
                      children: [
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(icon, color: AppColors.primary),
                        ),
                        SizedBox(width: AppSizes.md.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              SizedBox(height: AppSizes.xs.h),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.slate,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(20.w),
                sliver: SliverList.list(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: actionLabel,
                        icon: Icons.add,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.comingSoon(actionLabel),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSizes.lg.h),
                    ...sections.map(
                      (section) => Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.md.h),
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 38.w,
                                height: 38.w,
                                decoration: BoxDecoration(
                                  color: AppColors.softBlue,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: AppSizes.sm.w),
                              Expanded(
                                child: Text(
                                  section,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16.sp,
                                color: AppColors.slate,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
