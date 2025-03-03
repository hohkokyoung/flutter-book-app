import 'dart:io';
import 'dart:typed_data';

import 'package:booksum/modules/books/models/book.dart';
import 'package:booksum/modules/books/models/enum.dart';
import 'package:booksum/modules/books/states/book.dart';
import 'package:booksum/modules/core/models/enum.dart';
import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:booksum/modules/core/widgets/default_button.dart';
import 'package:booksum/modules/core/widgets/default_field.dart';
import 'package:booksum/modules/core/widgets/default_image_field.dart';
import 'package:booksum/modules/core/widgets/default_text_field.dart';
import 'package:booksum/modules/home/models/chart_data.dart';
import 'package:choice/choice.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:booksum/modules/books/screens/book_pdf_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:ui' as ui;

class BookDetailScreen extends ConsumerStatefulWidget {
  final ScreenState screenState;

  const BookDetailScreen({
    super.key,
    required this.screenState,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);

    return bookState.when(
      data: (book) => BookDetailContainer(
        screenState: widget.screenState,
        book: book ?? ref.read(bookRepositoryProvider).defaultBooks.first,
        isLoading: false,
      ),
      loading: () => BookDetailContainer(
        screenState: widget.screenState,
        book: ref.read(bookRepositoryProvider).defaultBooks.first,
        isLoading: true,
      ),
      error: (error, stack) {
        return Center(child: Text("Error: $error"));
      },
    );
  }
}

