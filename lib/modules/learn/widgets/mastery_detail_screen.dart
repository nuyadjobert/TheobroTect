import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// --- DATA MODEL ---
class Lesson {
  final String title;
  final String duration;
  final bool isCompleted;
  final String videoUrl;

  Lesson({
    required this.title,
    required this.duration,
    required this.isCompleted,
    required this.videoUrl,
  });
}

// --- MASTER DATA MAP ---
// This stores all your courses in one place
final Map<String, List<Lesson>> courseDataMap = {
  "Soil Fertility Secrets": [
    Lesson(title: "Understanding Soil pH", duration: "12:56", isCompleted: true, videoUrl: "https://www.youtube.com/watch?v=Izdgz-HBxlE"),
    Lesson(title: "Nitrogen vs Phosphorus", duration: "6:27", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=jpYoiK5UlHA"),
    Lesson(title: "Organic vs Synthetic", duration: "9:19", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=1IhKLu2gRbU"),
    Lesson(title: "Composting Techniques", duration: "10:00", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=gjwZalZGmQA"),
  ],
  "Rainy Season Care": [
    Lesson(title: "Drainage for Heavy Rain", duration: "0:16", isCompleted: false, videoUrl: "https://www.youtube.com/shorts/H2t4-R1ghCs"),
    Lesson(title: "Managing Wet Soil", duration: "11:21", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=QsaEmDF7heg"),
    Lesson(title: "Rainy Season Crops", duration: "10:36", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=H4zScZTERQM"),
  ],
  "Organic Compost": [
    Lesson(title: "How to Make Fast Compost", duration: "10:58", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=WS7X-5J5bQM"),
    Lesson(title: "Browns vs Greens Theory", duration: "7:45", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=M1kL49ZfLkE"),
    Lesson(title: "Vermicomposting 101", duration: "8:52", isCompleted: false, videoUrl: "https://www.youtube.com/watch?v=oY97Aa4b6aM"),
  ],
};

class MasteryDetailScreen extends StatefulWidget {
  final String title;
  final Color themeColor;

  const MasteryDetailScreen({super.key, required this.title, required this.themeColor});

  @override
  State<MasteryDetailScreen> createState() => _MasteryDetailScreenState();
}

class _MasteryDetailScreenState extends State<MasteryDetailScreen> {
  late YoutubePlayerController _controller;
  late List<Lesson> activeLessons;

  @override
  void initState() {
    super.initState();
    
    activeLessons = courseDataMap[widget.title] ?? courseDataMap["Soil Fertility Secrets"]!;

    final String? videoId = YoutubePlayer.convertUrlToId(activeLessons[0].videoUrl);
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
      ),
    );
  }

  void _onLessonTap(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      _controller.load(videoId);
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        progressColors: ProgressBarColors(
          playedColor: widget.themeColor,
          handleColor: widget.themeColor,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // FIXED: Safe Area and Back Button Pushing
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: const BackButton(color: Colors.black),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: player,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header Information
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("COURSE", 
                            style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(widget.title, 
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              SizedBox(width: 4),
                              Text("4.9 Mastery Rating", style: TextStyle(color: Colors.black54, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dynamic Lesson List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildLessonTile(index + 1, activeLessons[index]),
                        childCount: activeLessons.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              _buildBottomAction(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonTile(int number, Lesson lesson) {
    return InkWell(
      onTap: () => _onLessonTap(lesson.videoUrl),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: lesson.isCompleted ? const Color(0xFF2D6A4F) : Colors.white,
              radius: 18,
              child: lesson.isCompleted 
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text("$number", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(lesson.duration, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: widget.themeColor, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A5C4F), // Farming brown
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 4,
          ),
          child: const Text("Farming Technique's", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}