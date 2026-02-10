class Lesson {
  final String title;
  final String duration;
  final bool isCompleted;

  Lesson({required this.title, required this.duration, this.isCompleted = false});
}

class MasteryData {
  static final Map<String, List<Lesson>> courses = {
    "Soil Fertility Secrets": [
      Lesson(title: "Understanding Soil pH", duration: "3:20", isCompleted: true),
      Lesson(title: "Nitrogen vs Phosphorus", duration: "12:45"),
      Lesson(title: "Organic vs Synthetic", duration: "8:10"),
      Lesson(title: "Fertility Quiz", duration: "5 Questions"),
    ],
    "Rainy Season Care": [
      Lesson(title: "Preventing Root Rot", duration: "5:30", isCompleted: true),
      Lesson(title: "Drainage Infrastructure", duration: "15:00"),
      Lesson(title: "Emergency Care", duration: "10:20"),
    ],
    "Organic Compost": [
      Lesson(title: "Carbon/Nitrogen Ratio", duration: "6:15"),
      Lesson(title: "Aeration Techniques", duration: "9:40"),
      Lesson(title: "Final Harvest Test", duration: "4:00"),
    ],
  };
}