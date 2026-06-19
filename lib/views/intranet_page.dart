import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'internet/url_decode.dart';
import 'intranet/avbv.dart';
import 'intranet/base64.dart';
import 'intranet/beast.dart';
import 'intranet/garbled_screen.dart';
import 'intranet/ocr_screen.dart';
import 'intranet/qrcode.dart';

class IntranetPage extends StatefulWidget {
  const IntranetPage({super.key});

  @override
  State<IntranetPage> createState() => _IntranetPageState();
}

class _IntranetPageState extends State<IntranetPage> {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  int _adStateIndex = 0;
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

    if (_adStateIndex % 3 == 0 && _isAdReady && _interstitialAd != null) {
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
        title: Text('离线', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('无需联网', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 20),

              _buildFunctionItem(
                context,
                icon: Icons.import_export,
                title: 'URL解码',
                subtitle: 'URL解码与编辑',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const URLDecode()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.lock_open,
                title: 'Base64解码',
                subtitle: 'Base64编码与解码',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EncodeDecode()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.lock_open,
                title: '兽音译者',
                subtitle: '兽音译者编码与解码',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BeastEncodeDecode()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.qr_code,
                title: '图片扫码',
                subtitle: '识别图片中的条码和二维码，支持识别多个',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const QRCodeScan()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.transform,
                title: '乱码恢复',
                subtitle: '尝试将乱码恢复成人类语言',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GarbledRecovery()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.rotate_90_degrees_ccw,
                title: 'AVBV互转',
                subtitle: 'AV号和BV号转换',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AVBV()));
                  });
                },
              ),

              SizedBox(height: 16),

              _buildFunctionItem(
                context,
                icon: Icons.pageview,
                title: '离线OCR',
                subtitle: '从图片中提取文字',
                onTap: () {
                  _handleAdThenNavigate(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const OfflineOCRScreen()));
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
