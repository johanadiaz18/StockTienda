
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stocktienda/main.dart';

void main() {
  testWidgets('StockTienda muestra la pantalla de prueba SQLite',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StockTiendaApp());

    expect(find.text('StockTienda'), findsOneWidget);
    expect(find.text('Prueba de Base de Datos'), findsOneWidget);
    expect(find.text('Probar SQLite'), findsOneWidget);
    expect(find.byIcon(Icons.store), findsOneWidget);
  });
}
