import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../../core/usecases/complete_care_event.dart';

final currentUserIdProvider = Provider<int>((ref) => 1);

final userPlantsProvider = FutureProvider<List<Plant>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(plantRepositoryProvider);
  return repo.getByUser(userId);
});

final plantByIdProvider = FutureProvider.family<Plant?, int>((ref, id) async {
  final repo = ref.watch(plantRepositoryProvider);
  return repo.getById(id);
});

final allSpeciesProvider = FutureProvider<List<PlantSpecy>>((ref) async {
  final repo = ref.watch(speciesRepositoryProvider);
  return repo.getAll();
});

final freeSpeciesProvider = FutureProvider<List<PlantSpecy>>((ref) async {
  final repo = ref.watch(speciesRepositoryProvider);
  return repo.getNonPremium();
});

final plantsDueForWateringProvider = FutureProvider<List<Plant>>((ref) async {
  final repo = ref.watch(plantRepositoryProvider);
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return repo.getDueForWatering(endOfDay);
});

final plantCareEventsProvider = FutureProvider.family<List<CareEvent>, int>((
  ref,
  plantId,
) async {
  final repo = ref.watch(careEventRepositoryProvider);
  return repo.getByPlant(plantId);
});

final plantControllerProvider = Provider<PlantController>((ref) {
  return PlantController(ref);
});

class PlantController {
  PlantController(this._ref);

  final Ref _ref;

  Future<int> create(PlantsCompanion plant) async {
    final repo = _ref.read(plantRepositoryProvider);
    final scheduler = _ref.read(careSchedulerProvider);
    final notifications = _ref.read(notificationServiceProvider);
    final gamification = _ref.read(gamificationServiceProvider);
    final achievements = _ref.read(achievementCheckerProvider);
    final userId = _ref.read(currentUserIdProvider);

    PlantsCompanion enriched = plant;
    if (!plant.nextWaterDue.present) {
      final next = scheduler.calculateInitialWatering(
        createdAt: DateTime.now(),
        frequencyDays: plant.wateringFrequencyDays.value,
      );
      enriched = plant.copyWith(nextWaterDue: Value(next));
    }

    final id = await repo.create(enriched);
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);

    final saved = await repo.getById(id);
    if (saved != null) {
      await notifications.rescheduleForPlant(saved);
    }

    await gamification.addXp(
      userId: userId,
      amount: XpReward.addPlant,
      reason: 'add_plant',
    );

    await achievements.checkAll(userId);

    return id;
  }

  Future<void> update(int id, PlantsCompanion plant) async {
    final repo = _ref.read(plantRepositoryProvider);
    final notifications = _ref.read(notificationServiceProvider);

    await repo.update(id, plant);
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(plantByIdProvider(id));
    _ref.invalidate(plantsDueForWateringProvider);

    final saved = await repo.getById(id);
    if (saved != null) {
      await notifications.rescheduleForPlant(saved);
    }
  }

  Future<void> archive(int id) async {
    final repo = _ref.read(plantRepositoryProvider);
    final notifications = _ref.read(notificationServiceProvider);

    await repo.archive(id);
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);
    await notifications.cancelForPlant(id);
  }

  Future<void> delete(int id) async {
    final repo = _ref.read(plantRepositoryProvider);
    final notifications = _ref.read(notificationServiceProvider);

    await repo.delete(id);
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);
    await notifications.cancelForPlant(id);
  }
}

final careActionControllerProvider = Provider<CareActionController>((ref) {
  return CareActionController(ref);
});

class CareActionController {
  CareActionController(this._ref);

  final Ref _ref;

  Future<CareResult> perform({
    required int plantId,
    required String type,
    String? notes,
  }) async {
    final useCase = _ref.read(completeCareEventProvider);
    final userId = _ref.read(currentUserIdProvider);

    final result = await useCase(
      plantId: plantId,
      userId: userId,
      type: type,
      notes: notes,
    );

    _ref.invalidate(plantByIdProvider(plantId));
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);
    _ref.invalidate(plantCareEventsProvider(plantId));

    return result;
  }
}
