
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  runApp(const GeekPayTaskApp());
}

class GeekPayTaskApp extends StatelessWidget {
  const GeekPayTaskApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RootApp()));
    });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF7CFF00), Color(0xFF00A6FF)]).createShader(b), child: const Text("GK", style: TextStyle(fontSize: 110, fontWeight: FontWeight.w900, color: Colors.white))),
        const Text("Geek PayTask", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const Text("WATCH • EARN • CONNECT", style: TextStyle(fontSize: 10, letterSpacing: 3, color: Colors.white54)),
      ])),
    );
  }
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});
  @override State<RootApp> createState() => _RootAppState();
}
class _RootAppState extends State<RootApp> {
  int current = 0;
  final user = FirebaseAuth.instance.currentUser!;
  Stream<DocumentSnapshot> getStream() => FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({'balance': 250, 'callBalance': 100, 'createdAt': FieldValue.serverTimestamp()});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: getStream(),
      builder: (context, snap) {
        int bal = 250, callBal = 100;
        if (snap.hasData && snap.data!.exists) {
          var d = snap.data!.data() as Map<String, dynamic>;
          bal = d['balance']??250; callBal = d['callBalance']??100;
        }
        final tabs = [const FeedScreen(), WalletScreen(balance: bal, callBalance: callBal), const CreatePostScreen(), GKCallScreen(callBalance: callBal), RechargeScreen(balance: bal), const FootballScreen()];
        return Scaffold(
          body: tabs[current],
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 6), color: const Color(0xFF0F0F0F),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _b(Icons.home, "Home", 0, current), _b(Icons.account_balance_wallet, "Recharge", 4, current), _b(Icons.add_box, "Post", 2, current), _b(Icons.call, "Call", 3, current), _b(Icons.attach_money, "More Money", 1, current), _b(Icons.emoji_events, "Football", 5, current),
            ]),
          ),
        );
      },
    );
  }
  Widget _b(IconData ic, String t, int idx, int cur) => GestureDetector(onTap: ()=>setState(()=>current=idx), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(ic, color: cur==idx? const Color(0xFF7CFF00) : Colors.white54, size: 24), Text(t, style: TextStyle(fontSize: 8, color: cur==idx? const Color(0xFF7CFF00) : Colors.white54))]));
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Text("GK Geek PayTask", style: TextStyle(color: Color(0xFF7CFF00), fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.search)])), const Spacer(), Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("@sadiya_queen", style: TextStyle(fontWeight: FontWeight.bold)), Text("Life is better when you smile 💚")])), Column(children: [const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.favorite, color: Colors.red)), const Text("12.8K", style: TextStyle(fontSize: 10))])]))])));
}

class WalletScreen extends StatelessWidget {
  final int balance, callBalance; const WalletScreen({super.key, required this.balance, required this.callBalance});
  @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(14), children: [const Text("Wallet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 14), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7CFF00), Color(0xFF00A6FF)]), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Total Balance", style: TextStyle(color: Colors.black54)), Text("₦$balance.00", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)), Text("Call Balance: ₦$callBalance.00")])), const SizedBox(height: 12), ListTile(leading: const Icon(Icons.call, color: Color(0xFF7CFF00)), title: const Text("Call Balance"), trailing: Text("₦$callBalance.00", style: const TextStyle(color: Color(0xFF7CFF00))))]));
}

class RechargeScreen extends StatefulWidget {
  final int balance; const RechargeScreen({super.key, required this.balance});
  @override State<RechargeScreen> createState() => _RechargeScreenState();
}
class _RechargeScreenState extends State<RechargeScreen> {
  final c = TextEditingController(text: "100"); bool l = false;
  void recharge() async {
    setState(()=> l=true);
    int amt = int.tryParse(c.text)??0;
    var uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'balance': FieldValue.increment(amt), 'callBalance': FieldValue.increment(amt)});
    setState(()=> l=false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Recharged ₦$amt!")));
  }
  @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Recharge", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 20), Text("Current: ₦${widget.balance}.00", style: const TextStyle(color: Color(0xFF7CFF00))), const SizedBox(height: 20), TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Amount NGN", filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: l? null : recharge, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7CFF00)), child: Text("Recharge ₦${c.text}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))))])));
}

class GKCallScreen extends StatelessWidget {
  final int callBalance; const GKCallScreen({super.key, required this.callBalance});
  void callNow(BuildContext context) async {
    if (callBalance < 100) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Low balance, recharge"))); return; }
    var uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'callBalance': FieldValue.increment(-100)});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Call started! ₦100 deducted - 1 Hour active")));
  }
  @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(14), children: [const Text("GK Call", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 14), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Call Balance", style: TextStyle(color: Colors.white54, fontSize: 12)), Text("₦$callBalance.00", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7CFF00)))]), const Icon(Icons.add_circle, color: Color(0xFF7CFF00))])), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: ()=>callNow(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7CFF00), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text("Make Call Now - ₦100", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))))]));
}

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});
  @override Widget build(BuildContext context) => const SafeArea(child: Center(child: Text("Create Post - Coming Soon")));
}
class FootballScreen extends StatelessWidget {
  const FootballScreen({super.key});
  @override Widget build(BuildContext context) => const SafeArea(child: Center(child: Text("Football - Coming Soon")));
}
