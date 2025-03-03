import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:booksum/modules/books/models/book.dart';
import 'package:booksum/modules/books/screens/book_detail_screen.dart';
import 'package:booksum/modules/books/states/book.dart';
import 'package:booksum/modules/core/models/enum.dart';
import 'package:booksum/modules/core/widgets/background_paint.dart';
import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:booksum/modules/core/widgets/default_clickable_container.dart';
import 'package:booksum/modules/core/widgets/default_image_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:page_transition/page_transition.dart';

class BookListScreen extends ConsumerStatefulWidget {
  const BookListScreen({super.key});

  @override
  ConsumerState<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends ConsumerState<BookListScreen> {
  TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(booksProvider);
    final defaultBooks = ref.read(bookRepositoryProvider).defaultBooks;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 150, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Categories",
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.fontSize,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        AnimationLimiter(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 9 / 14,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    crossAxisCount: 2),
                            itemCount: !booksState.isLoading
                                ? booksState.value!.filteredBooks.length
                                : defaultBooks.length,
                            itemBuilder: (_, index) =>
                                AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: !booksState.isLoading
                                  ? booksState.value!.filteredBooks.length
                                  : defaultBooks.length,
                              duration: const Duration(milliseconds: 375),
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 375),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                          opacity: animation, child: child);
                                    },
                                    child: booksState.when(
                                      data: (state) => BookGridItem(
                                        key: const ValueKey<bool>(false),
                                        isLoading: false,
                                        book: state.filteredBooks[index],
                                      ),
                                      //refactor to book grid, so it can be used in loading and the data itself
                                      loading: () => BookGridItem(
                                        key: const ValueKey<bool>(true),
                                        isLoading: true,
                                        book: defaultBooks[index],
                                      ),
                                      error: (error, stack) =>
                                          Center(child: Text("Error: $error")),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const BackgroundPaint(),
            Container(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Transform.translate(
                offset: const Offset(0, -38),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.grid_view),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    Row(
                      children: [
                        AnimSearchBar(
                          width:
                              MediaQuery.sizeOf(context).width - 24 - 40 - 24,
                          color: Colors.transparent,
                          textFieldColor: Colors.transparent,
                          boxShadow: false,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.shadow,
                          ),
                          textController: searchTextController,
                          onSubmitted: (String query) async {
                            await ref
                                .read(booksProvider.notifier)
                                .searchBooks(query);
                          },
                          onSuffixTap: () async {
                            searchTextController.clear();
                            await ref
                                .read(booksProvider.notifier)
                                .resetSearch();
                          },
                        ),
                        const Icon(Icons.filter_alt),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookGridItem extends ConsumerWidget {
  final bool isLoading;
  final Book book;

  const BookGridItem({
    super.key,
    this.isLoading = false,
    required this.book,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      key: key,
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: DefaultClickableContainer(
            isLoading: isLoading,
            onTap: () {
              if (!isLoading) {
                ref.read(selectedBookIdProvider.notifier).state = book.id;
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRightWithFade,
                    child: const BookDetailScreen(
                      screenState: ScreenState.view,
                    ),
                  ),
                );
              }
            },
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return DefaultImageField(
                    imagePath: book.imageFilePath,
                    height: 180,
                    width: constraints.maxWidth,
                    imageFileType: ImageFileType.file,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  );
                },
              ),
              Positioned.fill(
                top: 180,
                child: Container(
                  decoration: BoxDecoration(
                    color: !isLoading ? Colors.white : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: !isLoading ? Colors.transparent : Colors.white,
                        height: !isLoading ? 34 : 32,
                        child: Text(
                          book.title,
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.fontSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: !isLoading ? 2 : 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color:
                                !isLoading ? Colors.transparent : Colors.white,
                            child: Text(
                              book.author,
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.fontSize,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryFixedDim,
                              ),
                            ),
                          ),
                          Container(
                            color:
                                !isLoading ? Colors.transparent : Colors.white,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 14,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  book.rating.toString(),
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.fontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      LinearProgressIndicator(
                        borderRadius: defaultBorderRadius,
                        value: book.readPercentage / 100,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color:
                                !isLoading ? Colors.transparent : Colors.white,
                            child: Text(
                              "Page ${book.currentPageNumber} / ${book.totalPageNumber}",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.fontSize,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Container(
                            color:
                                !isLoading ? Colors.transparent : Colors.white,
                            child: Text(
                              "${book.readPercentage}%",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.fontSize,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
