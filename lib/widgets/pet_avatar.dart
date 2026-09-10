import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';

class PetAvatar extends StatelessWidget {
  final String species;
  final String? avatarAsset;
  final double size;
  final bool isActive;
  final bool showBadge;
  final String? heroTag;
  final Color? backgroundColor;

  const PetAvatar({
    super.key,
    required this.species,
    this.avatarAsset,
    this.size = 56,
    this.isActive = false,
    this.showBadge = false,
    this.heroTag,
    this.backgroundColor,
  });

  IconData _getSpeciesIcon(String sp) {
    switch (sp.toLowerCase()) {
      case 'cat':
        return Icons.pets_rounded;
      case 'fish':
        return Icons.water_drop_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      case 'rabbit':
        return Icons.cruelty_free_rounded;
      case 'dog':
      default:
        return Icons.pets_rounded;
    }
  }

  Color _getSpeciesColor(String sp) {
    switch (sp.toLowerCase()) {
      case 'cat':
        return const Color(0xFF8B5CF6);
      case 'fish':
        return const Color(0xFF0284C7);
      case 'bird':
        return const Color(0xFF059669);
      case 'rabbit':
        return const Color(0xFFD97706);
      case 'dog':
      default:
        return AppColors.primaryTerracotta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final specColor = _getSpeciesColor(species);
    final bg = backgroundColor ?? specColor.withValues(alpha: 0.12);

    String? resolvedAsset;
    if (avatarAsset != null && avatarAsset!.isNotEmpty) {
      if (avatarAsset!.contains('assets/')) {
        resolvedAsset = avatarAsset;
      } else if (avatarAsset == 'dog_hero' || avatarAsset == 'dog_avatar') {
        resolvedAsset = 'assets/images/dog_avatar_bruno.jpg';
      } else if (avatarAsset == 'cat_hero' || avatarAsset == 'cat_avatar') {
        resolvedAsset = 'assets/images/cat_avatar_luna.jpg';
      } else {
        resolvedAsset = 'assets/images/$avatarAsset.jpg';
      }
    } else if (species.toLowerCase() == 'dog') {
      resolvedAsset = 'assets/images/dog_avatar_bruno.jpg';
    } else if (species.toLowerCase() == 'cat') {
      resolvedAsset = 'assets/images/cat_avatar_luna.jpg';
    }

    Widget avatarCore = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primaryTerracotta : Colors.white,
          width: isActive ? 2.5 : 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryTerracotta.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : AppShadows.softSm,
      ),
      child: ClipOval(
        child: resolvedAsset != null
            ? Image.asset(
                resolvedAsset,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    _getSpeciesIcon(species),
                    size: size * 0.48,
                    color: specColor,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  _getSpeciesIcon(species),
                  size: size * 0.48,
                  color: specColor,
                ),
              ),
      ),
    );

    if (heroTag != null) {
      avatarCore = Hero(tag: heroTag!, child: avatarCore);
    }

    if (!showBadge && !isActive) {
      return avatarCore;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarCore,
        if (isActive || showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: AppColors.pistachioSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pistachioDark.withValues(alpha: 0.2),
                    blurRadius: 4,
                  )
                ],
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
