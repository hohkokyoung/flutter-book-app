import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DailyQuote extends StatefulWidget {
  const DailyQuote({
    super.key,
  });

  @override
  State<DailyQuote> createState() => _DailyQuoteState();
}

class _DailyQuoteState extends State<DailyQuote>
    with SingleTickerProviderStateMixin {
  bool _isQuoteLiked = false;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quote of the day",
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius:  defaultBorderRadius,
            boxShadow: getDefaultBoxShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\"Learning operatic roles is ongoing, and I find that I can learn on the train or subway, during a manicure, getting my hair done, and even while driving if I only look at the score at red lights.\"",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isQuoteLiked = !_isQuoteLiked;
                      });
                      _animate();
                    },
                    child: Transform.scale(
                      scale: _scale,
                      child: Icon(
                        _isQuoteLiked
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    "Renee Fleming",
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium?.fontSize,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
