import 'package:flutter/material.dart';
import '/views/internet_page.dart';
import '/views/intranet_page.dart';
import '/service/share_handler.dart';
import '/views/about_page.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  static final List<Widget> _widgetOptions = <Widget>[
    InternetPage(),
    IntranetPage(),
    AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    ShareHandlerService().initPlatformState(context);

    _loadAd();
  }

  void _loadAd() async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );

    if (size == null) return;

    BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/9214589741",
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          setState(() {
            _bannerAd = null;
            _isAdLoaded = false;
          });
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),

          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: '在线',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_off),
            label: '离线',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: '关于',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.secondary,
        unselectedItemColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surface,
        onTap: _onItemTapped,
      ),
    );
  }
}