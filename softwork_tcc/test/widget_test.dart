import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/main.dart';

void main() {
  group('Widget Tests - SoftWork TCC', () {
    testWidgets('Deve carregar app principal com Firebase', (WidgetTester tester) async {

      await tester.pumpWidget(MyApp());

      expect(find.text('Firebase Conectado'), findsOneWidget);

      expect(find.text('Firebase está pronto para uso!'), findsOneWidget);

      expect(find.byType(AppBar), findsOneWidget);

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Deve ter estrutura básica do MaterialApp', (WidgetTester tester) async {

      await tester.pumpWidget(MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);

      expect(find.byType(Center), findsOneWidget);

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('Deve renderizar sem erros', (WidgetTester tester) async {

      await tester.pumpWidget(MyApp());

      expect(find.byType(MyApp), findsOneWidget);
    });
  });
}