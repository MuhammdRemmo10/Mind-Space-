import 'package:flutter/material.dart';

enum AppButtonStyle { primary, secondary, tonal, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return switch (style) {
      AppButtonStyle.primary => FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      AppButtonStyle.secondary => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      AppButtonStyle.tonal => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      AppButtonStyle.danger => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        child: child,
      ),
    };
  }
}
