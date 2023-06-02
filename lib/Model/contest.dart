class ContestModel {
  String name;
  String url;
  String startTime;
  String endTime;
  String duration;
  String in24Hours;
  String status;

  ContestModel(
      {required this.name,
      required this.url,
      required this.startTime,
      required this.endTime,
      required this.duration,
      required this.in24Hours,
      required this.status});

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'start_time': startTime,
        'end_time': endTime,
        'duration': duration,
        'in_24_hours': in24Hours,
        'status': status,
      };

  factory ContestModel.fromJson(Map<String, dynamic> json) {
    return ContestModel(
      name: json['name'],
      url: json['url'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      duration: json['duration'],
      in24Hours: json['in_24_hours'],
      status: json['status'],
    );
  }
}
