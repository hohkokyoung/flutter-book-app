import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultClickableContainer extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onTap;
  final bool isLoading;
  const DefaultClickableContainer({
    super.key,
    this.children = const [],
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget defaultClickableContainer = Stack(
      key: key,
      children: <Widget>[
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: defaultBorderRadius,
              boxShadow: getDefaultBoxShadow(context),
            ),
          ),
        ),
        ...children,
        Positioned.fill(
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: defaultBorderRadius,
            ),
            color: Colors.transparent,
            child: InkWell(
              highlightColor: Theme.of(context)
                  .colorScheme
                  .secondaryFixedDim
                  .withOpacity(.1),
              splashColor: Theme.of(context)
                  .colorScheme
                  .secondaryFixedDim
                  .withOpacity(.1),
              customBorder: RoundedRectangleBorder(
                borderRadius: defaultBorderRadius,
              ),
              onTap: onTap,
            ),
          ),
        ),
      ],
    );

    if (isLoading) {
      defaultClickableContainer = Shimmer.fromColors(
        key: key,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade200,
        child: defaultClickableContainer,
      );
    }

    return defaultClickableContainer;
  }
}
