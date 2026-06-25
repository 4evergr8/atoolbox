import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/views/online/search_image.dart';
import 'package:picorigin/views/online/search_thumbnail.dart';
import 'package:picorigin/views/online/video_backup.dart';

class InternetPage extends StatefulWidget {
  const InternetPage({super.key});

  @override
  State<InternetPage> createState() => _InternetPageState();
}

class _InternetPageState extends State<InternetPage> {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  int _adStateIndex = 0; // 0=显示 1=不显示（循环）

  VoidCallback? _pendingAction;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-9247927382433166/3109732268",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isAdReady = false;

              _pendingAction?.call();
              _pendingAction = null;

              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _interstitialAd = null;
              _isAdReady = false;

              _pendingAction?.call();
              _pendingAction = null;

              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _isAdReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void _handleAdThenNavigate(VoidCallback action) {
    _adStateIndex++;

    if (_adStateIndex % 3 == 1 && _isAdReady && _interstitialAd != null) {
      _pendingAction = action;
      _interstitialAd!.show();
    } else {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.online, style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFunctionItem(
                context,
                icon: Icons.image,
                title: AppLocalizations.of(context)!.reverse,
                subtitle: AppLocalizations.of(context)!.find_sourse,
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ImageSearchScreen()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.search,
                title: AppLocalizations.of(context)!.artwork,
                subtitle: AppLocalizations.of(context)!.artwork_sourse,
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ThumbnailSearchScreen()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.settings_backup_restore,
                title: AppLocalizations.of(context)!.backup,
                subtitle: AppLocalizations.of(context)!.backup_video,
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupScreen()));
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        onTap: onTap,
      ),
    );
  }
}
