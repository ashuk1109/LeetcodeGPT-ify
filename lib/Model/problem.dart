import 'dart:math';

class Problem {
  final String questionId;
  final String title;
  final String titleSlug;
  final String content;
  final String difficulty;
  final bool isPaidOnly;
  final List<String> topicTags;

  Problem({
    required this.questionId,
    required this.title,
    required this.titleSlug,
    required this.content,
    required this.difficulty,
    required this.isPaidOnly,
    required this.topicTags,
  });

  String get problemContent => title;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'title': title,
        'titleSlug': titleSlug,
        'content': content,
        'difficulty': difficulty,
        'isPaidOnly': isPaidOnly,
        'topicTags': topicTags,
      };

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      questionId: json['questionId'],
      title: json['title'],
      titleSlug: json['titleSlug'],
      content: json['content'],
      difficulty: json['difficulty'],
      isPaidOnly: json['isPaidOnly'],
      topicTags:
          List<String>.from(json['topicTags'].map((tag) => tag.toString())),
    );
  }

  static Problem generateRandom(List<Problem> problems) {
    var today = DateTime.now().day;
    var rng = Random(today);
    return problems[rng.nextInt(problems.length)];
  }
}
