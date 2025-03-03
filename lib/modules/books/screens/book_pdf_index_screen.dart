import 'package:booksum/modules/books/states/book.dart';
import 'package:booksum/modules/core/widgets/background_paint.dart';
import 'package:booksum/modules/books/models/bookmark.dart';
import 'package:booksum/modules/books/models/enum.dart';
import 'package:booksum/modules/books/models/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/src/widgets/pdf_viewer.dart';

import '../widgets/typewriter_text.dart';

class BookPdfIndexScreen extends ConsumerStatefulWidget {
  final PdfViewerController pdfViewerController;
  final List<Widget> tableOfContentsWidgets;
  const BookPdfIndexScreen({
    super.key,
    required this.pdfViewerController,
    required this.tableOfContentsWidgets,
  });

  @override
  ConsumerState<BookPdfIndexScreen> createState() => _BookPdfIndexScreenState();
}

class _BookPdfIndexScreenState extends ConsumerState<BookPdfIndexScreen> {
  IndexCategory currentIndexCategory = IndexCategory.tableOfContents;

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);
    final book = bookState.value!;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            getIndexScreenByCategory(book.bookmarks, book.notes),
            const BackgroundPaint(),
            Container(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back_ios_rounded),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndexCategory = IndexCategory.tableOfContents;
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.format_list_numbered_rounded),
                        const SizedBox(
                          width: 4,
                        ),
                        TypewriterText(
                          text: currentIndexCategory ==
                                  IndexCategory.tableOfContents
                              ? "Table of Contents"
                              : "",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndexCategory = IndexCategory.bookmarks;
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_border_rounded),
                        const SizedBox(
                          width: 4,
                        ),
                        TypewriterText(
                          text: currentIndexCategory == IndexCategory.bookmarks
                              ? "Bookmarks"
                              : "",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndexCategory = IndexCategory.notes;
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.text_snippet_outlined),
                        const SizedBox(
                          width: 4,
                        ),
                        TypewriterText(
                          text: currentIndexCategory == IndexCategory.notes
                              ? "Notes"
                              : "",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getIndexScreenByCategory(List<Bookmark> bookmarks, List<Note> notes) {
    switch (currentIndexCategory) {
      case IndexCategory.tableOfContents:
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                  top: 150,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: Column(
                  children: widget.tableOfContentsWidgets,
                ),
              ),
            ],
          ),
        );
      case IndexCategory.bookmarks:
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              return BookPdfIndexListItem(
                pdfViewerController: widget.pdfViewerController,
                id: bookmarks[index].pageNumber,
                pageNumber: bookmarks[index].pageNumber,
                index: index,
                itemLength: bookmarks.length,
                title: bookmarks[index].title,
                description: bookmarks[index].description,
                content: null,
                onDelete: (id) {
                  ref.read(bookProvider.notifier).deleteBookmark(id);
                },
              );
            },
          ),
        );

      case IndexCategory.notes:
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return BookPdfIndexListItem(
                pdfViewerController: widget.pdfViewerController,
                id: notes[index].id,
                pageNumber: notes[index].pageNumber,
                index: index,
                itemLength: notes.length,
                title: notes[index].title,
                description: notes[index].highlight.text,
                content: notes[index].text,
                onDelete: (id) {
                  ref.read(bookProvider.notifier).deleteNote(id);
                  // ref
                  //     .read(noteHighlightNotifierProvider.notifier)
                  //     .deleteHighlight(notes[index].pageNumber, id);
                },
              );
            },
          ),
        );
    }
  }
}

class BookPdfIndexListItem extends StatefulWidget {
  final PdfViewerController pdfViewerController;
  final int id;
  final int pageNumber;
  final int index;
  final int itemLength;
  final String title;
  final String description;
  final String? content;
  final Function(int) onDelete;

  const BookPdfIndexListItem({
    super.key,
    required this.pdfViewerController,
    required this.id,
    required this.pageNumber,
    required this.index,
    required this.itemLength,
    required this.title,
    required this.description,
    required this.content,
    required this.onDelete,
  });

  @override
  State<BookPdfIndexListItem> createState() => BookPdfIndexListItemState();
}

class BookPdfIndexListItemState extends State<BookPdfIndexListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: widget.index == 0 ? 150 : 0,
        bottom: widget.index == widget.itemLength - 1 ? 30 : 0,
      ),
      child: Transform.translate(
        // offset: const Offset(-.2, -1.6),
        offset: const Offset(0, 0),
        child: GestureDetector(
          onTap: () {
            widget.pdfViewerController.goToPage(pageNumber: widget.pageNumber);
            Navigator.of(context).pop();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_rounded),
                title: Container(
                  padding: const EdgeInsets.only(top: 0, bottom: 0.0),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleSmall?.fontSize,
                    ),
                  ),
                ),
                subtitle: Text(
                  "― page number ${widget.pageNumber.toString()}",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    color:
                        Theme.of(context).colorScheme.secondary.withOpacity(.6),
                  ),
                ),
                trailing: PopupMenuButton(
                  menuPadding: const EdgeInsets.all(0),
                  elevation: 2,
                  color: Theme.of(context).colorScheme.primary,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.fontSize,
                          ),
                        ),
                        onTap: () {
                          widget.onDelete(widget.id);
                        },
                      ),
                    ];
                  },
                ),
              ),
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(left: 54, right: 54),
                child: Text(
                  widget.description,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    overflow: TextOverflow.ellipsis,
                    backgroundColor: widget.content != null
                        ? Theme.of(context).colorScheme.primary.withOpacity(.5)
                        : Colors.transparent,
                  ),
                ),
              ),
              if (widget.content != null)
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(top: 10, left: 54, right: 54),
                  child: Text(
                    widget.content!,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
