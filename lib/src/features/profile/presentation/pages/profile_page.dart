import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entity_status.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../articles/domain/entities/article.dart';
import '../../../articles/presentation/cubit/articles_cubit.dart';
import '../../../articles/presentation/cubit/articles_state.dart';
import '../../../articles/presentation/pages/articles_page.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../content_library/domain/entities/content_library_item.dart';
import '../../../content_library/presentation/pages/content_library_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProfileCubit>()..load()),
        BlocProvider(create: (_) => sl<ArticlesCubit>()..load(allSpaces: true)),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading || state is ProfileInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProfileFailure) {
                  return Center(child: Text(context.l10n.profileLoadFailed));
                }

                final user = (state as ProfileLoaded).user;

                return ListView(
                  children: [
                    _ProfileHeader(
                      user: user,
                      onPickProfilePhoto: () =>
                          _pickPhoto(context, user, isCover: false),
                      onPickCoverPhoto: () =>
                          _pickPhoto(context, user, isCover: true),
                    ),
                    SizedBox(height: AppSizes.lg.h),
                    AppCard(
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.mail_outline,
                            label: context.l10n.email,
                            value: user.email,
                          ),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: context.l10n.phone,
                            value: user.phoneNumber ?? context.l10n.notAdded,
                          ),
                          _InfoRow(
                            icon: Icons.public,
                            label: context.l10n.country,
                            value: user.country ?? context.l10n.notAdded,
                          ),
                          _InfoRow(
                            icon: Icons.notes_outlined,
                            label: context.l10n.biography,
                            value: user.biography ?? context.l10n.notAdded,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.lg.h),
                    const _ProfileArticlesSection(),
                    SizedBox(height: AppSizes.lg.h),
                    AppButton(
                      label: context.l10n.editProfile,
                      icon: Icons.edit_outlined,
                      onPressed: () => _showEditProfileSheet(context, user),
                    ),
                    SizedBox(height: AppSizes.md.h),
                    _ProfileMenu(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(
    BuildContext context,
    AuthUser user, {
    required bool isCover,
  }) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: isCover ? 1800 : 900,
    );

    if (picked == null || !context.mounted) {
      return;
    }

    await context.read<ProfileCubit>().update(
      fullName: user.fullName,
      username: user.username,
      phoneNumber: user.phoneNumber,
      country: user.country,
      biography: user.biography,
      profilePhotoPath: isCover ? null : picked.path,
      coverPhotoPath: isCover ? picked.path : null,
    );
  }

  void _showEditProfileSheet(BuildContext context, AuthUser user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileCubit>(),
        child: _EditProfileSheet(user: user),
      ),
    );
  }
}

class _ProfileArticlesSection extends StatelessWidget {
  const _ProfileArticlesSection();

