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

  int _adStateIndex = 0; // 0=显示 1=不显示（循环）

  VoidCallback? _pendingAction;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "_adUnitId",
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

    // 0 = 显示广告
    if (_adStateIndex % 2 == 0 && _isAdReady && _interstitialAd != null) {
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
        title: Text('在线', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('需要联网', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 20),

              _buildFunctionItem(
                context,
                icon: Icons.image,
                title: '以图搜图',
                subtitle: '寻找图片的出处',
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
                title: '视频封面搜图',
                subtitle: '寻找视频封面的出处，目前仅支持哔哩哔哩',
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
                title: '视频备份',
                subtitle: '哔哩哔哩视频备份，无需登录',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupScreen()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.speed,
                title: '网速测试',
                subtitle: '网络下载速度测试',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SpeedTestScreen()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.dns,
                title: 'DNS 查询',
                subtitle: '加密DNS查询测试',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DNSScreen()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.web,
                title: 'IP反查域名',
                subtitle: 'DoHPTR查询测试',
                onTap: () {
                  _handleAdThenNavigate(() {
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
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        onTap: onTap,
      ),
    );
  }
}
