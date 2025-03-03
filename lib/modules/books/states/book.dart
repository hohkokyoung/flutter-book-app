import 'package:booksum/modules/books/models/book.dart';
import 'package:booksum/modules/books/models/bookmark.dart';
import 'package:booksum/modules/books/models/enum.dart';
import 'package:booksum/modules/books/models/highlight.dart';
import 'package:booksum/modules/books/models/note.dart';
import 'package:booksum/modules/core/utils/global.dart';
import 'package:booksum/services/global.dart';
import 'package:booksum/services/interfaces/global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'dart:ui' as ui;

class BookRepository {
  List<Book> get defaultBooks => List.generate(4, (index) {
        return Book(
          title: "Empty Book Title......................................",
          description: "",
          author: "Corey J. Ball",
          currentPageNumber: 0,
          totalPageNumber: 0,
          pdfFilePath: "",
          imageFilePath: "",
          lastRead: DateTime.now().subtract(const Duration(days: 3)),
          rating: 4.0,
          genres: ["Testing"],
          isFavourite: true,
          durationRead: const Duration(hours: 0),
          bookmarks: [],
          notes: [],
          highlights: [],
        );
      });

  Book get emptyTemporaryBook => Book(
        id: -1,
        title: "",
        description: "",
        author: "",
        currentPageNumber: 0,
        totalPageNumber: 0,
        pdfFilePath: "",
        imageFilePath: "",
        lastRead: DateTime.utc(0000, 1, 1),
        rating: 0,
        genres: [],
        isFavourite: false,
        durationRead: const Duration(hours: 0),
        bookmarks: [],
        notes: [],
        highlights: [],
      );

  static final List<Book> _books = [
    Book(
      id: 1,
      title: "#1 Book Title",
      description:
          "Lorem Ipsum es simplemente el texto de relleno de las imprentas y archivos de texto. Lorem Ipsum ha sido el texto de relleno estándar de las industrias desde el año 1500, c",
      author: "Corey J. Ball",
      currentPageNumber: 40,
      totalPageNumber: 613,
      pdfFilePath: "assets/pdfs/book-pdf-2.pdf",
      imageFilePath: "",
      lastRead: DateTime.now().subtract(const Duration(days: 3)),
      rating: 4.0,
      genres: ["Science", "Technology", "Horror"],
      isFavourite: true,
      durationRead: const Duration(hours: 1, minutes: 40),
      bookmarks: [
        Bookmark(
          title: "Bookmark Title",
          description: "First bookmark",
          pageNumber: 1,
        )
      ],
      notes: [],
      highlights: [],
    ),
    Book(
      id: 2,
      title: "#2 Book Title",
      description:
          "Lorem Ipsum es simplemente el texto de relleno de las imprentas y archivos de texto. Lorem Ipsum ha sido el texto de relleno estándar de las industrias desde el año 1500, c",
      author: "Corey J. Ball",
      currentPageNumber: 402,
      totalPageNumber: 613,
      pdfFilePath: "assets/pdfs/book-pdf-2.pdf",
      imageFilePath: "",
      lastRead: DateTime.now().subtract(const Duration(days: 2)),
      rating: 4.5,
      genres: ["Hacking", "Horror"],
      isFavourite: false,
      durationRead: const Duration(hours: 0, minutes: 20),
      bookmarks: [],
      notes: [],
      highlights: [],
    ),
    Book(
      id: 3,
      title: "Hacking APIs: Breaking Web Application Programming Interfaces",
      description:
          "Lorem Ipsum es simplemente el texto de relleno de las imprentas y archivos de texto. Lorem Ipsum ha sido el texto de relleno estándar de las industrias desde el año 1500, c",
      author: "Corey J. Ball",
      currentPageNumber: 363,
      totalPageNumber: 363,
      pdfFilePath: "assets/pdfs/book-pdf-1.pdf",
      imageFilePath: "",
      lastRead: DateTime.now().subtract(const Duration(days: 1)),
      rating: 3.0,
      genres: ["Programming", "Horror"],
      isFavourite: false,
      durationRead: const Duration(hours: 3, minutes: 30),
      bookmarks: [],
      notes: [],
      highlights: [],
    ),
  ];

