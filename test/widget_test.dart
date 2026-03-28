import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clearbg/src/presentation/widgets/glass_panel.dart';

void main() {
  testWidgets('GlassPanel renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GlassPanel(child: Text('ClearBG'))),
      ),
    );

    expect(find.text('ClearBG'), findsOneWidget);
  });
}
