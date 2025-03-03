// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:booksum/modules/books/models/highlight.dart';

class Note {
  static int _idCounter = 0; // Static variable to track the last assigned ID
  int id;
  int pageNumber;
  String title;
  String text;
  Highlight highlight;

  Note({
    int? id, // Optional id, if not provided, it will be auto-incremented
    required this.pageNumber,
    required this.title,
    required this.text,
    required this.highlight,
  }) : id = id ?? _idCounter++; // Assign incremented ID if id is not provided

  Note copyWith({
    int? id,
    int? pageNumber,
    String? title,
    String? highlightedText,
    String? text,
    Highlight? highlight,
  }) {
    return Note(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      title: title ?? this.title,
      text: text ?? this.text,
      highlight: highlight ?? this.highlight,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'pageNumber': pageNumber,
      'title': title,
      'text': text,
      'highlight': highlight,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      pageNumber: map['pageNumber'] as int,
      title: map['title'] as String,
      text: map['text'] as String,
      highlight: map['highlight'] as Highlight,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Note(id: $id, pageNumber: $pageNumber, title: $title, text: $text, highlight: $highlight)';

  @override
  bool operator ==(covariant Note other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.pageNumber == pageNumber &&
      other.title == title &&
      other.text == text &&
      other.highlight == highlight;
  }

  @override
  int get hashCode => id.hashCode ^ pageNumber.hashCode ^ title.hashCode ^ text.hashCode ^ highlight.hashCode;
}