  final ConnectionClient client;

  BookRepository({required this.client});

  Future<void> addBooks(Book book) async {
    final books = _books;
    final updatedBooks = [...books, book];
    await client.writeMany(updatedBooks);
  }

  Future<void> deleteBook(int id) async {
    final books = _books;
    final updatedBooks = books.where((book) => book.id != id).toList();
    await client.writeMany(updatedBooks);
  }

  Future<List<Book>> fetchBooks() async {
    final books = await client.readMany() as List<Book>;
    // await Future.delayed(const Duration(seconds: 2));

    // List<Book> books = _books;

    // if (query.isNotEmpty) {
    //   books = books
    //       .where(
    //           (book) => book.title.toLowerCase().contains(query.toLowerCase()))
    //       .toList();
    // }

    return books;
  }

  Future<Book> fetchBook(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    final books = await client.readMany() as List<Book>;
    return books.where((book) => book.id == id).single;
  }

  Future<Book> fetchLatestReadBook() async {
    // await Future.delayed(const Duration(seconds: 2));
    final books = await client.readMany() as List<Book>;
    return books.reduce((a, b) => a.lastRead.isAfter(b.lastRead) ? a : b);
  }
}

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => BookRepository(
    client: ConnectionClientFactory.createConnectionClient<Book>(
      useApi: false,
      pathOrUrl: "books.json",
      fromMap: (json) => Book.fromMap(json),
      toMap: (book) => book.toMap(),
    ),
  ),
);

class LatestReadBookNotifier extends AsyncNotifier<Book?> {
  @override
  Future<Book> build() async {
    state = const AsyncLoading();
    return await fetchLatestReadBook();
  }

  BookRepository get _repository => ref.read(bookRepositoryProvider);

  Future<Book> fetchLatestReadBook() async {
    final latestReadBook = await _repository.fetchLatestReadBook();
    return latestReadBook;
  }

  void syncState(Book updatedBook) {
    if (state.value?.id == updatedBook.id) {
      state = AsyncData(updatedBook);
    }
  }

  void syncRemoveState(int id) {
    if (state.value?.id == id) {
      state = const AsyncData(null);

      final booksState = ref.read(booksProvider);
      if (booksState.hasValue) {
        state = AsyncData(booksState.value!.allBooks
            .reduce((a, b) => a.lastRead.isAfter(b.lastRead) ? a : b));
      }
    }
  }
}

final latestReadBookProvider =
    AsyncNotifierProvider<LatestReadBookNotifier, Book?>(
        LatestReadBookNotifier.new);

class BooksNotifier extends AsyncNotifier<BooksState> {
  @override
  Future<BooksState> build() async {
    state = const AsyncValue.loading();
    List<Book> books = await fetchBooks();
    return BooksState(allBooks: books, filteredBooks: books);
  }

  BookRepository get _repository => ref.read(bookRepositoryProvider);

  Future<List<Book>> fetchBooks() async {
    final books = await _repository.fetchBooks();
    return books;
  }

  Future<void> searchBooks(String query) async {
    final booksState = state.value;

    if (booksState == null) return;

    if (query.isEmpty) {
      state =
          AsyncData(booksState.copyWith(filteredBooks: booksState.allBooks));
    } else {
      state = AsyncData(booksState.copyWith(filteredBooks: []));
      try {
        final filteredBooks = booksState.allBooks
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        state = AsyncData(booksState.copyWith(filteredBooks: filteredBooks));
      } catch (e, stackTrace) {
        state = AsyncError(e, stackTrace);
      }
    }
  }

  Future<void> resetSearch() async {
    await searchBooks("");
  }

