import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/main_shell_page.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthCubit>().register(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const MainShellPage()),
            );
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 28.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: l10n.back,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      SizedBox(height: AppSizes.md.h),
                      Center(
                        child: Column(
                          children: [
                            const BrandLogo(size: 88),
                            SizedBox(height: AppSizes.md.h),
                            Text(
                              l10n.registerTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: AppSizes.xs.h),
                            Text(
                              l10n.registerSubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.slate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.lg.h),
                      AppCard(
                        padding: EdgeInsets.all(18.w),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _fullNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.fullName,
                                prefixIcon: const Icon(Icons.badge_outlined),
                              ),
                              validator: (value) =>
                                  (value?.trim().length ?? 0) < 2
                                  ? l10n.fullNameMinLength
                                  : null,
                            ),
                            SizedBox(height: AppSizes.md.h),
                            TextFormField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.username,
                                prefixIcon: const Icon(Icons.alternate_email),
                              ),
                              validator: (value) =>
                                  (value?.trim().length ?? 0) < 3
                                  ? l10n.usernameMinLength
                                  : null,
                            ),
                            SizedBox(height: AppSizes.md.h),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                prefixIcon: const Icon(Icons.mail_outline),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return l10n.emailRequired;
                                }
                                if (!RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(text)) {
                                  return l10n.emailInvalid;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppSizes.md.h),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) => (value?.length ?? 0) < 8
                                  ? l10n.passwordMinLength
                                  : null,
                              onFieldSubmitted: (_) => _submit(context),
                            ),
                            SizedBox(height: AppSizes.lg.h),
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                label: l10n.createAccount,
                                icon: Icons.person_add_alt_1,
                                isLoading: isLoading,
                                onPressed: () => _submit(context),
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
          );
        },
      ),
    );
  }
}
