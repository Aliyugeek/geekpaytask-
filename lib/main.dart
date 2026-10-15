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

class GeekFeed extends StatelessWidget {
  const GeekFeed({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 1,
        itemBuilder: (_, i) => const VideoItem(),
      ),
    );
  }
}

class VideoItem extends StatefulWidget {
  const VideoItem({super.key});
  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController vc;
  bool ended = false;

  @override
  void initState() {
    super.initState();
    vc = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    )..initialize().then((_) {
        setState(() {});
        vc.play();
        vc.setLooping(false);
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
          ),
        GestureDetector(
          onTap: () => setState(() {
            vc.value.isPlaying ? vc.pause() : vc.play();
          }),
        ),
        if (ended)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Text('Ended', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
      ],
    );
  }
}
