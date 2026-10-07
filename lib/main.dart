
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeekPayTask',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.hasData) return HomePage();
        return LoginPage();
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  void loginAnon(BuildContext c) async {
    await auth.signInAnonymously();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.task_alt, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text("GeekPayTask", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Watch Ads & Earn Money"),
          SizedBox(height: 40),
          ElevatedButton(onPressed: () => loginAnon(context), child: Text("START EARNING")),
        ]),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RewardedAd? _rewardedAd;
  int coins = 0;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadAd();
    getCoins();
  }

  void getCoins() {
    FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((d) {
      if (d.exists) setState(() => coins = d['coins'] ?? 0);
    });
  }

  void loadAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (e) => print(e),
      ),
    );
  }

  void showAd() {
    if (_rewardedAd == null) { loadAd(); return; }
    _rewardedAd!.show(onUserEarnedReward: (ad, reward) async {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'coins': FieldValue.increment(10),
        'lastEarn': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      loadAd();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("+10 Coins Earned!")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GeekPayTask"), actions: [
        Center(child: Padding(padding: EdgeInsets.all(12), child: Text("$coins Coins", style: TextStyle(fontWeight: FontWeight.bold)))),
      ]),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(child: ListTile(title: Text("Balance"), subtitle: Text("$coins Coins = ${coins/10} Naira"), trailing: Icon(Icons.account_balance_wallet))),
          SizedBox(height: 20),
          Text("Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Card(child: ListTile(leading: Icon(Icons.play_circle, color: Colors.red), title: Text("Watch Video Ad"), subtitle: Text("Earn 10 coins per ad"), trailing: ElevatedButton(onPressed: showAd, child: Text("Watch")))),
          Card(child: ListTile(leading: Icon(Icons.share), title: Text("Daily Check-in"), subtitle: Text("Earn 20 coins"), trailing: ElevatedButton(onPressed: () async {
            await FirebaseFirestore.instance.collection('users').doc(uid).set({'coins': FieldValue.increment(20)}, SetOptions(merge: true));
          }, child: Text("Claim")))),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.all(16)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawPage(coins: coins))),
            child: Text("WITHDRAW VIA PAYSTACK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class WithdrawPage extends StatefulWidget {
  final int coins;
  WithdrawPage({required this.coins});
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final bankController = TextEditingController();
  final accController = TextEditingController();

  void withdraw() {
    if (widget.coins < 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Minimum 500 coins (50 Naira)")));
      return;
    }
    FirebaseFirestore.instance.collection('withdrawals').add({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'coins': widget.coins,
      'bank': bankController.text,
      'account': accController.text,
      'status': 'pending',
      'time': FieldValue.serverTimestamp()
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Withdrawal requested!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Withdraw")),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        TextField(controller: bankController, decoration: InputDecoration(labelText: "Bank Name")),
        TextField(controller: accController, decoration: InputDecoration(labelText: "Account Number"), keyboardType: TextInputType.number),
        SizedBox(height: 20),
        Text("Your Coins: ${widget.coins}"),
        SizedBox(height: 20),
        ElevatedButton(onPressed: withdraw, child: Text("Request Withdrawal")),
      ])),
    );
  }
}
