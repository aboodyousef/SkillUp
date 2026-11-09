class AiRecommenderService {
  static int calculateScore({
    required Map<String, dynamic> video,
    required List<String> interests,
    required List<String> savedVideoIds,
    required List<String> enrolledVideoIds,
    required String preferredLevel,
  }) {
    int score = 0;

    final subject = (video['subject'] ?? video['category'] ?? '').toString().toLowerCase();
    final title = (video['title'] ?? '').toString().toLowerCase();
    final level = (video['level'] ?? '').toString().toLowerCase();
    final description = (video['description'] ?? '').toString().toLowerCase();

    //Interests
    if (interests.any((i) => subject.contains(i.toLowerCase()))) {
      score += 5;
    }

    //Saved
    if (savedVideoIds.contains(video['id'])) {
      score += 4;
    }

    //Enrolled
    if (enrolledVideoIds.contains(video['id'])) {
      score += 3;
    }

    //Level match
    if (preferredLevel.isNotEmpty &&
        level == preferredLevel.toLowerCase()) {
      score += 2;
    }

    //Keyword bonus
    for (final i in interests) {
      if (title.contains(i.toLowerCase())) {
        score += 1;
      }
      if (description.contains(i.toLowerCase())) {
        score += 1;
      }
    }

    //Search keywords match
    final List<dynamic>? keywords = video['searchKeywords'] as List<dynamic>?;
    if (keywords != null) {
      for (final kw in keywords) {
        if (interests.any((i) => kw.toString().toLowerCase().contains(i.toLowerCase()))) {
          score += 2;
          break;
        }
      }
    }

    return score;
  }
}
