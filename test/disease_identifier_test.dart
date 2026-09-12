import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/services/disease_identifier_service.dart';

void main() {
  group('DiagnosisResult', () {
    test('Создаётся корректно', () {
      const result = DiagnosisResult(label: 'powdery_mildew', confidence: 0.92);
      expect(result.label, 'powdery_mildew');
      expect(result.confidence, 0.92);
    });

    test('toString содержит ключевые поля', () {
      const result = DiagnosisResult(label: 'rust', confidence: 0.4);
      expect(result.toString(), contains('rust'));
      expect(result.toString(), contains('0.400'));
    });
  });

  group('DiseaseIdentifierService', () {
    test('Создаётся без ошибок', () {
      final service = DiseaseIdentifierService();
      expect(service, isNotNull);
      expect(service.isMockMode, isTrue);
    });
  });
}