class BookDetailContainer extends ConsumerStatefulWidget {
  final ScreenState screenState;
  final Book book;
  final bool isLoading;
  const BookDetailContainer({
    super.key,
    required this.screenState,
    required this.book,
    this.isLoading = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookDetailContainerState();
}

class _BookDetailContainerState extends ConsumerState<BookDetailContainer> {
  final _formKey = GlobalKey<FormState>();
  late ScreenState _currentScreenState = widget.screenState;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> genreChoices = [
    "Technology",
    "Science",
    "Fiction",
    "Non-fiction",
    "Romance",
    "Horror",
    "Fantasy",
  ];
  ui.Image? temporaryBookImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImageFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        String filePath = result.files.single.path!;
        ref.read(bookProvider.notifier).modifyImageFilePath(filePath);
        setState(() {
          temporaryBookImage = null;
        });
      } else {}
    } catch (e) {}
  }

  Future<void> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        String fileName = result.files.single.name;
        String filePath = result.files.single.path!;
        ref.read(bookProvider.notifier).modifyPdfFilePath(fileName);
        PdfViewerController controller = PdfViewerController();
        var pdfViewer = PdfViewer.file(
          filePath,
          controller: controller,
          params: const PdfViewerParams(),
        );
        var document = await pdfViewer.documentRef.loadDocument(
          (x, [y]) {},
          (_x, y, z) {},
        );
        ref.read(bookProvider.notifier).modifyPageNumber(document.pages.length);

        var pdfImage = await document.pages[0].render(
            fullHeight: 900,
            fullWidth: 600,
            annotationRenderingMode: PdfAnnotationRenderingMode.none);
        var image = await pdfImage!.createImage();
        setState(() {
          temporaryBookImage = image;
        });
        await document.dispose();
      } else {}
    } catch (e) {}
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required.';
    }
    return null;
  }

  String? _validateAuthor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Author is required.';
    }
    return null;
  }

  ImageFileType getImageFileType(
    bool isEdit,
    String imageFilePath,
    ui.Image? temporaryBookImagePath,
  ) {
    ImageFileType imageFileType = ImageFileType.file;

    if (isEdit) {
      if (temporaryBookImagePath != null) {
        imageFileType = ImageFileType.image;
      }
    }

    return imageFileType;
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    final _isEditScreenState = _currentScreenState == ScreenState.edit;
    final _isViewScreenState = _currentScreenState == ScreenState.view;
    final _isPreviewScreenState = _currentScreenState == ScreenState.preview;

    Widget content = Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.only(top: 16, left: 34, right: 34),
      decoration: BoxDecoration(
        color: !widget.isLoading
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 40, bottom: 40),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditScreenState)
                  DefaultField(
                    label: "Pdf/Epub File",
                    text: "",
                    isEdit: _isEditScreenState,
                    showHeader: true,
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (book.pdfFilePath.isNotEmpty)
                          Flexible(
                            child: DefaultTextField(
                              text: book.pdfFilePath,
                              maxLines: 2,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        if (book.pdfFilePath.isNotEmpty)
                          const SizedBox(
                            width: 20,
                          ),
                        DefaultButton(
                          icon: Icon(
                            Icons.upload,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          padding: book.pdfFilePath.isNotEmpty
                              ? const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8)
                              : null,
                          onTap: () {
                            pickPdfFile();
                          },
                          showText: book.pdfFilePath.isEmpty,
                          showShadow: false,
                          borderRadius: BorderRadius.circular(8),
                          text: "Upload PDF/EPUB",
                        ),
                      ],
                    ),
                  ),
                if (_isEditScreenState)
                  DefaultField(
                    label: "Cover",
                    text: "",
                    isEdit: _isEditScreenState,
                    showHeader: true,
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (book.imageFilePath.isNotEmpty)
                          Flexible(
                            child: DefaultTextField(
                              text: book.imageFilePath,
                              maxLines: 2,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        if (book.imageFilePath.isNotEmpty)
                          const SizedBox(
                            width: 20,
                          ),
                        DefaultButton(
                          icon: Icon(
                            Icons.upload,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          padding: book.imageFilePath.isNotEmpty
                              ? const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8)
                              : null,
                          onTap: () {
                            pickImageFile();
                          },
                          showText: book.imageFilePath.isEmpty,
                          showShadow: false,
                          borderRadius: BorderRadius.circular(8),
                          text: "Upload Image Cover",
                        ),
                        if (book.imageFilePath.isNotEmpty)
                          const SizedBox(width: 10),
                        if (book.imageFilePath.isNotEmpty)
                          DefaultButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            padding: book.imageFilePath.isNotEmpty
                                ? const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8)
                                : null,
                            onTap: () {
                              ref
                                  .read(bookProvider.notifier)
                                  .modifyImageFilePath("");
                            },
                            showShadow: false,
                            borderRadius: BorderRadius.circular(8),
                          ),
                      ],
                    ),
                  ),
                DefaultField(
                  label: "Title",
                  text: book.title,
                  placeholder: "Book Title",
                  isLoading: widget.isLoading,
                  maxLines: _isEditScreenState ? 1 : 3,
                  isEdit: _isEditScreenState,
                  // validator: _validateTitle,
                  onChanged: (text) {
                    ref.read(bookProvider.notifier).modifyTitle(text);
                  },
                  showHeader: _isEditScreenState ? true : false,
                  controller: _titleController,
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: _isEditScreenState
                      ? Theme.of(context).textTheme.bodyMedium?.fontSize
                      : Theme.of(context).textTheme.titleMedium?.fontSize,
                ),
                DefaultField(
                  label: "Author",
                  text: _isEditScreenState ? book.author : "by ${book.author}",
                  isLoading: widget.isLoading,
                  placeholder: "Book Author",
                  maxLines: 1,
                  isEdit: _isEditScreenState,
                  onChanged: (text) {
                    ref.read(bookProvider.notifier).modifyAuthor(text);
                  },
                  showHeader: _isEditScreenState ? true : false,
                  // validator: _validateAuthor,
                  controller: _authorController,
                  color: _isEditScreenState
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.secondaryFixedDim,
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
                if (!_isEditScreenState)
                  Row(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${book.currentPageNumber} / ${book.totalPageNumber} pages",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timelapse_sharp,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${(book.durationRead.inMinutes / 60).toStringAsFixed(1)} hours",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (!_isEditScreenState)
                  const SizedBox(
                    height: 6,
                  ),
                DefaultField(
                  label: "Rating",
                  text: "",
                  isEdit: _isEditScreenState,
                  showHeader: _isEditScreenState ? true : false,
                  content: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RatingBar.builder(
                          initialRating: book.rating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: _isEditScreenState ? 22 : 16,
                          glow: false,
                          itemBuilder: (context, _) => Icon(
                            Icons.star_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          ignoreGestures: false,
                          onRatingUpdate: (value) {
                            ref.read(bookProvider.notifier).modifyRating(value);
                          },
                        ),
                        if (!_isEditScreenState) const SizedBox(width: 4),
                        if (!_isEditScreenState)
                          Text(
                            book.rating.toString(),
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.fontSize,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isEditScreenState ||
                    (!_isEditScreenState && book.genres.isNotEmpty))
                  DefaultField(
                    label: "Genres",
                    text: "",
                    isEdit: _isEditScreenState,
                    showHeader: _isEditScreenState ? true : false,
                    content: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          child: InlineChoice<String>.multiple(
                            clearable: true,
                            value: book.genres,
                            onChanged: (list) {
                              ref
                                  .read(bookProvider.notifier)
                                  .modifyGenres(list);
                            },
                            itemCount: _isEditScreenState
                                ? genreChoices.length
                                : book.genres.length,
                            itemBuilder: (state, i) {
                              return ChoiceChip(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                visualDensity:
                                    const VisualDensity(vertical: -4),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.fontSize,
                                ),
                                showCheckmark: false,
                                selected: _isEditScreenState
                                    ? state.selected(genreChoices[i])
                                    : true,
                                onSelected: _isEditScreenState
                                    ? state.onSelected(genreChoices[i])
                                    : (val) {},
                                label: _isEditScreenState
                                    ? Text(genreChoices[i])
                                    : Text(book.genres[i]),
                              );
                            },
                            listBuilder: ChoiceList.createWrapped(
                              spacing: 6,
                              runSpacing: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                DefaultField(
                  label: "Synopsis",
                  text: book.description,
                  isLoading: widget.isLoading,
                  placeholder: "Book Synopsis",
                  maxLines: _isEditScreenState ? 6 : 100,
                  isEdit: _isEditScreenState,
                  onChanged: (text) {
                    ref.read(bookProvider.notifier).modifyDescription(text);
                  },
                  showHeader: true,
                  controller: _descriptionController,
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget cover = AspectRatio(
      aspectRatio: 6 / 9,
      child: DefaultImageField(
        imagePath: book.imageFilePath,
        image: temporaryBookImage,
        imageFileType: getImageFileType(
          _isEditScreenState,
          book.imageFilePath,
          temporaryBookImage,
        ),
        // isEdit: _isEditScreenState,
        // onUpload: () {
        //   pickImageFile();
        // },
        // onClear: () {
        //   ref
        //       .read(booksProvider.notifier)
        //       .modifyImageFilePath("");
        //   ref
        //       .read(booksProvider.notifier)
        //       .clearTemporaryBookImage();
        // },
      ),
    );

    Widget action = BookDetailActions(
      book: widget.book,
      isLoading: widget.isLoading,
    );

    if (widget.isLoading) {
      content = Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade200,
        child: content,
      );

      cover = Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade200,
        child: cover,
      );

      action = Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade200,
        child: action,
      );
    }

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: BookDetailHeader(
                    book: book,
                    isViewScreenState: _isViewScreenState,
                    isLoading: widget.isLoading),
              ),
              const SizedBox(
                height: 20,
              ),
              // const Expanded(child: SizedBox()),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.isLoading)
                      Positioned.fill(
                        top: 270,
                        bottom: 0,
                        child: Container(
                          height: 270,
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.only(
                              top: 16, left: 34, right: 34),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      top: 270,
                      bottom: 0,
                      child: content,
                    ),
                    Positioned(
                      top: 0,
                      width: MediaQuery.sizeOf(context).width,
                      child: Center(
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: defaultBorderRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withOpacity(.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 2), // changes the shadow position
                              ),
                            ],
                          ),
                          child: cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: _isEditScreenState || _isPreviewScreenState
          ? ExpandableFab.location
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -5),
        child: _isEditScreenState || _isPreviewScreenState
            ? ExpandableFab(
                distance: 80,
                openButtonBuilder: buildExpandableFabOpenCloseButton(
                  Icons.miscellaneous_services_rounded,
                  Theme.of(context).colorScheme.tertiary,
                ),
                closeButtonBuilder: buildExpandableFabOpenCloseButton(
                  Icons.close_rounded,
                  Theme.of(context).colorScheme.primary,
                ),
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.restore_rounded),
                    onPressed: () {
                      ref.read(bookProvider.notifier).resetTemporaryBook();
                      _formKey.currentState!.reset();
                      _titleController.clear();
                      _authorController.clear();
                      _descriptionController.clear();
                      setState(() {
                        temporaryBookImage = null;
                      });
                    },
                  ),
                  FloatingActionButton.small(
                    heroTag: null,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.save_rounded),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //       content: Text('Form submitted successfully')),
                        // );
                        ref.read(bookProvider.notifier).saveBook();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  FloatingActionButton.small(
                    heroTag: null,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.remove_red_eye_rounded),
                    onPressed: () {
                      setState(() {
                        _currentScreenState = _isEditScreenState
                            ? ScreenState.preview
                            : ScreenState.edit;
                      });
                    },
                  ),
                ],
              )
            : action,
      ),
    );
  }

  FloatingActionButtonBuilder buildExpandableFabOpenCloseButton(
      IconData icon, Color color) {
    return FloatingActionButtonBuilder(
      size: 48,
      builder: (context, onPressed, progress) {
        return DefaultButton(
          icon: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onTap: onPressed,
          showShadow: true,
          backgroundColor: color,
          borderRadius: BorderRadius.circular(30),
        );
      },
    );
  }
}

