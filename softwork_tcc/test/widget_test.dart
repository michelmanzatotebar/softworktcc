import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - SoftWork TCC', () {
    testWidgets('Deve criar um widget Text simples', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text('Teste Widget'),
          ),
        ),
      );

      expect(find.text('Teste Widget'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('Deve criar um widget Container', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              child: Text('Container Teste'),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
      expect(find.text('Container Teste'), findsOneWidget);
    });

    testWidgets('Deve renderizar MaterialApp básico', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Teste')),
            body: Center(child: Text('Hello')),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });
  });
}