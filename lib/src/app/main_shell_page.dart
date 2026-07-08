import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/localization/l10n_extensions.dart';
import '../core/responsive/app_breakpoints.dart';
import '../core/theme/app_colors.dart';
import '../features/articles/presentation/pages/articles_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/files/presentation/pages/files_page.dart';
import '../features/notes/presentation/pages/notes_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/spaces/presentation/pages/spaces_page.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;
  int _mobileIndex = 0;
  String? _notesSpaceId;

  void _selectPage(int index) {
    setState(() {
      _mobileIndex = index;
      _selectedIndex = index == 4 ? -1 : index;
    });
  }

  void _openDestination(int index) {
    setState(() {
      _selectedIndex = index;
      _mobileIndex = index <= 3 ? index : 4;
    });
  }

  void _openNotes({String? spaceId}) {
    setState(() {
      _notesSpaceId = spaceId;
      _selectedIndex = 2;
      _mobileIndex = 2;
    });
  }

  void _openTasks() {
    setState(() {
      _selectedIndex = 3;
      _mobileIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = AppBreakpoints.isExpanded(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: isExpanded ? _buildRailLayout() : _buildBottomLayout(),
      bottomNavigationBar: isExpanded
          ? null
          : _MobileNavigationBar(
              selectedIndex: _mobileIndex,
              onDestinationSelected: _selectPage,
            ),
    );
  }

  Widget _buildBottomLayout() {
    final page = _mobileIndex == 4
        ? _selectedIndex >= 4
              ? _pageForIndex(_selectedIndex)
              : _MorePage(onOpenDestination: _openDestination)
        : _pageForIndex(_mobileIndex);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: ValueKey<String>('$_mobileIndex-$_selectedIndex-$_notesSpaceId'),
        child: page,
      ),
    );
  }

  Widget _buildRailLayout() {
    return SafeArea(
      child: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex < 0 ? 0 : _selectedIndex,
            onDestinationSelected: _openDestination,
            labelType: NavigationRailLabelType.all,
            minWidth: 92.w,
            destinations: _destinations(context)
                .map(
                  (destination) => NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey<String>('$_selectedIndex-$_notesSpaceId'),
                child: _pageForIndex(_selectedIndex < 0 ? 0 : _selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageForIndex(int index) {
    return switch (index) {
      0 => DashboardPage(
        onOpenSpaces: () => _openDestination(1),
        onOpenNotes: () => _openNotes(),
        onOpenTasks: _openTasks,
        onOpenArticles: () => _openDestination(4),
        onOpenFiles: () => _openDestination(5),
        onOpenNotesForSpace: (spaceId) => _openNotes(spaceId: spaceId),
      ),
      1 => SpacesPage(
        onOpenNotesForSpace: (spaceId) => _openNotes(spaceId: spaceId),
      ),
      2 => NotesPage(initialSpaceId: _notesSpaceId),
      3 => const TasksPage(),
      4 => const ArticlesPage(),
      5 => const FilesPage(),
      6 => const SettingsPage(),
      7 => const ProfilePage(),
      _ => const DashboardPage(),
    };
  }

  List<_ShellDestinationInfo> _destinations(BuildContext context) {
    final l10n = context.l10n;
    return [
      _ShellDestinationInfo(
        label: l10n.dashboard,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
      ),
      _ShellDestinationInfo(
        label: l10n.spaces,
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard,
      ),
      _ShellDestinationInfo(
        label: l10n.notes,
        icon: Icons.notes_outlined,
        selectedIcon: Icons.notes,
      ),
      _ShellDestinationInfo(
        label: l10n.tasks,
        icon: Icons.check_circle_outline,
        selectedIcon: Icons.check_circle,
      ),
      _ShellDestinationInfo(
        label: l10n.articles,
        icon: Icons.article_outlined,
        selectedIcon: Icons.article,
      ),
      _ShellDestinationInfo(
        label: l10n.files,
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
      ),
      _ShellDestinationInfo(
        label: l10n.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
      ),
      _ShellDestinationInfo(
        label: l10n.profile,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ];
  }
}

class _MobileNavigationBar extends StatelessWidget {
  const _MobileNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        height: 72.h,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const Icon(Icons.space_dashboard),
            label: l10n.spaces,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notes_outlined),
            selectedIcon: const Icon(Icons.notes),
            label: l10n.notes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: const Icon(Icons.check_circle),
            label: l10n.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}

class _ShellDestinationInfo {
  const _ShellDestinationInfo({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _MorePage extends StatelessWidget {
  const _MorePage({required this.onOpenDestination});

  final ValueChanged<int> onOpenDestination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final items = [
      (index: 4, title: l10n.articles, icon: Icons.article_outlined),
      (index: 5, title: l10n.files, icon: Icons.folder_outlined),
      (index: 6, title: l10n.settings, icon: Icons.settings_outlined),
      (index: 7, title: l10n.profile, icon: Icons.person_outline),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
          children: [
            Text(
              l10n.more,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.moreSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate,
              ),
            ),
            SizedBox(height: 20.h),
            ...items.map(
              (item) => Card(
                child: ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => onOpenDestination(item.index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
