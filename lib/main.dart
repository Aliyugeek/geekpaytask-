import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const Color neonGreen = Color(0xFF39FF55);
const Color neonBlue = Color(0xFF10C9FF);
const Color darkBg = Color(0xFF050709);

// Official Google Android TEST banner ID.
const String admobBannerTestId =
    'ca-app-pub-3940256099942544/6300978111';

// Insert your own Paystack PUBLIC TEST key here.
// This placeholder is not a working key.
const String paystackPublicTestKey = 'pk_test_REPLACE_WITH_YOUR_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await MobileAds.instance.initialize();

  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Authentication setup: $e');
  }

  runApp(const GeekPayTaskApp());
}

class GeekPayTaskApp extends StatelessWidget {
  const GeekPayTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geek Paytask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: neonGreen,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GeekHome(),
    );
  }
}

class GeekHome extends StatefulWidget {
  const GeekHome({super.key});

  @override
  State<GeekHome> createState() => _GeekHomeState();
}

class _GeekHomeState extends State<GeekHome> {
  int selectedIndex = 0;
  double testBalance = 0;

  final List<String> pageNames = [
    'Home',
    'Geek',
    'Recharge',
    'More Money',
    'Football',
    'GK Call',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const GeekProfilePage(),
      RechargePage(
        balance: testBalance,
        onTestRecharge: () {
          setState(() => testBalance += 100);
        },
      ),
      const MoreMoneyPage(),
      const FootballPage(),
      GKCallPage(balance: testBalance),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBg,
        title: const Text(
          'GEEK PAYTASK',
          style: TextStyle(
            color: neonGreen,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: neonBlue),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF101820),
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Geek Profile'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => selectedIndex = 1);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: const Text('Wallet and withdrawals'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => selectedIndex = 2);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101820),
        indicatorColor: neonGreen.withValues(alpha: 0.15),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Geek',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_card),
            label: 'Recharge',
          ),
          NavigationDestination(
            icon: Icon(Icons.monetization_on_outlined),
            label: 'More Money',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: 'Football',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            label: 'GK Call',
          ),
        ],
      ),
    );
  }
}class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'For You     Following',
          style: TextStyle(
            fontSize: 20,
            color: neonGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 350,
          decoration: BoxDecoration(
            color: const Color(0xFF111820),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: neonBlue),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.video_library, size: 65, color: neonGreen),
                SizedBox(height: 12),
                Text('Geek Paytask Video Feed'),
                SizedBox(height: 8),
                Text('Videos will appear here when connected.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.favorite_border, color: neonGreen),
            Icon(Icons.comment_outlined, color: neonBlue),
            Icon(Icons.share_outlined, color: neonGreen),
            Icon(Icons.person_add_alt, color: neonBlue),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Post a video',
          textAlign: TextAlign.center,
          style: TextStyle(color: neonGreen),
        ),
      ],
    );
  }
}

class GeekProfilePage extends StatelessWidget {
  const GeekProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: neonGreen,
            child: Icon(Icons.person, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 16),
          const Text(
            'Geek Profile',
            style: TextStyle(fontSize: 24, color: neonGreen),
          ),
          const SizedBox(height: 8),
          Text('User ID: ${user?.uid ?? "Not signed in"}'),
          const SizedBox(height: 20),
          const Text('Videos • Followers • Following'),
        ],
      ),
    );
  }
}

class RechargePage extends StatelessWidget {
  final double balance;
  final VoidCallback onTestRecharge;

  const RechargePage({
    super.key,
    required this.balance,
    required this.onTestRecharge,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.account_balance_wallet,
            size: 70, color: neonGreen),
        const SizedBox(height: 20),
        const Text(
          'Recharge Wallet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, color: neonGreen),
        ),
        const SizedBox(height: 12),
        Text(
          'Test balance: ₦${balance.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 24),
        const Text(
          'TEST MODE ONLY\n'
          'This button simulates a recharge. It does not charge '
          'your bank account or make a real Paystack payment.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orangeAccent),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onTestRecharge,
          child: const Text('Simulate ₦100 Test Recharge'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Paystack payment setup',
          style: TextStyle(color: neonBlue, fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          'The Paystack public test key is configured in Part 1. '
          'Real checkout requires a secure backend to initialize '
          'and verify payments before adding wallet funds.',
        ),
      ],
    );
  }
}

class MoreMoneyPage extends StatefulWidget {
  const MoreMoneyPage({super.key});

