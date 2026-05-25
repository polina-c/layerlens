import 'package:example/subfolder1/a.dart';
import 'package:example/subfolder1/b.dart';
import 'package:example/subfolder2/c.dart';
import 'package:example/subfolder2/d.dart';
import 'package:test/test.dart';

void main() {
  test('subfolder2 values', () {
    expect(d, 5);
    expect(c, 10);
  });

  test('subfolder1 values', () {
    expect(b, 5);
    expect(a, 10);
    expect(b1, 25);
  });
}
