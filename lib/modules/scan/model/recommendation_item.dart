class RecommendationItem {
  final String category;
  final List<String> contentEn;
  final List<String> contentTl;

  RecommendationItem({
    required this.category,
    required this.contentEn,
    required this.contentTl,
  });

  List<String> content(String lang) {
    if (lang == 'tl' && contentTl.isNotEmpty) return contentTl;
    return contentEn;
  }
}
