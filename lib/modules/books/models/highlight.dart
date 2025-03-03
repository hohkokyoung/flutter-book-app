import 'dart:convert';

import 'package:pdfrx/pdfrx.dart';

class Highlight {
  int pageNumber;
  String text;
  PdfRect pdfRect;

  Highlight({
    required this.pageNumber,
    required this.text,
    required this.pdfRect,
  });

  Highlight copyWith({int? pageNumber, String? text, PdfRect? pdfRect}) {
    return Highlight(
      pageNumber: pageNumber ?? this.pageNumber,
      text: text ?? this.text,
      pdfRect: pdfRect ?? this.pdfRect,
    );
  }
  
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pageNumber': pageNumber,
      'text': text,
      'pdfRect': pdfRect,
    };
  }

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      pageNumber: map['pageNumber'] as int,
      text: map['text'] as String,
      pdfRect: map['pdfRect'] as PdfRect,
    );
  }

  String toJson() => json.encode(toMap());

  factory Highlight.fromJson(String source) =>
      Highlight.fromMap(json.decode(source) as Map<String, dynamic>);
}