import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_typography.dart';

/// Primary filled action button with bounce animation, icon support, and loading state
class PrimaryPawButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const PrimaryPawButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 52,
    this.borderRadius = AppRadius.xl,
    this.padding,
  });

  @override
  State<PrimaryPawButton> createState() => _PrimaryPawButtonState();
}

class _PrimaryPawButtonState extends State<PrimaryPawButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final bgColor = widget.backgroundColor ?? AppColors.primaryTerracotta;
    final fgColor = widget.foregroundColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
            disabledForegroundColor: fgColor.withValues(alpha: 0.7),
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          onPressed: isEnabled
              ? () {
                  _controller.forward().then((_) => _controller.reverse());
                  widget.onPressed!();
                }
              : null,
          child: widget.isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: fgColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: fgColor),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: AppTypography.labelLarge.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Outlined secondary button with border styling and feedback
class SecondaryPawButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const SecondaryPawButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.borderRadius = AppRadius.xl,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.inkText;
    final bColor = borderColor ?? AppColors.dividerColor;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: bColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTypography.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular icon button with subtle background surface and ripple
class PawIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final Border? border;

  const PawIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.iconSize = 20,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? Colors.white;
    final effectiveIconColor = iconColor ?? AppColors.inkText;

    Widget btn = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: effectiveBg,
          shape: BoxShape.circle,
          border: border ?? Border.all(color: AppColors.dividerColor, width: 1),
          boxShadow: AppShadows.softSm,
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: effectiveIconColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}
