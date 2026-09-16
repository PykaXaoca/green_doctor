// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppUsersTable extends AppUsers with TableInfo<$AppUsersTable, AppUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _subscriptionTierMeta = const VerificationMeta(
    'subscriptionTier',
  );
  @override
  late final GeneratedColumn<String> subscriptionTier = GeneratedColumn<String>(
    'subscription_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
  );
  static const VerificationMeta _subscriptionExpiryMeta =
      const VerificationMeta('subscriptionExpiry');
  @override
  late final GeneratedColumn<DateTime> subscriptionExpiry =
      GeneratedColumn<DateTime>(
        'subscription_expiry',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    avatarPath,
    xp,
    level,
    subscriptionTier,
    subscriptionExpiry,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('subscription_tier')) {
      context.handle(
        _subscriptionTierMeta,
        subscriptionTier.isAcceptableOrUnknown(
          data['subscription_tier']!,
          _subscriptionTierMeta,
        ),
      );
    }
    if (data.containsKey('subscription_expiry')) {
      context.handle(
        _subscriptionExpiryMeta,
        subscriptionExpiry.isAcceptableOrUnknown(
          data['subscription_expiry']!,
          _subscriptionExpiryMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      subscriptionTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_tier'],
      )!,
      subscriptionExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscription_expiry'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUser extends DataClass implements Insertable<AppUser> {
  final int id;
  final String? displayName;
  final String? avatarPath;
  final int xp;
  final int level;
  final String subscriptionTier;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  const AppUser({
    required this.id,
    this.displayName,
    this.avatarPath,
    required this.xp,
    required this.level,
    required this.subscriptionTier,
    this.subscriptionExpiry,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['xp'] = Variable<int>(xp);
    map['level'] = Variable<int>(level);
    map['subscription_tier'] = Variable<String>(subscriptionTier);
    if (!nullToAbsent || subscriptionExpiry != null) {
      map['subscription_expiry'] = Variable<DateTime>(subscriptionExpiry);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      xp: Value(xp),
      level: Value(level),
      subscriptionTier: Value(subscriptionTier),
      subscriptionExpiry: subscriptionExpiry == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionExpiry),
      createdAt: Value(createdAt),
    );
  }

  factory AppUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUser(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      xp: serializer.fromJson<int>(json['xp']),
      level: serializer.fromJson<int>(json['level']),
      subscriptionTier: serializer.fromJson<String>(json['subscriptionTier']),
      subscriptionExpiry: serializer.fromJson<DateTime?>(
        json['subscriptionExpiry'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'xp': serializer.toJson<int>(xp),
      'level': serializer.toJson<int>(level),
      'subscriptionTier': serializer.toJson<String>(subscriptionTier),
      'subscriptionExpiry': serializer.toJson<DateTime?>(subscriptionExpiry),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AppUser copyWith({
    int? id,
    Value<String?> displayName = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    int? xp,
    int? level,
    String? subscriptionTier,
    Value<DateTime?> subscriptionExpiry = const Value.absent(),
    DateTime? createdAt,
  }) => AppUser(
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    xp: xp ?? this.xp,
    level: level ?? this.level,
    subscriptionTier: subscriptionTier ?? this.subscriptionTier,
    subscriptionExpiry: subscriptionExpiry.present
        ? subscriptionExpiry.value
        : this.subscriptionExpiry,
    createdAt: createdAt ?? this.createdAt,
  );
  AppUser copyWithCompanion(AppUsersCompanion data) {
    return AppUser(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      xp: data.xp.present ? data.xp.value : this.xp,
      level: data.level.present ? data.level.value : this.level,
      subscriptionTier: data.subscriptionTier.present
          ? data.subscriptionTier.value
          : this.subscriptionTier,
      subscriptionExpiry: data.subscriptionExpiry.present
          ? data.subscriptionExpiry.value
          : this.subscriptionExpiry,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUser(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('xp: $xp, ')
          ..write('level: $level, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('subscriptionExpiry: $subscriptionExpiry, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    avatarPath,
    xp,
    level,
    subscriptionTier,
    subscriptionExpiry,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUser &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.avatarPath == this.avatarPath &&
          other.xp == this.xp &&
          other.level == this.level &&
          other.subscriptionTier == this.subscriptionTier &&
          other.subscriptionExpiry == this.subscriptionExpiry &&
          other.createdAt == this.createdAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUser> {
  final Value<int> id;
  final Value<String?> displayName;
  final Value<String?> avatarPath;
  final Value<int> xp;
  final Value<int> level;
  final Value<String> subscriptionTier;
  final Value<DateTime?> subscriptionExpiry;
  final Value<DateTime> createdAt;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.xp = const Value.absent(),
    this.level = const Value.absent(),
    this.subscriptionTier = const Value.absent(),
    this.subscriptionExpiry = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.xp = const Value.absent(),
    this.level = const Value.absent(),
    this.subscriptionTier = const Value.absent(),
    this.subscriptionExpiry = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<AppUser> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? avatarPath,
    Expression<int>? xp,
    Expression<int>? level,
    Expression<String>? subscriptionTier,
    Expression<DateTime>? subscriptionExpiry,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (xp != null) 'xp': xp,
      if (level != null) 'level': level,
      if (subscriptionTier != null) 'subscription_tier': subscriptionTier,
      if (subscriptionExpiry != null) 'subscription_expiry': subscriptionExpiry,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppUsersCompanion copyWith({
    Value<int>? id,
    Value<String?>? displayName,
    Value<String?>? avatarPath,
    Value<int>? xp,
    Value<int>? level,
    Value<String>? subscriptionTier,
    Value<DateTime?>? subscriptionExpiry,
    Value<DateTime>? createdAt,
  }) {
    return AppUsersCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (subscriptionTier.present) {
      map['subscription_tier'] = Variable<String>(subscriptionTier.value);
    }
    if (subscriptionExpiry.present) {
      map['subscription_expiry'] = Variable<DateTime>(subscriptionExpiry.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('xp: $xp, ')
          ..write('level: $level, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('subscriptionExpiry: $subscriptionExpiry, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlantSpeciesTable extends PlantSpecies
    with TableInfo<$PlantSpeciesTable, PlantSpecy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantSpeciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commonNameMeta = const VerificationMeta(
    'commonName',
  );
  @override
  late final GeneratedColumn<String> commonName = GeneratedColumn<String>(
    'common_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _careGuideJsonMeta = const VerificationMeta(
    'careGuideJson',
  );
  @override
  late final GeneratedColumn<String> careGuideJson = GeneratedColumn<String>(
    'care_guide_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultWateringDaysMeta =
      const VerificationMeta('defaultWateringDays');
  @override
  late final GeneratedColumn<int> defaultWateringDays = GeneratedColumn<int>(
    'default_watering_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fertilizingFrequencyDaysMeta =
      const VerificationMeta('fertilizingFrequencyDays');
  @override
  late final GeneratedColumn<int> fertilizingFrequencyDays =
      GeneratedColumn<int>(
        'fertilizing_frequency_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fertilizerTypeMeta = const VerificationMeta(
    'fertilizerType',
  );
  @override
  late final GeneratedColumn<String> fertilizerType = GeneratedColumn<String>(
    'fertilizer_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lightRequirementsMeta = const VerificationMeta(
    'lightRequirements',
  );
  @override
  late final GeneratedColumn<String> lightRequirements =
      GeneratedColumn<String>(
        'light_requirements',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _minTemperatureMeta = const VerificationMeta(
    'minTemperature',
  );
  @override
  late final GeneratedColumn<int> minTemperature = GeneratedColumn<int>(
    'min_temperature',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxTemperatureMeta = const VerificationMeta(
    'maxTemperature',
  );
  @override
  late final GeneratedColumn<int> maxTemperature = GeneratedColumn<int>(
    'max_temperature',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _humidityMinMeta = const VerificationMeta(
    'humidityMin',
  );
  @override
  late final GeneratedColumn<int> humidityMin = GeneratedColumn<int>(
    'humidity_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _humidityMaxMeta = const VerificationMeta(
    'humidityMax',
  );
  @override
  late final GeneratedColumn<int> humidityMax = GeneratedColumn<int>(
    'humidity_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soilTypeMeta = const VerificationMeta(
    'soilType',
  );
  @override
  late final GeneratedColumn<String> soilType = GeneratedColumn<String>(
    'soil_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soilMoistureMeta = const VerificationMeta(
    'soilMoisture',
  );
  @override
  late final GeneratedColumn<String> soilMoisture = GeneratedColumn<String>(
    'soil_moisture',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repottingFrequencyMonthsMeta =
      const VerificationMeta('repottingFrequencyMonths');
  @override
  late final GeneratedColumn<int> repottingFrequencyMonths =
      GeneratedColumn<int>(
        'repotting_frequency_months',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pruningInfoMeta = const VerificationMeta(
    'pruningInfo',
  );
  @override
  late final GeneratedColumn<String> pruningInfo = GeneratedColumn<String>(
    'pruning_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toxicityMeta = const VerificationMeta(
    'toxicity',
  );
  @override
  late final GeneratedColumn<String> toxicity = GeneratedColumn<String>(
    'toxicity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelLabelIdMeta = const VerificationMeta(
    'modelLabelId',
  );
  @override
  late final GeneratedColumn<String> modelLabelId = GeneratedColumn<String>(
    'model_label_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageAssetPathMeta = const VerificationMeta(
    'imageAssetPath',
  );
  @override
  late final GeneratedColumn<String> imageAssetPath = GeneratedColumn<String>(
    'image_asset_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPremiumMeta = const VerificationMeta(
    'isPremium',
  );
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
    'is_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    commonName,
    scientificName,
    family,
    category,
    description,
    careGuideJson,
    defaultWateringDays,
    fertilizingFrequencyDays,
    fertilizerType,
    lightRequirements,
    minTemperature,
    maxTemperature,
    humidityMin,
    humidityMax,
    soilType,
    soilMoisture,
    repottingFrequencyMonths,
    pruningInfo,
    toxicity,
    modelLabelId,
    imageAssetPath,
    isPremium,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_species';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlantSpecy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('common_name')) {
      context.handle(
        _commonNameMeta,
        commonName.isAcceptableOrUnknown(data['common_name']!, _commonNameMeta),
      );
    } else if (isInserting) {
      context.missing(_commonNameMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('care_guide_json')) {
      context.handle(
        _careGuideJsonMeta,
        careGuideJson.isAcceptableOrUnknown(
          data['care_guide_json']!,
          _careGuideJsonMeta,
        ),
      );
    }
    if (data.containsKey('default_watering_days')) {
      context.handle(
        _defaultWateringDaysMeta,
        defaultWateringDays.isAcceptableOrUnknown(
          data['default_watering_days']!,
          _defaultWateringDaysMeta,
        ),
      );
    }
    if (data.containsKey('fertilizing_frequency_days')) {
      context.handle(
        _fertilizingFrequencyDaysMeta,
        fertilizingFrequencyDays.isAcceptableOrUnknown(
          data['fertilizing_frequency_days']!,
          _fertilizingFrequencyDaysMeta,
        ),
      );
    }
    if (data.containsKey('fertilizer_type')) {
      context.handle(
        _fertilizerTypeMeta,
        fertilizerType.isAcceptableOrUnknown(
          data['fertilizer_type']!,
          _fertilizerTypeMeta,
        ),
      );
    }
    if (data.containsKey('light_requirements')) {
      context.handle(
        _lightRequirementsMeta,
        lightRequirements.isAcceptableOrUnknown(
          data['light_requirements']!,
          _lightRequirementsMeta,
        ),
      );
    }
    if (data.containsKey('min_temperature')) {
      context.handle(
        _minTemperatureMeta,
        minTemperature.isAcceptableOrUnknown(
          data['min_temperature']!,
          _minTemperatureMeta,
        ),
      );
    }
    if (data.containsKey('max_temperature')) {
      context.handle(
        _maxTemperatureMeta,
        maxTemperature.isAcceptableOrUnknown(
          data['max_temperature']!,
          _maxTemperatureMeta,
        ),
      );
    }
    if (data.containsKey('humidity_min')) {
      context.handle(
        _humidityMinMeta,
        humidityMin.isAcceptableOrUnknown(
          data['humidity_min']!,
          _humidityMinMeta,
        ),
      );
    }
    if (data.containsKey('humidity_max')) {
      context.handle(
        _humidityMaxMeta,
        humidityMax.isAcceptableOrUnknown(
          data['humidity_max']!,
          _humidityMaxMeta,
        ),
      );
    }
    if (data.containsKey('soil_type')) {
      context.handle(
        _soilTypeMeta,
        soilType.isAcceptableOrUnknown(data['soil_type']!, _soilTypeMeta),
      );
    }
    if (data.containsKey('soil_moisture')) {
      context.handle(
        _soilMoistureMeta,
        soilMoisture.isAcceptableOrUnknown(
          data['soil_moisture']!,
          _soilMoistureMeta,
        ),
      );
    }
    if (data.containsKey('repotting_frequency_months')) {
      context.handle(
        _repottingFrequencyMonthsMeta,
        repottingFrequencyMonths.isAcceptableOrUnknown(
          data['repotting_frequency_months']!,
          _repottingFrequencyMonthsMeta,
        ),
      );
    }
    if (data.containsKey('pruning_info')) {
      context.handle(
        _pruningInfoMeta,
        pruningInfo.isAcceptableOrUnknown(
          data['pruning_info']!,
          _pruningInfoMeta,
        ),
      );
    }
    if (data.containsKey('toxicity')) {
      context.handle(
        _toxicityMeta,
        toxicity.isAcceptableOrUnknown(data['toxicity']!, _toxicityMeta),
      );
    }
    if (data.containsKey('model_label_id')) {
      context.handle(
        _modelLabelIdMeta,
        modelLabelId.isAcceptableOrUnknown(
          data['model_label_id']!,
          _modelLabelIdMeta,
        ),
      );
    }
    if (data.containsKey('image_asset_path')) {
      context.handle(
        _imageAssetPathMeta,
        imageAssetPath.isAcceptableOrUnknown(
          data['image_asset_path']!,
          _imageAssetPathMeta,
        ),
      );
    }
    if (data.containsKey('is_premium')) {
      context.handle(
        _isPremiumMeta,
        isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantSpecy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantSpecy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      commonName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_name'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      careGuideJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}care_guide_json'],
      ),
      defaultWateringDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_watering_days'],
      ),
      fertilizingFrequencyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fertilizing_frequency_days'],
      ),
      fertilizerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fertilizer_type'],
      ),
      lightRequirements: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}light_requirements'],
      ),
      minTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_temperature'],
      ),
      maxTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_temperature'],
      ),
      humidityMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}humidity_min'],
      ),
      humidityMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}humidity_max'],
      ),
      soilType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_type'],
      ),
      soilMoisture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_moisture'],
      ),
      repottingFrequencyMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repotting_frequency_months'],
      ),
      pruningInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pruning_info'],
      ),
      toxicity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toxicity'],
      ),
      modelLabelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_label_id'],
      ),
      imageAssetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_asset_path'],
      ),
      isPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_premium'],
      )!,
    );
  }

  @override
  $PlantSpeciesTable createAlias(String alias) {
    return $PlantSpeciesTable(attachedDatabase, alias);
  }
}