class BookDetailHeader extends ConsumerStatefulWidget {
  final bool isViewScreenState;
  final bool isLoading;
  final Book book;

  const BookDetailHeader({
    super.key,
    required this.isViewScreenState,
    this.isLoading = false,
    required this.book,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookDetailHeaderState();
}

class _BookDetailHeaderState extends ConsumerState<BookDetailHeader>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  double _scale = 1.0;
  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 200);
    final scaleTween = Tween(begin: 1.0, end: 1.2);
    _controller = AnimationController(duration: duration, vsync: this);
    _animation = scaleTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    )..addListener(() {
        setState(() => _scale = _animation.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    _animation.addStatusListener((AnimationStatus status) {
      if (_scale == 1.2) {
        _controller.reverse();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 30,
        left: 20,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_ios_rounded,
            ),
          ),
          if (widget.isViewScreenState && !widget.isLoading)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ref.read(bookProvider.notifier).toggleFavourite();
                    _animate();
                  },
                  child: Transform.scale(
                    scale: _scale,
                    child: Icon(
                      widget.book.isFavourite
                          ? Icons.bookmark_border_rounded
                          : Icons.bookmark_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    ref.read(bookProvider.notifier).removeBook();
                  },
                  child: Icon(
                    Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

class BookDetailActions extends ConsumerWidget {
  final Book book;
  final bool isLoading;

  const BookDetailActions({
    super.key,
    required this.book,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ChartData> lastReadCompletionPercentage = [
      ChartData(
        0,
        book.readPercentage.toDouble(),
        Theme.of(context).colorScheme.secondary,
      ),
    ];

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: SizedBox()),
          Material(
            color: Theme.of(context).colorScheme.tertiary,
            shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: (!isLoading) ? 3.0 : 0.0,
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onTap: () {
                if (!isLoading) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const BookPdfScreen(),
                    ),
                  );
                }
              },
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      child: Text(
                        "${book.readPercentage}%",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize:
                              Theme.of(context).textTheme.bodyMedium?.fontSize,
                        ),
                      ),
                    ),
                    SfCircularChart(
                      series: <CircularSeries>[
                        RadialBarSeries<ChartData, int>(
                          dataSource: lastReadCompletionPercentage,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          pointColorMapper: (ChartData data, _) => data.color,
                          radius: "24",
                          innerRadius: "20",
                          cornerStyle: CornerStyle.bothCurve,
                          maximumValue: 100,
                          trackColor: Theme.of(context).colorScheme.tertiary,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
