import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum CustomAppBarVariant { transparent, solid, minimal }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.solid,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color resolvedBg;
    Color resolvedFg;

    switch (variant) {
      case CustomAppBarVariant.transparent:
        resolvedBg = Colors.transparent;
        resolvedFg =
            foregroundColor ??
            (isDark ? AppTheme.onSurfaceDark : AppTheme.onBackgroundLight);
        break;
      case CustomAppBarVariant.minimal:
        resolvedBg =
            backgroundColor ??
            (isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight);
        resolvedFg =
            foregroundColor ??
            (isDark ? AppTheme.onSurfaceDark : AppTheme.primaryLight);
        break;
      case CustomAppBarVariant.solid:
      default:
        resolvedBg =
            backgroundColor ??
            (isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight);
        resolvedFg =
            foregroundColor ??
            (isDark ? AppTheme.onSurfaceDark : AppTheme.onBackgroundLight);
        break;
    }

    return AppBar(
      backgroundColor: resolvedBg,
      foregroundColor: resolvedFg,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBackButton,
      leading:
          leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: resolvedFg,
                    size: 20,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                )
              : null),
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: resolvedFg,
                letterSpacing: 0.1,
              ),
            )
          : null,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: variant != CustomAppBarVariant.transparent
            ? Divider(
                height: 1,
                thickness: 0.5,
                color: isDark
                    ? AppTheme.borderDark.withValues(alpha: 0.5)
                    : AppTheme.borderLight.withValues(alpha: 0.5),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
