import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crop_prediction_system/main.dart';

void main() {
  testWidgets('App loads and language selection screen appears', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CropPredictionSystemApp());

    // Verify that the language selection screen is present.
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
  });
}
