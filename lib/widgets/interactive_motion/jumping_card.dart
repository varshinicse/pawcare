import 'package:flutter/material.dart';

/// A vibrant, tactile card that bounces on tap, subtly floats in place,
/// and responds with a spring-loaded "jumping" animation on interaction.
class JumpingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableFloating;
  final double floatAmplitude;
  final double scaleOnTap;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final Color? glowColor;

  const JumpingCard({
    super.key,
    required this.child,
    this.onTap,
    this.enableFloating = true,
    this.floatAmplitude = 4.0,
    this.scaleOnTap = 0.94,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 180),
    this.glowColor,
  });

  @override
  State<JumpingCard> createState() => _JumpingCardState();
}

class _JumpingCardState extends State<JumpingCard> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _tapController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _jumpLiftAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Subtle floating breathing animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: widget.floatAmplitude,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutSine,
    ));

    if (widget.enableFloating) {
      _floatController.repeat(reverse: true);
    }

    // Spring-loaded tap & release jump animation
    _tapController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnTap,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeOutCubic,
    ));

    _jumpLiftAnimation = Tween<double>(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(16);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatController, _tapController]),
          builder: (context, child) {
            final floatOffset = widget.enableFloating ? _floatAnimation.value : 0.0;
            final jumpOffset = _jumpLiftAnimation.value;
            final hoverLift = _isHovered ? -3.0 : 0.0;
            final totalYOffset = floatOffset + jumpOffset + hoverLift;

            return Transform.translate(
              offset: Offset(0, totalYOffset),
              child: Transform.scale(
                scale: _scaleAnimation.value * (_isHovered ? 1.02 : 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: br,
                    boxShadow: widget.glowColor != null && _isHovered
                        ? [
                            BoxShadow(
                              color: widget.glowColor!.withValues(alpha: 0.28),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
