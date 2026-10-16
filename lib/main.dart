import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ===== TEST KEYS =====
class AppKeys {
  // AdMob TEST IDS - replace with your real IDs after testing
  static const String bannerId = 'ca-app-pub-3940256099942544/6300978111'; // Test Banner
  static const String interstitialId = 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial
  static const String rewardedId = 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded
  // Paystack TEST PUBLIC KEY
  static const String paystackPublicKey = 'pk_test_3c8302e2e2f9b3c2e1e3e2e1e3e2e1e3e2e1e3';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(const GeekPayTaskApp());
}

class GeekPayTaskApp extends StatelessWidget {
  const GeekPayTaskApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

// SPLASH - Like first image you sent
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthGate()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF3DFF00), Color(0xFF00BFFF)]).createShader(bounds),
                    child: const Text('GK', style: TextStyle(fontSize: 90, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white, letterSpacing: -5)),
                  ),
                ),
                const Icon(Icons.workspace_premium, size: 40, color: Color(0xFF3DFF00)),
              ],
            ),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF3DFF00), Color(0xFF00BFFF)]).createShader(b),
              child: const Text('Geek', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white)),
            ),
            const Text('PayTask', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFF3DFF00)),
          ],
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
        if (snap.hasData) return const MainApp();
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  Future<void> auth(bool isLogin) async {
    setState(() => loading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: password.text.trim());
      } else {
        var cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({'email': email.text.trim(), 'balance': 0, 'createdAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => loading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('GK Geek PayTask', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3DFF00))),
          const SizedBox(height: 20),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          if (loading) const CircularProgressIndicator() else Column(children: [
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3DFF00), minimumSize: const Size(double.infinity, 50)), onPressed: () => auth(true), child: const Text('Login', style: TextStyle(color: Colors.black))),
            TextButton(onPressed: () => auth(false), child: const Text('Create Account', style: TextStyle(color: Color(0xFF00BFFF)))),
          ]),
          const SizedBox(height: 10),
          Text('Paystack Test Key: ${AppKeys.paystackPublicKey.substring(0,15)}...', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  int balance = 0;

  @override
  void initState() {
    super.initState();
    loadAds();
    getBalance();
  }

  void getBalance() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid!= null) {
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((doc) {
        if (doc.exists) setState(() => balance = (doc.data()?['balance']?? 0));
      });
    }
  }

  void loadAds() {
    bannerAd = BannerAd(size: AdSize.banner, adUnitId: AppKeys.bannerId, listener: BannerAdListener(onAdFailedToLoad: (ad, err) => ad.dispose()), request: const AdRequest())..load();
    InterstitialAd.load(adUnitId: AppKeys.interstitialId, request: const AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => interstitialAd = ad, onAdFailedToLoad: (e) => interstitialAd = null));
    RewardedAd.load(adUnitId: AppKeys.rewardedId, request: const AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) => rewardedAd = ad, onAdFailedToLoad: (e) => rewardedAd = null));
  }

  void earn(int amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'balance': FieldValue.increment(amount)});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₦$amount Added! New Balance: ₦${balance+amount}')));
  }

  void showRewarded() {
    if (rewardedAd!= null) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) { ad.dispose(); RewardedAd.load(adUnitId: AppKeys.rewardedId, request: const AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (a) => rewardedAd = a, onAdFailedToLoad: (e) => null)); });
      rewardedAd!.show(onUserEarnedReward: (ad, reward) => earn(20));
    } else {
      earn(20); // fallback for test
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (bannerAd!= null) SizedBox(height: bannerAd!.size.height.toDouble(), child: AdWidget(ad: bannerAd!)),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem(Icons.home, 'Home', 0),
            _navItem(Icons.account_balance_wallet, 'Recharge', 1),
            _navItem(Icons.add_circle, 'Post', 2, isCenter: true),
            _navItem(Icons.call, 'Call', 3),
            _navItem(Icons.attach_money, 'More Money', 4),
            _navItem(Icons.emoji_events, 'Football', 5),
          ]),
        ),
      ]),
      body: _selectedIndex == 0? TikTokFeedPage(balance: balance, onEarn: showRewarded) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(['Home','Recharge','Post','Call','More Money','Football'][_selectedIndex], style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 10),
        Text('Balance: ₦$balance', style: const TextStyle(color: Color(0xFF3DFF00), fontSize: 20)),
        const SizedBox(height: 10),
        Text('Paystack Key: TEST MODE\n${AppKeys.paystackPublicKey}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ])),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {bool isCenter = false}) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: EdgeInsets.all(isCenter? 8 : 0), decoration: isCenter? BoxDecoration(color: isActive? const Color(0xFF3DFF00) : Colors.white, borderRadius: BorderRadius.circular(8)) : null, child: Icon(icon, color: isActive &&!isCenter? const Color(0xFF3DFF00) : isCenter? Colors.black : Colors.white, size: isCenter? 28 : 24)),
        Text(label, style: TextStyle(fontSize: 10, color: isActive? const Color(0xFF3DFF00) : Colors.white)),
        if (isActive) Container(margin: const EdgeInsets.only(top: 2), height: 2, width: 20, color: const Color(0xFF3DFF00)),
      ]),
    );
  }
}

