import 'package:booksum/modules/core/models/enum.dart';
import 'package:booksum/modules/core/widgets/default_clickable_container.dart';
import 'package:booksum/modules/core/widgets/default_image_field.dart';
import 'package:flutter/material.dart';

class TrendingNews extends StatelessWidget {
  const TrendingNews({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trending News",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  "See More >>",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 260,
          child: ListView(
            padding: const EdgeInsets.only(
              left: 20,
              bottom: 30,
            ),
            scrollDirection: Axis.horizontal,
            children: const [
              TrendingNewsItem(
                newsImagePath: "assets/images/news-1.jpg",
                newsTitle:
                    "As Israel ramps up war on multiple fronts, nobody knows what Netanyahu’s endgame is",
              ),
              SizedBox(width: 20),
              TrendingNewsItem(
                newsImagePath: "assets/images/news-2.jpg",
                newsTitle:
                    "World’s largest digital camera will be a ‘game-changer’ for astronomy",
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class TrendingNewsItem extends StatelessWidget {
  final String newsImagePath;
  final String newsTitle;
  const TrendingNewsItem({
    super.key,
    required this.newsImagePath,
    required this.newsTitle,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultClickableContainer(
      onTap: () {},
      children: [
        DefaultImageField(
          imageFileType: ImageFileType.asset,
          imagePath: newsImagePath,
          height: 128,
          width: MediaQuery.of(context).size.width * .6,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        Positioned.fill(
          top: 128,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsTitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium?.fontSize,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Trean Avanson",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyMedium?.fontSize,
                        ),
                      ),
                      Text(
                        "2h ago",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodySmall?.fontSize,
                          color:
                              Theme.of(context).colorScheme.secondaryFixedDim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
