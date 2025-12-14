import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/theme/app_colors.dart';

/// A full-screen blocking overlay to prevent race conditions during critical async actions.
/// Usage: Stack(children: [child, if (isLoading) const LoadingOverlay()])
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(179), // Semi-transparent blocking layer
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium Loader
            SpinKitDoubleBounce(color: AppColors.primary, size: 60.0),
            const SizedBox(height: 24),
            if (message != null)
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }
}
