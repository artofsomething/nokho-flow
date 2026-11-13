import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nokho_ui/nokho_ui.dart';

void main() {
  test('light and dark themes have matching brightness', () {
    expect(NokhoTheme.light().brightness, Brightness.light);
    expect(NokhoTheme.dark().brightness, Brightness.dark);
  });
}