  void _openArticle(BuildContext context, Article article) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, _) => BlocProvider.value(
          value: context.read<ArticlesCubit>(),
          child: ArticleDetailPage(article: article),
        ),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ArticlesCubit, ArticlesState>(
      builder: (context, state) {
        if (state is ArticlesLoading || state is ArticlesInitial) {
          return const AppCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final articles = state is ArticlesLoaded
            ? state.articles.take(4).toList()
            : <Article>[];

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: AppSizes.sm.w),
                  Expanded(
                    child: Text(
                      l10n.profileArticles,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.md.h),
              if (articles.isEmpty)
                Text(
                  l10n.noProfileArticles,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
                )
              else
                ...articles.map(
                  (article) => Padding(
                    padding: EdgeInsets.only(bottom: AppSizes.sm.h),
                    child: _ProfileArticleTile(
                      article: article,
                      onTap: () => _openArticle(context, article),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileArticleTile extends StatelessWidget {
  const _ProfileArticleTile({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDraft = article.status == EntityStatus.draft;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                child: SizedBox(
                  width: 58.w,
                  height: 58.w,
                  child:
                      article.coverImageUrl == null ||
                          article.coverImageUrl!.isEmpty
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                          ),
                          child: Icon(
                            Icons.auto_stories_outlined,
                            color: Colors.white,
                          ),
                        )
                      : Image.network(
                          article.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.auto_stories_outlined,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                ),
              ),
              SizedBox(width: AppSizes.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${isDraft ? l10n.draft : l10n.published} - ${l10n.articleReadingMinutes(article.readingTimeMinutes == 0 ? 1 : article.readingTimeMinutes)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.slate),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.onPickProfilePhoto,
    required this.onPickCoverPhoto,
  });

  final AuthUser user;
  final VoidCallback onPickProfilePhoto;
  final VoidCallback onPickCoverPhoto;

  @override
  Widget build(BuildContext context) {
    final initial = user.fullName.isNotEmpty
        ? user.fullName.characters.first.toUpperCase()
        : 'M';
    final l10n = context.l10n;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                child: SizedBox(
                  height: 148.h,
                  width: double.infinity,
                  child: user.coverPhotoUrl == null
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.secondary, AppColors.primary],
                            ),
                          ),
                        )
                      : Image.network(
                          user.coverPhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.secondary,
                                      AppColors.primary,
                                    ],
                                  ),
                                ),
                              ),
                        ),
                ),
              ),
              Positioned(
                right: 12.w,
                bottom: 12.h,
                child: _PhotoButton(
                  tooltip: l10n.changeCoverPhoto,
                  onPressed: onPickCoverPhoto,
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -38.h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 43.r,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 38.r,
                          backgroundColor: AppColors.ink,
                          backgroundImage: user.profilePhotoUrl == null
                              ? null
                              : NetworkImage(user.profilePhotoUrl!),
                          child: user.profilePhotoUrl == null
                              ? Text(
                                  initial,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: _PhotoButton(
                          tooltip: l10n.changeProfilePhoto,
                          onPressed: onPickProfilePhoto,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: AppSizes.md.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '@${user.username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.slate),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
            child: Text(
              user.biography?.isNotEmpty == true
                  ? user.biography!
                  : l10n.defaultBiography,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.slate,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({
    required this.tooltip,
    required this.onPressed,
    this.compact = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.w : 40.w;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.primary,
              size: compact ? 17.sp : 20.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: AppSizes.sm.w),
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (
        icon: Icons.star_border,
        title: l10n.favorites,
        page: const ContentLibraryPage(mode: ContentLibraryMode.favorites),
      ),
      (
        icon: Icons.archive_outlined,
        title: l10n.archive,
        page: const ContentLibraryPage(mode: ContentLibraryMode.archive),
      ),
      (
        icon: Icons.delete_outline,
        title: l10n.trash,
        page: const ContentLibraryPage(mode: ContentLibraryMode.trash),
      ),
      (
        icon: Icons.settings_outlined,
        title: l10n.settings,
        page: const SettingsPage(),
      ),
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
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => item.page)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});

  final AuthUser user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late final TextEditingController _biographyController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _usernameController = TextEditingController(text: widget.user.username);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _countryController = TextEditingController(text: widget.user.country);
    _biographyController = TextEditingController(text: widget.user.biography);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await context.read<ProfileCubit>().update(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      biography: _biographyController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      showSearch: true,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.72,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusMd.r),
        ),
        inputDecoration: InputDecoration(
          labelText: context.l10n.country,
          prefixIcon: const Icon(Icons.search),
        ),
      ),
      onSelect: (country) {
        _countryController.text = country.nameLocalized?.isNotEmpty == true
            ? country.nameLocalized!
            : country.name;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.editProfile,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: l10n.fullName),
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? l10n.fullNameMinLength
                    : null,
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: l10n.username),
                validator: (value) => (value?.trim().length ?? 0) < 3
                    ? l10n.usernameMinLength
                    : null,
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _countryController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.country,
                  suffixIcon: const Icon(Icons.keyboard_arrow_down),
                ),
                onTap: () => _showCountryPicker(context),
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _biographyController,
                decoration: InputDecoration(labelText: l10n.biography),
                minLines: 3,
                maxLines: 5,
              ),
              SizedBox(height: AppSizes.lg.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.save,
                  icon: Icons.check,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
