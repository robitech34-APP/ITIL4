import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../models/question_model.dart';
import '../models/exam_result.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ResultScreen extends StatefulWidget {
  final List<Question> questions;
  final List<int?> userAnswers;
  final Duration timeTaken;

  const ResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.timeTaken,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    _saveResult();

    // Load banner ad
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
          debugPrint('Banner failed to load: $error');
        },
      ),
    )..load();

    // Load interstitial ad
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6478870325296677/5712282287'
          : 'ca-app-pub-6478870325296677/8163339350',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
        },
      ),
    );
  }

  // -------------------------
  // SAVE EXAM RESULT TO HIVE
  // -------------------------
  void _saveResult() async {
    if (!mounted) return;

    int correctCount = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (widget.userAnswers[i] == widget.questions[i].correctIndex) correctCount++;
    }

    final box = Hive.box<ExamResult>('exam_results');
    final result = ExamResult(
      score: correctCount,
      totalQuestions: widget.questions.length,
      timeTakenSeconds: widget.timeTaken.inSeconds,
      date: DateTime.now(),
    );

    await box.add(result);
    debugPrint('Exam result saved to Hive.');
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // Signature matches PopInvokedWithResultCallback<Object?>
  void _handlePopInvoked(bool didPop, Object? result) {
    if (didPop) return;

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (mounted) Navigator.pop(context);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if (mounted) Navigator.pop(context);
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (widget.userAnswers[i] == widget.questions[i].correctIndex) correctCount++;
    }

    return PopScope(
      canPop: false,
      // ✨ FIX: Changed deprecated 'onPopInvoked' to 'onPopInvokedWithResult'
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Result')),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Score: $correctCount / ${widget.questions.length}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time Taken: ${widget.timeTaken.inMinutes} min ${widget.timeTaken.inSeconds % 60} sec',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(widget.questions.length, (i) {
                      bool correct = widget.userAnswers[i] == widget.questions[i].correctIndex;
                      return Card(
                        color: correct ? Colors.green[100] : Colors.red[100],
                        child: ListTile(
                          title: Text(widget.questions[i].question),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Answer: ${widget.userAnswers[i] != null ? widget.questions[i].options[widget.userAnswers[i]!] : 'Not Answered'}',
                              ),
                              if (!correct)
                                Text(
                                  'Correct Answer: ${widget.questions[i].options[widget.questions[i].correctIndex]}',
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
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
      ),
    );
  }
}