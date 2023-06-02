
class Notes{
  String questionId;
  String title;
  String note;

  Notes({required this.questionId, required this.title, required this.note});

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'note': note,
    'title': title,
  };

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      questionId: json['questionId'],
      note: json['note'],
      title: json['title'],
    );
  }
}