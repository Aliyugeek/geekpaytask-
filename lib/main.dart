 import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const Color neonGreen = Color(0xFF39FF55);
const Color neonBlue = Color(0xFF10C9FF);
const Color darkBg = Color(0xFF050709);

Future<void> main() async {
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
      title: 'Geek PayTask',
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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) return const HomePage();
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> start(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium,
                  size: 90, color: neonGreen),
              const SizedBox(height: 16),
              const Text(
                'Geek PayTask',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: neonGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Watch • Connect • Earn'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => start(context),
                  child: const Text('GET STARTED'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool following = false;
  bool liked = false;
  bool forYou = true;

  final List<String> pages = [
    'Home',
    'Recharge',
    'Post',
    'Call',
    'More Money',
    'Football',
  ];

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.account_balance_wallet_outlined,
    Icons.add_box_outlined,
    Icons.call_outlined,
    Icons.monetization_on_outlined,
    Icons.emoji_events_outlined,
  ];

  void notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void openMenu(String choice) {
    if (choice == 'Geek') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SimplePage(
          title: 'Geek Profile',
          description: 'Your profile and account information.',
          icon: Icons.person_outline,
        )),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SimplePage(
            title: choice,
            description: choice == 'Withdraw'
                ? 'View withdrawal options and your eligible funds.'
                : choice == 'Privacy Policy'
                    ? 'Geek PayTask privacy information will appear here.'
                    : 'Manage your Geek PayTask preferences.',
            icon: choice == 'Withdraw'
                ? Icons.payments_outlined
                : choice == 'Settings'
                    ? Icons.settings_outlined
                    : Icons.privacy_tip_outlined,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (selectedIndex == 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: neonGreen, size: 34),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Geek PayTask',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: neonGreen,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: VideoSearch(),
                        );
                      },
                      icon: const Icon(Icons.search, size: 29),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 28),
                      onSelected: openMenu,
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'Geek',
                          child: Text('Geek — Profile'),
                        ),
                        PopupMenuItem(
                          value: 'Withdraw',
                          child: Text('Withdraw'),
                        ),
                        PopupMenuItem(
                          value: 'Privacy Policy',
                          child: Text('Privacy Policy'),
                        ),
                        PopupMenuItem(
                          value: 'Settings',
                          child: Text('Settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: selectedIndex == 0
                  ? buildHomeFeed()
                  : FeaturePage(
                      title: pages[selectedIndex],
                      onMessage: notify,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF080C10),
          border: Border(
            top: BorderSide(color: neonBlue, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: List.generate(pages.length, (index) {
                final active = selectedIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => selectedIndex = index);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          size: 24,
                          color: active
                              ? neonGreen
                              : index == 2 || index == 5
                                  ? neonBlue
                                  : Colors.white,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            pages[index],
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: active ? neonGreen : Colors.white,
                            ),
                          ),
                        ),
                        if (active)
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            height: 2,
                            width: 25,
                            color: neonGreen,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHomeFeed() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => forYou = false),
                child: Text(
                  'Following',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: !forYou ? neonGreen : Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 22),
              Column(
                children: [
                  TextButton(
                    onPressed: () => setState(() => forYou = true),
                    child: Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: forYou ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                    width: 55,
                    decoration: BoxDecoration(
                      color: forYou ? neonBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF18352D),
                      Color(0xFF151B25),
                      Color(0xFF050709),
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline,
                          size: 82, color: neonGreen),
                      SizedBox(height: 12),
                      Text(
                        'Geek PayTask Video Feed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Real user videos will appear here',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 170,
                child: Column(
                  children: [
                    sideAction(
                      icon: following
                          ? Icons.person
                          : Icons.person_add_alt_1,
                      label: following ? 'Following' : 'Follow',
                      color: neonGreen,
                      action: () =>
                          setState(() => following = !following),
                    ),
                    const SizedBox(height: 18),
                    sideAction(
                      icon: liked ? Icons.favorite : Icons.favorite_border,
                      label: liked ? 'Liked' : 'Like',
                      color: Colors.redAccent,
                      action: () => setState(() => liked = !liked),
                    ),
                    const SizedBox(height: 18),
                    sideAction(
                      icon: Icons.comment,
                      label: 'Comment',
                      color: Colors.white,
                      action: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SimplePage(
                              title: 'Comments',
                              description:
                                  'Comments and partner messaging will be connected in a later step.',
                              icon: Icons.comment_outlined,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    sideAction(
                      icon: Icons.share,
                      label: 'Share',
                      color: Colors.white,
                      action: () => notify('Sharing will be added later.'),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 16,
                right: 95,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@geekpaytask',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Welcome to Geek PayTask! 💚'),
                    SizedBox(height: 6),
                    Text(
                      '#GK #GoodVibes #Football',
                      style: TextStyle(color: neonBlue),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.music_note, color: neonGreen),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Original Sound - GK',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget sideAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback action,
  }) {
    return InkWell(
      onTap: action,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturePage extends StatelessWidget {
  final String title;
  final ValueChanged<String> onMessage;

  const FeaturePage({
    super.key,
    required this.title,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String description;

    switch (title) {
      case 'Recharge':
        icon = Icons.account_balance_wallet_outlined;
        description =
            'Recharge your call balance using a verified payment.';
        break;
      case 'Post':
        icon = Icons.video_library_outlined;
        description =
            'Video gallery and posting will be connected in a later step.';
        break;
      case 'Call':
        icon = Icons.call_outlined;
        description =
            'Paid voice and video calls require a calling provider.';
        break;
      case 'More Money':
        icon = Icons.monetization_on_outlined;
        description =
            'Eligible rewarded ads and verified rewards will be added here.';
        break;
      default:
        icon = Icons.emoji_events_outlined;
        description =
            'Football search, videos and supported channels will appear here.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 75, color: neonGreen),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: neonGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => onMessage(
                '$title is ready for the next development step.',
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class SimplePage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const SimplePage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 70, color: neonGreen),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => Center(
        child: Text('Video search for: $query'),
      );

  @override
  Widget buildSuggestions(BuildContext context) => const Center(
        child: Text('Search Geek PayTask videos'),
      );
}
