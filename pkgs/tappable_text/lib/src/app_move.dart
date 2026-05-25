import 'package:flutter/widgets.dart';

class Shift extends StatelessWidget {
  const Shift(this.child, this.right, this.down);

  final Widget child;
  final double right;
  final double down;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(offset: Offset(right, down), child: child);
  }
}
