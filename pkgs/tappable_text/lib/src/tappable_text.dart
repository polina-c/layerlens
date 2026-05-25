import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

import 'primitives.dart';

bool _tryProcessEmail(BuildContext context, String url) {
  if (!url.startsWith('mailto:')) return false;
  _copyToClipboard(url.substring(7), context);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Email copied to clipboard')));
  return true;
}

void _copyToClipboard(String substring, BuildContext context) {
  Clipboard.setData(ClipboardData(text: substring));
}

class TappableText extends StatelessWidget {
  const TappableText({
    super.key,
    required this.link,
    required this.text,
    this.baseStyle,
    this.decoration = const LinkDecoration(),
    this.align,
  });

  final String link;
  final String text;
  final TextStyle? baseStyle;
  final TextAlign? align;

  final LinkDecoration decoration;

  @override
  Widget build(BuildContext context) {
    var style = baseStyle ?? Theme.of(context).textTheme.bodyMedium!;
    style = style.copyWith(color: decoration.colorForText);
    return Link(
      uri: Uri.parse(link),
      target: LinkTarget.defaultTarget,
      builder: (context, _) {
        return InkWell(
          // No onTap, because it is messed up when InkWell is here.
          child: TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(decoration.colorForHover),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    decoration.hoverBorderRadius,
                  ),
                ),
              ),
              padding: WidgetStateProperty.all(
                EdgeInsets.all(decoration.padding),
              ),
            ),
            onPressed: () {
              if (_tryProcessEmail(context, link)) return;
              launchUrl(Uri.parse(link));
            },
            child: Text(text, style: style, textAlign: align),
          ),
        );
      },
    );
  }
}

class MaybeClickableText extends StatelessWidget {
  const MaybeClickableText({
    super.key,
    required this.text,
    this.link,
    this.style,
    this.align,
  });

  final String text;
  final String? link;
  final TextStyle? style;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    if (link == null) {
      return Text(
        text,
        style: style,
        textAlign: align,
        softWrap: true,
        maxLines: null,
      );
    }
    return TappableText(
      text: text,
      link: link!,
      baseStyle: style,
      align: align,
    );
  }
}

class MaybeClickable extends StatelessWidget {
  const MaybeClickable({
    super.key,
    required this.child,
    required this.link,
    required this.clickable,
  });

  final Widget child;
  final String link;
  final bool clickable;

  @override
  Widget build(BuildContext context) {
    if (!clickable) return child;

    final uri = Uri.parse(link);

    // Link is used to enable web native link.
    return Link(
      uri: uri,
      target: LinkTarget.defaultTarget,
      builder: (context, _) {
        return InkWell(onTap: () => launchUrl(uri), child: child);
      },
    );
  }
}
