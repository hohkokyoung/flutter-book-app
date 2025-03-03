import 'package:booksum/modules/books/screens/book_pdf_index_screen.dart';
import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdfrx/pdfrx.dart';

class BookPdfBottomBar extends ConsumerStatefulWidget {
  final PdfViewerController pdfViewerController;
  final List<Widget> tableOfContentsWidgets;
  final double posX;
  final double scrollBarWidth;
  final Function(double) setScrollBarWidth;

  const BookPdfBottomBar({
    super.key,
    required this.pdfViewerController,
    required this.tableOfContentsWidgets,
    required this.posX,
    required this.scrollBarWidth,
    required this.setScrollBarWidth,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookPdfBottomBarState();
}

class _BookPdfBottomBarState extends ConsumerState<BookPdfBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      child: Visibility(
        visible: widget.pdfViewerController.isReady,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRightWithFade,
                    child: BookPdfIndexScreen(
                      pdfViewerController: widget.pdfViewerController,
                      tableOfContentsWidgets: widget.tableOfContentsWidgets,
                    ),
                  ),
                );
              },
              child: const SizedBox(
                width: 50,
                child: Icon(
                  Icons.menu_open,
                  size: 16,
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      onPanUpdate: (details) async {
                        await calculateCurrentPageNumberAndJump(
                          details,
                          constraints,
                        );
                      },
                      onTapDown: (details) async {
                        await calculateCurrentPageNumberAndJump(
                          details,
                          constraints,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                // this is to simultaneously set the scrollBarWidth
                                // while to prevent the scrollPointer from overflowing the bar
                                if (widget.scrollBarWidth == 0 &&
                                    widget.scrollBarWidth !=
                                        constraints.maxWidth) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    widget.setScrollBarWidth(
                                        constraints.maxWidth);
                                  });
                                }

                                return Container(
                                  height: 2, // Inner line height
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary, // Color of the line
                                    borderRadius: defaultBorderRadius,
                                  ),
                                );
                              },
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 0),
                            left: widget.posX,
                            child: Container(
                              alignment: Alignment.center,
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: defaultBorderRadius,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: defaultBorderRadius,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Go to page",
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.fontSize,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: "Page number",
                                  labelStyle: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.fontSize,
                                  ),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.fontSize,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allows only digits
                                ],
                                onSubmitted: (String value) async {
                                  final pageNumber = int.tryParse(value);
                                  if (pageNumber != null) {
                                    await widget.pdfViewerController.goToPage(
                                      pageNumber: pageNumber,
                                      duration: const Duration(milliseconds: 0),
                                    );
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: SizedBox(
                width: 50,
                child: Text(
                  "${widget.pdfViewerController.isReady ? widget.pdfViewerController.pageNumber : 0} / ${widget.pdfViewerController.isReady ? widget.pdfViewerController.pageCount : 0}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> calculateCurrentPageNumberAndJump(
      dynamic details, BoxConstraints constraints) async {
    final double currentX = switch (details) {
      DragUpdateDetails d => d.localPosition.dx,
      TapDownDetails t => t.localPosition.dx,
      _ => throw ArgumentError('Expected DragUpdateDetails or TapDownDetails'),
    };
    final double maxPosition = constraints.maxWidth - 10;

    final positionX = currentX.clamp(0, maxPosition);
    final currentPageNumberCalculated =
        ((positionX / maxPosition) * widget.pdfViewerController.pageCount + 1)
            .round()
            .clamp(0, widget.pdfViewerController.pageCount);

    await widget.pdfViewerController.goToPage(
      pageNumber: currentPageNumberCalculated,
      duration: const Duration(milliseconds: 0),
    );
  }
}
