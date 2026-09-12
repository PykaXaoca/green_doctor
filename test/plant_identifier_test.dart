import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/services/plant_identifier_service.dart';

void main() {
  group('RecognitionResult', () {
    test('Создаётся корректно', () {
      const result = RecognitionResult(
        label: 'monstera_deliciosa',
        confidence: 0.85,
      );
      expect(result.label, 'monstera_deliciosa');
      expect(result.confidence, 0.85);
    });

    test('toString содержит ключевые поля', () {
      const result = RecognitionResult(label: 'test', confidence: 0.5);
      expect(result.toString(), contains('test'));
      expect(result.toString(), contains('0.500'));
    });
  });

  group('PlantIdentifierService', () {
    test('Создаётся без ошибок', () {
      final service = PlantIdentifierService();
      expect(service, isNotNull);
      expect(service.isMockMode, isTrue); // до инициализации всегда mock
    });
  });
}