  void syncState(Book updatedBook, {bool sortByLastRead = false}) {
    final booksState = state.value;
    if (booksState == null) return;

    List<Book> updateAndSort(List<Book> books) {
      final bookIndex = books.indexWhere((b) => b.id == updatedBook.id);
      if (bookIndex != -1) {
        books[bookIndex] = updatedBook;
      } else {
        books.add(updatedBook..id = books.length + 1);
      }
      if (sortByLastRead) {
        books.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      }
      return books;
    }

    state = AsyncData(booksState.copyWith(
      allBooks: updateAndSort(List.of(booksState.allBooks)),
      filteredBooks: updateAndSort(List.of(booksState.filteredBooks)),
    ));
  }

  void syncRemoveState(int id) {
    final booksState = state.value;
    if (booksState == null) return;

    state = AsyncData(booksState.copyWith(
      allBooks: booksState.allBooks.where((book) => book.id != id).toList(),
      filteredBooks:
          booksState.filteredBooks.where((book) => book.id != id).toList(),
    ));
  }

  Book? syncLastReadState(Book updatedBook) {
    syncState(updatedBook, sortByLastRead: true);
    return state.value?.allBooks.firstOrNull;
  }
}

final booksProvider =
    AsyncNotifierProvider<BooksNotifier, BooksState>(BooksNotifier.new);

class BookNotifier extends AsyncNotifier<Book?> {
  @override
  Future<Book> build() async {
    state = const AsyncLoading();

    final bookId = ref.watch(selectedBookIdProvider);

    if (bookId == _repository.emptyTemporaryBook.id) {
      return _repository.emptyTemporaryBook;
    }

    if (ref.read(latestReadBookProvider).hasValue) {
      final latestReadBook = ref.read(latestReadBookProvider).value!;
      if (latestReadBook.id == bookId) {
        return latestReadBook;
      }
    }
    return await fetchBook(bookId);
  }

  BookRepository get _repository => ref.read(bookRepositoryProvider);

  Future<Book> fetchBook(int id) async {
    final book = await _repository.fetchBook(id);
    return book;
  }

  void setLastRead() {
    final bookState = state.value;

    if (bookState == null) return;

    final updatedBook = bookState.copyWith(lastRead: DateTime.now());
    state = AsyncData(updatedBook);

    Book? updatedLastReadBook =
        ref.read(booksProvider.notifier).syncLastReadState(updatedBook);
    if (updatedLastReadBook != null) {
      ref.read(latestReadBookProvider.notifier).syncState(updatedLastReadBook);
    }
  }

  void _updateState(Book Function(Book) update, {bool syncState = true}) {
    final bookState = state.value;
    if (bookState == null) return;

    state = AsyncData(update(bookState));

    if (syncState) {
      ref.read(booksProvider.notifier).syncState(state.value!);
      ref.read(latestReadBookProvider.notifier).syncState(state.value!);
    }
  }

  void _removeState() {
    final bookState = state.value;
    if (bookState == null) return;

    final bookId = bookState.id;

    state = const AsyncData(null);

    ref.read(booksProvider.notifier).syncRemoveState(bookId);
    ref.read(latestReadBookProvider.notifier).syncRemoveState(bookId);
  }

  void toggleFavourite() {
    _updateState((bookState) => bookState.copyWith(
          isFavourite: !bookState.isFavourite,
        ));

    //1. update the state
    //2. debouncing the api call (todo)
  }

  void addBookmark(Bookmark bookmark) {
    _updateState(
      (bookState) {
        final updatedBookmarks = [...bookState.bookmarks, bookmark]
          ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

        return bookState.copyWith(bookmarks: updatedBookmarks);
      },
    );
  }

  void deleteBookmark(int pageNumber) {
    _updateState((bookState) => bookState.copyWith(
          bookmarks: bookState.bookmarks
              .where((bookmark) => bookmark.pageNumber != pageNumber)
              .toList(),
        ));
  }

  void addNote(Note note) {
    _updateState((bookState) {
      final updatedNotes = [...bookState.notes, note]
        ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

      return bookState.copyWith(notes: updatedNotes);
    });
  }

