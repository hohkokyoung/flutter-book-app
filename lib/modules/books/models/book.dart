// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:booksum/modules/books/models/bookmark.dart';
import 'package:booksum/modules/books/models/highlight.dart';
import 'package:booksum/modules/books/models/note.dart';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Book {
  static int _idCounter = 0; // Static variable to track the last assigned ID
  int id;
  int totalPageNumber;
  int currentPageNumber;
  DateTime lastRead;
  String title;
  String description;
  String author;
  double rating;
  String imageFilePath;
  String pdfFilePath;
  bool isFavourite;
  List<String> genres;
  Duration durationRead;
  List<Bookmark> bookmarks;
  List<Note> notes;
  List<Highlight> highlights;

  Book({
    int? id, // Optional id, if not provided, it will be auto-incremented
    required this.totalPageNumber,
    required this.currentPageNumber,
    required this.lastRead,
    required this.title,
    required this.description,
    required this.author,
    required this.rating,
    required this.imageFilePath,
    required this.pdfFilePath,
    required this.genres,
    required this.isFavourite,
    required this.durationRead,
    required this.bookmarks,
    required this.notes,
    required this.highlights,
  }) : id = id ?? _idCounter++; // Assign incremented ID if id is not provided

  Book copyWith({
    int? id,
    int? totalPageNumber,
    int? currentPageNumber,
    DateTime? lastRead,
    String? title,
    String? description,
    String? author,
    double? rating,
    String? imageFilePath,
    String? pdfFilePath,
    List<String>? genres,
    bool? isFavourite,
    Duration? durationRead,
    List<Bookmark>? bookmarks,
    List<Note>? notes,
    List<Highlight>? highlights,
  }) {
    return Book(
      id: id ?? this.id,
      totalPageNumber: totalPageNumber ?? this.totalPageNumber,
      currentPageNumber: currentPageNumber ?? this.currentPageNumber,
      lastRead: lastRead ?? this.lastRead,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      imageFilePath: imageFilePath ?? this.imageFilePath,
      pdfFilePath: pdfFilePath ?? this.pdfFilePath,
      genres: genres ?? this.genres,
      isFavourite: isFavourite ?? this.isFavourite,
      durationRead: durationRead ?? this.durationRead,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
      highlights: highlights ?? this.highlights,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'totalPageNumber': totalPageNumber,
      'currentPageNumber': currentPageNumber,
      'lastRead': lastRead.toIso8601String(),
      'title': title,
      'description': description,
      'author': author,
      'rating': rating,
      'imageFilePath': imageFilePath,
      'pdfFilePath': pdfFilePath,
      'genres': genres,
      'isFavourite': isFavourite,
      'durationRead': durationRead.inMilliseconds,
      'bookmarks': bookmarks,
      'notes': notes,
      'highlights': highlights,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      totalPageNumber: map['totalPageNumber'] as int,
      currentPageNumber: map['currentPageNumber'] as int,
      lastRead: DateTime.parse(map['lastRead'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      rating: map['rating'] as double,
      imageFilePath: map['imageFilePath'] as String,
      pdfFilePath: map['pdfFilePath'] as String,
      genres: List<String>.from(map['genres'] as List<dynamic>),
      isFavourite: map['isFavourite'] as bool,
      durationRead: Duration(milliseconds: map['durationRead'] as int),
      bookmarks: List<Bookmark>.from((map['bookmarks'] as List<dynamic>)
          .map((item) => Bookmark.fromJson(item as String))),
      notes: List<Note>.from((map['notes'] as List<dynamic>)
          .map((item) => Note.fromJson(item as String))),
      highlights: List<Highlight>.from((map['highlights'] as List<dynamic>)
          .map((item) => Highlight.fromJson(item as String))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) =>
      Book.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => """Book(
          id: $id, 
          totalPageNumber: $totalPageNumber, 
          currentPageNumber: $currentPageNumber, 
          lastRead: ${lastRead.toIso8601String()}, 
          title: $title, 
          description: $description, 
          author: $author, 
          rating: $rating, 
          imageFilePath: $imageFilePath, 
          pdfFilePath: $pdfFilePath, 
          genres: $genres, 
          isFavourite: $isFavourite,
          durationRead: $durationRead,
          bookmarks: $bookmarks,
          notes: $notes,
          highlights: $highlights,
      )""";

  @override
  bool operator ==(covariant Book other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.totalPageNumber == totalPageNumber &&
        other.currentPageNumber == currentPageNumber &&
        other.lastRead == lastRead &&
        other.title == title &&
        other.description == description &&
        other.author == author &&
        other.rating == rating &&
        other.imageFilePath == imageFilePath &&
        other.pdfFilePath == pdfFilePath &&
        other.genres == genres &&
        other.isFavourite == isFavourite &&
        other.durationRead == durationRead &&
        other.bookmarks == bookmarks &&
        other.notes == notes &&
        other.highlights == highlights;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      totalPageNumber.hashCode ^
      currentPageNumber.hashCode ^
      lastRead.hashCode ^
      title.hashCode ^
      description.hashCode ^
      author.hashCode ^
      rating.hashCode ^
      imageFilePath.hashCode ^
      pdfFilePath.hashCode ^
      genres.hashCode ^
      isFavourite.hashCode ^
      durationRead.hashCode ^
      bookmarks.hashCode ^
      notes.hashCode ^
      highlights.hashCode;

  int get readPercentage {
    if (totalPageNumber == 0) {
      return 0;
    }

    return ((currentPageNumber / totalPageNumber) * 100).toInt();
  }
}

class BooksState {
  final List<Book> allBooks;
  final List<Book> filteredBooks;

  BooksState({required this.allBooks, required this.filteredBooks});

  BooksState copyWith({List<Book>? allBooks, List<Book>? filteredBooks}) {
    return BooksState(
      allBooks: allBooks ?? this.allBooks,
      filteredBooks: filteredBooks ?? this.filteredBooks,
    );
  }
}
