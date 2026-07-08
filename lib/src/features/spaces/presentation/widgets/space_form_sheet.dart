import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/space.dart';
import '../cubit/spaces_cubit.dart';

Future<void> showSpaceFormSheet(BuildContext context, {Space? space}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: context.read<SpacesCubit>(),
      child: _SpaceFormSheet(space: space),
    ),
  );
}

class _SpaceFormSheet extends StatefulWidget {
  const _SpaceFormSheet({this.space});

  final Space? space;

  @override
  State<_SpaceFormSheet> createState() => _SpaceFormSheetState();
}

class _SpaceFormSheetState extends State<_SpaceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _color = AppColors.primary;

  @override
  void initState() {
    super.initState();
    final space = widget.space;
    if (space != null) {
      _nameController.text = space.name;
      _descriptionController.text = space.description ?? '';
      _color = space.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final description = _descriptionController.text.trim();
    final cubit = context.read<SpacesCubit>();

    if (widget.space == null) {
      await cubit.create(
        name: _nameController.text.trim(),
        description: description.isEmpty ? null : description,
        color: _color,
      );
    } else {
      await cubit.update(
        space: widget.space!,
        name: _nameController.text.trim(),
        description: description.isEmpty ? null : description,
        color: _color,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = const [
      AppColors.primary,
      AppColors.mint,
      AppColors.amber,
      AppColors.coral,
      AppColors.blue,
      AppColors.slate,
    ];

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.space == null ? l10n.createSpace : l10n.editSpace,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.spaceName,
                  prefixIcon: const Icon(Icons.space_dashboard_outlined),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? l10n.spaceNameRequired
                    : null,
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
              SizedBox(height: AppSizes.md.h),
              Text(
                l10n.color,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSizes.xs.h),
              Wrap(
                spacing: AppSizes.sm.w,
                runSpacing: AppSizes.sm.h,
                children: colors
                    .map(
                      (color) => InkWell(
                        borderRadius: BorderRadius.circular(20.r),
                        onTap: () => setState(() => _color = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == color
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: _color == color
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppSizes.lg.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: widget.space == null ? l10n.createSpace : l10n.save,
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
