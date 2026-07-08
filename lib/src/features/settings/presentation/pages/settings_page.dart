import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../cubit/locale_cubit.dart';
import '../cubit/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
            children: [
              Text(
                l10n.settings,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSizes.xs.h),
              Text(
                l10n.settingsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate,
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppSizes.lg.h),
              _LanguageCard(),
              SizedBox(height: AppSizes.md.h),
              _ThemeCard(),
              SizedBox(height: AppSizes.md.h),
              _SettingsLinks(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedLocale = context.watch<LocaleCubit>().state;

    final options = <({Locale? locale, String label, IconData icon})>[
      (locale: null, label: l10n.systemLanguage, icon: Icons.devices_outlined),
      (
        locale: const Locale('tr'),
        label: l10n.turkish,
        icon: Icons.language_outlined,
      ),
      (
        locale: const Locale('ar'),
        label: l10n.arabic,
        icon: Icons.translate_outlined,
      ),
      (
        locale: const Locale('en'),
        label: l10n.english,
        icon: Icons.abc_outlined,
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.translate_outlined, title: l10n.language),
          SizedBox(height: AppSizes.sm.h),
          ...options.map((option) {
            final selected =
                option.locale?.languageCode == selectedLocale?.languageCode;
            final systemSelected =
                option.locale == null && selectedLocale == null;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                option.icon,
                color: selected || systemSelected
                    ? AppColors.primary
                    : AppColors.slate,
              ),
              title: Text(option.label),
              trailing: selected || systemSelected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                final cubit = context.read<LocaleCubit>();
                final locale = option.locale;
                if (locale == null) {
                  cubit.useSystemLocale();
                  return;
                }
                cubit.setLocale(locale);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeMode = context.watch<ThemeCubit>().state;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.contrast_outlined, title: l10n.theme),
          SizedBox(height: AppSizes.md.h),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.devices_outlined),
                label: Text(l10n.systemTheme),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.lightTheme),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.darkTheme),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (value) =>
                context.read<ThemeCubit>().setThemeMode(value.first),
          ),
        ],
      ),
    );
  }
}

class _SettingsLinks extends StatefulWidget {
  @override
  State<_SettingsLinks> createState() => _SettingsLinksState();
}

class _SettingsLinksState extends State<_SettingsLinks> {
  bool _notificationsEnabled = true;
  bool _securityEnabled = false;
  bool _privacyEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (
        id: 'notifications',
        icon: Icons.notifications_outlined,
        title: l10n.notifications,
      ),
      (id: 'security', icon: Icons.lock_outline, title: l10n.security),
      (id: 'backup', icon: Icons.backup_outlined, title: l10n.backupRestore),
      (id: 'privacy', icon: Icons.privacy_tip_outlined, title: l10n.privacy),
      (id: 'about', icon: Icons.info_outline, title: l10n.about),
    ];

    return AppCard(
      child: Column(
        children: items
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.icon, color: AppColors.ink),
                title: Text(item.title),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showSettingSheet(context, item),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showSettingSheet(
    BuildContext context,
    ({String id, IconData icon, String title}) item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final l10n = context.l10n;
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTitle(icon: item.icon, title: item.title),
                  SizedBox(height: AppSizes.md.h),
                  if (item.id == 'notifications')
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.notifications),
                      subtitle: Text(l10n.comingSoon(l10n.notifications)),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        setSheetState(() {});
                      },
                    )
                  else if (item.id == 'security')
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.security),
                      subtitle: Text(l10n.comingSoon(l10n.security)),
                      value: _securityEnabled,
                      onChanged: (value) {
                        setState(() => _securityEnabled = value);
                        setSheetState(() {});
                      },
                    )
                  else if (item.id == 'privacy')
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.privacy),
                      subtitle: Text(l10n.comingSoon(l10n.privacy)),
                      value: _privacyEnabled,
                      onChanged: (value) {
                        setState(() => _privacyEnabled = value);
                        setSheetState(() {});
                      },
                    )
                  else if (item.id == 'backup')
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cloud_done_outlined),
                      title: Text(l10n.backupRestore),
                      subtitle: Text(l10n.comingSoon(l10n.backupRestore)),
                    )
                  else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.apps_outlined),
                      title: const Text('MindSpace'),
                      subtitle: Text(l10n.settingsSubtitle),
                    ),
                  SizedBox(height: AppSizes.md.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        SizedBox(width: AppSizes.sm.w),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
