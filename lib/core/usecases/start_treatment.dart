import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/database.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';

/// Use case начала лечения растения.
class StartTreatment {
  StartTreatment(this._db, this._notifications, this._gamification);

  final AppDatabase _db;
  final NotificationService _notifications;
  final GamificationService _gamification;

  Future<int> call({
    required String diseaseId,
    required int userId,
    int? plantId,
    String? imagePath,
    double? confidence,
  }) async {
    final disease = await _db.diseaseDao.getById(diseaseId);
    if (disease == null) {
      throw Exception('Болезнь не найдена: $diseaseId');
    }

    final diagnosisId = await _db.diagnosisDao.insertDiagnosis(
      DiagnosesCompanion(
        plantId: Value(plantId),
        diseaseId: Value(diseaseId),
        imagePath: Value(imagePath),
        confidence: Value(confidence),
        status: const Value('active'),
      ),
    );

    final planJson = disease.treatmentPlanJson;
    if (planJson != null && planJson.isNotEmpty && planJson != '[]') {
      final plan = jsonDecode(planJson) as List<dynamic>;
      final now = DateTime.now();

      for (final item in plan) {
        final map = item as Map<String, dynamic>;
        final stepNumber = (map['step'] as int?) ?? 0;
        final title = (map['title'] as String?) ?? 'Шаг $stepNumber';
        final description = map['description'] as String?;
        final offsetDays = (map['due_offset_days'] as int?) ?? 0;

        final dueAt = now.add(Duration(days: offsetDays));

        await _db.diagnosisDao.insertStep(
          TreatmentStepsCompanion(
            diagnosisId: Value(diagnosisId),
            stepNumber: Value(stepNumber),
            title: Value(title),
            description: Value(description),
            dueAt: Value(dueAt),
          ),
        );

        if (dueAt.isAfter(now)) {
          final label = plantId != null ? 'Растение #$plantId' : 'Растение';
          await _notifications.scheduleReminder(
            reminderId: diagnosisId * 1000 + stepNumber,
            title: 'Лечение: $label',
            body: title,
            when: dueAt,
          );
        }
      }
    }

    await _gamification.addXp(
      userId: userId,
      amount: XpReward.diagnosis,
      reason: 'diagnosis',
    );

    return diagnosisId;
  }
}
