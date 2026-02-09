class NotificationTask {
  final String id;
  final String title;
  final String lastScanned;
  final String imagePath;
  final List<String> subTasks;

  NotificationTask({
    required this.id,
    required this.title,
    required this.lastScanned,
    required this.imagePath,
    required this.subTasks,
  });
}