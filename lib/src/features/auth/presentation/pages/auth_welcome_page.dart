import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/brand_logo.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthWelcomePage extends StatelessWidget {
  const AuthWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 28.h),
          child: Column(
            children: [
              const Spacer(),
              const BrandLogo(size: 118),
              SizedBox(height: AppSizes.lg.h),
              Text(
                'MindSpace',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              SizedBox(height: AppSizes.sm.h),
              Text(
                l10n.authWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.slate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSizes.xl.h),
              _FeatureLine(icon: Icons.edit_note, text: l10n.authFeatureNotes),
              _FeatureLine(
                icon: Icons.check_circle_outline,
                text: l10n.authFeatureTasks,
              ),
              _FeatureLine(
                icon: Icons.sync_outlined,
                text: l10n.authFeatureSync,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.login,
                  icon: Icons.login,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppSizes.sm.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.createAccount,
                  icon: Icons.person_add_alt_1,
                  style: AppButtonStyle.secondary,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: AppSizes.sm.w),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.slate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
