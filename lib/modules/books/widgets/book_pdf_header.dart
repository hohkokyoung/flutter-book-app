import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

class BookPdfHeader extends ConsumerStatefulWidget {
  final PdfViewerController pdfViewerController;
  final PdfTextSearcher pdfTextSearcher;
  final Function() update;
  final Function() resetAfterSnapFirstSearch;

  const BookPdfHeader({
    super.key,
    required this.pdfViewerController,
    required this.pdfTextSearcher,
    required this.update,
    required this.resetAfterSnapFirstSearch,
  });

  @override
  ConsumerState<BookPdfHeader> createState() => _BookPdfHeaderState();
}

class _BookPdfHeaderState extends ConsumerState<BookPdfHeader> {
  bool isSearching = false;
  final TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 30,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (isSearching) {
                setState(() {
                  isSearching = false;
                });
                widget.resetAfterSnapFirstSearch();
                widget.pdfTextSearcher.resetTextSearch();
                _searchTextController.clear();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Icon(
              Icons.arrow_back_ios_rounded,
            ),
          ),
          if (isSearching)
            Flexible(
              child: SearchBar(
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
                elevation: const WidgetStatePropertyAll(0),
                hintText: "Search in book",
                onSubmitted: (value) {
                  widget.pdfTextSearcher.resetTextSearch();
                  widget.resetAfterSnapFirstSearch();
                  widget.pdfTextSearcher
                      .startTextSearch(value, caseInsensitive: true);
                },
                constraints: const BoxConstraints(minHeight: 10),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                controller: _searchTextController,
              ),
            ),
          Row(
            children: [
              if (!isSearching && widget.pdfViewerController.isReady)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  child: const Icon(Icons.search),
                )
              else if (widget.pdfTextSearcher.hasMatches)
                GestureDetector(
                  onTap: () async {
                    await widget.pdfTextSearcher.goToPrevMatch();
                    await widget.pdfViewerController.goToPage(
                        pageNumber:
                            widget.pdfTextSearcher.controller!.pageNumber!);
                    widget.update();
                  },
                  child: const Icon(Icons.arrow_left_rounded),
                ),
              if (widget.pdfTextSearcher.hasMatches) const SizedBox(width: 8),
              if (widget.pdfTextSearcher.hasMatches)
                Text(
                  "${widget.pdfTextSearcher.currentIndex! + 1} / ${widget.pdfTextSearcher.matches.length}",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8),
              if (!isSearching)
                const Icon(
                  Icons.more_vert,
                )
              else if (widget.pdfTextSearcher.hasMatches)
                GestureDetector(
                  onTap: () async {
                    await widget.pdfTextSearcher.goToNextMatch();
                    await widget.pdfViewerController.goToPage(
                        pageNumber:
                            widget.pdfTextSearcher.controller!.pageNumber!);
                    widget.update();
                  },
                  child: const Icon(
                    Icons.arrow_right_rounded,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
