import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../database/database.dart';

/// Сервис геймификации: XP, уровни, история начислений.
class GamificationService {
  GamificationService(this._db);

  final AppDatabase _db;

  /// Начисляет XP пользователю и обновляет уровень.
  Future<XpResult> addXp({
    required int userId,
    required int amount,
    required String reason,
  }) async {
    if (amount <= 0) {
      final user = await _db.userDao.getUserById(userId);
      return XpResult(
        userId: userId,
        totalXp: user?.xp ?? 0,
        level: user?.level ?? 1,
        levelUp: false,
        addedXp: 0,
      );
    }

    await _db.userDao.addXpEvent(
      UserXpEventsCompanion(
        userId: Value(userId),
        amount: Value(amount),
        reason: Value(reason),
      ),
    );

    final user = await _db.userDao.getUserById(userId);
    if (user == null) {
      return const XpResult(
        userId: 0,
        totalXp: 0,
        level: 1,
        levelUp: false,
        addedXp: 0,
      );
    }

    final newXp = user.xp + amount;
    final newLevel = calculateLevel(newXp);
    final levelUp = newLevel > user.level;

    await _db.userDao.updateUser(user.copyWith(xp: newXp, level: newLevel));

    return XpResult(
      userId: userId,
      totalXp: newXp,
      level: newLevel,
      levelUp: levelUp,
      addedXp: amount,
    );
  }

  /// Формула уровня: level = floor(sqrt(xp / 100)) + 1.
  int calculateLevel(int xp) {
    if (xp <= 0) return 1;
    return math.sqrt(xp / 100).floor() + 1;
  }

  /// Сколько XP нужно накопить для перехода на [level].
  int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    return (level - 1) * (level - 1) * 100;
  }

  /// Сколько XP нужно для следующего уровня после [currentLevel].
  int xpForNextLevel(int currentLevel) {
    return xpRequiredForLevel(currentLevel + 1);
  }

  /// Прогресс от текущего уровня к следующему: 0.0 – 1.0.
  double progressToNextLevel({required int xp, required int level}) {
    final currentThreshold = xpRequiredForLevel(level);
    final nextThreshold = xpRequiredForLevel(level + 1);
    final span = nextThreshold - currentThreshold;
    if (span <= 0) return 0;
    final inLevel = xp - currentThreshold;
    return (inLevel / span).clamp(0.0, 1.0);
  }

  /// История начислений XP.
  Future<List<UserXpEvent>> getHistory(int userId, {int limit = 20}) async {
    final all = await _db.userDao.getXpHistory(userId);
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }
}

/// Результат начисления XP.
class XpResult {
  const XpResult({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.levelUp,
    required this.addedXp,
  });

  final int userId;
  final int totalXp;
  final int level;
  final bool levelUp;
  final int addedXp;
}

/// Веса XP за действия.
class XpReward {
  XpReward._();

  static const int addPlant = 20;
  static const int watering = 10;
  static const int fertilizing = 15;
  static const int misting = 5;
  static const int repotting = 25;
  static const int diagnosis = 50;
  static const int completedTreatment = 100;
  static const int unlockedAchievement = 30;
}
