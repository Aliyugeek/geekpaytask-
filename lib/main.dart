import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const GeekApp());

class GeekApp extends StatelessWidget {
  const GeekApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GeekFeed(),
    );
  }
}

class GeekFeed extends StatefulWidget {
  const GeekFeed({super.key});
  @override
  State<GeekFeed> createState() => _GeekFeedState();
}

class _GeekFeedState extends State<GeekFeed> {
  final controller = PageController();
  final vids = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.vertical,
        itemCount: vids.length,
        itemBuilder: (_, i) => VideoItem(url: vids[i]),
      ),
    );
  }
}

class VideoItem extends StatefulWidget {
  final String url;
  const VideoItem({super.key, required this.url});
  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController vc;
  bool ended = false;

  @override
  void initState() {
    super.initState();
    vc = VideoPlayerController.networkUrl(Uri.parse(widget.url))
    ..initialize().then((_) {
        setState(() {});
        vc.play();
        vc.addListener(() {
          if (vc.value.position >= vc.value.duration) {
            setState(() => ended = true);
          }
        });
      });
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (vc.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: vc.value.size.width,
              height: vc.value.size.height,
              child: VideoPlayer(vc),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        GestureDetector(
          onTap: () => setState(() => vc.value.isPlaying? vc.pause() : vc.play()),
        ),
        if (ended)
          Container(
            color: Colors.black.withOpacity(0.75),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logos/geek_gold_medium.png', width: 200),
                  const SizedBox(height: 8),
                  const Text('geek paytask', style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 3)),
                  const SizedBox(height: 30),
                  const Icon(Icons.keyboard_arrow_up, color: Colors.white54),
                  const Text('Swipe up', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
