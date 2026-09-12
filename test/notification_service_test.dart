import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('Создаётся без ошибок', () {
      final service = NotificationService();
      expect(service, isNotNull);
    });
  });
}
