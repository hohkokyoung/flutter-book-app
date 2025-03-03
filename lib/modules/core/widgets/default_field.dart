import 'package:flutter/material.dart';
import 'default_text_field.dart';

class DefaultField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String text;
  final bool isEdit;
  final bool showHeader;
  final bool isLoading;
  final int? maxLines;
  final Widget? content;
  final double? fontSize;
  final Color? color;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const DefaultField({
    super.key,
    required this.label,
    this.placeholder,
    this.fontSize,
    this.maxLines,
    this.color,
    required this.text,
    required this.isEdit,
    this.showHeader = true,
    this.content,
    this.controller,
    this.onChanged,
    this.validator,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          DefaultTextField(
            text: label,
            isEdit: false,
            isLoading: isLoading,
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        if (showHeader) const SizedBox(height: 6),
        content ??
            DefaultTextField(
              text: text,
              isEdit: isEdit,
              placeholder: placeholder,
              fontSize: fontSize,
              color: color,
              maxLines: maxLines,
              isLoading: isLoading,
              controller: controller,
              onChanged: onChanged,
              validator: validator,
            ),
        SizedBox(height: isEdit ? 12 : 6),
      ],
    );
  }
}
