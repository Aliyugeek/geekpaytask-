import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const Color neonGreen = Color(0xFF39FF55);
const Color neonBlue = Color(0xFF10C9FF);
const Color darkBg = Color(0xFF050709);
const String admobBannerTestId = 'ca-app-pub-3940256099942544/6300978111';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Auth: $e');
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
  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const GeekProfilePage(),
      RechargePage(balance: testBalance, onTestRecharge: () => setState(() => testBalance += 100)),
      const MoreMoneyPage(),
      const FootballPage(),
      GKCallPage(balance: testBalance),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBg,
        title: const Text('GEEK PAYTASK', style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101820),
        indicatorColor: neonGreen.withOpacity(0.15),
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => setState(() => selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Geek'),
          NavigationDestination(icon: Icon(Icons.add_card), label: 'Recharge'),
          NavigationDestination(icon: Icon(Icons.monetization_on_outlined), label: 'More Money'),
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Football'),
          NavigationDestination(icon: Icon(Icons.call_outlined), label: 'GK Call'),
        ],
      ),
    );
  }
}

class VideoPost {
  String id; String user; String caption; int likes; int comments; bool isLiked; List<String> commentList;
  VideoPost({required this.id, required this.user, required this.caption, this.likes=12800, this.comments=1200, this.isLiked=false, List<String>? c}) : commentList=c?? ['Nice one! 🔥','GK to the world 💚'];
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<VideoPost> posts = [
    VideoPost(id: '1', user: '@sadiya_queen', caption: 'Life is better when you smile 💚 #GK #GoodVibes'),
    VideoPost(id: '2', user: '@geek_boy', caption: 'Earn with GK PayTask today!'),
    VideoPost(id: '3', user: '@aisha_vibes', caption: 'My first earning ₦20k from GK! #PayTask'),
  ];
  String fmt(int n) => n>=1000? '${(n/1000).toStringAsFixed(1)}K' : '$n';
  void toggleLike(int i){ setState((){ if(posts[i].isLiked){ posts[i].likes--; posts[i].isLiked=false; } else { posts[i].likes++; posts[i].isLiked=true; } }); }
  void openComments(int i){
    final ctrl=TextEditingController();
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF101820), isScrollControlled: true, builder: (ctx)=> StatefulBuilder(builder: (ctx,setSheet)=> Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), child: Container(height: 400, padding: const EdgeInsets.all(12), child: Column(children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
      Text('${posts[i].comments} Comments', style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold)),
      const Divider(color: Colors.grey),
      Expanded(child: ListView.builder(itemCount: posts[i].commentList.length, itemBuilder: (c,j)=> ListTile(leading: const CircleAvatar(backgroundColor: neonGreen, child: Icon(Icons.person, color: Colors.black, size: 18)), title: Text(posts[i].commentList[j], style: const TextStyle(color: Colors.white)), subtitle: const Text('Just now', style: TextStyle(color: Colors.grey, fontSize: 10))))),
      Row(children: [ Expanded(child: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Add comment...', border: OutlineInputBorder()))), IconButton(icon: const Icon(Icons.send, color: neonGreen), onPressed: (){ if(ctrl.text.isNotEmpty){ setState(()=> posts[i].commentList.add(ctrl.text)); setSheet(()=> posts[i].comments++); ctrl.clear(); } }) ])
    ])))));
  }
  void sharePost(int i){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shared ${posts[i].user} video!'))); }
  @override Widget build(BuildContext context) => Column(children: [
    const Padding(padding: EdgeInsets.all(16), child: Row(children: [ Text('For You', style: TextStyle(fontSize: 20, color: neonGreen, fontWeight: FontWeight.bold)), SizedBox(width: 20), Text('Following', style: TextStyle(fontSize: 16, color: Colors.grey)), Spacer(), Icon(Icons.search, color: neonBlue) ])),
    Expanded(child: PageView.builder(scrollDirection: Axis.vertical, itemCount: posts.length, itemBuilder: (ctx,index){
      var p=posts[index];
      return Container(margin: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(18), border: Border.all(color: neonBlue)), child: Stack(children: [
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ CircleAvatar(radius: 30, backgroundColor: neonGreen, child: Text(p.user[1].toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))), const SizedBox(height: 10), Text(p.user, style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold)), Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: Text(p.caption, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))), const Icon(Icons.play_circle, size: 40, color: neonBlue) ])),
        Positioned(right: 10, bottom: 20, child: Column(children: [
          GestureDetector(onTap: ()=> toggleLike(index), child: Column(children: [ Icon(Icons.favorite, color: p.isLiked? Colors.red: Colors.white, size: 32), Text(fmt(p.likes), style: const TextStyle(color: Colors.white, fontSize: 12)) ])),
          const SizedBox(height: 16),
          GestureDetector(onTap: ()=> openComments(index), child: Column(children: [ const Icon(Icons.comment, color: neonBlue, size: 28), Text(fmt(p.comments), style: const TextStyle(color: Colors.white, fontSize: 12)) ])),
          const SizedBox(height: 16),
          GestureDetector(onTap: ()=> sharePost(index), child: const Column(children: [ Icon(Icons.share, color: neonGreen, size: 26), Text('Share', style: TextStyle(color: Colors.white, fontSize: 12)) ])),
        ]))
      ]));
    }))
  ]);
}

class GeekProfilePage extends StatelessWidget {
  const GeekProfilePage({super.key});
  @override Widget build(BuildContext context){
    final user=FirebaseAuth.instance.currentUser;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [ const CircleAvatar(radius: 42, backgroundColor: neonGreen, child: Icon(Icons.person, size: 50, color: Colors.black)), const SizedBox(height: 16), const Text('Geek Profile', style: TextStyle(fontSize: 24, color: neonGreen)), Text('User ID: ${user?.uid??"Not signed in"}') ]));
  }
}

