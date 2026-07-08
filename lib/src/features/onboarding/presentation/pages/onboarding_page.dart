import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../auth/presentation/pages/auth_welcome_page.dart';
import '../entities/onboarding_slide.dart';
import '../widgets/onboarding_illustration.dart';
import '../widgets/onboarding_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;
  static const int _slideCount = 3;

  List<OnboardingSlide> _slides(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardingSlide(
        icon: Icons.edit_note_outlined,
        title: l10n.onboardingWriteTitle,
        subtitle: l10n.onboardingWriteSubtitle,
        color: AppColors.primary,
      ),
      OnboardingSlide(
        icon: Icons.dashboard_customize_outlined,
        title: l10n.onboardingAllInOneTitle,
        subtitle: l10n.onboardingAllInOneSubtitle,
        color: AppColors.secondary,
      ),
      OnboardingSlide(
        icon: Icons.cloud_sync_outlined,
        title: l10n.onboardingSyncTitle,
        subtitle: l10n.onboardingSyncSubtitle,
        color: AppColors.blue,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _complete() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthWelcomePage()),
    );
  }

  void _next() {
    if (_index == _slideCount - 1) {
      _complete();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slides = _slides(context);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 24.h),
          child: Column(
            children: [
              Row(
                children: [
                  const BrandLogo(size: 44),
                  SizedBox(width: AppSizes.sm.w),
                  Text(
                    'MindSpace',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _complete,
                    child: Text(context.l10n.skip),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.md.h),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return _OnboardingCard(slide: slide);
                  },
                ),
              ),
              SizedBox(height: AppSizes.md.h),
              Row(
                children: [
                  OnboardingIndicator(length: slides.length, index: _index),
                  const Spacer(),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      fixedSize: Size(56.w, 56.w),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _next,
                    icon: Icon(
                      _index == slides.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(flex: 6, child: OnboardingIllustration(slide: slide)),
        SizedBox(height: AppSizes.lg.h),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  height: 1.14,
                ),
              ),
              SizedBox(height: AppSizes.md.h),
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
