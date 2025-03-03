import 'package:booksum/modules/core/utils/global.dart';
import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:booksum/modules/core/widgets/default_text_field.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final bool showText;
  final bool showShadow;
  final Icon? icon;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  const DefaultButton({
    super.key,
    this.text = "",
    this.showText = false,
    this.showShadow = false,
    this.icon,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: showShadow
          ? Theme.of(context).colorScheme.shadow
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? defaultBorderRadius,
      ),
      elevation: 3.0,
      color: backgroundColor ?? Theme.of(context).colorScheme.primary,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
        ),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon.isNotEmpty()) icon!,
              if (icon.isNotEmpty() && showText) const SizedBox(width: 6),
              if (showText)
                DefaultTextField(
                  text: text,
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