class RechargePage extends StatelessWidget {
  final double balance; final VoidCallback onTestRecharge;
  const RechargePage({super.key, required this.balance, required this.onTestRecharge});
  @override Widget build(BuildContext context)=> ListView(padding: const EdgeInsets.all(24), children: [ const Icon(Icons.account_balance_wallet, size: 70, color: neonGreen), const Text('Recharge Wallet', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, color: neonGreen)), Text('Test balance: ₦${balance.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)), const SizedBox(height: 20), ElevatedButton(onPressed: onTestRecharge, child: const Text('Simulate ₦100 Test Recharge')) ]);
}

class MoreMoneyPage extends StatefulWidget { const MoreMoneyPage({super.key}); @override State<MoreMoneyPage> createState()=> _MoreMoneyPageState(); }
class _MoreMoneyPageState extends State<MoreMoneyPage> {
  BannerAd? bannerAd; bool adLoaded=false;
  @override void initState(){ super.initState(); bannerAd=BannerAd(adUnitId: admobBannerTestId, size: AdSize.banner, request: const AdRequest(), listener: BannerAdListener(onAdLoaded: (ad){ if(mounted) setState(()=> adLoaded=true); }, onAdFailedToLoad: (ad,err){ ad.dispose(); }))..load(); }
  @override void dispose(){ bannerAd?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context)=> ListView(padding: const EdgeInsets.all(24), children: [ const Icon(Icons.monetization_on, size: 70, color: neonGreen), const Text('More Money', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, color: neonGreen)), const SizedBox(height: 20), Center(child: adLoaded&&bannerAd!=null? SizedBox(width: bannerAd!.size.width.toDouble(), height: bannerAd!.size.height.toDouble(), child: AdWidget(ad: bannerAd!)) : const Text('Loading test ad...')) ]);
}

class FootballPage extends StatelessWidget {
  const FootballPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Icon(Icons.sports_soccer, size: 60, color: neonGreen),
    const Text('Geek Football & Games', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: neonGreen, fontWeight: FontWeight.bold)),
    const SizedBox(height: 20),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(16), border: Border.all(color: neonGreen, width: 2)), child: Column(children: [
      const Icon(Icons.location_city, size: 60, color: neonGreen),
      const Text('CITY WARS', style: TextStyle(color: neonGreen, fontSize: 20, fontWeight: FontWeight.bold)),
      const Text('Capture the city - Tap to earn!', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: neonGreen, minimumSize: const Size(double.infinity, 50)), onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> const CityWarsGame())); }, child: const Text('PLAY CITY WARS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
    ])),
  ]);
}

class GKCallPage extends StatelessWidget { final double balance; const GKCallPage({super.key, required this.balance}); @override Widget build(BuildContext context)=> ListView(padding: const EdgeInsets.all(24), children: [ const Icon(Icons.video_call, size: 75, color: neonGreen), const Text('GK Call', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, color: neonGreen)), Text('Available test balance: ₦${balance.toStringAsFixed(2)}', textAlign: TextAlign.center), const TextField(decoration: InputDecoration(labelText: 'Enter Geek ID or phone', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_search))) ]); }

class CityWarsGame extends StatefulWidget { const CityWarsGame({super.key}); @override State<CityWarsGame> createState() => _CityWarsGameState(); }
class _CityWarsGameState extends State<CityWarsGame> {
  int score = 0; int energy = 10; bool gameOver = false;
  void tapCity(){ if(gameOver) return; setState((){ score+=10; energy--; if(energy<=0) gameOver=true; }); }
  void restartGame(){ setState((){ score=0; energy=10; gameOver=false; }); }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050709),
    appBar: AppBar(backgroundColor: const Color(0xFF050709), title: const Text('CITY WARS', style: TextStyle(color: Color(0xFF39FF55), fontWeight: FontWeight.bold)), leading: IconButton(icon: const Icon(Icons.arrow_back, color: neonGreen), onPressed: ()=> Navigator.pop(context))),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const Text('CAPTURE THE CITY', style: TextStyle(color: Color(0xFF10C9FF), fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      Text('Score: $score', style: const TextStyle(color: Color(0xFF39FF55), fontSize: 28)),
      Text('Energy: $energy', style: const TextStyle(color: Colors.white, fontSize: 18)),
      const SizedBox(height: 30),
      Expanded(child: Center(child: gameOver? const Text('GAME OVER!', style: TextStyle(color: Colors.redAccent, fontSize: 30, fontWeight: FontWeight.bold)) : GestureDetector(onTap: tapCity, child: Container(width: 220, height: 220, decoration: BoxDecoration(color: const Color(0xFF101820), border: Border.all(color: Color(0xFF39FF55), width: 3), borderRadius: BorderRadius.circular(24)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.location_city, color: Color(0xFF39FF55), size: 85), SizedBox(height: 12), Text('TAP TO CAPTURE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) ]))))),
      if(gameOver)...[ Text('Final score: $score', style: const TextStyle(color: Color(0xFF10C9FF), fontSize: 20)), const SizedBox(height: 12), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: neonGreen), onPressed: restartGame, child: const Text('PLAY AGAIN', style: TextStyle(color: Colors.black))) ],
      const SizedBox(height: 20),
      const Text('CITY WARS LEADERBOARD', style: TextStyle(color: Color(0xFF10C9FF), fontSize: 18, fontWeight: FontWeight.bold)),
      const ListTile(leading: Icon(Icons.emoji_events, color: Colors.amber), title: Text('Leaderboard', style: TextStyle(color: Colors.white)), subtitle: Text('Online rankings not connected yet', style: TextStyle(color: Colors.white70))),
    ])),
  );
}
