import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exam_result.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// Added for debugPrint

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6478870325296677/5261843846'
          : 'ca-app-pub-6478870325296677/9874888572',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed to load: $error'); // ✨ Changed to debugPrint
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6478870325296677/5712282287'
          : 'ca-app-pub-6478870325296677/8163339350',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.show();
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error'); // ✨ Changed to debugPrint
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam History'),
      ),
      // ⬇️ Wrap the body Column in a SafeArea, only applying bottom padding
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<ExamResult>('exam_results').listenable(),
                builder: (context, Box<ExamResult> box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text('No exam history yet.'),
                    );
                  }

                  final results = box.values.toList().reversed.toList(); // latest first

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      final minutes = result.timeTakenSeconds ~/ 60;
                      final seconds = result.timeTakenSeconds % 60;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Score: ${result.score} / ${result.totalQuestions}'),
                          subtitle: Text(
                            'Time Taken: $minutes min $seconds sec\nDate: ${result.date.toLocal().toString().split('.').first}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_bannerAd != null)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}