import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:booksum/modules/books/models/book.dart';
import 'package:booksum/modules/books/models/enum.dart';
import 'package:booksum/modules/books/models/highlight.dart';
import 'package:booksum/modules/books/states/book.dart';
import 'package:booksum/modules/books/widgets/book_pdf_header.dart';
import 'package:booksum/modules/home/states/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_flip/page_flip.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:booksum/modules/core/utils/global.dart';
import 'package:booksum/modules/books/models/bookmark.dart';
import 'package:booksum/modules/books/models/note.dart';
import 'package:booksum/modules/books/widgets/book_pdf_bottom_bar.dart';
import 'package:booksum/modules/books/widgets/bookmark_paint.dart';

class BookPdfScreen extends ConsumerStatefulWidget {
  const BookPdfScreen({super.key});

  @override
  ConsumerState<BookPdfScreen> createState() => _BookPdfScreenState();
}

class _BookPdfScreenState extends ConsumerState<BookPdfScreen> {
  final GlobalKey _pdfViewerKey = GlobalKey();
  final PdfViewerController pdfViewerController = PdfViewerController();
  late final pdfTextSearcher = PdfTextSearcher(pdfViewerController)
    ..addListener(update)
    ..addListener(_snapFirstSearch);

  late List<PdfOutlineNode> _outlines;
  List<Widget> tableOfContentsWidgets = [];
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(1);

  bool _afterSnapFirstSearch = false;

  double posX = 0.0;
  double scrollBarWidth = 0;

  double startingScrollPoint = 0.0;
  int _beforeScrollPageNumber = 1;
  bool _isAboveThreshold = false;
  bool _toNext = false;

  double _bookmarkHeight = 30;
  double _nonBookmarkHeight = 0;

  final TextEditingController _noteTextController = TextEditingController();
  String _currentlyHighlightedText = "";
  PdfRect _currentlyHighlightedPdfRect = const PdfRect(0, 0, 0, 0);
  // page number, component id, list of pdf rect
  // final Map<int, Map<int, List<PdfRect>>> _highlightedTexts = {};
  // final Map<int, List<PdfRect>> _highlightedTexts = {};
  // late List<int> _highlightedTextPages = [];
  // final Map<int, Map<int, List<PdfRect>>> _highlightedNotes = {};
  // final Map<int, List<PdfRect>> _highlightedNotes = {};
  // late List<int> _highlightedNotePages = [];
  final GlobalKey _textSelectionKey = GlobalKey();
  final FocusNode _textSelectionFocusNode = FocusNode();

  late Map<String, double> pdfPageSize = {
    'height': 0,
    'width': 0,
  };

  late DateTime _readingStartTime;

  @override
  void initState() {
    _readingStartTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);