  void deleteNote(int id) {
    _updateState((bookState) => bookState.copyWith(
          notes: bookState.notes.where((note) => note.id != id).toList(),
        ));
  }

  void setCurrentPageNumber(int pageNumber) {
    _updateState((bookState) => bookState.copyWith(
          currentPageNumber: pageNumber,
        ));
  }

  void updateDurationRead(Duration durationPassed) {
    _updateState((bookState) => bookState.copyWith(
          durationRead: bookState.durationRead + durationPassed,
        ));
  }

  void addHighlight(Highlight highlight) {
    final bookState = state.value;
    if (bookState == null) return;

    _updateState((bookState) {
      final updatedHighlights = List.of(bookState.highlights)..add(highlight);
      updatedHighlights.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

      return bookState.copyWith(highlights: updatedHighlights);
    });
  }

  (List<PdfRect>, List<int>) getAllHighlights(HighlightType highlightType) {
    final bookState = state.value;
    if (bookState == null) return ([], []);

    final highlightedIndexes = List<int>.filled(bookState.totalPageNumber, 0);
    List<PdfRect> highlightedPdfRects = [];

    switch (highlightType) {
      case HighlightType.text:
        for (var highlight in bookState.highlights) {
          for (int i = highlight.pageNumber;
              i < bookState.totalPageNumber;
              i++) {
            highlightedIndexes[i] += 1;
          }
        }
        highlightedPdfRects =
            bookState.highlights.map((highlight) => highlight.pdfRect).toList();
      case HighlightType.note:
        for (var note in bookState.notes) {
          for (int i = note.pageNumber; i < bookState.totalPageNumber; i++) {
            highlightedIndexes[i] += 1;
          }
        }
        highlightedPdfRects =
            bookState.notes.map((note) => note.highlight.pdfRect).toList();
    }

    return (highlightedPdfRects, highlightedIndexes);
  }

  void modifyTitle(String title) {
    _updateState((bookState) => bookState.copyWith(title: title),
        syncState: false);
  }

  void modifyAuthor(String author) {
    _updateState((bookState) => bookState.copyWith(author: author),
        syncState: false);
  }

  void modifyImageFilePath(String imageFilePath) {
    _updateState(
        (bookState) => bookState.copyWith(imageFilePath: imageFilePath),
        syncState: false);
  }

  void modifyPdfFilePath(String pdfFilePath) {
    _updateState((bookState) => bookState.copyWith(pdfFilePath: pdfFilePath),
        syncState: false);
  }

  void modifyPageNumber(int totalPageNumber) {
    _updateState(
        (bookState) => bookState.copyWith(
            currentPageNumber: 1, totalPageNumber: totalPageNumber),
        syncState: false);
  }

  void modifyRating(double rating) {
    _updateState((bookState) => bookState.copyWith(rating: rating),
        syncState: false);
  }

  void modifyDescription(String description) {
    _updateState((bookState) => bookState.copyWith(description: description),
        syncState: false);
  }

  void modifyGenres(List<String> genres) {
    _updateState((bookState) => bookState.copyWith(genres: genres),
        syncState: false);
  }

  void saveBook() {
    _updateState((bookState) => bookState);
    _repository.addBooks(state.value!);
  }

  void removeBook() {
    final bookId = state.value!.id;
    _removeState();
    _repository.deleteBook(bookId);
  }

  void selectTemporaryBook() {
    state = AsyncData(_repository.emptyTemporaryBook.copyWith());
    ref.read(selectedBookIdProvider.notifier).state =
        _repository.emptyTemporaryBook.id;
  }

  void resetTemporaryBook() {
    state = AsyncData(_repository.emptyTemporaryBook.copyWith());
  }
}

final bookProvider =
    AsyncNotifierProvider<BookNotifier, Book?>(BookNotifier.new);

final selectedBookIdProvider = StateProvider<int>((ref) => 1);
