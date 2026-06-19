import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'internet/backup_screen.dart';
import 'internet/dns_screen.dart';
import 'internet/image_screen.dart';
import 'internet/netspeed_screen.dart';
import 'internet/ptr_screen.dart';
import 'internet/thumbnail_screen.dart';

class InternetPage extends StatefulWidget {
  const InternetPage({super.key});

  @override
  State<InternetPage> createState() => _InternetPageState();
}

class _InternetPageState extends State<InternetPage> {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

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

  bool _shouldShowAd() {
    return Random().nextInt(5) == 0; // 1/5 概率
  }

  void _handleNavigation(VoidCallback action) {
    _pendingAction = action;

    if (_isAdReady && _interstitialAd != null && _shouldShowAd()) {
      _interstitialAd!.show();
    } else {
      _pendingAction!.call();
      _pendingAction = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('在线', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('需要联网', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 20),

              _buildFunctionItem(
                context,
                icon: Icons.image,
                title: '以图搜图',
                subtitle: '寻找图片的出处',
                onTap: () {
                  _handleNavigation(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ImageSearchScreen()));
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.search,
                title: '视频封面搜图',
                subtitle: '目前仅支持哔哩哔哩',
                onTap: () {
                  _handleNavigation(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ThumbnailSearchScreen()));
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.settings_backup_restore,
                title: '视频备份',
                subtitle: '无需登录',
                onTap: () {
                  _handleNavigation(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupScreen()));
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.speed,
                title: '网速测试',
                subtitle: '下载速度测试',
                onTap: () {
                  _handleNavigation(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SpeedTestScreen()));
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.dns,
                title: 'DNS 查询',
                subtitle: '加密DNS测试',
                onTap: () {
                  _handleNavigation(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DNSScreen()));
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.web,
                title: 'IP反查域名',
                subtitle: 'PTR查询测试',
                onTap: () {
                  _handleNavigation(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PTRScreen()));
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
      child: ListTile(leading: Icon(icon, size: 32), title: Text(title), subtitle: Text(subtitle), onTap: onTap),
    );
  }
}
