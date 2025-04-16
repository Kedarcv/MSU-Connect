import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class AppAnimations {
  static const defaultDuration = Duration(milliseconds: 300);
  static const longDuration = Duration(milliseconds: 500);

  // Fade in and slide up animation effects
  static List<Effect> get fadeInSlide => [
        FadeEffect(duration: defaultDuration),
        SlideEffect(begin: const Offset(0, 0.2), duration: defaultDuration),
      ];

  // Scale and fade animation for cards
  static List<Effect> get cardScale => [
        ScaleEffect(begin: const Offset(0.95, 0.95), duration: defaultDuration),
        FadeEffect(duration: defaultDuration),
      ];

  // Loading animations
  static Widget loadingDots(BuildContext context, {double size = 40}) {
    return LoadingAnimationWidget.dotsTriangle(
      color: AppTheme.msuMaroon,
      size: size,
    );
  }

  static Widget loadingSpinner(BuildContext context, {double size = 40}) {
    return LoadingAnimationWidget.staggeredDotsWave(
      color: AppTheme.msuMaroon,
      size: size,
    );
  }

  // Shimmer loading effect
  static Widget shimmerLoading(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: const Duration(seconds: 2));
  }

  // Hero tag generator for consistent hero animations
  static String heroTag(String id, String type) => '${type}_$id';
}