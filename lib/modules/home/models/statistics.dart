// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Statistics {
  Duration duration;
  int pages;
  DateTime date;
  Statistics({
    required this.duration,
    required this.pages,
    required this.date,
  });

  Statistics copyWith({
    Duration? duration,
    int? pages,
    DateTime? date,
  }) {
    return Statistics(
      duration: duration ?? this.duration,
      pages: pages ?? this.pages,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'duration': duration,
      'pages': pages,
      'date': date,
    };
  }

  factory Statistics.fromMap(Map<String, dynamic> map) {
    return Statistics(
      duration: map['duration'] as Duration,
      pages: map['pages'] as int,
      date: map['date'] as DateTime,
    );
  }

  String toJson() => json.encode(toMap());

  factory Statistics.fromJson(String source) =>
      Statistics.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Statistics(duration: $pages, title: $pages, date: $date)';

  @override
  bool operator ==(covariant Statistics other) {
    if (identical(this, other)) return true;

    return other.duration == duration &&
        other.pages == pages &&
        other.date == date;
  }

  @override
  int get hashCode =>
      duration.hashCode ^ pages.hashCode ^ date.hashCode;
}
