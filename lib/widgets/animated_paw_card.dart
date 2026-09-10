import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';

/// Interactive bouncy card that springs on tap, floats on hover, with smooth shadow transitions
class AnimatedPawCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? shadows;
  final bool isSelected;
  final double scaleDown;

  const AnimatedPawCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.border,
    this.shadows,
    this.isSelected = false,
    this.scaleDown = 0.96,
  });

  @override
  State<AnimatedPawCard> createState() => _AnimatedPawCardState();
}

class _AnimatedPawCardState extends State<AnimatedPawCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _liftAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _liftAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppRadius.xl;
    final effectiveBorderRadius = BorderRadius.circular(radius);

    final defaultBorder = widget.isSelected
        ? Border.all(color: AppColors.primaryTerracotta, width: 2)
        : Border.all(color: AppColors.dividerColor, width: 1);

    final defaultShadows = widget.isSelected
        ? AppShadows.primaryGlow
        : (_isHovered
            ? [
                BoxShadow(
                  color: AppColors.canopy.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primaryTerracotta.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : AppShadows.softSm);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final hoverY = _isHovered ? -3.0 : 0.0;
        final totalY = _liftAnimation.value + hoverY;

        return Transform.translate(
          offset: Offset(0, totalY),
          child: Transform.scale(
            scale: _scaleAnimation.value * (_isHovered ? 1.015 : 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: widget.margin,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: effectiveBorderRadius,
              splashColor: AppColors.primaryTerracotta.withValues(alpha: 0.08),
              highlightColor: AppColors.primaryTerracotta.withValues(alpha: 0.04),
              child: Ink(
                padding: widget.padding ?? AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: widget.gradient == null ? (widget.backgroundColor ?? AppColors.cardBg) : null,
                  gradient: widget.gradient,
                  borderRadius: effectiveBorderRadius,
                  border: widget.border ?? defaultBorder,
                  boxShadow: widget.shadows ?? defaultShadows,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
