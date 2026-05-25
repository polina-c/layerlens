import 'package:flutter/material.dart';

import 'package:markdown_widget/markdown_widget.dart';
import 'app_move.dart';
import 'tappable_text.dart';

Widget _defaultLinkBuilder(String text, String? href, String title) {
  if (href == null) {
    return Text(text);
  }
  final button = TappableText(
    text: text,
    link: href,
    baseStyle: AppTexts.normalLink,
  );

  return Shift(button, 0, 5);
}

class AppMarkdown extends StatelessWidget {
  AppMarkdown(
    this.content, {
    super.key,
    this.alignment = WrapAlignment.start,
    this.width,
    this.paragraphSpacing,
    Widget Function(String text, String? href, String title)? customLinkBuilder,
  }) : customLinkBuilder = customLinkBuilder ?? _defaultLinkBuilder;

  final String content;
  final WrapAlignment alignment;
  final double? width;
  final double? paragraphSpacing;
  final Widget Function(String text, String? href, String title)
  customLinkBuilder;

  @override
  Widget build(BuildContext context) {
    final textAlign = _wrapAlignmentToTextAlign(alignment);

    final widget = DefaultTextStyle(
      style: DefaultTextStyle.of(context).style,
      textAlign: textAlign,
      child: MarkdownWidget(
        // Use NeverScrollableScrollPhysics to prevent internal scrolling but allow parent ListView to scroll
        physics: const NeverScrollableScrollPhysics(),
        data: content,
        shrinkWrap: true,
        markdownGenerator: MarkdownGenerator(
          generators: [
            SpanNodeGeneratorWithTag(
              tag: MarkdownTag.a.name,
              generator: (e, config, visitor) =>
                  _CustomLinkNode(e.attributes, config.a, customLinkBuilder),
            ),
            SpanNodeGeneratorWithTag(
              tag: MarkdownTag.strong.name,
              generator: (e, config, visitor) => _CustomStrongNode(),
            ),
          ],
        ),
        // With selectable: true, 'long tap + copy link' is not working on mobile.
        selectable: false,
        config: MarkdownConfig(
          configs: [
            PConfig(textStyle: AppTexts.normal),
            const H1Config(
              // should not be used
              style: TextStyle(color: Colors.red),
            ),
            _H2ConfigNoDivider(style: AppTexts.markdownH2),
            _H3ConfigNoDivider(style: AppTexts.markdownH3),
            LinkConfig(style: AppTexts.normalLink),
            ListConfig(
              marginBottom: 12.0,
              marker: (isOrdered, depth, index) {
                if (isOrdered) {
                  return null; // Use default numbered markers for ordered lists
                }
                // Use arrow for unordered lists
                return const Align(
                  alignment: Alignment.centerRight,
                  child: Shift(
                    Text(
                      '$appArrowRight           ',
                      style: TextStyle(fontSize: 16, color: AppColors.link),
                    ),
                    0,
                    8,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (width == null) return widget;

    return SizedBox(width: width, child: widget);
  }

  TextAlign _wrapAlignmentToTextAlign(WrapAlignment wrapAlignment) {
    switch (wrapAlignment) {
      case WrapAlignment.start:
        return TextAlign.start;
      case WrapAlignment.center:
        return TextAlign.center;
      case WrapAlignment.end:
        return TextAlign.end;
      case WrapAlignment.spaceBetween:
      case WrapAlignment.spaceAround:
      case WrapAlignment.spaceEvenly:
        return TextAlign.justify;
    }
  }
}

class _CustomStrongNode extends ElementNode {
  @override
  TextStyle get style =>
      parentStyle == null ? AppTexts.normalBold : AppTexts.bold(parentStyle!);
}

class _CustomLinkNode extends LinkNode {
  final Widget Function(String text, String? href, String title) builder;

  _CustomLinkNode(super.attributes, super.linkConfig, this.builder);

  @override
  InlineSpan build() {
    final url = attributes['href'];
    final title = attributes['title'] ?? '';
    // Use the text content from children
    // This is a bit tricky as children are SpanNodes.
    // Usually link text is simple text, but can be formatted.
    // For custom builder we might assume it's just text or we need to extract it.
    // Let's verify what `children` contains.
    // LinkNode extends ElementNode, which has children.

    // If the builder expects text, we should probably construct it from children.
    final text = children.map((e) => e.build().toPlainText()).join();

    return WidgetSpan(child: builder(text, url, title));
  }
}

// Custom H2Config without divider
class _H2ConfigNoDivider extends H2Config {
  const _H2ConfigNoDivider({required super.style});

  @override
  HeadingDivider? get divider => null;
}

// Custom H3Config without divider
class _H3ConfigNoDivider extends H3Config {
  const _H3ConfigNoDivider({required super.style});

  @override
  HeadingDivider? get divider => null;
}
