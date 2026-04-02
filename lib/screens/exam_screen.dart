import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io'; // Needed for Platform check
import '../models/question_model.dart';
import '../data/questions_data.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late List<Question> randomQuestions;
  List<int?> userAnswers = List.filled(40, null);
  int currentIndex = 0;
  int remainingSeconds = 60 * 60; // 60 minutes
  Timer? timer;

  // Ads
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    randomQuestions = getRandomQuestions(40);
    startTimer();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  List<Question> getRandomQuestions(int count) {
    final shuffled = List<Question>.from(allQuestions)..shuffle();
    return shuffled.take(count).toList();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          timer?.cancel();
          submitExam();
        }
      });
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6478870325296677/5261843846' // Android real ID
          : 'ca-app-pub-6478870325296677/9874888572', // iOS real ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner failed to load: $error');
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6478870325296677/5712282287' // Android real ID
          : 'ca-app-pub-6478870325296677/5005705274', // iOS real ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial failed to load: $error');
        },
      ),
    );
  }

  void submitExam() {
    timer?.cancel();
    Duration timeTaken = Duration(seconds: 60 * 60 - remainingSeconds);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          questions: randomQuestions,
          userAnswers: userAnswers,
          timeTaken: timeTaken,
        ),
      ),
    ).then((_) {
      // Show interstitial ad when user comes back from ResultScreen
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // preload next ad
            }, onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            });
        _interstitialAd!.show();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Question q = randomQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1}/40'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / 40,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    color: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Question ${currentIndex + 1} of 40',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    q.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...List.generate(q.options.length, (i) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: userAnswers[currentIndex] == i ? Colors.red[50] : Colors.white,
                      child: ListTile(
                        title: Text(q.options[i], style: const TextStyle(fontSize: 16)),
                        leading: Radio<int>(
                          value: i,
                          groupValue: userAnswers[currentIndex],
                          onChanged: (val) {
                            setState(() {
                              userAnswers[currentIndex] = val;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            userAnswers[currentIndex] = i;
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentIndex > 0)
                        ElevatedButton.icon(
                          onPressed: () => setState(() => currentIndex--),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                        ),
                      if (currentIndex < 39)
                        ElevatedButton.icon(
                          onPressed: () => setState(() => currentIndex++),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        ),
                      if (currentIndex == 39)
                        ElevatedButton.icon(
                          onPressed: submitExam,
                          icon: const Icon(Icons.check),
                          label: const Text('Submit Exam'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