  @override
  State<MoreMoneyPage> createState() => _MoreMoneyPageState();
}

class _MoreMoneyPageState extends State<MoreMoneyPage> {
  BannerAd? bannerAd;
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();

    bannerAd = BannerAd(
      adUnitId: admobBannerTestId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => adLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdMob error: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.monetization_on,
            size: 70, color: neonGreen),
        const SizedBox(height: 16),
        const Text(
          'More Money',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, color: neonGreen),
        ),
        const SizedBox(height: 12),
        const Text(
          'AdMob test advertisement',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: adLoaded && bannerAd != null
              ? SizedBox(
                  width: bannerAd!.size.width.toDouble(),
                  height: bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd!),
                )
              : const SizedBox(
                  height: 50,
                  child: Center(child: Text('Loading test ad...')),
                ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Rewards will require a verified reward-ad system '
          'and secure balance updates before launch.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}class FootballPage extends StatelessWidget {
  const FootballPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        Icon(Icons.sports_soccer, size: 75, color: neonGreen),
        SizedBox(height: 20),
        Text(
          'Geek Football',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, color: neonGreen),
        ),
        SizedBox(height: 16),
        Text(
          'Search football channels and watch football videos.',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          'Football streaming and channel links need to be connected '
          'to authorized video sources.',
          textAlign: TextAlign.center,
          style: TextStyle(color: neonBlue),
        ),
      ],
    );
  }
}

class GKCallPage extends StatelessWidget {
  final double balance;

  const GKCallPage({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.video_call, size: 75, color: neonGreen),
        const SizedBox(height: 16),
        const Text(
          'GK Call',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, color: neonGreen),
        ),
        const SizedBox(height: 20),
        Text(
          'Available test balance: ₦${balance.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        const TextField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Enter Geek ID or phone number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_search),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Voice and video calling will require a connected calling '
          'service and a verified wallet-payment system.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}class CityWarsGame extends StatefulWidget {
  const CityWarsGame({super.key});

  @override
  State<CityWarsGame> createState() => _CityWarsGameState();
}

class _CityWarsGameState extends State<CityWarsGame> {
  int score = 0;
  int energy = 10;
  bool gameOver = false;

  void tapCity() {
    if (gameOver) return;

    setState(() {
      score += 10;
      energy--;

      if (energy <= 0) {
        gameOver = true;
      }
    });
  }

  void restartGame() {
    setState(() {
      score = 0;
      energy = 10;
      gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050709),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050709),
        title: const Text(
          'CITY WARS',
          style: TextStyle(
            color: Color(0xFF39FF55),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'CAPTURE THE CITY',
              style: TextStyle(
                color: Color(0xFF10C9FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $score',
              style: const TextStyle(
                color: Color(0xFF39FF55),
                fontSize: 28,
              ),
            ),
            Text(
              'Energy: $energy',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: gameOver
                    ? const Text(
                        'GAME OVER!',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : GestureDetector(
                        onTap: tapCity,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: const Color(0xFF101820),
                            border: Border.all(
                              color: const Color(0xFF39FF55),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x5539FF55),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_city,
                                color: Color(0xFF39FF55),
                                size: 85,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'TAP TO CAPTURE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            if (gameOver) ...[
              Text(
                'Final score: $score',
                style: const TextStyle(
                  color: Color(0xFF10C9FF),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: restartGame,
                child: const Text('PLAY AGAIN'),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'CITY WARS LEADERBOARD',
              style: TextStyle(
                color: Color(0xFF10C9FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.amber),
              title: Text(
                'Leaderboard',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Online rankings not connected yet',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
