import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const GeekApp());

class GeekApp extends StatelessWidget {
  const GeekApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: GeekFeed());
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
    vc = VideoPlayerController.networkUrl(Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
     ..initialize().then((_) {
        setState(() {}); vc.play();
        vc.addListener(() { if(vc.value.position >= vc.value.duration) setState(()=> ended=true); });
      });
  }
  @override
  void dispose() { vc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      if(vc.value.isInitialized) FittedBox(fit: BoxFit.cover, child: SizedBox(width: vc.value.size.width, height: vc.value.size.height, child: VideoPlayer(vc))) else const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      GestureDetector(onTap: ()=> setState(()=> vc.value.isPlaying? vc.pause(): vc.play())),
      if(ended) Container(color: Colors.black.withOpacity(0.8), child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.monetization_on, color: Color(0xFFD4AF37), size: 80), SizedBox(height:10), Text('GEEK PAYTASK', style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 3, fontSize: 20)), SizedBox(height:30), Icon(Icons.keyboard_arrow_up, color: Colors.white54), Text('Swipe up', style: TextStyle(color: Colors.white54))]))),
    ]);
  }
}
