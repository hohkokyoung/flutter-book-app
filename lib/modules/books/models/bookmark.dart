// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Bookmark {
  int pageNumber;
  String title;
  String description;
  Bookmark({
    required this.pageNumber,
    required this.title,
    required this.description,
  });

  Bookmark copyWith({
    int? pageNumber,
    String? title,
    String? description,
  }) {
    return Bookmark(
      pageNumber: pageNumber ?? this.pageNumber,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pageNumber': pageNumber,
      'title': title,
      'description': description,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      pageNumber: map['pageNumber'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bookmark.fromJson(String source) =>
      Bookmark.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Bookmark(pageNumber: $pageNumber, title: $title, description: $description)';

  @override
  bool operator ==(covariant Bookmark other) {
    if (identical(this, other)) return true;

    return other.pageNumber == pageNumber &&
        other.title == title &&
        other.description == description;
  }

  @override
  int get hashCode =>
      pageNumber.hashCode ^ title.hashCode ^ description.hashCode;
}
