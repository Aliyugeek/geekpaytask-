import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const String ADMOB_APP_ID = "ca-app-pub-7768520042626041~4128663213";
const String ADMOB_REWARDED_ID = "ca-app-pub-7768520042626041/55755253044";
const String ADMOB_INTERSTITIAL_ID = "ca-app-pub-7768520042626041/55755253044";
const int ZEGO_APP_ID = 1234567890;
const String ZEGO_APP_SIGN = "REPLACE_WITH_YOURS";
const String PAYSTACK_PUBLIC_KEY = "pk_test_REPLACE_WITH_YOURS";

String generateGeekId() {
  final random = Random();
  final num = 7900000 + random.nextInt(100000);
  return "geek$num";
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(GeekPayTaskApp());
}

class GeekPayTaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geek PayTask',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Color(0xFF00E676),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF00E676))));
        }
        if (snap.hasData) return HomeShell();
        return LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  bool loading = false;

  Future<void> signIn() async {
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      final uid = cred.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        final geekId = generateGeekId();
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': nameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'geekId': geekId,
          'photo': 'https://i.pravatar.cc/150?u=$uid',
          'balance': 100,
          'callBalance': 100,
          'created': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GK', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
            Text('Geek PayTask', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Your Name', filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Phone Number', filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: loading? null : signIn, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00E676)), child: loading? CircularProgressIndicator(color: Colors.black) : Text('Continue - Get @geek79 ID', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  @override
  _HomeShellState createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int idx = 0;
  final pages = [HomeFeed(), RechargeScreen(), PostScreen(), CallScreen(), WalletScreen(), FootballScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white10))),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomItem(Icons.home, 'Home', 0),
                _bottomItem(Icons.account_balance_wallet, 'Recharge', 1),
                _bottomItem(Icons.add_box, 'Post', 2),
                _bottomItem(Icons.call, 'Call', 3),
                _bottomItem(Icons.monetization_on, 'More Money', 4),
                _bottomItem(Icons.emoji_events, 'Football', 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomItem(IconData icon, String label, int i) {
    bool active = idx == i;
    return InkWell(
      onTap: () => setState(() => idx = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active? Color(0xFF00E676) : Colors.white54, size: active? 28 : 24),
          SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: active? Color(0xFF00E676) : Colors.white54, fontWeight: active? FontWeight.bold : FontWeight.normal)),
          if (active) Container(margin: EdgeInsets.only(top: 3), height: 3, width: 30, decoration: BoxDecoration(color: Color(0xFF00E676), borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }
}

class HomeFeed extends StatefulWidget {
  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  InterstitialAd? _interstitialAd;
  int _videosWatched = 0;
  int _adCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: ADMOB_INTERSTITIAL_ID,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (e) => _interstitialAd = null,
      ),
    );
  }

  void _showAdIfNeeded() {
    _videosWatched++;
    if (_videosWatched % 5 == 0 && _interstitialAd!= null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          _rewardUserForAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _adCount++;
      setState(() {});
    }
  }

  void _rewardUserForAd() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'balance': FieldValue.increment(2), 'adsWatched': FieldValue.increment(1)});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You earned ₦2 for watching ad! 🎉'), backgroundColor: Color(0xFF00E676)));
    } catch (e) {}
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network('https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=800', fit: BoxFit.cover),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.black87]))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(0xFF00E676), width: 2)), child: Text('GK', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00E676), fontSize: 14))),
                      SizedBox(width: 8),
                      Text('Geek', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(' PayTask', style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold, fontSize: 18)),
                      Spacer(),
                      Icon(Icons.search, color: Colors.white),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Following', style: TextStyle(color: Colors.white60, fontSize: 16)),
                    SizedBox(width: 40),
                    Column(
                      children: [
                        Text('For You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Container(height: 3, width: 35, color: Colors.white),
                        Container(height: 3, width: 35, margin: EdgeInsets.only(top: 1), color: Color(0xFF00E676)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 110,
            child: Column(
              children: [
                Column(children: [
                  Container(padding: EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(0xFF00E676), width: 2.5)), child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E676)), child: Icon(Icons.person_add, color: Colors.white, size: 22))),
                  SizedBox(height: 2),
                  Text('Follow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
                SizedBox(height: 22),
                Column(children: [Icon(Icons.favorite, color: Colors.red, size: 38), Text('12.8K', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                SizedBox(height: 18),
                Column(children: [Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.chat_bubble, color: Colors.black, size: 22)), Text('1.2K', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                SizedBox(height: 18),
                Column(children: [Icon(Icons.share, color: Colors.white, size: 34), Text('Share', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 80,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@sadiya_queen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 6),
                Text('Life is better when you smile 💚', style: TextStyle(fontSize: 14)),
                SizedBox(height: 4),
                Text('#GK #GoodVibes #Together', style: TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Row(children: [Icon(Icons.music_note, size: 16), SizedBox(width: 6), Text('Original Sound - GK', style: TextStyle(fontSize: 12))]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Post'), backgroundColor: Colors.black), body: Center(child: Text('Post Screen - Upload video')));
  }
}

class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('More Money'), backgroundColor: Colors.black), body: Center(child: Text('More Money - Watch Ad = ₦2')));
  }
}

class FootballScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Football'), backgroundColor: Colors.black), body: Center(child: Text('Football ⚽')));
  }
}

class RechargeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Recharge'), backgroundColor: Colors.black), body: Center(child: Text('Recharge - Buy Airtime/Data')));
  }
}

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final searchCtrl = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('GK Call'), backgroundColor: Colors.black),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: TextField(
                controller: searchCtrl,
                onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                decoration: InputDecoration(hintText: 'Search @geek79 ID', prefixIcon: Icon(Icons.search), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
            ),
            Expanded(child: Center(child: Text('GK Call - Balance ₦100\nSearch @geek79 to call', textAlign: TextAlign.center))),
          ],
        ),
      ),
    );
  }
}