class PlantSpecy extends DataClass implements Insertable<PlantSpecy> {
  final String id;
  final String commonName;
  final String scientificName;
  final String? family;
  final String? category;
  final String? description;
  final String? careGuideJson;
  final int? defaultWateringDays;
  final int? fertilizingFrequencyDays;
  final String? fertilizerType;
  final String? lightRequirements;
  final int? minTemperature;
  final int? maxTemperature;
  final int? humidityMin;
  final int? humidityMax;
  final String? soilType;
  final String? soilMoisture;
  final int? repottingFrequencyMonths;
  final String? pruningInfo;
  final String? toxicity;
  final String? modelLabelId;
  final String? imageAssetPath;
  final bool isPremium;
  const PlantSpecy({
    required this.id,
    required this.commonName,
    required this.scientificName,
    this.family,
    this.category,
    this.description,
    this.careGuideJson,
    this.defaultWateringDays,
    this.fertilizingFrequencyDays,
    this.fertilizerType,
    this.lightRequirements,
    this.minTemperature,
    this.maxTemperature,
    this.humidityMin,
    this.humidityMax,
    this.soilType,
    this.soilMoisture,
    this.repottingFrequencyMonths,
    this.pruningInfo,
    this.toxicity,
    this.modelLabelId,
    this.imageAssetPath,
    required this.isPremium,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['common_name'] = Variable<String>(commonName);
    map['scientific_name'] = Variable<String>(scientificName);
    if (!nullToAbsent || family != null) {
      map['family'] = Variable<String>(family);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || careGuideJson != null) {
      map['care_guide_json'] = Variable<String>(careGuideJson);
    }
    if (!nullToAbsent || defaultWateringDays != null) {
      map['default_watering_days'] = Variable<int>(defaultWateringDays);
    }
    if (!nullToAbsent || fertilizingFrequencyDays != null) {
      map['fertilizing_frequency_days'] = Variable<int>(
        fertilizingFrequencyDays,
      );
    }
    if (!nullToAbsent || fertilizerType != null) {
      map['fertilizer_type'] = Variable<String>(fertilizerType);
    }
    if (!nullToAbsent || lightRequirements != null) {
      map['light_requirements'] = Variable<String>(lightRequirements);
    }
    if (!nullToAbsent || minTemperature != null) {
      map['min_temperature'] = Variable<int>(minTemperature);
    }
    if (!nullToAbsent || maxTemperature != null) {
      map['max_temperature'] = Variable<int>(maxTemperature);
    }
    if (!nullToAbsent || humidityMin != null) {
      map['humidity_min'] = Variable<int>(humidityMin);
    }
    if (!nullToAbsent || humidityMax != null) {
      map['humidity_max'] = Variable<int>(humidityMax);
    }
    if (!nullToAbsent || soilType != null) {
      map['soil_type'] = Variable<String>(soilType);
    }
    if (!nullToAbsent || soilMoisture != null) {
      map['soil_moisture'] = Variable<String>(soilMoisture);
    }
    if (!nullToAbsent || repottingFrequencyMonths != null) {
      map['repotting_frequency_months'] = Variable<int>(
        repottingFrequencyMonths,
      );
    }
    if (!nullToAbsent || pruningInfo != null) {
      map['pruning_info'] = Variable<String>(pruningInfo);
    }
    if (!nullToAbsent || toxicity != null) {
      map['toxicity'] = Variable<String>(toxicity);
    }
    if (!nullToAbsent || modelLabelId != null) {
      map['model_label_id'] = Variable<String>(modelLabelId);
    }
    if (!nullToAbsent || imageAssetPath != null) {
      map['image_asset_path'] = Variable<String>(imageAssetPath);
    }
    map['is_premium'] = Variable<bool>(isPremium);
    return map;
  }

  PlantSpeciesCompanion toCompanion(bool nullToAbsent) {
    return PlantSpeciesCompanion(
      id: Value(id),
      commonName: Value(commonName),
      scientificName: Value(scientificName),
      family: family == null && nullToAbsent
          ? const Value.absent()
          : Value(family),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      careGuideJson: careGuideJson == null && nullToAbsent
          ? const Value.absent()
          : Value(careGuideJson),
      defaultWateringDays: defaultWateringDays == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultWateringDays),
      fertilizingFrequencyDays: fertilizingFrequencyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(fertilizingFrequencyDays),
      fertilizerType: fertilizerType == null && nullToAbsent
          ? const Value.absent()
          : Value(fertilizerType),
      lightRequirements: lightRequirements == null && nullToAbsent
          ? const Value.absent()
          : Value(lightRequirements),
      minTemperature: minTemperature == null && nullToAbsent
          ? const Value.absent()
          : Value(minTemperature),
      maxTemperature: maxTemperature == null && nullToAbsent
          ? const Value.absent()
          : Value(maxTemperature),
      humidityMin: humidityMin == null && nullToAbsent
          ? const Value.absent()
          : Value(humidityMin),
      humidityMax: humidityMax == null && nullToAbsent
          ? const Value.absent()
          : Value(humidityMax),
      soilType: soilType == null && nullToAbsent
          ? const Value.absent()
          : Value(soilType),
      soilMoisture: soilMoisture == null && nullToAbsent
          ? const Value.absent()
          : Value(soilMoisture),
      repottingFrequencyMonths: repottingFrequencyMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(repottingFrequencyMonths),
      pruningInfo: pruningInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(pruningInfo),
      toxicity: toxicity == null && nullToAbsent
          ? const Value.absent()
          : Value(toxicity),
      modelLabelId: modelLabelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelLabelId),
      imageAssetPath: imageAssetPath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageAssetPath),
      isPremium: Value(isPremium),
    );
  }

  factory PlantSpecy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantSpecy(
      id: serializer.fromJson<String>(json['id']),
      commonName: serializer.fromJson<String>(json['commonName']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      family: serializer.fromJson<String?>(json['family']),
      category: serializer.fromJson<String?>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      careGuideJson: serializer.fromJson<String?>(json['careGuideJson']),
      defaultWateringDays: serializer.fromJson<int?>(
        json['defaultWateringDays'],
      ),
      fertilizingFrequencyDays: serializer.fromJson<int?>(
        json['fertilizingFrequencyDays'],
      ),
      fertilizerType: serializer.fromJson<String?>(json['fertilizerType']),
      lightRequirements: serializer.fromJson<String?>(
        json['lightRequirements'],
      ),
      minTemperature: serializer.fromJson<int?>(json['minTemperature']),
      maxTemperature: serializer.fromJson<int?>(json['maxTemperature']),
      humidityMin: serializer.fromJson<int?>(json['humidityMin']),
      humidityMax: serializer.fromJson<int?>(json['humidityMax']),
      soilType: serializer.fromJson<String?>(json['soilType']),
      soilMoisture: serializer.fromJson<String?>(json['soilMoisture']),
      repottingFrequencyMonths: serializer.fromJson<int?>(
        json['repottingFrequencyMonths'],
      ),
      pruningInfo: serializer.fromJson<String?>(json['pruningInfo']),
      toxicity: serializer.fromJson<String?>(json['toxicity']),
      modelLabelId: serializer.fromJson<String?>(json['modelLabelId']),
      imageAssetPath: serializer.fromJson<String?>(json['imageAssetPath']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'commonName': serializer.toJson<String>(commonName),
      'scientificName': serializer.toJson<String>(scientificName),
      'family': serializer.toJson<String?>(family),
      'category': serializer.toJson<String?>(category),
      'description': serializer.toJson<String?>(description),
      'careGuideJson': serializer.toJson<String?>(careGuideJson),
      'defaultWateringDays': serializer.toJson<int?>(defaultWateringDays),
      'fertilizingFrequencyDays': serializer.toJson<int?>(
        fertilizingFrequencyDays,
      ),
      'fertilizerType': serializer.toJson<String?>(fertilizerType),
      'lightRequirements': serializer.toJson<String?>(lightRequirements),
      'minTemperature': serializer.toJson<int?>(minTemperature),
      'maxTemperature': serializer.toJson<int?>(maxTemperature),
      'humidityMin': serializer.toJson<int?>(humidityMin),
      'humidityMax': serializer.toJson<int?>(humidityMax),
      'soilType': serializer.toJson<String?>(soilType),
      'soilMoisture': serializer.toJson<String?>(soilMoisture),
      'repottingFrequencyMonths': serializer.toJson<int?>(
        repottingFrequencyMonths,
      ),
      'pruningInfo': serializer.toJson<String?>(pruningInfo),
      'toxicity': serializer.toJson<String?>(toxicity),
      'modelLabelId': serializer.toJson<String?>(modelLabelId),
      'imageAssetPath': serializer.toJson<String?>(imageAssetPath),
      'isPremium': serializer.toJson<bool>(isPremium),
    };
  }

  PlantSpecy copyWith({
    String? id,
    String? commonName,
    String? scientificName,
    Value<String?> family = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> careGuideJson = const Value.absent(),
    Value<int?> defaultWateringDays = const Value.absent(),
    Value<int?> fertilizingFrequencyDays = const Value.absent(),
    Value<String?> fertilizerType = const Value.absent(),
    Value<String?> lightRequirements = const Value.absent(),
    Value<int?> minTemperature = const Value.absent(),
    Value<int?> maxTemperature = const Value.absent(),
    Value<int?> humidityMin = const Value.absent(),
    Value<int?> humidityMax = const Value.absent(),
    Value<String?> soilType = const Value.absent(),
    Value<String?> soilMoisture = const Value.absent(),
    Value<int?> repottingFrequencyMonths = const Value.absent(),
    Value<String?> pruningInfo = const Value.absent(),
    Value<String?> toxicity = const Value.absent(),
    Value<String?> modelLabelId = const Value.absent(),
    Value<String?> imageAssetPath = const Value.absent(),
    bool? isPremium,
  }) => PlantSpecy(
    id: id ?? this.id,
    commonName: commonName ?? this.commonName,
    scientificName: scientificName ?? this.scientificName,
    family: family.present ? family.value : this.family,
    category: category.present ? category.value : this.category,
    description: description.present ? description.value : this.description,
    careGuideJson: careGuideJson.present
        ? careGuideJson.value
        : this.careGuideJson,
    defaultWateringDays: defaultWateringDays.present
        ? defaultWateringDays.value
        : this.defaultWateringDays,
    fertilizingFrequencyDays: fertilizingFrequencyDays.present
        ? fertilizingFrequencyDays.value
        : this.fertilizingFrequencyDays,
    fertilizerType: fertilizerType.present
        ? fertilizerType.value
        : this.fertilizerType,
    lightRequirements: lightRequirements.present
        ? lightRequirements.value
        : this.lightRequirements,
    minTemperature: minTemperature.present
        ? minTemperature.value
        : this.minTemperature,
    maxTemperature: maxTemperature.present
        ? maxTemperature.value
        : this.maxTemperature,
    humidityMin: humidityMin.present ? humidityMin.value : this.humidityMin,
    humidityMax: humidityMax.present ? humidityMax.value : this.humidityMax,
    soilType: soilType.present ? soilType.value : this.soilType,
    soilMoisture: soilMoisture.present ? soilMoisture.value : this.soilMoisture,
    repottingFrequencyMonths: repottingFrequencyMonths.present
        ? repottingFrequencyMonths.value
        : this.repottingFrequencyMonths,
    pruningInfo: pruningInfo.present ? pruningInfo.value : this.pruningInfo,
    toxicity: toxicity.present ? toxicity.value : this.toxicity,
    modelLabelId: modelLabelId.present ? modelLabelId.value : this.modelLabelId,
    imageAssetPath: imageAssetPath.present
        ? imageAssetPath.value
        : this.imageAssetPath,
    isPremium: isPremium ?? this.isPremium,
  );
  PlantSpecy copyWithCompanion(PlantSpeciesCompanion data) {
    return PlantSpecy(
      id: data.id.present ? data.id.value : this.id,
      commonName: data.commonName.present
          ? data.commonName.value
          : this.commonName,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      family: data.family.present ? data.family.value : this.family,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      careGuideJson: data.careGuideJson.present
          ? data.careGuideJson.value
          : this.careGuideJson,
      defaultWateringDays: data.defaultWateringDays.present
          ? data.defaultWateringDays.value
          : this.defaultWateringDays,
      fertilizingFrequencyDays: data.fertilizingFrequencyDays.present
          ? data.fertilizingFrequencyDays.value
          : this.fertilizingFrequencyDays,
      fertilizerType: data.fertilizerType.present
          ? data.fertilizerType.value
          : this.fertilizerType,
      lightRequirements: data.lightRequirements.present
          ? data.lightRequirements.value
          : this.lightRequirements,
      minTemperature: data.minTemperature.present
          ? data.minTemperature.value
          : this.minTemperature,
      maxTemperature: data.maxTemperature.present
          ? data.maxTemperature.value
          : this.maxTemperature,
      humidityMin: data.humidityMin.present
          ? data.humidityMin.value
          : this.humidityMin,
      humidityMax: data.humidityMax.present
          ? data.humidityMax.value
          : this.humidityMax,
      soilType: data.soilType.present ? data.soilType.value : this.soilType,
      soilMoisture: data.soilMoisture.present
          ? data.soilMoisture.value
          : this.soilMoisture,
      repottingFrequencyMonths: data.repottingFrequencyMonths.present
          ? data.repottingFrequencyMonths.value
          : this.repottingFrequencyMonths,
      pruningInfo: data.pruningInfo.present
          ? data.pruningInfo.value
          : this.pruningInfo,
      toxicity: data.toxicity.present ? data.toxicity.value : this.toxicity,
      modelLabelId: data.modelLabelId.present
          ? data.modelLabelId.value
          : this.modelLabelId,
      imageAssetPath: data.imageAssetPath.present
          ? data.imageAssetPath.value
          : this.imageAssetPath,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantSpecy(')
          ..write('id: $id, ')
          ..write('commonName: $commonName, ')
          ..write('scientificName: $scientificName, ')
          ..write('family: $family, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('careGuideJson: $careGuideJson, ')
          ..write('defaultWateringDays: $defaultWateringDays, ')
          ..write('fertilizingFrequencyDays: $fertilizingFrequencyDays, ')
          ..write('fertilizerType: $fertilizerType, ')
          ..write('lightRequirements: $lightRequirements, ')
          ..write('minTemperature: $minTemperature, ')
          ..write('maxTemperature: $maxTemperature, ')
          ..write('humidityMin: $humidityMin, ')
          ..write('humidityMax: $humidityMax, ')
          ..write('soilType: $soilType, ')
          ..write('soilMoisture: $soilMoisture, ')
          ..write('repottingFrequencyMonths: $repottingFrequencyMonths, ')
          ..write('pruningInfo: $pruningInfo, ')
          ..write('toxicity: $toxicity, ')
          ..write('modelLabelId: $modelLabelId, ')
          ..write('imageAssetPath: $imageAssetPath, ')
          ..write('isPremium: $isPremium')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    commonName,
    scientificName,
    family,
    category,
    description,
    careGuideJson,
    defaultWateringDays,
    fertilizingFrequencyDays,
    fertilizerType,
    lightRequirements,
    minTemperature,
    maxTemperature,
    humidityMin,
    humidityMax,
    soilType,
    soilMoisture,
    repottingFrequencyMonths,
    pruningInfo,
    toxicity,
    modelLabelId,
    imageAssetPath,
    isPremium,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantSpecy &&
          other.id == this.id &&
          other.commonName == this.commonName &&
          other.scientificName == this.scientificName &&
          other.family == this.family &&
          other.category == this.category &&
          other.description == this.description &&
          other.careGuideJson == this.careGuideJson &&
          other.defaultWateringDays == this.defaultWateringDays &&
          other.fertilizingFrequencyDays == this.fertilizingFrequencyDays &&
          other.fertilizerType == this.fertilizerType &&
          other.lightRequirements == this.lightRequirements &&
          other.minTemperature == this.minTemperature &&
          other.maxTemperature == this.maxTemperature &&
          other.humidityMin == this.humidityMin &&
          other.humidityMax == this.humidityMax &&
          other.soilType == this.soilType &&
          other.soilMoisture == this.soilMoisture &&
          other.repottingFrequencyMonths == this.repottingFrequencyMonths &&
          other.pruningInfo == this.pruningInfo &&
          other.toxicity == this.toxicity &&
          other.modelLabelId == this.modelLabelId &&
          other.imageAssetPath == this.imageAssetPath &&
          other.isPremium == this.isPremium);
}

class PlantSpeciesCompanion extends UpdateCompanion<PlantSpecy> {
  final Value<String> id;
  final Value<String> commonName;
  final Value<String> scientificName;
  final Value<String?> family;
  final Value<String?> category;
  final Value<String?> description;
  final Value<String?> careGuideJson;
  final Value<int?> defaultWateringDays;
  final Value<int?> fertilizingFrequencyDays;
  final Value<String?> fertilizerType;
  final Value<String?> lightRequirements;
  final Value<int?> minTemperature;
  final Value<int?> maxTemperature;
  final Value<int?> humidityMin;
  final Value<int?> humidityMax;
  final Value<String?> soilType;
  final Value<String?> soilMoisture;
  final Value<int?> repottingFrequencyMonths;
  final Value<String?> pruningInfo;
  final Value<String?> toxicity;
  final Value<String?> modelLabelId;
  final Value<String?> imageAssetPath;
  final Value<bool> isPremium;
  final Value<int> rowid;
  const PlantSpeciesCompanion({
    this.id = const Value.absent(),
    this.commonName = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.family = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.careGuideJson = const Value.absent(),
    this.defaultWateringDays = const Value.absent(),
    this.fertilizingFrequencyDays = const Value.absent(),
    this.fertilizerType = const Value.absent(),
    this.lightRequirements = const Value.absent(),
    this.minTemperature = const Value.absent(),
    this.maxTemperature = const Value.absent(),
    this.humidityMin = const Value.absent(),
    this.humidityMax = const Value.absent(),
    this.soilType = const Value.absent(),
    this.soilMoisture = const Value.absent(),
    this.repottingFrequencyMonths = const Value.absent(),
    this.pruningInfo = const Value.absent(),
    this.toxicity = const Value.absent(),
    this.modelLabelId = const Value.absent(),
    this.imageAssetPath = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantSpeciesCompanion.insert({
    required String id,
    required String commonName,
    required String scientificName,
    this.family = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.careGuideJson = const Value.absent(),
    this.defaultWateringDays = const Value.absent(),
    this.fertilizingFrequencyDays = const Value.absent(),
    this.fertilizerType = const Value.absent(),
    this.lightRequirements = const Value.absent(),
    this.minTemperature = const Value.absent(),
    this.maxTemperature = const Value.absent(),
    this.humidityMin = const Value.absent(),
    this.humidityMax = const Value.absent(),
    this.soilType = const Value.absent(),
    this.soilMoisture = const Value.absent(),
    this.repottingFrequencyMonths = const Value.absent(),
    this.pruningInfo = const Value.absent(),
    this.toxicity = const Value.absent(),
    this.modelLabelId = const Value.absent(),
    this.imageAssetPath = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       commonName = Value(commonName),
       scientificName = Value(scientificName);
  static Insertable<PlantSpecy> custom({
    Expression<String>? id,
    Expression<String>? commonName,
    Expression<String>? scientificName,
    Expression<String>? family,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? careGuideJson,
    Expression<int>? defaultWateringDays,
    Expression<int>? fertilizingFrequencyDays,
    Expression<String>? fertilizerType,
    Expression<String>? lightRequirements,
    Expression<int>? minTemperature,
    Expression<int>? maxTemperature,
    Expression<int>? humidityMin,
    Expression<int>? humidityMax,
    Expression<String>? soilType,
    Expression<String>? soilMoisture,
    Expression<int>? repottingFrequencyMonths,
    Expression<String>? pruningInfo,
    Expression<String>? toxicity,
    Expression<String>? modelLabelId,
    Expression<String>? imageAssetPath,
    Expression<bool>? isPremium,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commonName != null) 'common_name': commonName,
      if (scientificName != null) 'scientific_name': scientificName,
      if (family != null) 'family': family,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (careGuideJson != null) 'care_guide_json': careGuideJson,
      if (defaultWateringDays != null)
        'default_watering_days': defaultWateringDays,
      if (fertilizingFrequencyDays != null)
        'fertilizing_frequency_days': fertilizingFrequencyDays,
      if (fertilizerType != null) 'fertilizer_type': fertilizerType,
      if (lightRequirements != null) 'light_requirements': lightRequirements,
      if (minTemperature != null) 'min_temperature': minTemperature,
      if (maxTemperature != null) 'max_temperature': maxTemperature,
      if (humidityMin != null) 'humidity_min': humidityMin,
      if (humidityMax != null) 'humidity_max': humidityMax,
      if (soilType != null) 'soil_type': soilType,
      if (soilMoisture != null) 'soil_moisture': soilMoisture,
      if (repottingFrequencyMonths != null)
        'repotting_frequency_months': repottingFrequencyMonths,
      if (pruningInfo != null) 'pruning_info': pruningInfo,
      if (toxicity != null) 'toxicity': toxicity,
      if (modelLabelId != null) 'model_label_id': modelLabelId,
      if (imageAssetPath != null) 'image_asset_path': imageAssetPath,
      if (isPremium != null) 'is_premium': isPremium,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantSpeciesCompanion copyWith({
    Value<String>? id,
    Value<String>? commonName,
    Value<String>? scientificName,
    Value<String?>? family,
    Value<String?>? category,
    Value<String?>? description,
    Value<String?>? careGuideJson,
    Value<int?>? defaultWateringDays,
    Value<int?>? fertilizingFrequencyDays,
    Value<String?>? fertilizerType,
    Value<String?>? lightRequirements,
    Value<int?>? minTemperature,
    Value<int?>? maxTemperature,
    Value<int?>? humidityMin,
    Value<int?>? humidityMax,
    Value<String?>? soilType,
    Value<String?>? soilMoisture,
    Value<int?>? repottingFrequencyMonths,
    Value<String?>? pruningInfo,
    Value<String?>? toxicity,
    Value<String?>? modelLabelId,
    Value<String?>? imageAssetPath,
    Value<bool>? isPremium,
    Value<int>? rowid,
  }) {
    return PlantSpeciesCompanion(
      id: id ?? this.id,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      family: family ?? this.family,
      category: category ?? this.category,
      description: description ?? this.description,
      careGuideJson: careGuideJson ?? this.careGuideJson,
      defaultWateringDays: defaultWateringDays ?? this.defaultWateringDays,
      fertilizingFrequencyDays:
          fertilizingFrequencyDays ?? this.fertilizingFrequencyDays,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      lightRequirements: lightRequirements ?? this.lightRequirements,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      humidityMin: humidityMin ?? this.humidityMin,
      humidityMax: humidityMax ?? this.humidityMax,
      soilType: soilType ?? this.soilType,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      repottingFrequencyMonths:
          repottingFrequencyMonths ?? this.repottingFrequencyMonths,
      pruningInfo: pruningInfo ?? this.pruningInfo,
      toxicity: toxicity ?? this.toxicity,
      modelLabelId: modelLabelId ?? this.modelLabelId,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      isPremium: isPremium ?? this.isPremium,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (commonName.present) {
      map['common_name'] = Variable<String>(commonName.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (careGuideJson.present) {
      map['care_guide_json'] = Variable<String>(careGuideJson.value);
    }
    if (defaultWateringDays.present) {
      map['default_watering_days'] = Variable<int>(defaultWateringDays.value);
    }
    if (fertilizingFrequencyDays.present) {
      map['fertilizing_frequency_days'] = Variable<int>(
        fertilizingFrequencyDays.value,
      );
    }
    if (fertilizerType.present) {
      map['fertilizer_type'] = Variable<String>(fertilizerType.value);
    }
    if (lightRequirements.present) {
      map['light_requirements'] = Variable<String>(lightRequirements.value);
    }
    if (minTemperature.present) {
      map['min_temperature'] = Variable<int>(minTemperature.value);
    }
    if (maxTemperature.present) {
      map['max_temperature'] = Variable<int>(maxTemperature.value);
    }
    if (humidityMin.present) {
      map['humidity_min'] = Variable<int>(humidityMin.value);
    }
    if (humidityMax.present) {
      map['humidity_max'] = Variable<int>(humidityMax.value);
    }
    if (soilType.present) {
      map['soil_type'] = Variable<String>(soilType.value);
    }
    if (soilMoisture.present) {
      map['soil_moisture'] = Variable<String>(soilMoisture.value);
    }
    if (repottingFrequencyMonths.present) {
      map['repotting_frequency_months'] = Variable<int>(
        repottingFrequencyMonths.value,
      );
    }
    if (pruningInfo.present) {
      map['pruning_info'] = Variable<String>(pruningInfo.value);
    }
    if (toxicity.present) {
      map['toxicity'] = Variable<String>(toxicity.value);
    }
    if (modelLabelId.present) {
      map['model_label_id'] = Variable<String>(modelLabelId.value);
    }
    if (imageAssetPath.present) {
      map['image_asset_path'] = Variable<String>(imageAssetPath.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantSpeciesCompanion(')
          ..write('id: $id, ')
          ..write('commonName: $commonName, ')
          ..write('scientificName: $scientificName, ')
          ..write('family: $family, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('careGuideJson: $careGuideJson, ')
          ..write('defaultWateringDays: $defaultWateringDays, ')
          ..write('fertilizingFrequencyDays: $fertilizingFrequencyDays, ')
          ..write('fertilizerType: $fertilizerType, ')
          ..write('lightRequirements: $lightRequirements, ')
          ..write('minTemperature: $minTemperature, ')
          ..write('maxTemperature: $maxTemperature, ')
          ..write('humidityMin: $humidityMin, ')
          ..write('humidityMax: $humidityMax, ')
          ..write('soilType: $soilType, ')
          ..write('soilMoisture: $soilMoisture, ')
          ..write('repottingFrequencyMonths: $repottingFrequencyMonths, ')
          ..write('pruningInfo: $pruningInfo, ')
          ..write('toxicity: $toxicity, ')
          ..write('modelLabelId: $modelLabelId, ')
          ..write('imageAssetPath: $imageAssetPath, ')
          ..write('isPremium: $isPremium, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlantsTable extends Plants with TableInfo<$PlantsTable, Plant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plant_species (id)',
    ),
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lightDirectionMeta = const VerificationMeta(
    'lightDirection',
  );
  @override
  late final GeneratedColumn<String> lightDirection = GeneratedColumn<String>(
    'light_direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wateringFrequencyDaysMeta =
      const VerificationMeta('wateringFrequencyDays');
  @override
  late final GeneratedColumn<int> wateringFrequencyDays = GeneratedColumn<int>(
    'watering_frequency_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fertilizingFrequencyDaysMeta =
      const VerificationMeta('fertilizingFrequencyDays');
  @override
  late final GeneratedColumn<int> fertilizingFrequencyDays =
      GeneratedColumn<int>(
        'fertilizing_frequency_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _soilTypeMeta = const VerificationMeta(
    'soilType',
  );
  @override
  late final GeneratedColumn<String> soilType = GeneratedColumn<String>(
    'soil_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potSizeMeta = const VerificationMeta(
    'potSize',
  );
  @override
  late final GeneratedColumn<String> potSize = GeneratedColumn<String>(
    'pot_size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedPacketImagePathMeta =
      const VerificationMeta('seedPacketImagePath');
  @override
  late final GeneratedColumn<String> seedPacketImagePath =
      GeneratedColumn<String>(
        'seed_packet_image_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _seedVarietyNameMeta = const VerificationMeta(
    'seedVarietyName',
  );
  @override
  late final GeneratedColumn<String> seedVarietyName = GeneratedColumn<String>(
    'seed_variety_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plantingLocationMeta = const VerificationMeta(
    'plantingLocation',
  );
  @override
  late final GeneratedColumn<String> plantingLocation = GeneratedColumn<String>(
    'planting_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedlingPlantingDateMeta =
      const VerificationMeta('seedlingPlantingDate');
  @override
  late final GeneratedColumn<DateTime> seedlingPlantingDate =
      GeneratedColumn<DateTime>(
        'seedling_planting_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastWateredAtMeta = const VerificationMeta(
    'lastWateredAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastWateredAt =
      GeneratedColumn<DateTime>(
        'last_watered_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastFertilizedAtMeta = const VerificationMeta(
    'lastFertilizedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFertilizedAt =
      GeneratedColumn<DateTime>(
        'last_fertilized_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastRepottedAtMeta = const VerificationMeta(
    'lastRepottedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRepottedAt =
      GeneratedColumn<DateTime>(
        'last_repotted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextWaterDueMeta = const VerificationMeta(
    'nextWaterDue',
  );
  @override
  late final GeneratedColumn<DateTime> nextWaterDue = GeneratedColumn<DateTime>(
    'next_water_due',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    speciesId,
    customName,
    imagePath,
    location,
    lightDirection,
    wateringFrequencyDays,
    fertilizingFrequencyDays,
    soilType,
    potSize,
    notes,
    seedPacketImagePath,
    seedVarietyName,
    plantingLocation,
    seedlingPlantingDate,
    lastWateredAt,
    lastFertilizedAt,
    lastRepottedAt,
    nextWaterDue,
    createdAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    } else if (isInserting) {
      context.missing(_customNameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('light_direction')) {
      context.handle(
        _lightDirectionMeta,
        lightDirection.isAcceptableOrUnknown(
          data['light_direction']!,
          _lightDirectionMeta,
        ),
      );
    }
    if (data.containsKey('watering_frequency_days')) {
      context.handle(
        _wateringFrequencyDaysMeta,
        wateringFrequencyDays.isAcceptableOrUnknown(
          data['watering_frequency_days']!,
          _wateringFrequencyDaysMeta,
        ),
      );
    }
    if (data.containsKey('fertilizing_frequency_days')) {
      context.handle(
        _fertilizingFrequencyDaysMeta,
        fertilizingFrequencyDays.isAcceptableOrUnknown(
          data['fertilizing_frequency_days']!,
          _fertilizingFrequencyDaysMeta,
        ),
      );
    }
    if (data.containsKey('soil_type')) {
      context.handle(
        _soilTypeMeta,
        soilType.isAcceptableOrUnknown(data['soil_type']!, _soilTypeMeta),
      );
    }
    if (data.containsKey('pot_size')) {
      context.handle(
        _potSizeMeta,
        potSize.isAcceptableOrUnknown(data['pot_size']!, _potSizeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('seed_packet_image_path')) {
      context.handle(
        _seedPacketImagePathMeta,
        seedPacketImagePath.isAcceptableOrUnknown(
          data['seed_packet_image_path']!,
          _seedPacketImagePathMeta,
        ),
      );
    }
    if (data.containsKey('seed_variety_name')) {
      context.handle(
        _seedVarietyNameMeta,
        seedVarietyName.isAcceptableOrUnknown(
          data['seed_variety_name']!,
          _seedVarietyNameMeta,
        ),
      );
    }
    if (data.containsKey('planting_location')) {
      context.handle(
        _plantingLocationMeta,
        plantingLocation.isAcceptableOrUnknown(
          data['planting_location']!,
          _plantingLocationMeta,
        ),
      );
    }
    if (data.containsKey('seedling_planting_date')) {
      context.handle(
        _seedlingPlantingDateMeta,
        seedlingPlantingDate.isAcceptableOrUnknown(
          data['seedling_planting_date']!,
          _seedlingPlantingDateMeta,
        ),
      );
    }
    if (data.containsKey('last_watered_at')) {
      context.handle(
        _lastWateredAtMeta,
        lastWateredAt.isAcceptableOrUnknown(
          data['last_watered_at']!,
          _lastWateredAtMeta,
        ),
      );
    }
    if (data.containsKey('last_fertilized_at')) {
      context.handle(
        _lastFertilizedAtMeta,
        lastFertilizedAt.isAcceptableOrUnknown(
          data['last_fertilized_at']!,
          _lastFertilizedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_repotted_at')) {
      context.handle(
        _lastRepottedAtMeta,
        lastRepottedAt.isAcceptableOrUnknown(
          data['last_repotted_at']!,
          _lastRepottedAtMeta,
        ),
      );
    }
    if (data.containsKey('next_water_due')) {
      context.handle(
        _nextWaterDueMeta,
        nextWaterDue.isAcceptableOrUnknown(
          data['next_water_due']!,
          _nextWaterDueMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_id'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      lightDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}light_direction'],
      ),
      wateringFrequencyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}watering_frequency_days'],
      ),
      fertilizingFrequencyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fertilizing_frequency_days'],
      ),
      soilType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_type'],
      ),
      potSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pot_size'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      seedPacketImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_packet_image_path'],
      ),
      seedVarietyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_variety_name'],
      ),
      plantingLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planting_location'],
      ),
      seedlingPlantingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seedling_planting_date'],
      ),
      lastWateredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_watered_at'],
      ),
      lastFertilizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fertilized_at'],
      ),
      lastRepottedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_repotted_at'],
      ),
      nextWaterDue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_water_due'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $PlantsTable createAlias(String alias) {
    return $PlantsTable(attachedDatabase, alias);
  }
}

class Plant extends DataClass implements Insertable<Plant> {
  final int id;
  final int userId;
  final String? speciesId;
  final String customName;
  final String? imagePath;
  final String? location;
  final String? lightDirection;
  final int? wateringFrequencyDays;
  final int? fertilizingFrequencyDays;
  final String? soilType;
  final String? potSize;
  final String? notes;
  final String? seedPacketImagePath;
  final String? seedVarietyName;
  final String? plantingLocation;
  final DateTime? seedlingPlantingDate;
  final DateTime? lastWateredAt;
  final DateTime? lastFertilizedAt;

  /// Дата последней пересадки. Если null — берётся [createdAt]
  /// в расчёте следующей пересадки.
  final DateTime? lastRepottedAt;
  final DateTime? nextWaterDue;
  final DateTime createdAt;
  final bool isArchived;
  const Plant({
    required this.id,
    required this.userId,
    this.speciesId,
    required this.customName,
    this.imagePath,
    this.location,
    this.lightDirection,
    this.wateringFrequencyDays,
    this.fertilizingFrequencyDays,
    this.soilType,
    this.potSize,
    this.notes,
    this.seedPacketImagePath,
    this.seedVarietyName,
    this.plantingLocation,
    this.seedlingPlantingDate,
    this.lastWateredAt,
    this.lastFertilizedAt,
    this.lastRepottedAt,
    this.nextWaterDue,
    required this.createdAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<String>(speciesId);
    }
    map['custom_name'] = Variable<String>(customName);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || lightDirection != null) {
      map['light_direction'] = Variable<String>(lightDirection);
    }
    if (!nullToAbsent || wateringFrequencyDays != null) {
      map['watering_frequency_days'] = Variable<int>(wateringFrequencyDays);
    }
    if (!nullToAbsent || fertilizingFrequencyDays != null) {
      map['fertilizing_frequency_days'] = Variable<int>(
        fertilizingFrequencyDays,
      );
    }
    if (!nullToAbsent || soilType != null) {
      map['soil_type'] = Variable<String>(soilType);
    }
    if (!nullToAbsent || potSize != null) {
      map['pot_size'] = Variable<String>(potSize);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || seedPacketImagePath != null) {
      map['seed_packet_image_path'] = Variable<String>(seedPacketImagePath);
    }
    if (!nullToAbsent || seedVarietyName != null) {
      map['seed_variety_name'] = Variable<String>(seedVarietyName);
    }
    if (!nullToAbsent || plantingLocation != null) {
      map['planting_location'] = Variable<String>(plantingLocation);
    }
    if (!nullToAbsent || seedlingPlantingDate != null) {
      map['seedling_planting_date'] = Variable<DateTime>(seedlingPlantingDate);
    }
    if (!nullToAbsent || lastWateredAt != null) {
      map['last_watered_at'] = Variable<DateTime>(lastWateredAt);
    }
    if (!nullToAbsent || lastFertilizedAt != null) {
      map['last_fertilized_at'] = Variable<DateTime>(lastFertilizedAt);
    }
    if (!nullToAbsent || lastRepottedAt != null) {
      map['last_repotted_at'] = Variable<DateTime>(lastRepottedAt);
    }
    if (!nullToAbsent || nextWaterDue != null) {
      map['next_water_due'] = Variable<DateTime>(nextWaterDue);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  PlantsCompanion toCompanion(bool nullToAbsent) {
    return PlantsCompanion(
      id: Value(id),
      userId: Value(userId),
      speciesId: speciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesId),
      customName: Value(customName),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      lightDirection: lightDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(lightDirection),
      wateringFrequencyDays: wateringFrequencyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(wateringFrequencyDays),
      fertilizingFrequencyDays: fertilizingFrequencyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(fertilizingFrequencyDays),
      soilType: soilType == null && nullToAbsent
          ? const Value.absent()
          : Value(soilType),
      potSize: potSize == null && nullToAbsent
          ? const Value.absent()
          : Value(potSize),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      seedPacketImagePath: seedPacketImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(seedPacketImagePath),
      seedVarietyName: seedVarietyName == null && nullToAbsent
          ? const Value.absent()
          : Value(seedVarietyName),
      plantingLocation: plantingLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(plantingLocation),
      seedlingPlantingDate: seedlingPlantingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(seedlingPlantingDate),
      lastWateredAt: lastWateredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWateredAt),
      lastFertilizedAt: lastFertilizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFertilizedAt),
      lastRepottedAt: lastRepottedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRepottedAt),
      nextWaterDue: nextWaterDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextWaterDue),
      createdAt: Value(createdAt),
      isArchived: Value(isArchived),
    );
  }

  factory Plant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plant(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      speciesId: serializer.fromJson<String?>(json['speciesId']),
      customName: serializer.fromJson<String>(json['customName']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      location: serializer.fromJson<String?>(json['location']),
      lightDirection: serializer.fromJson<String?>(json['lightDirection']),
      wateringFrequencyDays: serializer.fromJson<int?>(
        json['wateringFrequencyDays'],
      ),
      fertilizingFrequencyDays: serializer.fromJson<int?>(
        json['fertilizingFrequencyDays'],
      ),
      soilType: serializer.fromJson<String?>(json['soilType']),
      potSize: serializer.fromJson<String?>(json['potSize']),
      notes: serializer.fromJson<String?>(json['notes']),
      seedPacketImagePath: serializer.fromJson<String?>(
        json['seedPacketImagePath'],
      ),
      seedVarietyName: serializer.fromJson<String?>(json['seedVarietyName']),
      plantingLocation: serializer.fromJson<String?>(json['plantingLocation']),
      seedlingPlantingDate: serializer.fromJson<DateTime?>(
        json['seedlingPlantingDate'],
      ),
      lastWateredAt: serializer.fromJson<DateTime?>(json['lastWateredAt']),
      lastFertilizedAt: serializer.fromJson<DateTime?>(
        json['lastFertilizedAt'],
      ),
      lastRepottedAt: serializer.fromJson<DateTime?>(json['lastRepottedAt']),
      nextWaterDue: serializer.fromJson<DateTime?>(json['nextWaterDue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'speciesId': serializer.toJson<String?>(speciesId),
      'customName': serializer.toJson<String>(customName),
      'imagePath': serializer.toJson<String?>(imagePath),
      'location': serializer.toJson<String?>(location),
      'lightDirection': serializer.toJson<String?>(lightDirection),
      'wateringFrequencyDays': serializer.toJson<int?>(wateringFrequencyDays),
      'fertilizingFrequencyDays': serializer.toJson<int?>(
        fertilizingFrequencyDays,
      ),
      'soilType': serializer.toJson<String?>(soilType),
      'potSize': serializer.toJson<String?>(potSize),
      'notes': serializer.toJson<String?>(notes),
      'seedPacketImagePath': serializer.toJson<String?>(seedPacketImagePath),
      'seedVarietyName': serializer.toJson<String?>(seedVarietyName),
      'plantingLocation': serializer.toJson<String?>(plantingLocation),
      'seedlingPlantingDate': serializer.toJson<DateTime?>(
        seedlingPlantingDate,
      ),
      'lastWateredAt': serializer.toJson<DateTime?>(lastWateredAt),
      'lastFertilizedAt': serializer.toJson<DateTime?>(lastFertilizedAt),
      'lastRepottedAt': serializer.toJson<DateTime?>(lastRepottedAt),
      'nextWaterDue': serializer.toJson<DateTime?>(nextWaterDue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Plant copyWith({
    int? id,
    int? userId,
    Value<String?> speciesId = const Value.absent(),
    String? customName,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> lightDirection = const Value.absent(),
    Value<int?> wateringFrequencyDays = const Value.absent(),
    Value<int?> fertilizingFrequencyDays = const Value.absent(),
    Value<String?> soilType = const Value.absent(),
    Value<String?> potSize = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> seedPacketImagePath = const Value.absent(),
    Value<String?> seedVarietyName = const Value.absent(),
    Value<String?> plantingLocation = const Value.absent(),
    Value<DateTime?> seedlingPlantingDate = const Value.absent(),
    Value<DateTime?> lastWateredAt = const Value.absent(),
    Value<DateTime?> lastFertilizedAt = const Value.absent(),
    Value<DateTime?> lastRepottedAt = const Value.absent(),
    Value<DateTime?> nextWaterDue = const Value.absent(),
    DateTime? createdAt,
    bool? isArchived,
  }) => Plant(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    customName: customName ?? this.customName,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    location: location.present ? location.value : this.location,
    lightDirection: lightDirection.present
        ? lightDirection.value
        : this.lightDirection,
    wateringFrequencyDays: wateringFrequencyDays.present
        ? wateringFrequencyDays.value
        : this.wateringFrequencyDays,
    fertilizingFrequencyDays: fertilizingFrequencyDays.present
        ? fertilizingFrequencyDays.value
        : this.fertilizingFrequencyDays,
    soilType: soilType.present ? soilType.value : this.soilType,
    potSize: potSize.present ? potSize.value : this.potSize,
    notes: notes.present ? notes.value : this.notes,
    seedPacketImagePath: seedPacketImagePath.present
        ? seedPacketImagePath.value
        : this.seedPacketImagePath,
    seedVarietyName: seedVarietyName.present
        ? seedVarietyName.value
        : this.seedVarietyName,
    plantingLocation: plantingLocation.present
        ? plantingLocation.value
        : this.plantingLocation,
    seedlingPlantingDate: seedlingPlantingDate.present
        ? seedlingPlantingDate.value
        : this.seedlingPlantingDate,
    lastWateredAt: lastWateredAt.present
        ? lastWateredAt.value
        : this.lastWateredAt,
    lastFertilizedAt: lastFertilizedAt.present
        ? lastFertilizedAt.value
        : this.lastFertilizedAt,
    lastRepottedAt: lastRepottedAt.present
        ? lastRepottedAt.value
        : this.lastRepottedAt,
    nextWaterDue: nextWaterDue.present ? nextWaterDue.value : this.nextWaterDue,
    createdAt: createdAt ?? this.createdAt,
    isArchived: isArchived ?? this.isArchived,
  );
  Plant copyWithCompanion(PlantsCompanion data) {
    return Plant(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      location: data.location.present ? data.location.value : this.location,
      lightDirection: data.lightDirection.present
          ? data.lightDirection.value
          : this.lightDirection,
      wateringFrequencyDays: data.wateringFrequencyDays.present
          ? data.wateringFrequencyDays.value
          : this.wateringFrequencyDays,
      fertilizingFrequencyDays: data.fertilizingFrequencyDays.present
          ? data.fertilizingFrequencyDays.value
          : this.fertilizingFrequencyDays,
      soilType: data.soilType.present ? data.soilType.value : this.soilType,
      potSize: data.potSize.present ? data.potSize.value : this.potSize,
      notes: data.notes.present ? data.notes.value : this.notes,
      seedPacketImagePath: data.seedPacketImagePath.present
          ? data.seedPacketImagePath.value
          : this.seedPacketImagePath,
      seedVarietyName: data.seedVarietyName.present
          ? data.seedVarietyName.value
          : this.seedVarietyName,
      plantingLocation: data.plantingLocation.present
          ? data.plantingLocation.value
          : this.plantingLocation,
      seedlingPlantingDate: data.seedlingPlantingDate.present
          ? data.seedlingPlantingDate.value
          : this.seedlingPlantingDate,
      lastWateredAt: data.lastWateredAt.present
          ? data.lastWateredAt.value
          : this.lastWateredAt,
      lastFertilizedAt: data.lastFertilizedAt.present
          ? data.lastFertilizedAt.value
          : this.lastFertilizedAt,
      lastRepottedAt: data.lastRepottedAt.present
          ? data.lastRepottedAt.value
          : this.lastRepottedAt,
      nextWaterDue: data.nextWaterDue.present
          ? data.nextWaterDue.value
          : this.nextWaterDue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plant(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('customName: $customName, ')
          ..write('imagePath: $imagePath, ')
          ..write('location: $location, ')
          ..write('lightDirection: $lightDirection, ')
          ..write('wateringFrequencyDays: $wateringFrequencyDays, ')
          ..write('fertilizingFrequencyDays: $fertilizingFrequencyDays, ')
          ..write('soilType: $soilType, ')
          ..write('potSize: $potSize, ')
          ..write('notes: $notes, ')
          ..write('seedPacketImagePath: $seedPacketImagePath, ')
          ..write('seedVarietyName: $seedVarietyName, ')
          ..write('plantingLocation: $plantingLocation, ')
          ..write('seedlingPlantingDate: $seedlingPlantingDate, ')
          ..write('lastWateredAt: $lastWateredAt, ')
          ..write('lastFertilizedAt: $lastFertilizedAt, ')
          ..write('lastRepottedAt: $lastRepottedAt, ')
          ..write('nextWaterDue: $nextWaterDue, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    speciesId,
    customName,
    imagePath,
    location,
    lightDirection,
    wateringFrequencyDays,
    fertilizingFrequencyDays,
    soilType,
    potSize,
    notes,
    seedPacketImagePath,
    seedVarietyName,
    plantingLocation,
    seedlingPlantingDate,
    lastWateredAt,
    lastFertilizedAt,
    lastRepottedAt,
    nextWaterDue,
    createdAt,
    isArchived,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plant &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.speciesId == this.speciesId &&
          other.customName == this.customName &&
          other.imagePath == this.imagePath &&
          other.location == this.location &&
          other.lightDirection == this.lightDirection &&
          other.wateringFrequencyDays == this.wateringFrequencyDays &&
          other.fertilizingFrequencyDays == this.fertilizingFrequencyDays &&
          other.soilType == this.soilType &&
          other.potSize == this.potSize &&
          other.notes == this.notes &&
          other.seedPacketImagePath == this.seedPacketImagePath &&
          other.seedVarietyName == this.seedVarietyName &&
          other.plantingLocation == this.plantingLocation &&
          other.seedlingPlantingDate == this.seedlingPlantingDate &&
          other.lastWateredAt == this.lastWateredAt &&
          other.lastFertilizedAt == this.lastFertilizedAt &&
          other.lastRepottedAt == this.lastRepottedAt &&
          other.nextWaterDue == this.nextWaterDue &&
          other.createdAt == this.createdAt &&
          other.isArchived == this.isArchived);
}

class PlantsCompanion extends UpdateCompanion<Plant> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String?> speciesId;
  final Value<String> customName;
  final Value<String?> imagePath;
  final Value<String?> location;
  final Value<String?> lightDirection;
  final Value<int?> wateringFrequencyDays;
  final Value<int?> fertilizingFrequencyDays;
  final Value<String?> soilType;
  final Value<String?> potSize;
  final Value<String?> notes;
  final Value<String?> seedPacketImagePath;
  final Value<String?> seedVarietyName;
  final Value<String?> plantingLocation;
  final Value<DateTime?> seedlingPlantingDate;
  final Value<DateTime?> lastWateredAt;
  final Value<DateTime?> lastFertilizedAt;
  final Value<DateTime?> lastRepottedAt;
  final Value<DateTime?> nextWaterDue;
  final Value<DateTime> createdAt;
  final Value<bool> isArchived;
  const PlantsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.customName = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.location = const Value.absent(),
    this.lightDirection = const Value.absent(),
    this.wateringFrequencyDays = const Value.absent(),
    this.fertilizingFrequencyDays = const Value.absent(),
    this.soilType = const Value.absent(),
    this.potSize = const Value.absent(),
    this.notes = const Value.absent(),
    this.seedPacketImagePath = const Value.absent(),
    this.seedVarietyName = const Value.absent(),
    this.plantingLocation = const Value.absent(),
    this.seedlingPlantingDate = const Value.absent(),
    this.lastWateredAt = const Value.absent(),
    this.lastFertilizedAt = const Value.absent(),
    this.lastRepottedAt = const Value.absent(),
    this.nextWaterDue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  PlantsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.speciesId = const Value.absent(),
    required String customName,
    this.imagePath = const Value.absent(),
    this.location = const Value.absent(),
    this.lightDirection = const Value.absent(),
    this.wateringFrequencyDays = const Value.absent(),
    this.fertilizingFrequencyDays = const Value.absent(),
    this.soilType = const Value.absent(),
    this.potSize = const Value.absent(),
    this.notes = const Value.absent(),
    this.seedPacketImagePath = const Value.absent(),
    this.seedVarietyName = const Value.absent(),
    this.plantingLocation = const Value.absent(),
    this.seedlingPlantingDate = const Value.absent(),
    this.lastWateredAt = const Value.absent(),
    this.lastFertilizedAt = const Value.absent(),
    this.lastRepottedAt = const Value.absent(),
    this.nextWaterDue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : userId = Value(userId),
       customName = Value(customName);
  static Insertable<Plant> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? speciesId,
    Expression<String>? customName,
    Expression<String>? imagePath,
    Expression<String>? location,
    Expression<String>? lightDirection,
    Expression<int>? wateringFrequencyDays,
    Expression<int>? fertilizingFrequencyDays,
    Expression<String>? soilType,
    Expression<String>? potSize,
    Expression<String>? notes,
    Expression<String>? seedPacketImagePath,
    Expression<String>? seedVarietyName,
    Expression<String>? plantingLocation,
    Expression<DateTime>? seedlingPlantingDate,
    Expression<DateTime>? lastWateredAt,
    Expression<DateTime>? lastFertilizedAt,
    Expression<DateTime>? lastRepottedAt,
    Expression<DateTime>? nextWaterDue,
    Expression<DateTime>? createdAt,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (speciesId != null) 'species_id': speciesId,
      if (customName != null) 'custom_name': customName,
      if (imagePath != null) 'image_path': imagePath,
      if (location != null) 'location': location,
      if (lightDirection != null) 'light_direction': lightDirection,
      if (wateringFrequencyDays != null)
        'watering_frequency_days': wateringFrequencyDays,
      if (fertilizingFrequencyDays != null)
        'fertilizing_frequency_days': fertilizingFrequencyDays,
      if (soilType != null) 'soil_type': soilType,
      if (potSize != null) 'pot_size': potSize,
      if (notes != null) 'notes': notes,
      if (seedPacketImagePath != null)
        'seed_packet_image_path': seedPacketImagePath,
      if (seedVarietyName != null) 'seed_variety_name': seedVarietyName,
      if (plantingLocation != null) 'planting_location': plantingLocation,
      if (seedlingPlantingDate != null)
        'seedling_planting_date': seedlingPlantingDate,
      if (lastWateredAt != null) 'last_watered_at': lastWateredAt,
      if (lastFertilizedAt != null) 'last_fertilized_at': lastFertilizedAt,
      if (lastRepottedAt != null) 'last_repotted_at': lastRepottedAt,
      if (nextWaterDue != null) 'next_water_due': nextWaterDue,
      if (createdAt != null) 'created_at': createdAt,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  PlantsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String?>? speciesId,
    Value<String>? customName,
    Value<String?>? imagePath,
    Value<String?>? location,
    Value<String?>? lightDirection,
    Value<int?>? wateringFrequencyDays,
    Value<int?>? fertilizingFrequencyDays,
    Value<String?>? soilType,
    Value<String?>? potSize,
    Value<String?>? notes,
    Value<String?>? seedPacketImagePath,
    Value<String?>? seedVarietyName,
    Value<String?>? plantingLocation,
    Value<DateTime?>? seedlingPlantingDate,
    Value<DateTime?>? lastWateredAt,
    Value<DateTime?>? lastFertilizedAt,
    Value<DateTime?>? lastRepottedAt,
    Value<DateTime?>? nextWaterDue,
    Value<DateTime>? createdAt,
    Value<bool>? isArchived,
  }) {
    return PlantsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesId: speciesId ?? this.speciesId,
      customName: customName ?? this.customName,
      imagePath: imagePath ?? this.imagePath,
      location: location ?? this.location,
      lightDirection: lightDirection ?? this.lightDirection,
      wateringFrequencyDays:
          wateringFrequencyDays ?? this.wateringFrequencyDays,
      fertilizingFrequencyDays:
          fertilizingFrequencyDays ?? this.fertilizingFrequencyDays,
      soilType: soilType ?? this.soilType,
      potSize: potSize ?? this.potSize,
      notes: notes ?? this.notes,
      seedPacketImagePath: seedPacketImagePath ?? this.seedPacketImagePath,
      seedVarietyName: seedVarietyName ?? this.seedVarietyName,
      plantingLocation: plantingLocation ?? this.plantingLocation,
      seedlingPlantingDate: seedlingPlantingDate ?? this.seedlingPlantingDate,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      lastFertilizedAt: lastFertilizedAt ?? this.lastFertilizedAt,
      lastRepottedAt: lastRepottedAt ?? this.lastRepottedAt,
      nextWaterDue: nextWaterDue ?? this.nextWaterDue,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (lightDirection.present) {
      map['light_direction'] = Variable<String>(lightDirection.value);
    }
    if (wateringFrequencyDays.present) {
      map['watering_frequency_days'] = Variable<int>(
        wateringFrequencyDays.value,
      );
    }
    if (fertilizingFrequencyDays.present) {
      map['fertilizing_frequency_days'] = Variable<int>(
        fertilizingFrequencyDays.value,
      );
    }
    if (soilType.present) {
      map['soil_type'] = Variable<String>(soilType.value);
    }
    if (potSize.present) {
      map['pot_size'] = Variable<String>(potSize.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (seedPacketImagePath.present) {
      map['seed_packet_image_path'] = Variable<String>(
        seedPacketImagePath.value,
      );
    }
    if (seedVarietyName.present) {
      map['seed_variety_name'] = Variable<String>(seedVarietyName.value);
    }
    if (plantingLocation.present) {
      map['planting_location'] = Variable<String>(plantingLocation.value);
    }
    if (seedlingPlantingDate.present) {
      map['seedling_planting_date'] = Variable<DateTime>(
        seedlingPlantingDate.value,
      );
    }
    if (lastWateredAt.present) {
      map['last_watered_at'] = Variable<DateTime>(lastWateredAt.value);
    }
    if (lastFertilizedAt.present) {
      map['last_fertilized_at'] = Variable<DateTime>(lastFertilizedAt.value);
    }
    if (lastRepottedAt.present) {
      map['last_repotted_at'] = Variable<DateTime>(lastRepottedAt.value);
    }
    if (nextWaterDue.present) {
      map['next_water_due'] = Variable<DateTime>(nextWaterDue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('customName: $customName, ')
          ..write('imagePath: $imagePath, ')
          ..write('location: $location, ')
          ..write('lightDirection: $lightDirection, ')
          ..write('wateringFrequencyDays: $wateringFrequencyDays, ')
          ..write('fertilizingFrequencyDays: $fertilizingFrequencyDays, ')
          ..write('soilType: $soilType, ')
          ..write('potSize: $potSize, ')
          ..write('notes: $notes, ')
          ..write('seedPacketImagePath: $seedPacketImagePath, ')
          ..write('seedVarietyName: $seedVarietyName, ')
          ..write('plantingLocation: $plantingLocation, ')
          ..write('seedlingPlantingDate: $seedlingPlantingDate, ')
          ..write('lastWateredAt: $lastWateredAt, ')
          ..write('lastFertilizedAt: $lastFertilizedAt, ')
          ..write('lastRepottedAt: $lastRepottedAt, ')
          ..write('nextWaterDue: $nextWaterDue, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $CareEventsTable extends CareEvents
    with TableInfo<$CareEventsTable, CareEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  @override
  late final GeneratedColumn<int> plantId = GeneratedColumn<int>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plants (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, plantId, type, performedAt, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CareEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plant_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CareEventsTable createAlias(String alias) {
    return $CareEventsTable(attachedDatabase, alias);
  }
}

class CareEvent extends DataClass implements Insertable<CareEvent> {
  final int id;
  final int plantId;
  final String type;
  final DateTime performedAt;
  final String? notes;
  const CareEvent({
    required this.id,
    required this.plantId,
    required this.type,
    required this.performedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plant_id'] = Variable<int>(plantId);
    map['type'] = Variable<String>(type);
    map['performed_at'] = Variable<DateTime>(performedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CareEventsCompanion toCompanion(bool nullToAbsent) {
    return CareEventsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      type: Value(type),
      performedAt: Value(performedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CareEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareEvent(
      id: serializer.fromJson<int>(json['id']),
      plantId: serializer.fromJson<int>(json['plantId']),
      type: serializer.fromJson<String>(json['type']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plantId': serializer.toJson<int>(plantId),
      'type': serializer.toJson<String>(type),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CareEvent copyWith({
    int? id,
    int? plantId,
    String? type,
    DateTime? performedAt,
    Value<String?> notes = const Value.absent(),
  }) => CareEvent(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    type: type ?? this.type,
    performedAt: performedAt ?? this.performedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  CareEvent copyWithCompanion(CareEventsCompanion data) {
    return CareEvent(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      type: data.type.present ? data.type.value : this.type,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareEvent(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('type: $type, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, type, performedAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareEvent &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.type == this.type &&
          other.performedAt == this.performedAt &&
          other.notes == this.notes);
}

class CareEventsCompanion extends UpdateCompanion<CareEvent> {
  final Value<int> id;
  final Value<int> plantId;
  final Value<String> type;
  final Value<DateTime> performedAt;
  final Value<String?> notes;
  const CareEventsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.type = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CareEventsCompanion.insert({
    this.id = const Value.absent(),
    required int plantId,
    required String type,
    this.performedAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : plantId = Value(plantId),
       type = Value(type);
  static Insertable<CareEvent> custom({
    Expression<int>? id,
    Expression<int>? plantId,
    Expression<String>? type,
    Expression<DateTime>? performedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (type != null) 'type': type,
      if (performedAt != null) 'performed_at': performedAt,
      if (notes != null) 'notes': notes,
    });
  }

  CareEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? plantId,
    Value<String>? type,
    Value<DateTime>? performedAt,
    Value<String?>? notes,
  }) {
    return CareEventsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      type: type ?? this.type,
      performedAt: performedAt ?? this.performedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<int>(plantId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareEventsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('type: $type, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  @override
  late final GeneratedColumn<int> plantId = GeneratedColumn<int>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plants (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isRepeatingMeta = const VerificationMeta(
    'isRepeating',
  );
  @override
  late final GeneratedColumn<bool> isRepeating = GeneratedColumn<bool>(
    'is_repeating',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_repeating" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repeatIntervalDaysMeta =
      const VerificationMeta('repeatIntervalDays');
  @override
  late final GeneratedColumn<int> repeatIntervalDays = GeneratedColumn<int>(
    'repeat_interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plantId,
    type,
    dueAt,
    isActive,
    isRepeating,
    repeatIntervalDays,
    notificationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_repeating')) {
      context.handle(
        _isRepeatingMeta,
        isRepeating.isAcceptableOrUnknown(
          data['is_repeating']!,
          _isRepeatingMeta,
        ),
      );
    }
    if (data.containsKey('repeat_interval_days')) {
      context.handle(
        _repeatIntervalDaysMeta,
        repeatIntervalDays.isAcceptableOrUnknown(
          data['repeat_interval_days']!,
          _repeatIntervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plant_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isRepeating: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_repeating'],
      )!,
      repeatIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval_days'],
      ),
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int plantId;
  final String type;
  final DateTime dueAt;
  final bool isActive;
  final bool isRepeating;
  final int? repeatIntervalDays;
  final int? notificationId;
  const Reminder({
    required this.id,
    required this.plantId,
    required this.type,
    required this.dueAt,
    required this.isActive,
    required this.isRepeating,
    this.repeatIntervalDays,
    this.notificationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plant_id'] = Variable<int>(plantId);
    map['type'] = Variable<String>(type);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['is_active'] = Variable<bool>(isActive);
    map['is_repeating'] = Variable<bool>(isRepeating);
    if (!nullToAbsent || repeatIntervalDays != null) {
      map['repeat_interval_days'] = Variable<int>(repeatIntervalDays);
    }
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      plantId: Value(plantId),
      type: Value(type),
      dueAt: Value(dueAt),
      isActive: Value(isActive),
      isRepeating: Value(isRepeating),
      repeatIntervalDays: repeatIntervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatIntervalDays),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      plantId: serializer.fromJson<int>(json['plantId']),
      type: serializer.fromJson<String>(json['type']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isRepeating: serializer.fromJson<bool>(json['isRepeating']),
      repeatIntervalDays: serializer.fromJson<int?>(json['repeatIntervalDays']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plantId': serializer.toJson<int>(plantId),
      'type': serializer.toJson<String>(type),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'isActive': serializer.toJson<bool>(isActive),
      'isRepeating': serializer.toJson<bool>(isRepeating),
      'repeatIntervalDays': serializer.toJson<int?>(repeatIntervalDays),
      'notificationId': serializer.toJson<int?>(notificationId),
    };
  }

  Reminder copyWith({
    int? id,
    int? plantId,
    String? type,
    DateTime? dueAt,
    bool? isActive,
    bool? isRepeating,
    Value<int?> repeatIntervalDays = const Value.absent(),
    Value<int?> notificationId = const Value.absent(),
  }) => Reminder(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    type: type ?? this.type,
    dueAt: dueAt ?? this.dueAt,
    isActive: isActive ?? this.isActive,
    isRepeating: isRepeating ?? this.isRepeating,
    repeatIntervalDays: repeatIntervalDays.present
        ? repeatIntervalDays.value
        : this.repeatIntervalDays,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      type: data.type.present ? data.type.value : this.type,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isRepeating: data.isRepeating.present
          ? data.isRepeating.value
          : this.isRepeating,
      repeatIntervalDays: data.repeatIntervalDays.present
          ? data.repeatIntervalDays.value
          : this.repeatIntervalDays,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('type: $type, ')
          ..write('dueAt: $dueAt, ')
          ..write('isActive: $isActive, ')
          ..write('isRepeating: $isRepeating, ')
          ..write('repeatIntervalDays: $repeatIntervalDays, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plantId,
    type,
    dueAt,
    isActive,
    isRepeating,
    repeatIntervalDays,
    notificationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.type == this.type &&
          other.dueAt == this.dueAt &&
          other.isActive == this.isActive &&
          other.isRepeating == this.isRepeating &&
          other.repeatIntervalDays == this.repeatIntervalDays &&
          other.notificationId == this.notificationId);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> plantId;
  final Value<String> type;
  final Value<DateTime> dueAt;
  final Value<bool> isActive;
  final Value<bool> isRepeating;
  final Value<int?> repeatIntervalDays;
  final Value<int?> notificationId;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.type = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isRepeating = const Value.absent(),
    this.repeatIntervalDays = const Value.absent(),
    this.notificationId = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int plantId,
    required String type,
    required DateTime dueAt,
    this.isActive = const Value.absent(),
    this.isRepeating = const Value.absent(),
    this.repeatIntervalDays = const Value.absent(),
    this.notificationId = const Value.absent(),
  }) : plantId = Value(plantId),
       type = Value(type),
       dueAt = Value(dueAt);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? plantId,
    Expression<String>? type,
    Expression<DateTime>? dueAt,
    Expression<bool>? isActive,
    Expression<bool>? isRepeating,
    Expression<int>? repeatIntervalDays,
    Expression<int>? notificationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (type != null) 'type': type,
      if (dueAt != null) 'due_at': dueAt,
      if (isActive != null) 'is_active': isActive,
      if (isRepeating != null) 'is_repeating': isRepeating,
      if (repeatIntervalDays != null)
        'repeat_interval_days': repeatIntervalDays,
      if (notificationId != null) 'notification_id': notificationId,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? plantId,
    Value<String>? type,
    Value<DateTime>? dueAt,
    Value<bool>? isActive,
    Value<bool>? isRepeating,
    Value<int?>? repeatIntervalDays,
    Value<int?>? notificationId,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      type: type ?? this.type,
      dueAt: dueAt ?? this.dueAt,
      isActive: isActive ?? this.isActive,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatIntervalDays: repeatIntervalDays ?? this.repeatIntervalDays,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<int>(plantId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isRepeating.present) {
      map['is_repeating'] = Variable<bool>(isRepeating.value);
    }
    if (repeatIntervalDays.present) {
      map['repeat_interval_days'] = Variable<int>(repeatIntervalDays.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('type: $type, ')
          ..write('dueAt: $dueAt, ')
          ..write('isActive: $isActive, ')
          ..write('isRepeating: $isRepeating, ')
          ..write('repeatIntervalDays: $repeatIntervalDays, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }
}

class $WeatherCacheTable extends WeatherCache
    with TableInfo<$WeatherCacheTable, WeatherCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeatherCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latitude,
    longitude,
    payloadJson,
    fetchedAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weather_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeatherCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeatherCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeatherCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $WeatherCacheTable createAlias(String alias) {
    return $WeatherCacheTable(attachedDatabase, alias);
  }
}

class WeatherCacheData extends DataClass
    implements Insertable<WeatherCacheData> {
  final int id;
  final double latitude;
  final double longitude;
  final String payloadJson;
  final DateTime fetchedAt;
  final DateTime expiresAt;
  const WeatherCacheData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.payloadJson,
    required this.fetchedAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['payload_json'] = Variable<String>(payloadJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  WeatherCacheCompanion toCompanion(bool nullToAbsent) {
    return WeatherCacheCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      payloadJson: Value(payloadJson),
      fetchedAt: Value(fetchedAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory WeatherCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeatherCacheData(
      id: serializer.fromJson<int>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  WeatherCacheData copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? payloadJson,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) => WeatherCacheData(
    id: id ?? this.id,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    payloadJson: payloadJson ?? this.payloadJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  WeatherCacheData copyWithCompanion(WeatherCacheCompanion data) {
    return WeatherCacheData(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeatherCacheData(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, latitude, longitude, payloadJson, fetchedAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeatherCacheData &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.payloadJson == this.payloadJson &&
          other.fetchedAt == this.fetchedAt &&
          other.expiresAt == this.expiresAt);
}

class WeatherCacheCompanion extends UpdateCompanion<WeatherCacheData> {
  final Value<int> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> payloadJson;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> expiresAt;
  const WeatherCacheCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  WeatherCacheCompanion.insert({
    this.id = const Value.absent(),
    required double latitude,
    required double longitude,
    required String payloadJson,
    this.fetchedAt = const Value.absent(),
    required DateTime expiresAt,
  }) : latitude = Value(latitude),
       longitude = Value(longitude),
       payloadJson = Value(payloadJson),
       expiresAt = Value(expiresAt);
  static Insertable<WeatherCacheData> custom({
    Expression<int>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? payloadJson,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  WeatherCacheCompanion copyWith({
    Value<int>? id,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? payloadJson,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? expiresAt,
  }) {
    return WeatherCacheCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      payloadJson: payloadJson ?? this.payloadJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeatherCacheCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $PlantDiseasesTable extends PlantDiseases
    with TableInfo<$PlantDiseasesTable, PlantDisease> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantDiseasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsJsonMeta = const VerificationMeta(
    'symptomsJson',
  );
  @override
  late final GeneratedColumn<String> symptomsJson = GeneratedColumn<String>(
    'symptoms_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _treatmentPlanJsonMeta = const VerificationMeta(
    'treatmentPlanJson',
  );
  @override
  late final GeneratedColumn<String> treatmentPlanJson =
      GeneratedColumn<String>(
        'treatment_plan_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _modelLabelIdMeta = const VerificationMeta(
    'modelLabelId',
  );
  @override
  late final GeneratedColumn<int> modelLabelId = GeneratedColumn<int>(
    'model_label_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPremiumMeta = const VerificationMeta(
    'isPremium',
  );
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
    'is_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    symptomsJson,
    treatmentPlanJson,
    modelLabelId,
    isPremium,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_diseases';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlantDisease> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('symptoms_json')) {
      context.handle(
        _symptomsJsonMeta,
        symptomsJson.isAcceptableOrUnknown(
          data['symptoms_json']!,
          _symptomsJsonMeta,
        ),
      );
    }
    if (data.containsKey('treatment_plan_json')) {
      context.handle(
        _treatmentPlanJsonMeta,
        treatmentPlanJson.isAcceptableOrUnknown(
          data['treatment_plan_json']!,
          _treatmentPlanJsonMeta,
        ),
      );
    }
    if (data.containsKey('model_label_id')) {
      context.handle(
        _modelLabelIdMeta,
        modelLabelId.isAcceptableOrUnknown(
          data['model_label_id']!,
          _modelLabelIdMeta,
        ),
      );
    }
    if (data.containsKey('is_premium')) {
      context.handle(
        _isPremiumMeta,
        isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantDisease map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantDisease(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      symptomsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms_json'],
      ),
      treatmentPlanJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment_plan_json'],
      ),
      modelLabelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}model_label_id'],
      ),
      isPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_premium'],
      )!,
    );
  }

  @override
  $PlantDiseasesTable createAlias(String alias) {
    return $PlantDiseasesTable(attachedDatabase, alias);
  }
}

class PlantDisease extends DataClass implements Insertable<PlantDisease> {
  final String id;
  final String name;
  final String? description;
  final String? symptomsJson;
  final String? treatmentPlanJson;
  final int? modelLabelId;
  final bool isPremium;
  const PlantDisease({
    required this.id,
    required this.name,
    this.description,
    this.symptomsJson,
    this.treatmentPlanJson,
    this.modelLabelId,
    required this.isPremium,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || symptomsJson != null) {
      map['symptoms_json'] = Variable<String>(symptomsJson);
    }
    if (!nullToAbsent || treatmentPlanJson != null) {
      map['treatment_plan_json'] = Variable<String>(treatmentPlanJson);
    }
    if (!nullToAbsent || modelLabelId != null) {
      map['model_label_id'] = Variable<int>(modelLabelId);
    }
    map['is_premium'] = Variable<bool>(isPremium);
    return map;
  }

  PlantDiseasesCompanion toCompanion(bool nullToAbsent) {
    return PlantDiseasesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      symptomsJson: symptomsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(symptomsJson),
      treatmentPlanJson: treatmentPlanJson == null && nullToAbsent
          ? const Value.absent()
          : Value(treatmentPlanJson),
      modelLabelId: modelLabelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelLabelId),
      isPremium: Value(isPremium),
    );
  }

  factory PlantDisease.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantDisease(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      symptomsJson: serializer.fromJson<String?>(json['symptomsJson']),
      treatmentPlanJson: serializer.fromJson<String?>(
        json['treatmentPlanJson'],
      ),
      modelLabelId: serializer.fromJson<int?>(json['modelLabelId']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'symptomsJson': serializer.toJson<String?>(symptomsJson),
      'treatmentPlanJson': serializer.toJson<String?>(treatmentPlanJson),
      'modelLabelId': serializer.toJson<int?>(modelLabelId),
      'isPremium': serializer.toJson<bool>(isPremium),
    };
  }

  PlantDisease copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> symptomsJson = const Value.absent(),
    Value<String?> treatmentPlanJson = const Value.absent(),
    Value<int?> modelLabelId = const Value.absent(),
    bool? isPremium,
  }) => PlantDisease(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    symptomsJson: symptomsJson.present ? symptomsJson.value : this.symptomsJson,
    treatmentPlanJson: treatmentPlanJson.present
        ? treatmentPlanJson.value
        : this.treatmentPlanJson,
    modelLabelId: modelLabelId.present ? modelLabelId.value : this.modelLabelId,
    isPremium: isPremium ?? this.isPremium,
  );
  PlantDisease copyWithCompanion(PlantDiseasesCompanion data) {
    return PlantDisease(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      symptomsJson: data.symptomsJson.present
          ? data.symptomsJson.value
          : this.symptomsJson,
      treatmentPlanJson: data.treatmentPlanJson.present
          ? data.treatmentPlanJson.value
          : this.treatmentPlanJson,
      modelLabelId: data.modelLabelId.present
          ? data.modelLabelId.value
          : this.modelLabelId,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantDisease(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('treatmentPlanJson: $treatmentPlanJson, ')
          ..write('modelLabelId: $modelLabelId, ')
          ..write('isPremium: $isPremium')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    symptomsJson,
    treatmentPlanJson,
    modelLabelId,
    isPremium,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantDisease &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.symptomsJson == this.symptomsJson &&
          other.treatmentPlanJson == this.treatmentPlanJson &&
          other.modelLabelId == this.modelLabelId &&
          other.isPremium == this.isPremium);
}

class PlantDiseasesCompanion extends UpdateCompanion<PlantDisease> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> symptomsJson;
  final Value<String?> treatmentPlanJson;
  final Value<int?> modelLabelId;
  final Value<bool> isPremium;
  final Value<int> rowid;
  const PlantDiseasesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.symptomsJson = const Value.absent(),
    this.treatmentPlanJson = const Value.absent(),
    this.modelLabelId = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantDiseasesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.symptomsJson = const Value.absent(),
    this.treatmentPlanJson = const Value.absent(),
    this.modelLabelId = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PlantDisease> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? symptomsJson,
    Expression<String>? treatmentPlanJson,
    Expression<int>? modelLabelId,
    Expression<bool>? isPremium,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (symptomsJson != null) 'symptoms_json': symptomsJson,
      if (treatmentPlanJson != null) 'treatment_plan_json': treatmentPlanJson,
      if (modelLabelId != null) 'model_label_id': modelLabelId,
      if (isPremium != null) 'is_premium': isPremium,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantDiseasesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? symptomsJson,
    Value<String?>? treatmentPlanJson,
    Value<int?>? modelLabelId,
    Value<bool>? isPremium,
    Value<int>? rowid,
  }) {
    return PlantDiseasesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      symptomsJson: symptomsJson ?? this.symptomsJson,
      treatmentPlanJson: treatmentPlanJson ?? this.treatmentPlanJson,
      modelLabelId: modelLabelId ?? this.modelLabelId,
      isPremium: isPremium ?? this.isPremium,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (symptomsJson.present) {
      map['symptoms_json'] = Variable<String>(symptomsJson.value);
    }
    if (treatmentPlanJson.present) {
      map['treatment_plan_json'] = Variable<String>(treatmentPlanJson.value);
    }
    if (modelLabelId.present) {
      map['model_label_id'] = Variable<int>(modelLabelId.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantDiseasesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('treatmentPlanJson: $treatmentPlanJson, ')
          ..write('modelLabelId: $modelLabelId, ')
          ..write('isPremium: $isPremium, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosesTable extends Diagnoses
    with TableInfo<$DiagnosesTable, Diagnose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  @override
  late final GeneratedColumn<int> plantId = GeneratedColumn<int>(
    'plant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plants (id)',
    ),
  );
  static const VerificationMeta _diseaseIdMeta = const VerificationMeta(
    'diseaseId',
  );
  @override
  late final GeneratedColumn<String> diseaseId = GeneratedColumn<String>(
    'disease_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plant_diseases (id)',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plantId,
    diseaseId,
    imagePath,
    confidence,
    status,
    startedAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnoses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Diagnose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    }
    if (data.containsKey('disease_id')) {
      context.handle(
        _diseaseIdMeta,
        diseaseId.isAcceptableOrUnknown(data['disease_id']!, _diseaseIdMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Diagnose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Diagnose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plant_id'],
      ),
      diseaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disease_id'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $DiagnosesTable createAlias(String alias) {
    return $DiagnosesTable(attachedDatabase, alias);
  }
}

class Diagnose extends DataClass implements Insertable<Diagnose> {
  final int id;
  final int? plantId;
  final String? diseaseId;
  final String? imagePath;
  final double? confidence;
  final String status;
  final DateTime startedAt;
  final DateTime? resolvedAt;
  const Diagnose({
    required this.id,
    this.plantId,
    this.diseaseId,
    this.imagePath,
    this.confidence,
    required this.status,
    required this.startedAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || plantId != null) {
      map['plant_id'] = Variable<int>(plantId);
    }
    if (!nullToAbsent || diseaseId != null) {
      map['disease_id'] = Variable<String>(diseaseId);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  DiagnosesCompanion toCompanion(bool nullToAbsent) {
    return DiagnosesCompanion(
      id: Value(id),
      plantId: plantId == null && nullToAbsent
          ? const Value.absent()
          : Value(plantId),
      diseaseId: diseaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(diseaseId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      status: Value(status),
      startedAt: Value(startedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory Diagnose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Diagnose(
      id: serializer.fromJson<int>(json['id']),
      plantId: serializer.fromJson<int?>(json['plantId']),
      diseaseId: serializer.fromJson<String?>(json['diseaseId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plantId': serializer.toJson<int?>(plantId),
      'diseaseId': serializer.toJson<String?>(diseaseId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'confidence': serializer.toJson<double?>(confidence),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  Diagnose copyWith({
    int? id,
    Value<int?> plantId = const Value.absent(),
    Value<String?> diseaseId = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    String? status,
    DateTime? startedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => Diagnose(
    id: id ?? this.id,
    plantId: plantId.present ? plantId.value : this.plantId,
    diseaseId: diseaseId.present ? diseaseId.value : this.diseaseId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    confidence: confidence.present ? confidence.value : this.confidence,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  Diagnose copyWithCompanion(DiagnosesCompanion data) {
    return Diagnose(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      diseaseId: data.diseaseId.present ? data.diseaseId.value : this.diseaseId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Diagnose(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('imagePath: $imagePath, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plantId,
    diseaseId,
    imagePath,
    confidence,
    status,
    startedAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Diagnose &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.diseaseId == this.diseaseId &&
          other.imagePath == this.imagePath &&
          other.confidence == this.confidence &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.resolvedAt == this.resolvedAt);
}

class DiagnosesCompanion extends UpdateCompanion<Diagnose> {
  final Value<int> id;
  final Value<int?> plantId;
  final Value<String?> diseaseId;
  final Value<String?> imagePath;
  final Value<double?> confidence;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> resolvedAt;
  const DiagnosesCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.diseaseId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.confidence = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  DiagnosesCompanion.insert({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.diseaseId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.confidence = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  static Insertable<Diagnose> custom({
    Expression<int>? id,
    Expression<int>? plantId,
    Expression<String>? diseaseId,
    Expression<String>? imagePath,
    Expression<double>? confidence,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? resolvedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (diseaseId != null) 'disease_id': diseaseId,
      if (imagePath != null) 'image_path': imagePath,
      if (confidence != null) 'confidence': confidence,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
    });
  }

  DiagnosesCompanion copyWith({
    Value<int>? id,
    Value<int?>? plantId,
    Value<String?>? diseaseId,
    Value<String?>? imagePath,
    Value<double?>? confidence,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? resolvedAt,
  }) {
    return DiagnosesCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      diseaseId: diseaseId ?? this.diseaseId,
      imagePath: imagePath ?? this.imagePath,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<int>(plantId.value);
    }
    if (diseaseId.present) {
      map['disease_id'] = Variable<String>(diseaseId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosesCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('imagePath: $imagePath, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }
}

class $TreatmentStepsTable extends TreatmentSteps
    with TableInfo<$TreatmentStepsTable, TreatmentStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreatmentStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _diagnosisIdMeta = const VerificationMeta(
    'diagnosisId',
  );
  @override
  late final GeneratedColumn<int> diagnosisId = GeneratedColumn<int>(
    'diagnosis_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES diagnoses (id)',
    ),
  );
  static const VerificationMeta _stepNumberMeta = const VerificationMeta(
    'stepNumber',
  );
  @override
  late final GeneratedColumn<int> stepNumber = GeneratedColumn<int>(
    'step_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    diagnosisId,
    stepNumber,
    title,
    description,
    dueAt,
    completedAt,
    isCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treatment_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreatmentStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('diagnosis_id')) {
      context.handle(
        _diagnosisIdMeta,
        diagnosisId.isAcceptableOrUnknown(
          data['diagnosis_id']!,
          _diagnosisIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diagnosisIdMeta);
    }
    if (data.containsKey('step_number')) {
      context.handle(
        _stepNumberMeta,
        stepNumber.isAcceptableOrUnknown(data['step_number']!, _stepNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_stepNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreatmentStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreatmentStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      diagnosisId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diagnosis_id'],
      )!,
      stepNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $TreatmentStepsTable createAlias(String alias) {
    return $TreatmentStepsTable(attachedDatabase, alias);
  }
}

class TreatmentStep extends DataClass implements Insertable<TreatmentStep> {
  final int id;
  final int diagnosisId;
  final int stepNumber;
  final String title;
  final String? description;
  final DateTime dueAt;
  final DateTime? completedAt;
  final bool isCompleted;
  const TreatmentStep({
    required this.id,
    required this.diagnosisId,
    required this.stepNumber,
    required this.title,
    this.description,
    required this.dueAt,
    this.completedAt,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['diagnosis_id'] = Variable<int>(diagnosisId);
    map['step_number'] = Variable<int>(stepNumber);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  TreatmentStepsCompanion toCompanion(bool nullToAbsent) {
    return TreatmentStepsCompanion(
      id: Value(id),
      diagnosisId: Value(diagnosisId),
      stepNumber: Value(stepNumber),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueAt: Value(dueAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isCompleted: Value(isCompleted),
    );
  }

  factory TreatmentStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreatmentStep(
      id: serializer.fromJson<int>(json['id']),
      diagnosisId: serializer.fromJson<int>(json['diagnosisId']),
      stepNumber: serializer.fromJson<int>(json['stepNumber']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'diagnosisId': serializer.toJson<int>(diagnosisId),
      'stepNumber': serializer.toJson<int>(stepNumber),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  TreatmentStep copyWith({
    int? id,
    int? diagnosisId,
    int? stepNumber,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? dueAt,
    Value<DateTime?> completedAt = const Value.absent(),
    bool? isCompleted,
  }) => TreatmentStep(
    id: id ?? this.id,
    diagnosisId: diagnosisId ?? this.diagnosisId,
    stepNumber: stepNumber ?? this.stepNumber,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueAt: dueAt ?? this.dueAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  TreatmentStep copyWithCompanion(TreatmentStepsCompanion data) {
    return TreatmentStep(
      id: data.id.present ? data.id.value : this.id,
      diagnosisId: data.diagnosisId.present
          ? data.diagnosisId.value
          : this.diagnosisId,
      stepNumber: data.stepNumber.present
          ? data.stepNumber.value
          : this.stepNumber,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentStep(')
          ..write('id: $id, ')
          ..write('diagnosisId: $diagnosisId, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    diagnosisId,
    stepNumber,
    title,
    description,
    dueAt,
    completedAt,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreatmentStep &&
          other.id == this.id &&
          other.diagnosisId == this.diagnosisId &&
          other.stepNumber == this.stepNumber &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueAt == this.dueAt &&
          other.completedAt == this.completedAt &&
          other.isCompleted == this.isCompleted);
}

class TreatmentStepsCompanion extends UpdateCompanion<TreatmentStep> {
  final Value<int> id;
  final Value<int> diagnosisId;
  final Value<int> stepNumber;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> dueAt;
  final Value<DateTime?> completedAt;
  final Value<bool> isCompleted;
  const TreatmentStepsCompanion({
    this.id = const Value.absent(),
    this.diagnosisId = const Value.absent(),
    this.stepNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  TreatmentStepsCompanion.insert({
    this.id = const Value.absent(),
    required int diagnosisId,
    required int stepNumber,
    required String title,
    this.description = const Value.absent(),
    required DateTime dueAt,
    this.completedAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
  }) : diagnosisId = Value(diagnosisId),
       stepNumber = Value(stepNumber),
       title = Value(title),
       dueAt = Value(dueAt);
  static Insertable<TreatmentStep> custom({
    Expression<int>? id,
    Expression<int>? diagnosisId,
    Expression<int>? stepNumber,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? completedAt,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (diagnosisId != null) 'diagnosis_id': diagnosisId,
      if (stepNumber != null) 'step_number': stepNumber,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueAt != null) 'due_at': dueAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  TreatmentStepsCompanion copyWith({
    Value<int>? id,
    Value<int>? diagnosisId,
    Value<int>? stepNumber,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? dueAt,
    Value<DateTime?>? completedAt,
    Value<bool>? isCompleted,
  }) {
    return TreatmentStepsCompanion(
      id: id ?? this.id,
      diagnosisId: diagnosisId ?? this.diagnosisId,
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (diagnosisId.present) {
      map['diagnosis_id'] = Variable<int>(diagnosisId.value);
    }
    if (stepNumber.present) {
      map['step_number'] = Variable<int>(stepNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentStepsCompanion(')
          ..write('id: $id, ')
          ..write('diagnosisId: $diagnosisId, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconAssetMeta = const VerificationMeta(
    'iconAsset',
  );
  @override
  late final GeneratedColumn<String> iconAsset = GeneratedColumn<String>(
    'icon_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardXpMeta = const VerificationMeta(
    'rewardXp',
  );
  @override
  late final GeneratedColumn<int> rewardXp = GeneratedColumn<int>(
    'reward_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criteriaJsonMeta = const VerificationMeta(
    'criteriaJson',
  );
  @override
  late final GeneratedColumn<String> criteriaJson = GeneratedColumn<String>(
    'criteria_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    description,
    iconAsset,
    rewardXp,
    criteriaJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon_asset')) {
      context.handle(
        _iconAssetMeta,
        iconAsset.isAcceptableOrUnknown(data['icon_asset']!, _iconAssetMeta),
      );
    }
    if (data.containsKey('reward_xp')) {
      context.handle(
        _rewardXpMeta,
        rewardXp.isAcceptableOrUnknown(data['reward_xp']!, _rewardXpMeta),
      );
    }
    if (data.containsKey('criteria_json')) {
      context.handle(
        _criteriaJsonMeta,
        criteriaJson.isAcceptableOrUnknown(
          data['criteria_json']!,
          _criteriaJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      iconAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_asset'],
      ),
      rewardXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_xp'],
      )!,
      criteriaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criteria_json'],
      ),
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String code;
  final String name;
  final String? description;
  final String? iconAsset;
  final int rewardXp;
  final String? criteriaJson;
  const Achievement({
    required this.code,
    required this.name,
    this.description,
    this.iconAsset,
    required this.rewardXp,
    this.criteriaJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || iconAsset != null) {
      map['icon_asset'] = Variable<String>(iconAsset);
    }
    map['reward_xp'] = Variable<int>(rewardXp);
    if (!nullToAbsent || criteriaJson != null) {
      map['criteria_json'] = Variable<String>(criteriaJson);
    }
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      code: Value(code),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      iconAsset: iconAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(iconAsset),
      rewardXp: Value(rewardXp),
      criteriaJson: criteriaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(criteriaJson),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      iconAsset: serializer.fromJson<String?>(json['iconAsset']),
      rewardXp: serializer.fromJson<int>(json['rewardXp']),
      criteriaJson: serializer.fromJson<String?>(json['criteriaJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'iconAsset': serializer.toJson<String?>(iconAsset),
      'rewardXp': serializer.toJson<int>(rewardXp),
      'criteriaJson': serializer.toJson<String?>(criteriaJson),
    };
  }

  Achievement copyWith({
    String? code,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> iconAsset = const Value.absent(),
    int? rewardXp,
    Value<String?> criteriaJson = const Value.absent(),
  }) => Achievement(
    code: code ?? this.code,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    iconAsset: iconAsset.present ? iconAsset.value : this.iconAsset,
    rewardXp: rewardXp ?? this.rewardXp,
    criteriaJson: criteriaJson.present ? criteriaJson.value : this.criteriaJson,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconAsset: data.iconAsset.present ? data.iconAsset.value : this.iconAsset,
      rewardXp: data.rewardXp.present ? data.rewardXp.value : this.rewardXp,
      criteriaJson: data.criteriaJson.present
          ? data.criteriaJson.value
          : this.criteriaJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconAsset: $iconAsset, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('criteriaJson: $criteriaJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, name, description, iconAsset, rewardXp, criteriaJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.iconAsset == this.iconAsset &&
          other.rewardXp == this.rewardXp &&
          other.criteriaJson == this.criteriaJson);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> code;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> iconAsset;
  final Value<int> rewardXp;
  final Value<String?> criteriaJson;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.iconAsset = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.criteriaJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String code,
    required String name,
    this.description = const Value.absent(),
    this.iconAsset = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.criteriaJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name);
  static Insertable<Achievement> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? iconAsset,
    Expression<int>? rewardXp,
    Expression<String>? criteriaJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (iconAsset != null) 'icon_asset': iconAsset,
      if (rewardXp != null) 'reward_xp': rewardXp,
      if (criteriaJson != null) 'criteria_json': criteriaJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? iconAsset,
    Value<int>? rewardXp,
    Value<String?>? criteriaJson,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      iconAsset: iconAsset ?? this.iconAsset,
      rewardXp: rewardXp ?? this.rewardXp,
      criteriaJson: criteriaJson ?? this.criteriaJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconAsset.present) {
      map['icon_asset'] = Variable<String>(iconAsset.value);
    }
    if (rewardXp.present) {
      map['reward_xp'] = Variable<int>(rewardXp.value);
    }
    if (criteriaJson.present) {
      map['criteria_json'] = Variable<String>(criteriaJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconAsset: $iconAsset, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('criteriaJson: $criteriaJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserAchievementsTable extends UserAchievements
    with TableInfo<$UserAchievementsTable, UserAchievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _achievementCodeMeta = const VerificationMeta(
    'achievementCode',
  );
  @override
  late final GeneratedColumn<String> achievementCode = GeneratedColumn<String>(
    'achievement_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES achievements (code)',
    ),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    achievementCode,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAchievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('achievement_code')) {
      context.handle(
        _achievementCodeMeta,
        achievementCode.isAcceptableOrUnknown(
          data['achievement_code']!,
          _achievementCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementCodeMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAchievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAchievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      achievementCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_code'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $UserAchievementsTable createAlias(String alias) {
    return $UserAchievementsTable(attachedDatabase, alias);
  }
}

class UserAchievement extends DataClass implements Insertable<UserAchievement> {
  final int id;
  final int userId;
  final String achievementCode;
  final DateTime unlockedAt;
  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementCode,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['achievement_code'] = Variable<String>(achievementCode);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  UserAchievementsCompanion toCompanion(bool nullToAbsent) {
    return UserAchievementsCompanion(
      id: Value(id),
      userId: Value(userId),
      achievementCode: Value(achievementCode),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory UserAchievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAchievement(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      achievementCode: serializer.fromJson<String>(json['achievementCode']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'achievementCode': serializer.toJson<String>(achievementCode),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  UserAchievement copyWith({
    int? id,
    int? userId,
    String? achievementCode,
    DateTime? unlockedAt,
  }) => UserAchievement(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    achievementCode: achievementCode ?? this.achievementCode,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  UserAchievement copyWithCompanion(UserAchievementsCompanion data) {
    return UserAchievement(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      achievementCode: data.achievementCode.present
          ? data.achievementCode.value
          : this.achievementCode,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievement(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('achievementCode: $achievementCode, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, achievementCode, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAchievement &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.achievementCode == this.achievementCode &&
          other.unlockedAt == this.unlockedAt);
}

class UserAchievementsCompanion extends UpdateCompanion<UserAchievement> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> achievementCode;
  final Value<DateTime> unlockedAt;
  const UserAchievementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.achievementCode = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  UserAchievementsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String achievementCode,
    this.unlockedAt = const Value.absent(),
  }) : userId = Value(userId),
       achievementCode = Value(achievementCode);
  static Insertable<UserAchievement> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? achievementCode,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (achievementCode != null) 'achievement_code': achievementCode,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  UserAchievementsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? achievementCode,
    Value<DateTime>? unlockedAt,
  }) {
    return UserAchievementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementCode: achievementCode ?? this.achievementCode,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (achievementCode.present) {
      map['achievement_code'] = Variable<String>(achievementCode.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('achievementCode: $achievementCode, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $UserXpEventsTable extends UserXpEvents
    with TableInfo<$UserXpEventsTable, UserXpEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserXpEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, amount, reason, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_xp_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserXpEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserXpEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserXpEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserXpEventsTable createAlias(String alias) {
    return $UserXpEventsTable(attachedDatabase, alias);
  }
}

class UserXpEvent extends DataClass implements Insertable<UserXpEvent> {
  final int id;
  final int userId;
  final int amount;
  final String reason;
  final DateTime createdAt;
  const UserXpEvent({
    required this.id,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserXpEventsCompanion toCompanion(bool nullToAbsent) {
    return UserXpEventsCompanion(
      id: Value(id),
      userId: Value(userId),
      amount: Value(amount),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory UserXpEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserXpEvent(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserXpEvent copyWith({
    int? id,
    int? userId,
    int? amount,
    String? reason,
    DateTime? createdAt,
  }) => UserXpEvent(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  UserXpEvent copyWithCompanion(UserXpEventsCompanion data) {
    return UserXpEvent(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserXpEvent(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, amount, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserXpEvent &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class UserXpEventsCompanion extends UpdateCompanion<UserXpEvent> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> amount;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  const UserXpEventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserXpEventsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int amount,
    required String reason,
    this.createdAt = const Value.absent(),
  }) : userId = Value(userId),
       amount = Value(amount),
       reason = Value(reason);
  static Insertable<UserXpEvent> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserXpEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? amount,
    Value<String>? reason,
    Value<DateTime>? createdAt,
  }) {
    return UserXpEventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserXpEventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String? value;
  const AppMetaData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppMetaData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppMetaData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $PlantSpeciesTable plantSpecies = $PlantSpeciesTable(this);
  late final $PlantsTable plants = $PlantsTable(this);
  late final $CareEventsTable careEvents = $CareEventsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $WeatherCacheTable weatherCache = $WeatherCacheTable(this);
  late final $PlantDiseasesTable plantDiseases = $PlantDiseasesTable(this);
  late final $DiagnosesTable diagnoses = $DiagnosesTable(this);
  late final $TreatmentStepsTable treatmentSteps = $TreatmentStepsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $UserAchievementsTable userAchievements = $UserAchievementsTable(
    this,
  );
  late final $UserXpEventsTable userXpEvents = $UserXpEventsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final SpeciesDao speciesDao = SpeciesDao(this as AppDatabase);
  late final PlantDao plantDao = PlantDao(this as AppDatabase);
  late final CareEventDao careEventDao = CareEventDao(this as AppDatabase);
  late final ReminderDao reminderDao = ReminderDao(this as AppDatabase);
  late final WeatherDao weatherDao = WeatherDao(this as AppDatabase);
  late final DiseaseDao diseaseDao = DiseaseDao(this as AppDatabase);
  late final DiagnosisDao diagnosisDao = DiagnosisDao(this as AppDatabase);
  late final AchievementDao achievementDao = AchievementDao(
    this as AppDatabase,
  );
  late final AppMetaDao appMetaDao = AppMetaDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appUsers,
    plantSpecies,
    plants,
    careEvents,
    reminders,
    weatherCache,
    plantDiseases,
    diagnoses,
    treatmentSteps,
    achievements,
    userAchievements,
    userXpEvents,
    appMeta,
  ];
}

typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> id,
      Value<String?> displayName,
      Value<String?> avatarPath,
      Value<int> xp,
      Value<int> level,
      Value<String> subscriptionTier,
      Value<DateTime?> subscriptionExpiry,
      Value<DateTime> createdAt,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> id,
      Value<String?> displayName,
      Value<String?> avatarPath,
      Value<int> xp,
      Value<int> level,
      Value<String> subscriptionTier,
      Value<DateTime?> subscriptionExpiry,
      Value<DateTime> createdAt,
    });

final class $$AppUsersTableReferences
    extends BaseReferences<_$AppDatabase, $AppUsersTable, AppUser> {
  $$AppUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTable, List<Plant>> _plantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plants,
    aliasName: 'app_users__id__plants__user_id',
  );

  $$PlantsTableProcessedTableManager get plantsRefs {
    final manager = $$PlantsTableTableManager(
      $_db,
      $_db.plants,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_plantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserAchievementsTable, List<UserAchievement>>
  _userAchievementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userAchievements,
    aliasName: 'app_users__id__user_achievements__user_id',
  );

  $$UserAchievementsTableProcessedTableManager get userAchievementsRefs {
    final manager = $$UserAchievementsTableTableManager(
      $_db,
      $_db.userAchievements,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userAchievementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserXpEventsTable, List<UserXpEvent>>
  _userXpEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userXpEvents,
    aliasName: 'app_users__id__user_xp_events__user_id',
  );

  $$UserXpEventsTableProcessedTableManager get userXpEventsRefs {
    final manager = $$UserXpEventsTableTableManager(
      $_db,
      $_db.userXpEvents,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userXpEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscriptionExpiry => $composableBuilder(
    column: $table.subscriptionExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> plantsRefs(
    Expression<bool> Function($$PlantsTableFilterComposer f) f,
  ) {
    final $$PlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableFilterComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userAchievementsRefs(
    Expression<bool> Function($$UserAchievementsTableFilterComposer f) f,
  ) {
    final $$UserAchievementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userAchievements,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserAchievementsTableFilterComposer(
            $db: $db,
            $table: $db.userAchievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userXpEventsRefs(
    Expression<bool> Function($$UserXpEventsTableFilterComposer f) f,
  ) {
    final $$UserXpEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userXpEvents,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserXpEventsTableFilterComposer(
            $db: $db,
            $table: $db.userXpEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscriptionExpiry => $composableBuilder(
    column: $table.subscriptionExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get subscriptionExpiry => $composableBuilder(
    column: $table.subscriptionExpiry,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> plantsRefs<T extends Object>(
    Expression<T> Function($$PlantsTableAnnotationComposer a) f,
  ) {
    final $$PlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userAchievementsRefs<T extends Object>(
    Expression<T> Function($$UserAchievementsTableAnnotationComposer a) f,
  ) {
    final $$UserAchievementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userAchievements,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserAchievementsTableAnnotationComposer(
            $db: $db,
            $table: $db.userAchievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userXpEventsRefs<T extends Object>(
    Expression<T> Function($$UserXpEventsTableAnnotationComposer a) f,
  ) {
    final $$UserXpEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userXpEvents,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserXpEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.userXpEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUser,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUser, $$AppUsersTableReferences),
          AppUser,
          PrefetchHooks Function({
            bool plantsRefs,
            bool userAchievementsRefs,
            bool userXpEventsRefs,
          })
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> subscriptionTier = const Value.absent(),
                Value<DateTime?> subscriptionExpiry = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppUsersCompanion(
                id: id,
                displayName: displayName,
                avatarPath: avatarPath,
                xp: xp,
                level: level,
                subscriptionTier: subscriptionTier,
                subscriptionExpiry: subscriptionExpiry,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> subscriptionTier = const Value.absent(),
                Value<DateTime?> subscriptionExpiry = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppUsersCompanion.insert(
                id: id,
                displayName: displayName,
                avatarPath: avatarPath,
                xp: xp,
                level: level,
                subscriptionTier: subscriptionTier,
                subscriptionExpiry: subscriptionExpiry,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppUsersTable, AppUser>(table),
                  $$AppUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                plantsRefs = false,
                userAchievementsRefs = false,
                userXpEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plantsRefs) db.plants,
                    if (userAchievementsRefs) db.userAchievements,
                    if (userXpEventsRefs) db.userXpEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (plantsRefs)
                        await $_getPrefetchedData<
                          AppUser,
                          $AppUsersTable,
                          Plant
                        >(
                          currentTable: table,
                          referencedTable: $$AppUsersTableReferences
                              ._plantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AppUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).plantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userAchievementsRefs)
                        await $_getPrefetchedData<
                          AppUser,
                          $AppUsersTable,
                          UserAchievement
                        >(
                          currentTable: table,
                          referencedTable: $$AppUsersTableReferences
                              ._userAchievementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AppUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userAchievementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userXpEventsRefs)
                        await $_getPrefetchedData<
                          AppUser,
                          $AppUsersTable,
                          UserXpEvent
                        >(
                          currentTable: table,
                          referencedTable: $$AppUsersTableReferences
                              ._userXpEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AppUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userXpEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUser,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUser, $$AppUsersTableReferences),
      AppUser,
      PrefetchHooks Function({
        bool plantsRefs,
        bool userAchievementsRefs,
        bool userXpEventsRefs,
      })
    >;
typedef $$PlantSpeciesTableCreateCompanionBuilder =
    PlantSpeciesCompanion Function({
      required String id,
      required String commonName,
      required String scientificName,
      Value<String?> family,
      Value<String?> category,
      Value<String?> description,
      Value<String?> careGuideJson,
      Value<int?> defaultWateringDays,
      Value<int?> fertilizingFrequencyDays,
      Value<String?> fertilizerType,
      Value<String?> lightRequirements,
      Value<int?> minTemperature,
      Value<int?> maxTemperature,
      Value<int?> humidityMin,
      Value<int?> humidityMax,
      Value<String?> soilType,
      Value<String?> soilMoisture,
      Value<int?> repottingFrequencyMonths,
      Value<String?> pruningInfo,
      Value<String?> toxicity,
      Value<String?> modelLabelId,
      Value<String?> imageAssetPath,
      Value<bool> isPremium,
      Value<int> rowid,
    });
typedef $$PlantSpeciesTableUpdateCompanionBuilder =
    PlantSpeciesCompanion Function({
      Value<String> id,
      Value<String> commonName,
      Value<String> scientificName,
      Value<String?> family,
      Value<String?> category,
      Value<String?> description,
      Value<String?> careGuideJson,
      Value<int?> defaultWateringDays,
      Value<int?> fertilizingFrequencyDays,
      Value<String?> fertilizerType,
      Value<String?> lightRequirements,
      Value<int?> minTemperature,
      Value<int?> maxTemperature,
      Value<int?> humidityMin,
      Value<int?> humidityMax,
      Value<String?> soilType,
      Value<String?> soilMoisture,
      Value<int?> repottingFrequencyMonths,
      Value<String?> pruningInfo,
      Value<String?> toxicity,
      Value<String?> modelLabelId,
      Value<String?> imageAssetPath,
      Value<bool> isPremium,
      Value<int> rowid,
    });

final class $$PlantSpeciesTableReferences
    extends BaseReferences<_$AppDatabase, $PlantSpeciesTable, PlantSpecy> {
  $$PlantSpeciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTable, List<Plant>> _plantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plants,
    aliasName: 'plant_species__id__plants__species_id',
  );

  $$PlantsTableProcessedTableManager get plantsRefs {
    final manager = $$PlantsTableTableManager(
      $_db,
      $_db.plants,
    ).filter((f) => f.speciesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_plantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlantSpeciesTableFilterComposer
    extends Composer<_$AppDatabase, $PlantSpeciesTable> {
  $$PlantSpeciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get careGuideJson => $composableBuilder(
    column: $table.careGuideJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultWateringDays => $composableBuilder(
    column: $table.defaultWateringDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fertilizingFrequencyDays => $composableBuilder(
    column: $table.fertilizingFrequencyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fertilizerType => $composableBuilder(
    column: $table.fertilizerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lightRequirements => $composableBuilder(
    column: $table.lightRequirements,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minTemperature => $composableBuilder(
    column: $table.minTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxTemperature => $composableBuilder(
    column: $table.maxTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get humidityMin => $composableBuilder(
    column: $table.humidityMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get humidityMax => $composableBuilder(
    column: $table.humidityMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilType => $composableBuilder(
    column: $table.soilType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilMoisture => $composableBuilder(
    column: $table.soilMoisture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repottingFrequencyMonths => $composableBuilder(
    column: $table.repottingFrequencyMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pruningInfo => $composableBuilder(
    column: $table.pruningInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toxicity => $composableBuilder(
    column: $table.toxicity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelLabelId => $composableBuilder(
    column: $table.modelLabelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageAssetPath => $composableBuilder(
    column: $table.imageAssetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> plantsRefs(
    Expression<bool> Function($$PlantsTableFilterComposer f) f,
  ) {
    final $$PlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.speciesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableFilterComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantSpeciesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantSpeciesTable> {
  $$PlantSpeciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get careGuideJson => $composableBuilder(
    column: $table.careGuideJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultWateringDays => $composableBuilder(
    column: $table.defaultWateringDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fertilizingFrequencyDays => $composableBuilder(
    column: $table.fertilizingFrequencyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fertilizerType => $composableBuilder(
    column: $table.fertilizerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lightRequirements => $composableBuilder(
    column: $table.lightRequirements,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minTemperature => $composableBuilder(
    column: $table.minTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxTemperature => $composableBuilder(
    column: $table.maxTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get humidityMin => $composableBuilder(
    column: $table.humidityMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get humidityMax => $composableBuilder(
    column: $table.humidityMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilType => $composableBuilder(
    column: $table.soilType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilMoisture => $composableBuilder(
    column: $table.soilMoisture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repottingFrequencyMonths => $composableBuilder(
    column: $table.repottingFrequencyMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pruningInfo => $composableBuilder(
    column: $table.pruningInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toxicity => $composableBuilder(
    column: $table.toxicity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelLabelId => $composableBuilder(
    column: $table.modelLabelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageAssetPath => $composableBuilder(
    column: $table.imageAssetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlantSpeciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantSpeciesTable> {
  $$PlantSpeciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get careGuideJson => $composableBuilder(
    column: $table.careGuideJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultWateringDays => $composableBuilder(
    column: $table.defaultWateringDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fertilizingFrequencyDays => $composableBuilder(
    column: $table.fertilizingFrequencyDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fertilizerType => $composableBuilder(
    column: $table.fertilizerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lightRequirements => $composableBuilder(
    column: $table.lightRequirements,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minTemperature => $composableBuilder(
    column: $table.minTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxTemperature => $composableBuilder(
    column: $table.maxTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get humidityMin => $composableBuilder(
    column: $table.humidityMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get humidityMax => $composableBuilder(
    column: $table.humidityMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get soilType =>
      $composableBuilder(column: $table.soilType, builder: (column) => column);

  GeneratedColumn<String> get soilMoisture => $composableBuilder(
    column: $table.soilMoisture,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repottingFrequencyMonths => $composableBuilder(
    column: $table.repottingFrequencyMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pruningInfo => $composableBuilder(
    column: $table.pruningInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toxicity =>
      $composableBuilder(column: $table.toxicity, builder: (column) => column);

  GeneratedColumn<String> get modelLabelId => $composableBuilder(
    column: $table.modelLabelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageAssetPath => $composableBuilder(
    column: $table.imageAssetPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  Expression<T> plantsRefs<T extends Object>(
    Expression<T> Function($$PlantsTableAnnotationComposer a) f,
  ) {
    final $$PlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.speciesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantSpeciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantSpeciesTable,
          PlantSpecy,
          $$PlantSpeciesTableFilterComposer,
          $$PlantSpeciesTableOrderingComposer,
          $$PlantSpeciesTableAnnotationComposer,
          $$PlantSpeciesTableCreateCompanionBuilder,
          $$PlantSpeciesTableUpdateCompanionBuilder,
          (PlantSpecy, $$PlantSpeciesTableReferences),
          PlantSpecy,
          PrefetchHooks Function({bool plantsRefs})
        > {
  $$PlantSpeciesTableTableManager(_$AppDatabase db, $PlantSpeciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantSpeciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantSpeciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantSpeciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> commonName = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<String?> family = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> careGuideJson = const Value.absent(),
                Value<int?> defaultWateringDays = const Value.absent(),
                Value<int?> fertilizingFrequencyDays = const Value.absent(),
                Value<String?> fertilizerType = const Value.absent(),
                Value<String?> lightRequirements = const Value.absent(),
                Value<int?> minTemperature = const Value.absent(),
                Value<int?> maxTemperature = const Value.absent(),
                Value<int?> humidityMin = const Value.absent(),
                Value<int?> humidityMax = const Value.absent(),
                Value<String?> soilType = const Value.absent(),
                Value<String?> soilMoisture = const Value.absent(),
                Value<int?> repottingFrequencyMonths = const Value.absent(),
                Value<String?> pruningInfo = const Value.absent(),
                Value<String?> toxicity = const Value.absent(),
                Value<String?> modelLabelId = const Value.absent(),
                Value<String?> imageAssetPath = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantSpeciesCompanion(
                id: id,
                commonName: commonName,
                scientificName: scientificName,
                family: family,
                category: category,
                description: description,
                careGuideJson: careGuideJson,
                defaultWateringDays: defaultWateringDays,
                fertilizingFrequencyDays: fertilizingFrequencyDays,
                fertilizerType: fertilizerType,
                lightRequirements: lightRequirements,
                minTemperature: minTemperature,
                maxTemperature: maxTemperature,
                humidityMin: humidityMin,
                humidityMax: humidityMax,
                soilType: soilType,
                soilMoisture: soilMoisture,
                repottingFrequencyMonths: repottingFrequencyMonths,
                pruningInfo: pruningInfo,
                toxicity: toxicity,
                modelLabelId: modelLabelId,
                imageAssetPath: imageAssetPath,
                isPremium: isPremium,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String commonName,
                required String scientificName,
                Value<String?> family = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> careGuideJson = const Value.absent(),
                Value<int?> defaultWateringDays = const Value.absent(),
                Value<int?> fertilizingFrequencyDays = const Value.absent(),
                Value<String?> fertilizerType = const Value.absent(),
                Value<String?> lightRequirements = const Value.absent(),
                Value<int?> minTemperature = const Value.absent(),
                Value<int?> maxTemperature = const Value.absent(),
                Value<int?> humidityMin = const Value.absent(),
                Value<int?> humidityMax = const Value.absent(),
                Value<String?> soilType = const Value.absent(),
                Value<String?> soilMoisture = const Value.absent(),
                Value<int?> repottingFrequencyMonths = const Value.absent(),
                Value<String?> pruningInfo = const Value.absent(),
                Value<String?> toxicity = const Value.absent(),
                Value<String?> modelLabelId = const Value.absent(),
                Value<String?> imageAssetPath = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantSpeciesCompanion.insert(
                id: id,
                commonName: commonName,
                scientificName: scientificName,
                family: family,
                category: category,
                description: description,
                careGuideJson: careGuideJson,
                defaultWateringDays: defaultWateringDays,
                fertilizingFrequencyDays: fertilizingFrequencyDays,
                fertilizerType: fertilizerType,
                lightRequirements: lightRequirements,
                minTemperature: minTemperature,
                maxTemperature: maxTemperature,
                humidityMin: humidityMin,
                humidityMax: humidityMax,
                soilType: soilType,
                soilMoisture: soilMoisture,
                repottingFrequencyMonths: repottingFrequencyMonths,
                pruningInfo: pruningInfo,
                toxicity: toxicity,
                modelLabelId: modelLabelId,
                imageAssetPath: imageAssetPath,
                isPremium: isPremium,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlantSpeciesTable, PlantSpecy>(table),
                  $$PlantSpeciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plantsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plantsRefs) db.plants],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plantsRefs)
                    await $_getPrefetchedData<
                      PlantSpecy,
                      $PlantSpeciesTable,
                      Plant
                    >(
                      currentTable: table,
                      referencedTable: $$PlantSpeciesTableReferences
                          ._plantsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlantSpeciesTableReferences(
                            db,
                            table,
                            p0,
                          ).plantsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.speciesId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlantSpeciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantSpeciesTable,
      PlantSpecy,
      $$PlantSpeciesTableFilterComposer,
      $$PlantSpeciesTableOrderingComposer,
      $$PlantSpeciesTableAnnotationComposer,
      $$PlantSpeciesTableCreateCompanionBuilder,
      $$PlantSpeciesTableUpdateCompanionBuilder,
      (PlantSpecy, $$PlantSpeciesTableReferences),
      PlantSpecy,
      PrefetchHooks Function({bool plantsRefs})
    >;
typedef $$PlantsTableCreateCompanionBuilder =
    PlantsCompanion Function({
      Value<int> id,
      required int userId,
      Value<String?> speciesId,
      required String customName,
      Value<String?> imagePath,
      Value<String?> location,
      Value<String?> lightDirection,
      Value<int?> wateringFrequencyDays,
      Value<int?> fertilizingFrequencyDays,
      Value<String?> soilType,
      Value<String?> potSize,
      Value<String?> notes,
      Value<String?> seedPacketImagePath,
      Value<String?> seedVarietyName,
      Value<String?> plantingLocation,
      Value<DateTime?> seedlingPlantingDate,
      Value<DateTime?> lastWateredAt,
      Value<DateTime?> lastFertilizedAt,
      Value<DateTime?> lastRepottedAt,
      Value<DateTime?> nextWaterDue,
      Value<DateTime> createdAt,
      Value<bool> isArchived,
    });
typedef $$PlantsTableUpdateCompanionBuilder =
    PlantsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String?> speciesId,
      Value<String> customName,
      Value<String?> imagePath,
      Value<String?> location,
      Value<String?> lightDirection,
      Value<int?> wateringFrequencyDays,
      Value<int?> fertilizingFrequencyDays,
      Value<String?> soilType,
      Value<String?> potSize,
      Value<String?> notes,
      Value<String?> seedPacketImagePath,
      Value<String?> seedVarietyName,
      Value<String?> plantingLocation,
      Value<DateTime?> seedlingPlantingDate,
      Value<DateTime?> lastWateredAt,
      Value<DateTime?> lastFertilizedAt,
      Value<DateTime?> lastRepottedAt,
      Value<DateTime?> nextWaterDue,
      Value<DateTime> createdAt,
      Value<bool> isArchived,
    });

final class $$PlantsTableReferences
    extends BaseReferences<_$AppDatabase, $PlantsTable, Plant> {
  $$PlantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUsersTable _userIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias('plants__user_id__app_users__id');

  $$AppUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlantSpeciesTable _speciesIdTable(_$AppDatabase db) =>
      db.plantSpecies.createAlias('plants__species_id__plant_species__id');

  $$PlantSpeciesTableProcessedTableManager? get speciesId {
    final $_column = $_itemColumn<String>('species_id');
    if ($_column == null) return null;
    final manager = $$PlantSpeciesTableTableManager(
      $_db,
      $_db.plantSpecies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speciesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CareEventsTable, List<CareEvent>>
  _careEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.careEvents,
    aliasName: 'plants__id__care_events__plant_id',
  );

  $$CareEventsTableProcessedTableManager get careEventsRefs {
    final manager = $$CareEventsTableTableManager(
      $_db,
      $_db.careEvents,
    ).filter((f) => f.plantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_careEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'plants__id__reminders__plant_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.plantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DiagnosesTable, List<Diagnose>>
  _diagnosesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diagnoses,
    aliasName: 'plants__id__diagnoses__plant_id',
  );

  $$DiagnosesTableProcessedTableManager get diagnosesRefs {
    final manager = $$DiagnosesTableTableManager(
      $_db,
      $_db.diagnoses,
    ).filter((f) => f.plantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_diagnosesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlantsTableFilterComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lightDirection => $composableBuilder(
    column: $table.lightDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wateringFrequencyDays => $composableBuilder(
    column: $table.wateringFrequencyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fertilizingFrequencyDays => $composableBuilder(
    column: $table.fertilizingFrequencyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilType => $composableBuilder(
    column: $table.soilType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get potSize => $composableBuilder(
    column: $table.potSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seedPacketImagePath => $composableBuilder(
    column: $table.seedPacketImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seedVarietyName => $composableBuilder(
    column: $table.seedVarietyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantingLocation => $composableBuilder(
    column: $table.plantingLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get seedlingPlantingDate => $composableBuilder(
    column: $table.seedlingPlantingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWateredAt => $composableBuilder(
    column: $table.lastWateredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFertilizedAt => $composableBuilder(
    column: $table.lastFertilizedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRepottedAt => $composableBuilder(
    column: $table.lastRepottedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextWaterDue => $composableBuilder(
    column: $table.nextWaterDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUsersTableFilterComposer get userId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlantSpeciesTableFilterComposer get speciesId {
    final $$PlantSpeciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.plantSpecies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantSpeciesTableFilterComposer(
            $db: $db,
            $table: $db.plantSpecies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> careEventsRefs(
    Expression<bool> Function($$CareEventsTableFilterComposer f) f,
  ) {
    final $$CareEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.careEvents,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CareEventsTableFilterComposer(
            $db: $db,
            $table: $db.careEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> diagnosesRefs(
    Expression<bool> Function($$DiagnosesTableFilterComposer f) f,
  ) {
    final $$DiagnosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableFilterComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lightDirection => $composableBuilder(
    column: $table.lightDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wateringFrequencyDays => $composableBuilder(
    column: $table.wateringFrequencyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fertilizingFrequencyDays => $composableBuilder(
    column: $table.fertilizingFrequencyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilType => $composableBuilder(
    column: $table.soilType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get potSize => $composableBuilder(
    column: $table.potSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seedPacketImagePath => $composableBuilder(
    column: $table.seedPacketImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seedVarietyName => $composableBuilder(
    column: $table.seedVarietyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantingLocation => $composableBuilder(
    column: $table.plantingLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get seedlingPlantingDate => $composableBuilder(
    column: $table.seedlingPlantingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWateredAt => $composableBuilder(
    column: $table.lastWateredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFertilizedAt => $composableBuilder(
    column: $table.lastFertilizedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRepottedAt => $composableBuilder(
    column: $table.lastRepottedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextWaterDue => $composableBuilder(
    column: $table.nextWaterDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUsersTableOrderingComposer get userId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlantSpeciesTableOrderingComposer get speciesId {
    final $$PlantSpeciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.plantSpecies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantSpeciesTableOrderingComposer(
            $db: $db,
            $table: $db.plantSpecies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get lightDirection => $composableBuilder(
    column: $table.lightDirection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wateringFrequencyDays => $composableBuilder(
    column: $table.wateringFrequencyDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fertilizingFrequencyDays => $composableBuilder(
    column: $table.fertilizingFrequencyDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get soilType =>
      $composableBuilder(column: $table.soilType, builder: (column) => column);

  GeneratedColumn<String> get potSize =>
      $composableBuilder(column: $table.potSize, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get seedPacketImagePath => $composableBuilder(
    column: $table.seedPacketImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seedVarietyName => $composableBuilder(
    column: $table.seedVarietyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plantingLocation => $composableBuilder(
    column: $table.plantingLocation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get seedlingPlantingDate => $composableBuilder(
    column: $table.seedlingPlantingDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastWateredAt => $composableBuilder(
    column: $table.lastWateredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFertilizedAt => $composableBuilder(
    column: $table.lastFertilizedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastRepottedAt => $composableBuilder(
    column: $table.lastRepottedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextWaterDue => $composableBuilder(
    column: $table.nextWaterDue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  $$AppUsersTableAnnotationComposer get userId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlantSpeciesTableAnnotationComposer get speciesId {
    final $$PlantSpeciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.plantSpecies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantSpeciesTableAnnotationComposer(
            $db: $db,
            $table: $db.plantSpecies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> careEventsRefs<T extends Object>(
    Expression<T> Function($$CareEventsTableAnnotationComposer a) f,
  ) {
    final $$CareEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.careEvents,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CareEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.careEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> diagnosesRefs<T extends Object>(
    Expression<T> Function($$DiagnosesTableAnnotationComposer a) f,
  ) {
    final $$DiagnosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableAnnotationComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantsTable,
          Plant,
          $$PlantsTableFilterComposer,
          $$PlantsTableOrderingComposer,
          $$PlantsTableAnnotationComposer,
          $$PlantsTableCreateCompanionBuilder,
          $$PlantsTableUpdateCompanionBuilder,
          (Plant, $$PlantsTableReferences),
          Plant,
          PrefetchHooks Function({
            bool userId,
            bool speciesId,
            bool careEventsRefs,
            bool remindersRefs,
            bool diagnosesRefs,
          })
        > {
  $$PlantsTableTableManager(_$AppDatabase db, $PlantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> speciesId = const Value.absent(),
                Value<String> customName = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> lightDirection = const Value.absent(),
                Value<int?> wateringFrequencyDays = const Value.absent(),
                Value<int?> fertilizingFrequencyDays = const Value.absent(),
                Value<String?> soilType = const Value.absent(),
                Value<String?> potSize = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> seedPacketImagePath = const Value.absent(),
                Value<String?> seedVarietyName = const Value.absent(),
                Value<String?> plantingLocation = const Value.absent(),
                Value<DateTime?> seedlingPlantingDate = const Value.absent(),
                Value<DateTime?> lastWateredAt = const Value.absent(),
                Value<DateTime?> lastFertilizedAt = const Value.absent(),
                Value<DateTime?> lastRepottedAt = const Value.absent(),
                Value<DateTime?> nextWaterDue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => PlantsCompanion(
                id: id,
                userId: userId,
                speciesId: speciesId,
                customName: customName,
                imagePath: imagePath,
                location: location,
                lightDirection: lightDirection,
                wateringFrequencyDays: wateringFrequencyDays,
                fertilizingFrequencyDays: fertilizingFrequencyDays,
                soilType: soilType,
                potSize: potSize,
                notes: notes,
                seedPacketImagePath: seedPacketImagePath,
                seedVarietyName: seedVarietyName,
                plantingLocation: plantingLocation,
                seedlingPlantingDate: seedlingPlantingDate,
                lastWateredAt: lastWateredAt,
                lastFertilizedAt: lastFertilizedAt,
                lastRepottedAt: lastRepottedAt,
                nextWaterDue: nextWaterDue,
                createdAt: createdAt,
                isArchived: isArchived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                Value<String?> speciesId = const Value.absent(),
                required String customName,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> lightDirection = const Value.absent(),
                Value<int?> wateringFrequencyDays = const Value.absent(),
                Value<int?> fertilizingFrequencyDays = const Value.absent(),
                Value<String?> soilType = const Value.absent(),
                Value<String?> potSize = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> seedPacketImagePath = const Value.absent(),
                Value<String?> seedVarietyName = const Value.absent(),
                Value<String?> plantingLocation = const Value.absent(),
                Value<DateTime?> seedlingPlantingDate = const Value.absent(),
                Value<DateTime?> lastWateredAt = const Value.absent(),
                Value<DateTime?> lastFertilizedAt = const Value.absent(),
                Value<DateTime?> lastRepottedAt = const Value.absent(),
                Value<DateTime?> nextWaterDue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => PlantsCompanion.insert(
                id: id,
                userId: userId,
                speciesId: speciesId,
                customName: customName,
                imagePath: imagePath,
                location: location,
                lightDirection: lightDirection,
                wateringFrequencyDays: wateringFrequencyDays,
                fertilizingFrequencyDays: fertilizingFrequencyDays,
                soilType: soilType,
                potSize: potSize,
                notes: notes,
                seedPacketImagePath: seedPacketImagePath,
                seedVarietyName: seedVarietyName,
                plantingLocation: plantingLocation,
                seedlingPlantingDate: seedlingPlantingDate,
                lastWateredAt: lastWateredAt,
                lastFertilizedAt: lastFertilizedAt,
                lastRepottedAt: lastRepottedAt,
                nextWaterDue: nextWaterDue,
                createdAt: createdAt,
                isArchived: isArchived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlantsTable, Plant>(table),
                  $$PlantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userId = false,
                speciesId = false,
                careEventsRefs = false,
                remindersRefs = false,
                diagnosesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (careEventsRefs) db.careEvents,
                    if (remindersRefs) db.reminders,
                    if (diagnosesRefs) db.diagnoses,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable: $$PlantsTableReferences
                                        ._userIdTable(db),
                                    referencedColumn: $$PlantsTableReferences
                                        ._userIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (speciesId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.speciesId,
                                    referencedTable: $$PlantsTableReferences
                                        ._speciesIdTable(db),
                                    referencedColumn: $$PlantsTableReferences
                                        ._speciesIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (careEventsRefs)
                        await $_getPrefetchedData<
                          Plant,
                          $PlantsTable,
                          CareEvent
                        >(
                          currentTable: table,
                          referencedTable: $$PlantsTableReferences
                              ._careEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlantsTableReferences(
                                db,
                                table,
                                p0,
                              ).careEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          Plant,
                          $PlantsTable,
                          Reminder
                        >(
                          currentTable: table,
                          referencedTable: $$PlantsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlantsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (diagnosesRefs)
                        await $_getPrefetchedData<
                          Plant,
                          $PlantsTable,
                          Diagnose
                        >(
                          currentTable: table,
                          referencedTable: $$PlantsTableReferences
                              ._diagnosesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlantsTableReferences(
                                db,
                                table,
                                p0,
                              ).diagnosesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plantId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantsTable,
      Plant,
      $$PlantsTableFilterComposer,
      $$PlantsTableOrderingComposer,
      $$PlantsTableAnnotationComposer,
      $$PlantsTableCreateCompanionBuilder,
      $$PlantsTableUpdateCompanionBuilder,
      (Plant, $$PlantsTableReferences),
      Plant,
      PrefetchHooks Function({
        bool userId,
        bool speciesId,
        bool careEventsRefs,
        bool remindersRefs,
        bool diagnosesRefs,
      })
    >;
typedef $$CareEventsTableCreateCompanionBuilder =
    CareEventsCompanion Function({
      Value<int> id,
      required int plantId,
      required String type,
      Value<DateTime> performedAt,
      Value<String?> notes,
    });
typedef $$CareEventsTableUpdateCompanionBuilder =
    CareEventsCompanion Function({
      Value<int> id,
      Value<int> plantId,
      Value<String> type,
      Value<DateTime> performedAt,
      Value<String?> notes,
    });

final class $$CareEventsTableReferences
    extends BaseReferences<_$AppDatabase, $CareEventsTable, CareEvent> {
  $$CareEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlantsTable _plantIdTable(_$AppDatabase db) =>
      db.plants.createAlias('care_events__plant_id__plants__id');

  $$PlantsTableProcessedTableManager get plantId {
    final $_column = $_itemColumn<int>('plant_id')!;

    final manager = $$PlantsTableTableManager(
      $_db,
      $_db.plants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CareEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CareEventsTable> {
  $$CareEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PlantsTableFilterComposer get plantId {
    final $$PlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableFilterComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CareEventsTable> {
  $$CareEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlantsTableOrderingComposer get plantId {
    final $$PlantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableOrderingComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareEventsTable> {
  $$CareEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PlantsTableAnnotationComposer get plantId {
    final $$PlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CareEventsTable,
          CareEvent,
          $$CareEventsTableFilterComposer,
          $$CareEventsTableOrderingComposer,
          $$CareEventsTableAnnotationComposer,
          $$CareEventsTableCreateCompanionBuilder,
          $$CareEventsTableUpdateCompanionBuilder,
          (CareEvent, $$CareEventsTableReferences),
          CareEvent,
          PrefetchHooks Function({bool plantId})
        > {
  $$CareEventsTableTableManager(_$AppDatabase db, $CareEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> plantId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CareEventsCompanion(
                id: id,
                plantId: plantId,
                type: type,
                performedAt: performedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int plantId,
                required String type,
                Value<DateTime> performedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CareEventsCompanion.insert(
                id: id,
                plantId: plantId,
                type: type,
                performedAt: performedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CareEventsTable, CareEvent>(table),
                  $$CareEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (plantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.plantId,
                                referencedTable: $$CareEventsTableReferences
                                    ._plantIdTable(db),
                                referencedColumn: $$CareEventsTableReferences
                                    ._plantIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CareEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CareEventsTable,
      CareEvent,
      $$CareEventsTableFilterComposer,
      $$CareEventsTableOrderingComposer,
      $$CareEventsTableAnnotationComposer,
      $$CareEventsTableCreateCompanionBuilder,
      $$CareEventsTableUpdateCompanionBuilder,
      (CareEvent, $$CareEventsTableReferences),
      CareEvent,
      PrefetchHooks Function({bool plantId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required int plantId,
      required String type,
      required DateTime dueAt,
      Value<bool> isActive,
      Value<bool> isRepeating,
      Value<int?> repeatIntervalDays,
      Value<int?> notificationId,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<int> plantId,
      Value<String> type,
      Value<DateTime> dueAt,
      Value<bool> isActive,
      Value<bool> isRepeating,
      Value<int?> repeatIntervalDays,
      Value<int?> notificationId,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlantsTable _plantIdTable(_$AppDatabase db) =>
      db.plants.createAlias('reminders__plant_id__plants__id');

  $$PlantsTableProcessedTableManager get plantId {
    final $_column = $_itemColumn<int>('plant_id')!;

    final manager = $$PlantsTableTableManager(
      $_db,
      $_db.plants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRepeating => $composableBuilder(
    column: $table.isRepeating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatIntervalDays => $composableBuilder(
    column: $table.repeatIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  $$PlantsTableFilterComposer get plantId {
    final $$PlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableFilterComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRepeating => $composableBuilder(
    column: $table.isRepeating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatIntervalDays => $composableBuilder(
    column: $table.repeatIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlantsTableOrderingComposer get plantId {
    final $$PlantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableOrderingComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isRepeating => $composableBuilder(
    column: $table.isRepeating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatIntervalDays => $composableBuilder(
    column: $table.repeatIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  $$PlantsTableAnnotationComposer get plantId {
    final $$PlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool plantId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> plantId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isRepeating = const Value.absent(),
                Value<int?> repeatIntervalDays = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                plantId: plantId,
                type: type,
                dueAt: dueAt,
                isActive: isActive,
                isRepeating: isRepeating,
                repeatIntervalDays: repeatIntervalDays,
                notificationId: notificationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int plantId,
                required String type,
                required DateTime dueAt,
                Value<bool> isActive = const Value.absent(),
                Value<bool> isRepeating = const Value.absent(),
                Value<int?> repeatIntervalDays = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                plantId: plantId,
                type: type,
                dueAt: dueAt,
                isActive: isActive,
                isRepeating: isRepeating,
                repeatIntervalDays: repeatIntervalDays,
                notificationId: notificationId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, Reminder>(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (plantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.plantId,
                                referencedTable: $$RemindersTableReferences
                                    ._plantIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._plantIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool plantId})
    >;
typedef $$WeatherCacheTableCreateCompanionBuilder =
    WeatherCacheCompanion Function({
      Value<int> id,
      required double latitude,
      required double longitude,
      required String payloadJson,
      Value<DateTime> fetchedAt,
      required DateTime expiresAt,
    });
typedef $$WeatherCacheTableUpdateCompanionBuilder =
    WeatherCacheCompanion Function({
      Value<int> id,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> payloadJson,
      Value<DateTime> fetchedAt,
      Value<DateTime> expiresAt,
    });

class $$WeatherCacheTableFilterComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeatherCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeatherCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$WeatherCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeatherCacheTable,
          WeatherCacheData,
          $$WeatherCacheTableFilterComposer,
          $$WeatherCacheTableOrderingComposer,
          $$WeatherCacheTableAnnotationComposer,
          $$WeatherCacheTableCreateCompanionBuilder,
          $$WeatherCacheTableUpdateCompanionBuilder,
          (
            WeatherCacheData,
            BaseReferences<_$AppDatabase, $WeatherCacheTable, WeatherCacheData>,
          ),
          WeatherCacheData,
          PrefetchHooks Function()
        > {
  $$WeatherCacheTableTableManager(_$AppDatabase db, $WeatherCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeatherCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeatherCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeatherCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => WeatherCacheCompanion(
                id: id,
                latitude: latitude,
                longitude: longitude,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double latitude,
                required double longitude,
                required String payloadJson,
                Value<DateTime> fetchedAt = const Value.absent(),
                required DateTime expiresAt,
              }) => WeatherCacheCompanion.insert(
                id: id,
                latitude: latitude,
                longitude: longitude,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeatherCacheTable, WeatherCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeatherCacheTable,
                    WeatherCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeatherCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeatherCacheTable,
      WeatherCacheData,
      $$WeatherCacheTableFilterComposer,
      $$WeatherCacheTableOrderingComposer,
      $$WeatherCacheTableAnnotationComposer,
      $$WeatherCacheTableCreateCompanionBuilder,
      $$WeatherCacheTableUpdateCompanionBuilder,
      (
        WeatherCacheData,
        BaseReferences<_$AppDatabase, $WeatherCacheTable, WeatherCacheData>,
      ),
      WeatherCacheData,
      PrefetchHooks Function()
    >;
typedef $$PlantDiseasesTableCreateCompanionBuilder =
    PlantDiseasesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> symptomsJson,
      Value<String?> treatmentPlanJson,
      Value<int?> modelLabelId,
      Value<bool> isPremium,
      Value<int> rowid,
    });
typedef $$PlantDiseasesTableUpdateCompanionBuilder =
    PlantDiseasesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> symptomsJson,
      Value<String?> treatmentPlanJson,
      Value<int?> modelLabelId,
      Value<bool> isPremium,
      Value<int> rowid,
    });

final class $$PlantDiseasesTableReferences
    extends BaseReferences<_$AppDatabase, $PlantDiseasesTable, PlantDisease> {
  $$PlantDiseasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DiagnosesTable, List<Diagnose>>
  _diagnosesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diagnoses,
    aliasName: 'plant_diseases__id__diagnoses__disease_id',
  );

  $$DiagnosesTableProcessedTableManager get diagnosesRefs {
    final manager = $$DiagnosesTableTableManager(
      $_db,
      $_db.diagnoses,
    ).filter((f) => f.diseaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_diagnosesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlantDiseasesTableFilterComposer
    extends Composer<_$AppDatabase, $PlantDiseasesTable> {
  $$PlantDiseasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatmentPlanJson => $composableBuilder(
    column: $table.treatmentPlanJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modelLabelId => $composableBuilder(
    column: $table.modelLabelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> diagnosesRefs(
    Expression<bool> Function($$DiagnosesTableFilterComposer f) f,
  ) {
    final $$DiagnosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.diseaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableFilterComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantDiseasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantDiseasesTable> {
  $$PlantDiseasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatmentPlanJson => $composableBuilder(
    column: $table.treatmentPlanJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modelLabelId => $composableBuilder(
    column: $table.modelLabelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlantDiseasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantDiseasesTable> {
  $$PlantDiseasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get treatmentPlanJson => $composableBuilder(
    column: $table.treatmentPlanJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get modelLabelId => $composableBuilder(
    column: $table.modelLabelId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  Expression<T> diagnosesRefs<T extends Object>(
    Expression<T> Function($$DiagnosesTableAnnotationComposer a) f,
  ) {
    final $$DiagnosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.diseaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableAnnotationComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantDiseasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantDiseasesTable,
          PlantDisease,
          $$PlantDiseasesTableFilterComposer,
          $$PlantDiseasesTableOrderingComposer,
          $$PlantDiseasesTableAnnotationComposer,
          $$PlantDiseasesTableCreateCompanionBuilder,
          $$PlantDiseasesTableUpdateCompanionBuilder,
          (PlantDisease, $$PlantDiseasesTableReferences),
          PlantDisease,
          PrefetchHooks Function({bool diagnosesRefs})
        > {
  $$PlantDiseasesTableTableManager(_$AppDatabase db, $PlantDiseasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantDiseasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantDiseasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantDiseasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> symptomsJson = const Value.absent(),
                Value<String?> treatmentPlanJson = const Value.absent(),
                Value<int?> modelLabelId = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantDiseasesCompanion(
                id: id,
                name: name,
                description: description,
                symptomsJson: symptomsJson,
                treatmentPlanJson: treatmentPlanJson,
                modelLabelId: modelLabelId,
                isPremium: isPremium,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> symptomsJson = const Value.absent(),
                Value<String?> treatmentPlanJson = const Value.absent(),
                Value<int?> modelLabelId = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantDiseasesCompanion.insert(
                id: id,
                name: name,
                description: description,
                symptomsJson: symptomsJson,
                treatmentPlanJson: treatmentPlanJson,
                modelLabelId: modelLabelId,
                isPremium: isPremium,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlantDiseasesTable, PlantDisease>(table),
                  $$PlantDiseasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({diagnosesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (diagnosesRefs) db.diagnoses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (diagnosesRefs)
                    await $_getPrefetchedData<
                      PlantDisease,
                      $PlantDiseasesTable,
                      Diagnose
                    >(
                      currentTable: table,
                      referencedTable: $$PlantDiseasesTableReferences
                          ._diagnosesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlantDiseasesTableReferences(
                            db,
                            table,
                            p0,
                          ).diagnosesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.diseaseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlantDiseasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantDiseasesTable,
      PlantDisease,
      $$PlantDiseasesTableFilterComposer,
      $$PlantDiseasesTableOrderingComposer,
      $$PlantDiseasesTableAnnotationComposer,
      $$PlantDiseasesTableCreateCompanionBuilder,
      $$PlantDiseasesTableUpdateCompanionBuilder,
      (PlantDisease, $$PlantDiseasesTableReferences),
      PlantDisease,
      PrefetchHooks Function({bool diagnosesRefs})
    >;
typedef $$DiagnosesTableCreateCompanionBuilder =
    DiagnosesCompanion Function({
      Value<int> id,
      Value<int?> plantId,
      Value<String?> diseaseId,
      Value<String?> imagePath,
      Value<double?> confidence,
      Value<String> status,
      Value<DateTime> startedAt,
      Value<DateTime?> resolvedAt,
    });
typedef $$DiagnosesTableUpdateCompanionBuilder =
    DiagnosesCompanion Function({
      Value<int> id,
      Value<int?> plantId,
      Value<String?> diseaseId,
      Value<String?> imagePath,
      Value<double?> confidence,
      Value<String> status,
      Value<DateTime> startedAt,
      Value<DateTime?> resolvedAt,
    });

final class $$DiagnosesTableReferences
    extends BaseReferences<_$AppDatabase, $DiagnosesTable, Diagnose> {
  $$DiagnosesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlantsTable _plantIdTable(_$AppDatabase db) =>
      db.plants.createAlias('diagnoses__plant_id__plants__id');

  $$PlantsTableProcessedTableManager? get plantId {
    final $_column = $_itemColumn<int>('plant_id');
    if ($_column == null) return null;
    final manager = $$PlantsTableTableManager(
      $_db,
      $_db.plants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlantDiseasesTable _diseaseIdTable(_$AppDatabase db) =>
      db.plantDiseases.createAlias('diagnoses__disease_id__plant_diseases__id');

  $$PlantDiseasesTableProcessedTableManager? get diseaseId {
    final $_column = $_itemColumn<String>('disease_id');
    if ($_column == null) return null;
    final manager = $$PlantDiseasesTableTableManager(
      $_db,
      $_db.plantDiseases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_diseaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TreatmentStepsTable, List<TreatmentStep>>
  _treatmentStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.treatmentSteps,
    aliasName: 'diagnoses__id__treatment_steps__diagnosis_id',
  );

  $$TreatmentStepsTableProcessedTableManager get treatmentStepsRefs {
    final manager = $$TreatmentStepsTableTableManager(
      $_db,
      $_db.treatmentSteps,
    ).filter((f) => f.diagnosisId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_treatmentStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DiagnosesTableFilterComposer
    extends Composer<_$AppDatabase, $DiagnosesTable> {
  $$DiagnosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlantsTableFilterComposer get plantId {
    final $$PlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableFilterComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlantDiseasesTableFilterComposer get diseaseId {
    final $$PlantDiseasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.diseaseId,
      referencedTable: $db.plantDiseases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantDiseasesTableFilterComposer(
            $db: $db,
            $table: $db.plantDiseases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> treatmentStepsRefs(
    Expression<bool> Function($$TreatmentStepsTableFilterComposer f) f,
  ) {
    final $$TreatmentStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentSteps,
      getReferencedColumn: (t) => t.diagnosisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentStepsTableFilterComposer(
            $db: $db,
            $table: $db.treatmentSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DiagnosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiagnosesTable> {
  $$DiagnosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlantsTableOrderingComposer get plantId {
    final $$PlantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableOrderingComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlantDiseasesTableOrderingComposer get diseaseId {
    final $$PlantDiseasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.diseaseId,
      referencedTable: $db.plantDiseases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantDiseasesTableOrderingComposer(
            $db: $db,
            $table: $db.plantDiseases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiagnosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiagnosesTable> {
  $$DiagnosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  $$PlantsTableAnnotationComposer get plantId {
    final $$PlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlantDiseasesTableAnnotationComposer get diseaseId {
    final $$PlantDiseasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.diseaseId,
      referencedTable: $db.plantDiseases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantDiseasesTableAnnotationComposer(
            $db: $db,
            $table: $db.plantDiseases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> treatmentStepsRefs<T extends Object>(
    Expression<T> Function($$TreatmentStepsTableAnnotationComposer a) f,
  ) {
    final $$TreatmentStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentSteps,
      getReferencedColumn: (t) => t.diagnosisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.treatmentSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DiagnosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiagnosesTable,
          Diagnose,
          $$DiagnosesTableFilterComposer,
          $$DiagnosesTableOrderingComposer,
          $$DiagnosesTableAnnotationComposer,
          $$DiagnosesTableCreateCompanionBuilder,
          $$DiagnosesTableUpdateCompanionBuilder,
          (Diagnose, $$DiagnosesTableReferences),
          Diagnose,
          PrefetchHooks Function({
            bool plantId,
            bool diseaseId,
            bool treatmentStepsRefs,
          })
        > {
  $$DiagnosesTableTableManager(_$AppDatabase db, $DiagnosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> plantId = const Value.absent(),
                Value<String?> diseaseId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => DiagnosesCompanion(
                id: id,
                plantId: plantId,
                diseaseId: diseaseId,
                imagePath: imagePath,
                confidence: confidence,
                status: status,
                startedAt: startedAt,
                resolvedAt: resolvedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> plantId = const Value.absent(),
                Value<String?> diseaseId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => DiagnosesCompanion.insert(
                id: id,
                plantId: plantId,
                diseaseId: diseaseId,
                imagePath: imagePath,
                confidence: confidence,
                status: status,
                startedAt: startedAt,
                resolvedAt: resolvedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiagnosesTable, Diagnose>(table),
                  $$DiagnosesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                plantId = false,
                diseaseId = false,
                treatmentStepsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (treatmentStepsRefs) db.treatmentSteps,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (plantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.plantId,
                                    referencedTable: $$DiagnosesTableReferences
                                        ._plantIdTable(db),
                                    referencedColumn: $$DiagnosesTableReferences
                                        ._plantIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (diseaseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.diseaseId,
                                    referencedTable: $$DiagnosesTableReferences
                                        ._diseaseIdTable(db),
                                    referencedColumn: $$DiagnosesTableReferences
                                        ._diseaseIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (treatmentStepsRefs)
                        await $_getPrefetchedData<
                          Diagnose,
                          $DiagnosesTable,
                          TreatmentStep
                        >(
                          currentTable: table,
                          referencedTable: $$DiagnosesTableReferences
                              ._treatmentStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DiagnosesTableReferences(
                                db,
                                table,
                                p0,
                              ).treatmentStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.diagnosisId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DiagnosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiagnosesTable,
      Diagnose,
      $$DiagnosesTableFilterComposer,
      $$DiagnosesTableOrderingComposer,
      $$DiagnosesTableAnnotationComposer,
      $$DiagnosesTableCreateCompanionBuilder,
      $$DiagnosesTableUpdateCompanionBuilder,
      (Diagnose, $$DiagnosesTableReferences),
      Diagnose,
      PrefetchHooks Function({
        bool plantId,
        bool diseaseId,
        bool treatmentStepsRefs,
      })
    >;
typedef $$TreatmentStepsTableCreateCompanionBuilder =
    TreatmentStepsCompanion Function({
      Value<int> id,
      required int diagnosisId,
      required int stepNumber,
      required String title,
      Value<String?> description,
      required DateTime dueAt,
      Value<DateTime?> completedAt,
      Value<bool> isCompleted,
    });
typedef $$TreatmentStepsTableUpdateCompanionBuilder =
    TreatmentStepsCompanion Function({
      Value<int> id,
      Value<int> diagnosisId,
      Value<int> stepNumber,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> dueAt,
      Value<DateTime?> completedAt,
      Value<bool> isCompleted,
    });

final class $$TreatmentStepsTableReferences
    extends BaseReferences<_$AppDatabase, $TreatmentStepsTable, TreatmentStep> {
  $$TreatmentStepsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DiagnosesTable _diagnosisIdTable(_$AppDatabase db) =>
      db.diagnoses.createAlias('treatment_steps__diagnosis_id__diagnoses__id');

  $$DiagnosesTableProcessedTableManager get diagnosisId {
    final $_column = $_itemColumn<int>('diagnosis_id')!;

    final manager = $$DiagnosesTableTableManager(
      $_db,
      $_db.diagnoses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_diagnosisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TreatmentStepsTableFilterComposer
    extends Composer<_$AppDatabase, $TreatmentStepsTable> {
  $$TreatmentStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$DiagnosesTableFilterComposer get diagnosisId {
    final $$DiagnosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.diagnosisId,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableFilterComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreatmentStepsTable> {
  $$TreatmentStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$DiagnosesTableOrderingComposer get diagnosisId {
    final $$DiagnosesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.diagnosisId,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableOrderingComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreatmentStepsTable> {
  $$TreatmentStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$DiagnosesTableAnnotationComposer get diagnosisId {
    final $$DiagnosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.diagnosisId,
      referencedTable: $db.diagnoses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosesTableAnnotationComposer(
            $db: $db,
            $table: $db.diagnoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreatmentStepsTable,
          TreatmentStep,
          $$TreatmentStepsTableFilterComposer,
          $$TreatmentStepsTableOrderingComposer,
          $$TreatmentStepsTableAnnotationComposer,
          $$TreatmentStepsTableCreateCompanionBuilder,
          $$TreatmentStepsTableUpdateCompanionBuilder,
          (TreatmentStep, $$TreatmentStepsTableReferences),
          TreatmentStep,
          PrefetchHooks Function({bool diagnosisId})
        > {
  $$TreatmentStepsTableTableManager(
    _$AppDatabase db,
    $TreatmentStepsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreatmentStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreatmentStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreatmentStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> diagnosisId = const Value.absent(),
                Value<int> stepNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => TreatmentStepsCompanion(
                id: id,
                diagnosisId: diagnosisId,
                stepNumber: stepNumber,
                title: title,
                description: description,
                dueAt: dueAt,
                completedAt: completedAt,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int diagnosisId,
                required int stepNumber,
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime dueAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => TreatmentStepsCompanion.insert(
                id: id,
                diagnosisId: diagnosisId,
                stepNumber: stepNumber,
                title: title,
                description: description,
                dueAt: dueAt,
                completedAt: completedAt,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TreatmentStepsTable, TreatmentStep>(table),
                  $$TreatmentStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({diagnosisId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (diagnosisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.diagnosisId,
                                referencedTable: $$TreatmentStepsTableReferences
                                    ._diagnosisIdTable(db),
                                referencedColumn:
                                    $$TreatmentStepsTableReferences
                                        ._diagnosisIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TreatmentStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreatmentStepsTable,
      TreatmentStep,
      $$TreatmentStepsTableFilterComposer,
      $$TreatmentStepsTableOrderingComposer,
      $$TreatmentStepsTableAnnotationComposer,
      $$TreatmentStepsTableCreateCompanionBuilder,
      $$TreatmentStepsTableUpdateCompanionBuilder,
      (TreatmentStep, $$TreatmentStepsTableReferences),
      TreatmentStep,
      PrefetchHooks Function({bool diagnosisId})
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String code,
      required String name,
      Value<String?> description,
      Value<String?> iconAsset,
      Value<int> rewardXp,
      Value<String?> criteriaJson,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String?> description,
      Value<String?> iconAsset,
      Value<int> rewardXp,
      Value<String?> criteriaJson,
      Value<int> rowid,
    });

final class $$AchievementsTableReferences
    extends BaseReferences<_$AppDatabase, $AchievementsTable, Achievement> {
  $$AchievementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserAchievementsTable, List<UserAchievement>>
  _userAchievementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userAchievements,
    aliasName: 'achievements__code__user_achievements__achievement_code',
  );

  $$UserAchievementsTableProcessedTableManager get userAchievementsRefs {
    final manager =
        $$UserAchievementsTableTableManager($_db, $_db.userAchievements).filter(
          (f) =>
              f.achievementCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _userAchievementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconAsset => $composableBuilder(
    column: $table.iconAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criteriaJson => $composableBuilder(
    column: $table.criteriaJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userAchievementsRefs(
    Expression<bool> Function($$UserAchievementsTableFilterComposer f) f,
  ) {
    final $$UserAchievementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.userAchievements,
      getReferencedColumn: (t) => t.achievementCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserAchievementsTableFilterComposer(
            $db: $db,
            $table: $db.userAchievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconAsset => $composableBuilder(
    column: $table.iconAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criteriaJson => $composableBuilder(
    column: $table.criteriaJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconAsset =>
      $composableBuilder(column: $table.iconAsset, builder: (column) => column);

  GeneratedColumn<int> get rewardXp =>
      $composableBuilder(column: $table.rewardXp, builder: (column) => column);

  GeneratedColumn<String> get criteriaJson => $composableBuilder(
    column: $table.criteriaJson,
    builder: (column) => column,
  );

  Expression<T> userAchievementsRefs<T extends Object>(
    Expression<T> Function($$UserAchievementsTableAnnotationComposer a) f,
  ) {
    final $$UserAchievementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.userAchievements,
      getReferencedColumn: (t) => t.achievementCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserAchievementsTableAnnotationComposer(
            $db: $db,
            $table: $db.userAchievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (Achievement, $$AchievementsTableReferences),
          Achievement,
          PrefetchHooks Function({bool userAchievementsRefs})
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> iconAsset = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<String?> criteriaJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                code: code,
                name: name,
                description: description,
                iconAsset: iconAsset,
                rewardXp: rewardXp,
                criteriaJson: criteriaJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> iconAsset = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<String?> criteriaJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                code: code,
                name: name,
                description: description,
                iconAsset: iconAsset,
                rewardXp: rewardXp,
                criteriaJson: criteriaJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTable, Achievement>(table),
                  $$AchievementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userAchievementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userAchievementsRefs) db.userAchievements,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userAchievementsRefs)
                    await $_getPrefetchedData<
                      Achievement,
                      $AchievementsTable,
                      UserAchievement
                    >(
                      currentTable: table,
                      referencedTable: $$AchievementsTableReferences
                          ._userAchievementsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AchievementsTableReferences(
                            db,
                            table,
                            p0,
                          ).userAchievementsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.achievementCode == item.code,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (Achievement, $$AchievementsTableReferences),
      Achievement,
      PrefetchHooks Function({bool userAchievementsRefs})
    >;
typedef $$UserAchievementsTableCreateCompanionBuilder =
    UserAchievementsCompanion Function({
      Value<int> id,
      required int userId,
      required String achievementCode,
      Value<DateTime> unlockedAt,
    });
typedef $$UserAchievementsTableUpdateCompanionBuilder =
    UserAchievementsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> achievementCode,
      Value<DateTime> unlockedAt,
    });

final class $$UserAchievementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $UserAchievementsTable, UserAchievement> {
  $$UserAchievementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AppUsersTable _userIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias('user_achievements__user_id__app_users__id');

  $$AppUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AchievementsTable _achievementCodeTable(_$AppDatabase db) => db
      .achievements
      .createAlias('user_achievements__achievement_code__achievements__code');

  $$AchievementsTableProcessedTableManager get achievementCode {
    final $_column = $_itemColumn<String>('achievement_code')!;

    final manager = $$AchievementsTableTableManager(
      $_db,
      $_db.achievements,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_achievementCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUsersTableFilterComposer get userId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AchievementsTableFilterComposer get achievementCode {
    final $$AchievementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.achievementCode,
      referencedTable: $db.achievements,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AchievementsTableFilterComposer(
            $db: $db,
            $table: $db.achievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUsersTableOrderingComposer get userId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AchievementsTableOrderingComposer get achievementCode {
    final $$AchievementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.achievementCode,
      referencedTable: $db.achievements,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AchievementsTableOrderingComposer(
            $db: $db,
            $table: $db.achievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  $$AppUsersTableAnnotationComposer get userId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AchievementsTableAnnotationComposer get achievementCode {
    final $$AchievementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.achievementCode,
      referencedTable: $db.achievements,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AchievementsTableAnnotationComposer(
            $db: $db,
            $table: $db.achievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAchievementsTable,
          UserAchievement,
          $$UserAchievementsTableFilterComposer,
          $$UserAchievementsTableOrderingComposer,
          $$UserAchievementsTableAnnotationComposer,
          $$UserAchievementsTableCreateCompanionBuilder,
          $$UserAchievementsTableUpdateCompanionBuilder,
          (UserAchievement, $$UserAchievementsTableReferences),
          UserAchievement,
          PrefetchHooks Function({bool userId, bool achievementCode})
        > {
  $$UserAchievementsTableTableManager(
    _$AppDatabase db,
    $UserAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> achievementCode = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => UserAchievementsCompanion(
                id: id,
                userId: userId,
                achievementCode: achievementCode,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String achievementCode,
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => UserAchievementsCompanion.insert(
                id: id,
                userId: userId,
                achievementCode: achievementCode,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserAchievementsTable, UserAchievement>(table),
                  $$UserAchievementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, achievementCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$UserAchievementsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$UserAchievementsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (achievementCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.achievementCode,
                                referencedTable:
                                    $$UserAchievementsTableReferences
                                        ._achievementCodeTable(db),
                                referencedColumn:
                                    $$UserAchievementsTableReferences
                                        ._achievementCodeTable(db)
                                        .code,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAchievementsTable,
      UserAchievement,
      $$UserAchievementsTableFilterComposer,
      $$UserAchievementsTableOrderingComposer,
      $$UserAchievementsTableAnnotationComposer,
      $$UserAchievementsTableCreateCompanionBuilder,
      $$UserAchievementsTableUpdateCompanionBuilder,
      (UserAchievement, $$UserAchievementsTableReferences),
      UserAchievement,
      PrefetchHooks Function({bool userId, bool achievementCode})
    >;
typedef $$UserXpEventsTableCreateCompanionBuilder =
    UserXpEventsCompanion Function({
      Value<int> id,
      required int userId,
      required int amount,
      required String reason,
      Value<DateTime> createdAt,
    });
typedef $$UserXpEventsTableUpdateCompanionBuilder =
    UserXpEventsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> amount,
      Value<String> reason,
      Value<DateTime> createdAt,
    });

final class $$UserXpEventsTableReferences
    extends BaseReferences<_$AppDatabase, $UserXpEventsTable, UserXpEvent> {
  $$UserXpEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUsersTable _userIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias('user_xp_events__user_id__app_users__id');

  $$AppUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserXpEventsTableFilterComposer
    extends Composer<_$AppDatabase, $UserXpEventsTable> {
  $$UserXpEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUsersTableFilterComposer get userId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserXpEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserXpEventsTable> {
  $$UserXpEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUsersTableOrderingComposer get userId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserXpEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserXpEventsTable> {
  $$UserXpEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AppUsersTableAnnotationComposer get userId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserXpEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserXpEventsTable,
          UserXpEvent,
          $$UserXpEventsTableFilterComposer,
          $$UserXpEventsTableOrderingComposer,
          $$UserXpEventsTableAnnotationComposer,
          $$UserXpEventsTableCreateCompanionBuilder,
          $$UserXpEventsTableUpdateCompanionBuilder,
          (UserXpEvent, $$UserXpEventsTableReferences),
          UserXpEvent,
          PrefetchHooks Function({bool userId})
        > {
  $$UserXpEventsTableTableManager(_$AppDatabase db, $UserXpEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserXpEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserXpEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserXpEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserXpEventsCompanion(
                id: id,
                userId: userId,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required int amount,
                required String reason,
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserXpEventsCompanion.insert(
                id: id,
                userId: userId,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserXpEventsTable, UserXpEvent>(table),
                  $$UserXpEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$UserXpEventsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$UserXpEventsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserXpEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserXpEventsTable,
      UserXpEvent,
      $$UserXpEventsTableFilterComposer,
      $$UserXpEventsTableOrderingComposer,
      $$UserXpEventsTableAnnotationComposer,
      $$UserXpEventsTableCreateCompanionBuilder,
      $$UserXpEventsTableUpdateCompanionBuilder,
      (UserXpEvent, $$UserXpEventsTableReferences),
      UserXpEvent,
      PrefetchHooks Function({bool userId})
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaData>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$PlantSpeciesTableTableManager get plantSpecies =>
      $$PlantSpeciesTableTableManager(_db, _db.plantSpecies);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db, _db.plants);
  $$CareEventsTableTableManager get careEvents =>
      $$CareEventsTableTableManager(_db, _db.careEvents);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$WeatherCacheTableTableManager get weatherCache =>
      $$WeatherCacheTableTableManager(_db, _db.weatherCache);
  $$PlantDiseasesTableTableManager get plantDiseases =>
      $$PlantDiseasesTableTableManager(_db, _db.plantDiseases);
  $$DiagnosesTableTableManager get diagnoses =>
      $$DiagnosesTableTableManager(_db, _db.diagnoses);
  $$TreatmentStepsTableTableManager get treatmentSteps =>
      $$TreatmentStepsTableTableManager(_db, _db.treatmentSteps);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$UserAchievementsTableTableManager get userAchievements =>
      $$UserAchievementsTableTableManager(_db, _db.userAchievements);
  $$UserXpEventsTableTableManager get userXpEvents =>
      $$UserXpEventsTableTableManager(_db, _db.userXpEvents);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