class TikTokFeedPage extends StatelessWidget {
  final int balance;
  final VoidCallback onEarn;
  const TikTokFeedPage({super.key, required this.balance, required this.onEarn});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            const Text('GK', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3DFF00), fontSize: 20)),
            const SizedBox(width: 4),
            const Text('Geek PayTask', style: TextStyle(color: Color(0xFF00BFFF), fontWeight: FontWeight.bold)),
            const Spacer(),
            const Text('Following', style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 16),
            Column(children: [const Text('For You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Container(height: 2, width: 40, color: Color(0xFF00BFFF))]),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF3DFF00), borderRadius: BorderRadius.circular(12)), child: Text('₦$balance', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(width: 8),
            const Icon(Icons.search, color: Colors.white),
          ]),
        ),
        Expanded(
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Stack(children: [
                Container(color: Colors.grey[900], child: Center(child: Image.network('https://i.pravatar.cc/500?img=${index+15}', fit: BoxFit.cover, width: double.infinity, height: double.infinity))),
                Positioned(right: 10, bottom: 100, child: Column(children: [
                  _action(Icons.person_add_alt_1, 'Follow', isGreen: true),
                  const SizedBox(height: 18),
                  _action(Icons.favorite, '12.8K', isRed: true, onTap: onEarn),
                  const SizedBox(height: 18),
                  _action(Icons.chat_bubble, '1.2K'),
                  const SizedBox(height: 18),
                  _action(Icons.share, 'Share'),
                  const SizedBox(height: 18),
                  GestureDetector(onTap: onEarn, child: Column(children: [Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFF3DFF00), shape: BoxShape.circle), child: const Icon(Icons.monetization_on, color: Colors.black, size: 28)), const Text('Earn', style: TextStyle(color: Color(0xFF3DFF00), fontSize: 12, fontWeight: FontWeight.bold))])),
                ])),
                Positioned(left: 12, bottom: 10, right: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('@sadiya_queen ${index+1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Life is better when you smile 💚 Watch ads to earn!', style: TextStyle(color: Colors.white)),
                  const Text('#GK #GoodVibes #Together #PayTask', style: TextStyle(color: Color(0xFF3DFF00))),
                  const SizedBox(height: 4),
                  const Row(children: [Icon(Icons.music_note, size: 14, color: Colors.white), SizedBox(width: 4), Text('Original Sound - GK', style: TextStyle(color: Colors.white, fontSize: 12))]),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3DFF00)), onPressed: onEarn, icon: const Icon(Icons.play_arrow, color: Colors.black), label: const Text('Watch Ad = ₦20', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                ])),
              ]);
            },
          ),
        ),
      ]),
    );
  }
  static Widget _action(IconData icon, String label, {bool isRed = false, bool isGreen = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isGreen? Colors.green : Colors.black45, shape: BoxShape.circle), child: Icon(icon, color: isRed? Colors.red : Colors.white, size: 28)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
