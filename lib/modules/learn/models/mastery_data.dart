class Lesson {
  final String title;
  final String duration;
  final bool isCompleted;
  final String videoId; // Added this for real video playback

  Lesson({
    required this.title, 
    required this.duration, 
    this.isCompleted = false, 
    required this.videoId
  });
}

class MasteryData {
  static final Map<String, List<Lesson>> courses = {
    "Soil Fertility Secrets": [
      Lesson(title: "Understanding Soil pH", duration: "3:20", isCompleted: true, videoId: "u1zgFlCw8DQ"),
      Lesson(title: "Nitrogen vs Phosphorus", duration: "12:45", videoId: "dQw4w9WgXcQ"),
      Lesson(title: "Organic vs Synthetic", duration: "8:10", videoId: "3S5S1n5CIdE"),
      Lesson(title: "Fertility Quiz", duration: "5 Questions", videoId: "76839201"),
    ],
    "Rainy Season Care": [
      Lesson(title: "Preventing Root Rot", duration: "5:30", isCompleted: true, videoId: "VIDEO_ID_HERE"),
      Lesson(title: "Drainage Infrastructure", duration: "15:00", videoId: "VIDEO_ID_HERE"),
      Lesson(title: "Emergency Care", duration: "10:20", videoId: "VIDEO_ID_HERE"),
    ],
    "Organic Compost": [
      Lesson(title: "Carbon/Nitrogen Ratio", duration: "6:15", videoId: "VIDEO_ID_HERE"),
      Lesson(title: "Aeration Techniques", duration: "9:40", videoId: "VIDEO_ID_HERE"),
      Lesson(title: "Final Harvest Test", duration: "4:00", videoId: "VIDEO_ID_HERE"),
    ],
  };
}