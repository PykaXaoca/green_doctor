import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/app.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/core/providers/database_providers.dart';

void main() {
  testWidgets('Приложение запускается и показывает 4 таба', (
    WidgetTester tester,
  ) async {
    // In-memory база, чтобы не открывать файл на диске.
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(testDb.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(testDb)],
        child: const PocketBotanistApp(),
      ),
    );

    // Первый кадр — загрузка. Прокрутим несколько раз,
    // чтобы дать FutureProvider завершиться без ожидания анимаций.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Проверяем, что навигация отрисовалась.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Сегодня'), findsWidgets);
    expect(find.text('Растения'), findsWidgets);
    expect(find.text('Определить'), findsWidgets);
    expect(find.text('Профиль'), findsWidgets);
  });
}
