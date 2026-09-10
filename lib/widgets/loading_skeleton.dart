import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';

/// Shimmer-animated loading placeholder container
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.md,
    this.shape,
  });

  const ShimmerBox.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 999,
        shape = const CircleBorder();

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.shape == null ? BorderRadius.circular(widget.borderRadius) : null,
            shape: widget.shape is CircleBorder ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer skeleton for Pet Card
class PetCardSkeleton extends StatelessWidget {
  const PetCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        children: [
          const ShimmerBox.circle(size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 120, height: 18, borderRadius: AppRadius.sm),
                const SizedBox(height: 8),
                const ShimmerBox(width: 180, height: 12, borderRadius: AppRadius.xs),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    ShimmerBox(width: 50, height: 20, borderRadius: AppRadius.xs),
                    SizedBox(width: 6),
                    ShimmerBox(width: 50, height: 20, borderRadius: AppRadius.xs),
                    SizedBox(width: 6),
                    ShimmerBox(width: 50, height: 20, borderRadius: AppRadius.xs),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for List items
class ListSkeleton extends StatelessWidget {
  final int count;

  const ListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const PetCardSkeleton(),
    );
  }
}