    List<Widget> getContentWidgets() {
      final book = bookState.value!;

      final textHighlights =
          ref.read(bookProvider.notifier).getAllHighlights(HighlightType.text);
      final noteHighlights =
          ref.read(bookProvider.notifier).getAllHighlights(HighlightType.note);

      return [
        SizedBox(
          height: pdfPageSize["height"].isEmpty()
              ? MediaQuery.sizeOf(context).height * .5
              : pdfPageSize["height"],
          child: PdfViewer.asset(
            book.pdfFilePath,
            initialPageNumber: book.currentPageNumber,
            controller: pdfViewerController,
            key: _pdfViewerKey,
            params: PdfViewerParams(
              onViewerReady: (document, controller) async {
                setState(() {
                  pdfPageSize["height"] =
                      pdfViewerController.visibleRect.height;
                  pdfPageSize["width"] = pdfViewerController.visibleRect.width;
                });

                List<PdfOutlineNode> outlines = await document.loadOutline();

                setState(() {
                  _outlines = outlines;
                  tableOfContentsWidgets =
                      getTableOfContentsWidgets(outlines, context);
                });

                updatePagePosition(pdfViewerController.pageNumber!,
                    pdfViewerController.pageCount);

                ref.read(statisticsNotifierProvider.notifier).addStatistics();

                ref.read(bookProvider.notifier).setLastRead();
              },
              layoutPages: (pages, params) {
                final height =
                    pages.fold(0.0, (prev, page) => max(prev, page.height)) +
                        params.margin * 2;
                final pageLayouts = <Rect>[];
                double x = params.margin;
                for (var page in pages) {
                  pageLayouts.add(
                    Rect.fromLTWH(
                      x,
                      (height - page.height) / 2, // center vertically
                      page.width + params.margin,
                      page.height,
                    ),
                  );
                  x += page.width + params.margin;
                }
                return PdfPageLayout(
                  pageLayouts: pageLayouts,
                  documentSize: Size(x, height),
                );
              },
              margin: 0,
              pageOverlaysBuilder: (context, pageRect, page) {
                return [
                  Align(
                    alignment: Alignment.topRight,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 24,
                      height: (book.bookmarks.any((bookmark) =>
                              bookmark.pageNumber ==
                              pdfViewerController.pageNumber))
                          ? _bookmarkHeight
                          : _nonBookmarkHeight,
                      margin: const EdgeInsets.only(right: 28),
                      child: CustomPaint(
                        painter: BookmarkPainter(
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ),
                  )
                ];
              },
              viewerOverlayBuilder: (context, size, handleLinkTap) => [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: () {
                    _textSelectionFocusNode.unfocus();
                    pdfViewerController.zoomUp(loop: true);
                  },

                  onTap: () {
                    _textSelectionFocusNode.unfocus();
                  },

                  // If you use GestureDetector on viewerOverlayBuilder, it breaks link-tap handling
                  // and you should manually handle it using onTapUp callback
                  onTapUp: (details) {
                    handleLinkTap(details.localPosition);
                  },

                  // Make the GestureDetector covers all the viewer widget's area
                  // but also make the event go through to the viewer.
                  child: IgnorePointer(
                    child: SizedBox(width: size.width, height: size.height),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _bookmarkHeight = 40;
                      _nonBookmarkHeight = 40;
                    });
                    int pageNumber = pdfViewerController.pageNumber!;

                    if (book.bookmarks
                        .any((bookmark) => bookmark.pageNumber == pageNumber)) {
                      ref
                          .read(bookProvider.notifier)
                          .deleteBookmark(pdfViewerController.pageNumber!);
                    } else {
                      PdfPageText pageText = await pdfViewerController
                          .pages[pageNumber - 1]
                          .loadText();
                      String title =
                          getTitleFromOutline(_outlines, pageNumber - 1);

                      ref.read(bookProvider.notifier).addBookmark(
                            Bookmark(
                              pageNumber: pageNumber,
                              title: title,
                              description: pageText.fullText
                                  .split("\n")
                                  .take(3)
                                  .join(" "),
                            ),
                          );
                    }
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        _bookmarkHeight = 30;
                        _nonBookmarkHeight = 0;
                      });
                    });
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      color: Colors.transparent,
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 14),
                    ),
                  ),
                ),
              ],
              interactionEndFrictionCoefficient:
                  0.000000000000000000000000000000000000000000000000000000000001,
              onInteractionStart: (details) {
                _textSelectionFocusNode.unfocus();
                setState(() {
                  startingScrollPoint = details.focalPoint.dx;
                  _beforeScrollPageNumber = pdfViewerController.pageNumber!;
                });
              },
              onInteractionUpdate: (details) {
                _calculatePageScrollThreshold(details);
              },
              onInteractionEnd: (details) async {
                if (!_isAboveThreshold) {
                  final int staticPageNumber = pdfViewerController.pageNumber!;

                  await pdfViewerController.goToPage(
                      pageNumber: staticPageNumber);
                } else {
                  int subsequentPageNumber = _toNext
                      ? _beforeScrollPageNumber + 1
                      : _beforeScrollPageNumber - 1;
                  int currentPageNumber = pdfViewerController.pageNumber!;

                  if (_beforeScrollPageNumber != currentPageNumber) {
                    await pdfViewerController.goToPage(
                        pageNumber: currentPageNumber);
                  } else {
                    await pdfViewerController.goToPage(
                        pageNumber: subsequentPageNumber);
                  }
                }
              },
              selectableRegionInjector: (context, child) =>
                  getSelectableRegionInjector(context, child),
              enableTextSelection: true,
              onTextSelectionChange: (selections) {
                if (selections.isNotEmpty) {
                  setState(() {
                    _currentlyHighlightedPdfRect = selections.first.bounds;
                    _currentlyHighlightedText = selections.first.text;
                  });
                }
              },
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              pageDropShadow: const BoxShadow(),
              onPageChanged: (pageNumber) {
                updatePagePosition(pageNumber!, pdfViewerController.pageCount);
                setState(() {
                  currentPageNotifier.value = pageNumber;
                });
                ref.read(bookProvider.notifier).setCurrentPageNumber(
                      pageNumber,
                    );

                if (pageNumber != book.currentPageNumber) {
                  ref
                      .read(statisticsNotifierProvider.notifier)
                      .updateStatistics(_readingStartTime);
                  _readingStartTime = DateTime.now();
                }
              },
              loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
                return Center(
                  child: CircularProgressIndicator(
                    // totalBytes may not be available on certain case
                    backgroundColor:
                        Theme.of(context).colorScheme.shadow.withOpacity(.2),
                  ),
                );
              },
              pagePaintCallbacks: [
                pdfTextSearcher.pageTextMatchPaintCallback,
                (ui.Canvas canvas, Rect pageRect, PdfPage page) =>
                    _pageHighlightedTextMatchPaintCallback(
                      canvas,
                      pageRect,
                      page,
                      textHighlights.$1,
                      textHighlights.$2,
                      Theme.of(context).colorScheme.tertiary,
                    ),
                (ui.Canvas canvas, Rect pageRect, PdfPage page) =>
                    _pageHighlightedTextMatchPaintCallback(
                      canvas,
                      pageRect,
                      page,
                      noteHighlights.$1,
                      noteHighlights.$2,
                      Theme.of(context).colorScheme.primary,
                    ),
              ],
              matchTextColor:
                  Theme.of(context).colorScheme.primary.withOpacity(.3),
              activeMatchTextColor:
                  Theme.of(context).colorScheme.primary.withOpacity(.5),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
        if (pdfViewerController.isReady)
          BookPdfBottomBar(
            pdfViewerController: pdfViewerController,
            tableOfContentsWidgets: tableOfContentsWidgets,
            posX: posX,
            scrollBarWidth: scrollBarWidth,
            setScrollBarWidth: setScrollBarWidth,
          ),
      ];
    }

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookPdfHeader(
              pdfViewerController: pdfViewerController,
              pdfTextSearcher: pdfTextSearcher,
              update: update,
              resetAfterSnapFirstSearch: resetAfterSnapFirstSearch,
            ),
            if (!bookState.isLoading) const Expanded(child: SizedBox()),
            if (bookState.isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor:
                        Theme.of(context).colorScheme.shadow.withOpacity(.2),
                  ),
                ),
              ),
            if (!bookState.isLoading) ...getContentWidgets(),
          ],
        ),
      ),
    );
  }

  void _calculatePageScrollThreshold(ScaleUpdateDetails details) {
    double scrollDistance = startingScrollPoint - details.focalPoint.dx;
    double scrollRatio = scrollDistance / MediaQuery.sizeOf(context).width;
    const double threshold = 0.1;

    bool toNext = scrollRatio > threshold;
    bool toPrevious = scrollRatio < -threshold;

    // Update threshold state
    setState(() {
      _isAboveThreshold = toNext || toPrevious;
      _toNext = toNext;
    });
  }

  Widget getSelectableRegionInjector(BuildContext context, Widget child) {
    return SelectionArea(
      key: _textSelectionKey,
      focusNode: _textSelectionFocusNode,
      contextMenuBuilder: (context, state) {
        return AdaptiveTextSelectionToolbar(
          anchors: state.contextMenuAnchors,
          children: [
            getTextSelectionHighlightToolbarItem(ref),
            getTextSelectionNoteToolbarItem(ref),
          ],
        );
      },
      child: child,
    );
  }

  Widget getTextSelectionHighlightToolbarItem(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(bookProvider.notifier).addHighlight(Highlight(
            pageNumber: pdfViewerController.pageNumber!,
            text: _currentlyHighlightedText,
            pdfRect: _currentlyHighlightedPdfRect));

        _textSelectionFocusNode.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        color: Theme.of(context).colorScheme.onPrimary,
        child: const Text("Highlight"),
      ),
    );
  }

  Widget getTextSelectionNoteToolbarItem(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          enableDrag: true,
          isDismissible: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              color: Colors.transparent,
              child: Container(
                height: 300,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 2, // Border width
                  ),
                ),
                width: MediaQuery.of(context).size.width * .8,
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteTextController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Enter text here',
                          border: InputBorder.none, // Removes underline
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              int pageNumber = pdfViewerController.pageNumber!;

                              String title = getTitleFromOutline(
                                  _outlines, pageNumber - 1);

                              Note note = Note(
                                pageNumber: pageNumber,
                                title: title,
                                text: _noteTextController.text,
                                highlight: Highlight(
                                    pageNumber: pageNumber,
                                    pdfRect: _currentlyHighlightedPdfRect,
                                    text: _currentlyHighlightedText),
                              );

                              ref.read(bookProvider.notifier).addNote(
                                    note,
                                  );

                              _noteTextController.clear();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(.6),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: const Text("Add Note"),
      ),
    );
  }

  ({int start, int end})? _getHighlightedMatchesRangeForPage(
      List<PdfRect> highlights, List<int> highlightedPages, int pageNumber) {
    if (highlightedPages.length < pageNumber) return null;
    final start = highlightedPages[pageNumber - 1];
    final end = highlightedPages.length > pageNumber
        ? highlightedPages[pageNumber]
        : highlights.length;
    return (start: start, end: end);
  }

  void _pageHighlightedTextMatchPaintCallback(
    ui.Canvas canvas,
    Rect pageRect,
    PdfPage page,
    List<PdfRect> highlights,
    List<int> highlightedPages,
    Color matchTextColor,
  ) {
    final range = _getHighlightedMatchesRangeForPage(
        highlights, highlightedPages, page.pageNumber);

    if (range == null) return;

    for (int i = range.start; i < range.end; i++) {
      final m = highlights[i];
      final rect = m
          .toRect(page: page, scaledPageSize: pageRect.size)
          .translate(pageRect.left, pageRect.top);
      canvas.drawRect(
        rect,
        Paint()..color = matchTextColor.withOpacity(.5),
      );
    }
  }

  void setScrollBarWidth(double maxWidth) {
    setState(() {
      scrollBarWidth = maxWidth - 10;
    });
  }

  List<Widget> getTableOfContentsWidgets(
      List<PdfOutlineNode> tableOfContents, BuildContext context) {
    List<Widget> tableOfContentsWidgets = [];

    String getPageNumberText(
        PdfOutlineNode content, int pageNumber, int currentPageNumber) {
      String pageNumberText = "";

      pageNumberText = "page number $pageNumber";

      if (pageNumber == currentPageNumber) {
        pageNumberText = "currently on $pageNumberText";
      }
      return pageNumberText;
    }

    Color getColor(int pageNumber, int currentPageNumber) {
      return pageNumber == currentPageNumber
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary;
    }

    void addTableOfContentsWidgets(
        List<PdfOutlineNode> contents, List<Widget> parentWidgets,
        [int level = 0]) {
      for (int i = 0; i < contents.length; i++) {
        List<Widget> nestedContentWidgets = [];
        int pageNumber = contents[i].dest!.pageNumber;
        parentWidgets.add(
          Padding(
            padding: EdgeInsets.only(left: level * 12),
            child: ListTileTheme(
              minVerticalPadding: 0,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.only(right: 16),
                minTileHeight: 0,
                dense: true,
                title: ValueListenableBuilder(
                  valueListenable: currentPageNotifier,
                  builder: (context, currentPageNumber, child) {
                    return GestureDetector(
                      onTap: () {
                        pdfViewerController.goToPage(pageNumber: pageNumber);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(
                            left: 16, top: 12, bottom: 12.0),
                        child: Text(
                          contents[i].title,
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.fontSize,
                            color: getColor(pageNumber, currentPageNumber),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                subtitle: ValueListenableBuilder(
                  valueListenable: currentPageNotifier,
                  builder: (context, currentPageNumber, child) {
                    return GestureDetector(
                      onTap: () {
                        pdfViewerController.goToPage(pageNumber: pageNumber);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(
                            left: 16, right: 12, bottom: 12),
                        child: Text(
                          getPageNumberText(
                              contents[i], pageNumber, currentPageNumber),
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.bodySmall?.fontSize,
                            color: getColor(pageNumber, currentPageNumber),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                showTrailingIcon: contents[i].children.isNotEmpty,
                shape: const Border(),
                children: nestedContentWidgets,
              ),
            ),
          ),
        );

        if (contents[i].children.isNotEmpty) {
          addTableOfContentsWidgets(
              contents[i].children, nestedContentWidgets, level + 1);
        }
      }
    }

    addTableOfContentsWidgets(tableOfContents, tableOfContentsWidgets);

    return tableOfContentsWidgets;
  }

  void updatePagePosition(int currentPageNumber, int totalPageNumber) {
    posX = ((currentPageNumber - 1) / totalPageNumber) * scrollBarWidth;

    posX.clamp(0.0, scrollBarWidth);
  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  void resetAfterSnapFirstSearch() {
    setState(() {
      _afterSnapFirstSearch = false;
    });
  }

  void _snapFirstSearch() async {
    if (mounted) {
      if (pdfTextSearcher.hasMatches && pdfTextSearcher.currentIndex == 0) {
        if (!_afterSnapFirstSearch) {
          await pdfViewerController.goToPage(
              pageNumber: pdfTextSearcher.matches.first.pageNumber);
          setState(() {
            _afterSnapFirstSearch = true;
          });
        }
      }
    }
  }

  String getTitleFromOutline(List<PdfOutlineNode> outlines, int pageNumber) {
    for (var outline in outlines) {
      if (pageNumber < outline.dest!.pageNumber) {
        return outline.title;
      }
      getTitleFromOutline(outline.children, pageNumber);
    }
    return "";
  }

  @override
  void dispose() {
    pdfTextSearcher.removeListener(update);
    pdfTextSearcher.removeListener(_snapFirstSearch);
    pdfTextSearcher.dispose();
    _noteTextController.dispose();
    super.dispose();
  }
}
