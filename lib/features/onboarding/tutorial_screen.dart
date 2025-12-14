import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/gradient_button.dart';

/// Tutorial screen for first-time users - 5 step onboarding
class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({super.key, required this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      emoji: '👆',
      title: 'Tap to Mine',
      description:
          'Tap the mining button to earn coins. Each tap gives you coins based on your tap power!',
      highlight: 'Tap Power = Coins per tap',
      color: AppColors.primary,
    ),
    _TutorialStep(
      emoji: '💯',
      title: 'Reach 100 Taps',
      description:
          'Every 100 taps, you\'ll unlock the ability to claim your earned coins.',
      highlight: '100 taps = 1 claim opportunity',
      color: AppColors.secondary,
    ),
    _TutorialStep(
      emoji: '🎬',
      title: 'Watch Ad to Claim',
      description:
          'Watch a short video ad to claim your coins and add them to your wallet balance.',
      highlight: 'No ad = No claim (coins stay pending)',
      color: AppColors.success,
    ),
    _TutorialStep(
      emoji: '⬆️',
      title: 'Buy Upgrades',
      description:
          'Spend your coins on upgrades to increase tap power and passive mining rate!',
      highlight: 'More upgrades = Faster earnings',
      color: AppColors.coinGold,
    ),
    _TutorialStep(
      emoji: '😴',
      title: 'Passive Mining',
      description:
          'Earn coins even while you\'re away! Come back to claim up to 6 hours of passive earnings.',
      highlight: 'Upgrade passive rate for more offline coins!',
      color: AppColors.info,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.5,
            colors: [
              _steps[_currentStep].color.withValues(alpha: 0.15),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentStep = index);
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _TutorialStepWidget(
                      step: _steps[index],
                      stepNumber: index + 1,
                      totalSteps: _steps.length,
                    );
                  },
                ),
              ),

              // Progress indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 32 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isActive
                            ? _steps[_currentStep].color
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _steps[_currentStep].color.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),

              // Next/Complete button
              Padding(
                padding: const EdgeInsets.all(24),
                child: GradientButton(
                  text: _currentStep == _steps.length - 1
                      ? 'START MINING! +5,000 COINS'
                      : 'NEXT',
                  width: double.infinity,
                  gradientColors: _currentStep == _steps.length - 1
                      ? AppColors.successGradient
                      : [
                          _steps[_currentStep].color,
                          _steps[_currentStep].color.withValues(alpha: 0.8),
                        ],
                  icon: _currentStep == _steps.length - 1
                      ? Icons.rocket_launch
                      : Icons.arrow_forward,
                  onPressed: _nextStep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String emoji;
  final String title;
  final String description;
  final String highlight;
  final Color color;

  _TutorialStep({
    required this.emoji,
    required this.title,
    required this.description,
    required this.highlight,
    required this.color,
  });
}

class _TutorialStepWidget extends StatelessWidget {
  final _TutorialStep step;
  final int stepNumber;
  final int totalSteps;

  const _TutorialStepWidget({
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: step.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Step $stepNumber of $totalSteps',
              style: AppTextStyles.labelMedium.copyWith(color: step.color),
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          // Emoji icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  step.color.withValues(alpha: 0.2),
                  step.color.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: step.color.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(step.emoji, style: const TextStyle(fontSize: 64)),
            ),
          ).animate().scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 500.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 48),

          // Title
          Text(
                step.title,
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 24),

          // Highlight box
          Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: step.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb, color: step.color, size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        step.highlight,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: step.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        ],
      ),
    );
  }
}
