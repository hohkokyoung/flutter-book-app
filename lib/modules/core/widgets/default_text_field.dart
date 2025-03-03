import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultTextField extends StatelessWidget {
  final bool isEdit;
  final FontWeight? fontWeight;
  final Color? color;
  final double? fontSize;
  final String text;
  final int? maxLines;
  final String? placeholder;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isLoading;
  const DefaultTextField({
    super.key,
    required this.text,
    this.maxLines,
    this.placeholder,
    this.isEdit = false,
    this.controller,
    this.onChanged,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.fontSize,
    this.validator,
    this.keyboardType = TextInputType.multiline,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Text valueWidget = Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.primary,
        fontSize: fontSize ?? Theme.of(context).textTheme.bodyMedium?.fontSize,
        overflow: TextOverflow.ellipsis,
      ),
      maxLines: maxLines,
    );

    TextFormField textFieldWidget = TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.primary,
        fontSize: fontSize ?? Theme.of(context).textTheme.bodyMedium?.fontSize,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: placeholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondaryFixedDim,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        isDense: true,
      ),
    );

    Widget textField = isEdit ? textFieldWidget : valueWidget;

    if (isLoading) {
      textField = Container(
        color: Colors.white,
        child: textField,
      );
    }

    return textField;
  }
}
