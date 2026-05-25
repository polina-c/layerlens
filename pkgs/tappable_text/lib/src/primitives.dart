import 'package:flutter/material.dart';

class LinkDecoration {
  const LinkDecoration({
    this.colorForText = Colors.blue,
    this.colorForHover = Colors.grey,
    this.padding = 2.0,
    this.hoverBorderRadius = 2.0,
  });

  final Color colorForText;
  final Color colorForHover;

  /// The padding to use for the button.
  final double padding;

  final double hoverBorderRadius;
}
