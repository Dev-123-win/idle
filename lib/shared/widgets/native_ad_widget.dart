import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Native ad widget for displaying in lists (F9.5)
class NativeAdWidget extends StatefulWidget {
  final double? height;

  const NativeAdWidget({super.key, this.height});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _adFailed = false;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdMobIds.nativeAdUnitId,
      factoryId: 'listTile', // Native ad factory registered in Android
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isAdLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _adFailed = true;
              _errorMessage = error.message;
            });
          }
        },
        onAdClicked: (ad) {
          debugPrint('Native ad clicked');
        },
        onAdImpression: (ad) {
          debugPrint('Native ad impression');
        },
      ),
      request: const AdRequest(),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if ad failed
    // Show error state for debugging
    if (_adFailed) {
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.red.withOpacity(0.1),
        child: Center(
          child: Text(
            'Ad Failed: $_errorMessage',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: widget.height ?? 280,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: _isAdLoaded && _nativeAd != null
          ? Stack(
              children: [
                AdWidget(ad: _nativeAd!),
                // Sponsored badge
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Ad',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _buildLoadingPlaceholder(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Media placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to insert native ads into lists
class NativeAdListHelper {
  /// Insert native ads into a list at specified intervals
  /// Returns a new list with ads inserted
  static List<dynamic> insertAdsInList({
    required List<dynamic> items,
    required int interval,
  }) {
    if (interval <= 0 || items.isEmpty) return items;

    final result = <dynamic>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);

      // Insert ad after every [interval] items (not at the end)
      if ((i + 1) % interval == 0 && i < items.length - 1) {
        result.add(const _NativeAdPlaceholder());
      }
    }
    return result;
  }

  /// Check if an item is a native ad placeholder
  static bool isAdPlaceholder(dynamic item) => item is _NativeAdPlaceholder;
}

class _NativeAdPlaceholder {
  const _NativeAdPlaceholder();
}

/// Widget builder for lists with native ads
class NativeAdListView extends StatelessWidget {
  final List<dynamic> items;
  final int adInterval;
  final Widget Function(BuildContext context, dynamic item, int index)
      itemBuilder;
  final EdgeInsetsGeometry? padding;

  const NativeAdListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.adInterval = 5,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final itemsWithAds = NativeAdListHelper.insertAdsInList(
      items: items,
      interval: adInterval,
    );

    return ListView.builder(
      padding: padding,
      itemCount: itemsWithAds.length,
      itemBuilder: (context, index) {
        final item = itemsWithAds[index];

        if (NativeAdListHelper.isAdPlaceholder(item)) {
          return const NativeAdWidget();
        }

        return itemBuilder(context, item, index);
      },
    );
  }
}
