// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $ExerciseTable extends Exercise
    with TableInfo<$ExerciseTable, ExerciseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardioMeta = const VerificationMeta('cardio');
  @override
  late final GeneratedColumn<double> cardio = GeneratedColumn<double>(
    'cardio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, difficulty, cardio];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('cardio')) {
      context.handle(
        _cardioMeta,
        cardio.isAcceptableOrUnknown(data['cardio']!, _cardioMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      difficulty:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}difficulty'],
          )!,
      cardio:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}cardio'],
          )!,
    );
  }

  @override
  $ExerciseTable createAlias(String alias) {
    return $ExerciseTable(attachedDatabase, alias);
  }
}

class ExerciseData extends DataClass implements Insertable<ExerciseData> {
  final int id;
  final String name;
  final String type;
  final int difficulty;
  final double cardio;
  const ExerciseData({
    required this.id,
    required this.name,
    required this.type,
    required this.difficulty,
    required this.cardio,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['difficulty'] = Variable<int>(difficulty);
    map['cardio'] = Variable<double>(cardio);
    return map;
  }

  ExerciseCompanion toCompanion(bool nullToAbsent) {
    return ExerciseCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      difficulty: Value(difficulty),
      cardio: Value(cardio),
    );
  }

  factory ExerciseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      cardio: serializer.fromJson<double>(json['cardio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'difficulty': serializer.toJson<int>(difficulty),
      'cardio': serializer.toJson<double>(cardio),
    };
  }

  ExerciseData copyWith({
    int? id,
    String? name,
    String? type,
    int? difficulty,
    double? cardio,
  }) => ExerciseData(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    difficulty: difficulty ?? this.difficulty,
    cardio: cardio ?? this.cardio,
  );
  ExerciseData copyWithCompanion(ExerciseCompanion data) {
    return ExerciseData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      cardio: data.cardio.present ? data.cardio.value : this.cardio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('cardio: $cardio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, difficulty, cardio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.difficulty == this.difficulty &&
          other.cardio == this.cardio);
}

class ExerciseCompanion extends UpdateCompanion<ExerciseData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> difficulty;
  final Value<double> cardio;
  const ExerciseCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.cardio = const Value.absent(),
  });
  ExerciseCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required int difficulty,
    this.cardio = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       difficulty = Value(difficulty);
  static Insertable<ExerciseData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? difficulty,
    Expression<double>? cardio,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (difficulty != null) 'difficulty': difficulty,
      if (cardio != null) 'cardio': cardio,
    });
  }

  ExerciseCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int>? difficulty,
    Value<double>? cardio,
  }) {
    return ExerciseCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      cardio: cardio ?? this.cardio,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (cardio.present) {
      map['cardio'] = Variable<double>(cardio.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('cardio: $cardio')
          ..write(')'))
        .toString();
  }
}

class $MuscleTable extends Muscle with TableInfo<$MuscleTable, MuscleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuscleTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscle';
  @override
  VerificationContext validateIntegrity(
    Insertable<MuscleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MuscleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuscleData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
    );
  }

  @override
  $MuscleTable createAlias(String alias) {
    return $MuscleTable(attachedDatabase, alias);
  }
}

class MuscleData extends DataClass implements Insertable<MuscleData> {
  final int id;
  final String name;
  const MuscleData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MuscleCompanion toCompanion(bool nullToAbsent) {
    return MuscleCompanion(id: Value(id), name: Value(name));
  }

  factory MuscleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuscleData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  MuscleData copyWith({int? id, String? name}) =>
      MuscleData(id: id ?? this.id, name: name ?? this.name);
  MuscleData copyWithCompanion(MuscleCompanion data) {
    return MuscleData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MuscleData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuscleData && other.id == this.id && other.name == this.name);
}

class MuscleCompanion extends UpdateCompanion<MuscleData> {
  final Value<int> id;
  final Value<String> name;
  const MuscleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  MuscleCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<MuscleData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  MuscleCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return MuscleCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuscleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMuscleTable extends ExerciseMuscle
    with TableInfo<$ExerciseMuscleTable, ExerciseMuscleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMuscleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleIdMeta = const VerificationMeta(
    'muscleId',
  );
  @override
  late final GeneratedColumn<int> muscleId = GeneratedColumn<int>(
    'muscle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscleId, weight];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscle';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle_id')) {
      context.handle(
        _muscleIdMeta,
        muscleId.isAcceptableOrUnknown(data['muscle_id']!, _muscleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscleId};
  @override
  ExerciseMuscleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscleData(
      exerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}exercise_id'],
          )!,
      muscleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}muscle_id'],
          )!,
      weight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}weight'],
          )!,
    );
  }

  @override
  $ExerciseMuscleTable createAlias(String alias) {
    return $ExerciseMuscleTable(attachedDatabase, alias);
  }
}

class ExerciseMuscleData extends DataClass
    implements Insertable<ExerciseMuscleData> {
  final int exerciseId;
  final int muscleId;
  final double weight;
  const ExerciseMuscleData({
    required this.exerciseId,
    required this.muscleId,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<int>(exerciseId);
    map['muscle_id'] = Variable<int>(muscleId);
    map['weight'] = Variable<double>(weight);
    return map;
  }

  ExerciseMuscleCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMuscleCompanion(
      exerciseId: Value(exerciseId),
      muscleId: Value(muscleId),
      weight: Value(weight),
    );
  }

  factory ExerciseMuscleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscleData(
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      muscleId: serializer.fromJson<int>(json['muscleId']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<int>(exerciseId),
      'muscleId': serializer.toJson<int>(muscleId),
      'weight': serializer.toJson<double>(weight),
    };
  }

  ExerciseMuscleData copyWith({
    int? exerciseId,
    int? muscleId,
    double? weight,
  }) => ExerciseMuscleData(
    exerciseId: exerciseId ?? this.exerciseId,
    muscleId: muscleId ?? this.muscleId,
    weight: weight ?? this.weight,
  );
  ExerciseMuscleData copyWithCompanion(ExerciseMuscleCompanion data) {
    return ExerciseMuscleData(
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      muscleId: data.muscleId.present ? data.muscleId.value : this.muscleId,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscleData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscleId, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscleData &&
          other.exerciseId == this.exerciseId &&
          other.muscleId == this.muscleId &&
          other.weight == this.weight);
}

class ExerciseMuscleCompanion extends UpdateCompanion<ExerciseMuscleData> {
  final Value<int> exerciseId;
  final Value<int> muscleId;
  final Value<double> weight;
  final Value<int> rowid;
  const ExerciseMuscleCompanion({
    this.exerciseId = const Value.absent(),
    this.muscleId = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMuscleCompanion.insert({
    required int exerciseId,
    required int muscleId,
    required double weight,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscleId = Value(muscleId),
       weight = Value(weight);
  static Insertable<ExerciseMuscleData> custom({
    Expression<int>? exerciseId,
    Expression<int>? muscleId,
    Expression<double>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscleId != null) 'muscle_id': muscleId,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMuscleCompanion copyWith({
    Value<int>? exerciseId,
    Value<int>? muscleId,
    Value<double>? weight,
    Value<int>? rowid,
  }) {
    return ExerciseMuscleCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleId: muscleId ?? this.muscleId,
      weight: weight ?? this.weight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (muscleId.present) {
      map['muscle_id'] = Variable<int>(muscleId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscleCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('weight: $weight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EquipmentTable extends Equipment
    with TableInfo<$EquipmentTable, EquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<EquipmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EquipmentData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
    );
  }

  @override
  $EquipmentTable createAlias(String alias) {
    return $EquipmentTable(attachedDatabase, alias);
  }
}

class EquipmentData extends DataClass implements Insertable<EquipmentData> {
  final int id;
  final String name;
  const EquipmentData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  EquipmentCompanion toCompanion(bool nullToAbsent) {
    return EquipmentCompanion(id: Value(id), name: Value(name));
  }

  factory EquipmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EquipmentData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  EquipmentData copyWith({int? id, String? name}) =>
      EquipmentData(id: id ?? this.id, name: name ?? this.name);
  EquipmentData copyWithCompanion(EquipmentCompanion data) {
    return EquipmentData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EquipmentData &&
          other.id == this.id &&
          other.name == this.name);
}

class EquipmentCompanion extends UpdateCompanion<EquipmentData> {
  final Value<int> id;
  final Value<String> name;
  const EquipmentCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  EquipmentCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<EquipmentData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  EquipmentCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return EquipmentCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ExerciseEquipmentTable extends ExerciseEquipment
    with TableInfo<$ExerciseEquipmentTable, ExerciseEquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseEquipmentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<int> equipmentId = GeneratedColumn<int>(
    'equipment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, equipmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseEquipmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, equipmentId};
  @override
  ExerciseEquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseEquipmentData(
      exerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}exercise_id'],
          )!,
      equipmentId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}equipment_id'],
          )!,
    );
  }

  @override
  $ExerciseEquipmentTable createAlias(String alias) {
    return $ExerciseEquipmentTable(attachedDatabase, alias);
  }
}

class ExerciseEquipmentData extends DataClass
    implements Insertable<ExerciseEquipmentData> {
  final int exerciseId;
  final int equipmentId;
  const ExerciseEquipmentData({
    required this.exerciseId,
    required this.equipmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<int>(exerciseId);
    map['equipment_id'] = Variable<int>(equipmentId);
    return map;
  }

  ExerciseEquipmentCompanion toCompanion(bool nullToAbsent) {
    return ExerciseEquipmentCompanion(
      exerciseId: Value(exerciseId),
      equipmentId: Value(equipmentId),
    );
  }

  factory ExerciseEquipmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseEquipmentData(
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      equipmentId: serializer.fromJson<int>(json['equipmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<int>(exerciseId),
      'equipmentId': serializer.toJson<int>(equipmentId),
    };
  }

  ExerciseEquipmentData copyWith({int? exerciseId, int? equipmentId}) =>
      ExerciseEquipmentData(
        exerciseId: exerciseId ?? this.exerciseId,
        equipmentId: equipmentId ?? this.equipmentId,
      );
  ExerciseEquipmentData copyWithCompanion(ExerciseEquipmentCompanion data) {
    return ExerciseEquipmentData(
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      equipmentId:
          data.equipmentId.present ? data.equipmentId.value : this.equipmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, equipmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseEquipmentData &&
          other.exerciseId == this.exerciseId &&
          other.equipmentId == this.equipmentId);
}

class ExerciseEquipmentCompanion
    extends UpdateCompanion<ExerciseEquipmentData> {
  final Value<int> exerciseId;
  final Value<int> equipmentId;
  final Value<int> rowid;
  const ExerciseEquipmentCompanion({
    this.exerciseId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseEquipmentCompanion.insert({
    required int exerciseId,
    required int equipmentId,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       equipmentId = Value(equipmentId);
  static Insertable<ExerciseEquipmentData> custom({
    Expression<int>? exerciseId,
    Expression<int>? equipmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseEquipmentCompanion copyWith({
    Value<int>? exerciseId,
    Value<int>? equipmentId,
    Value<int>? rowid,
  }) {
    return ExerciseEquipmentCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      equipmentId: equipmentId ?? this.equipmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<int>(equipmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUserTable extends AppUser with TableInfo<$AppUserTable, AppUserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUserTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_user';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUserData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
    );
  }

  @override
  $AppUserTable createAlias(String alias) {
    return $AppUserTable(attachedDatabase, alias);
  }
}

class AppUserData extends DataClass implements Insertable<AppUserData> {
  final int id;
  final String? name;
  const AppUserData({required this.id, this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  AppUserCompanion toCompanion(bool nullToAbsent) {
    return AppUserCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory AppUserData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
    };
  }

  AppUserData copyWith({int? id, Value<String?> name = const Value.absent()}) =>
      AppUserData(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
      );
  AppUserData copyWithCompanion(AppUserCompanion data) {
    return AppUserData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserData && other.id == this.id && other.name == this.name);
}

class AppUserCompanion extends UpdateCompanion<AppUserData> {
  final Value<int> id;
  final Value<String?> name;
  const AppUserCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  AppUserCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  static Insertable<AppUserData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  AppUserCompanion copyWith({Value<int>? id, Value<String?>? name}) {
    return AppUserCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUserCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $UserFeedbackTable extends UserFeedback
    with TableInfo<$UserFeedbackTable, UserFeedbackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFeedbackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likedMeta = const VerificationMeta('liked');
  @override
  late final GeneratedColumn<int> liked = GeneratedColumn<int>(
    'liked',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultMeta = const VerificationMeta(
    'difficult',
  );
  @override
  late final GeneratedColumn<int> difficult = GeneratedColumn<int>(
    'difficult',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pleasantMeta = const VerificationMeta(
    'pleasant',
  );
  @override
  late final GeneratedColumn<int> pleasant = GeneratedColumn<int>(
    'pleasant',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uselessMeta = const VerificationMeta(
    'useless',
  );
  @override
  late final GeneratedColumn<int> useless = GeneratedColumn<int>(
    'useless',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    exerciseId,
    liked,
    difficult,
    pleasant,
    useless,
    ts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFeedbackData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('liked')) {
      context.handle(
        _likedMeta,
        liked.isAcceptableOrUnknown(data['liked']!, _likedMeta),
      );
    } else if (isInserting) {
      context.missing(_likedMeta);
    }
    if (data.containsKey('difficult')) {
      context.handle(
        _difficultMeta,
        difficult.isAcceptableOrUnknown(data['difficult']!, _difficultMeta),
      );
    }
    if (data.containsKey('pleasant')) {
      context.handle(
        _pleasantMeta,
        pleasant.isAcceptableOrUnknown(data['pleasant']!, _pleasantMeta),
      );
    }
    if (data.containsKey('useless')) {
      context.handle(
        _uselessMeta,
        useless.isAcceptableOrUnknown(data['useless']!, _uselessMeta),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, exerciseId, ts};
  @override
  UserFeedbackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFeedbackData(
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}user_id'],
          )!,
      exerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}exercise_id'],
          )!,
      liked:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}liked'],
          )!,
      difficult:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}difficult'],
          )!,
      pleasant:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}pleasant'],
          )!,
      useless:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}useless'],
          )!,
      ts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}ts'],
          )!,
    );
  }

  @override
  $UserFeedbackTable createAlias(String alias) {
    return $UserFeedbackTable(attachedDatabase, alias);
  }
}

class UserFeedbackData extends DataClass
    implements Insertable<UserFeedbackData> {
  final int userId;
  final int exerciseId;
  final int liked;
  final int difficult;
  final int pleasant;
  final int useless;
  final int ts;
  const UserFeedbackData({
    required this.userId,
    required this.exerciseId,
    required this.liked,
    required this.difficult,
    required this.pleasant,
    required this.useless,
    required this.ts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['liked'] = Variable<int>(liked);
    map['difficult'] = Variable<int>(difficult);
    map['pleasant'] = Variable<int>(pleasant);
    map['useless'] = Variable<int>(useless);
    map['ts'] = Variable<int>(ts);
    return map;
  }

  UserFeedbackCompanion toCompanion(bool nullToAbsent) {
    return UserFeedbackCompanion(
      userId: Value(userId),
      exerciseId: Value(exerciseId),
      liked: Value(liked),
      difficult: Value(difficult),
      pleasant: Value(pleasant),
      useless: Value(useless),
      ts: Value(ts),
    );
  }

  factory UserFeedbackData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFeedbackData(
      userId: serializer.fromJson<int>(json['userId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      liked: serializer.fromJson<int>(json['liked']),
      difficult: serializer.fromJson<int>(json['difficult']),
      pleasant: serializer.fromJson<int>(json['pleasant']),
      useless: serializer.fromJson<int>(json['useless']),
      ts: serializer.fromJson<int>(json['ts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'liked': serializer.toJson<int>(liked),
      'difficult': serializer.toJson<int>(difficult),
      'pleasant': serializer.toJson<int>(pleasant),
      'useless': serializer.toJson<int>(useless),
      'ts': serializer.toJson<int>(ts),
    };
  }

  UserFeedbackData copyWith({
    int? userId,
    int? exerciseId,
    int? liked,
    int? difficult,
    int? pleasant,
    int? useless,
    int? ts,
  }) => UserFeedbackData(
    userId: userId ?? this.userId,
    exerciseId: exerciseId ?? this.exerciseId,
    liked: liked ?? this.liked,
    difficult: difficult ?? this.difficult,
    pleasant: pleasant ?? this.pleasant,
    useless: useless ?? this.useless,
    ts: ts ?? this.ts,
  );
  UserFeedbackData copyWithCompanion(UserFeedbackCompanion data) {
    return UserFeedbackData(
      userId: data.userId.present ? data.userId.value : this.userId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      liked: data.liked.present ? data.liked.value : this.liked,
      difficult: data.difficult.present ? data.difficult.value : this.difficult,
      pleasant: data.pleasant.present ? data.pleasant.value : this.pleasant,
      useless: data.useless.present ? data.useless.value : this.useless,
      ts: data.ts.present ? data.ts.value : this.ts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFeedbackData(')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('liked: $liked, ')
          ..write('difficult: $difficult, ')
          ..write('pleasant: $pleasant, ')
          ..write('useless: $useless, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, exerciseId, liked, difficult, pleasant, useless, ts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFeedbackData &&
          other.userId == this.userId &&
          other.exerciseId == this.exerciseId &&
          other.liked == this.liked &&
          other.difficult == this.difficult &&
          other.pleasant == this.pleasant &&
          other.useless == this.useless &&
          other.ts == this.ts);
}

class UserFeedbackCompanion extends UpdateCompanion<UserFeedbackData> {
  final Value<int> userId;
  final Value<int> exerciseId;
  final Value<int> liked;
  final Value<int> difficult;
  final Value<int> pleasant;
  final Value<int> useless;
  final Value<int> ts;
  final Value<int> rowid;
  const UserFeedbackCompanion({
    this.userId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.liked = const Value.absent(),
    this.difficult = const Value.absent(),
    this.pleasant = const Value.absent(),
    this.useless = const Value.absent(),
    this.ts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFeedbackCompanion.insert({
    required int userId,
    required int exerciseId,
    required int liked,
    this.difficult = const Value.absent(),
    this.pleasant = const Value.absent(),
    this.useless = const Value.absent(),
    required int ts,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       exerciseId = Value(exerciseId),
       liked = Value(liked),
       ts = Value(ts);
  static Insertable<UserFeedbackData> custom({
    Expression<int>? userId,
    Expression<int>? exerciseId,
    Expression<int>? liked,
    Expression<int>? difficult,
    Expression<int>? pleasant,
    Expression<int>? useless,
    Expression<int>? ts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (liked != null) 'liked': liked,
      if (difficult != null) 'difficult': difficult,
      if (pleasant != null) 'pleasant': pleasant,
      if (useless != null) 'useless': useless,
      if (ts != null) 'ts': ts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFeedbackCompanion copyWith({
    Value<int>? userId,
    Value<int>? exerciseId,
    Value<int>? liked,
    Value<int>? difficult,
    Value<int>? pleasant,
    Value<int>? useless,
    Value<int>? ts,
    Value<int>? rowid,
  }) {
    return UserFeedbackCompanion(
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      liked: liked ?? this.liked,
      difficult: difficult ?? this.difficult,
      pleasant: pleasant ?? this.pleasant,
      useless: useless ?? this.useless,
      ts: ts ?? this.ts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (liked.present) {
      map['liked'] = Variable<int>(liked.value);
    }
    if (difficult.present) {
      map['difficult'] = Variable<int>(difficult.value);
    }
    if (pleasant.present) {
      map['pleasant'] = Variable<int>(pleasant.value);
    }
    if (useless.present) {
      map['useless'] = Variable<int>(useless.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFeedbackCompanion(')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('liked: $liked, ')
          ..write('difficult: $difficult, ')
          ..write('pleasant: $pleasant, ')
          ..write('useless: $useless, ')
          ..write('ts: $ts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionTable extends Session with TableInfo<$SessionTable, SessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _dateTsMeta = const VerificationMeta('dateTs');
  @override
  late final GeneratedColumn<int> dateTs = GeneratedColumn<int>(
    'date_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, dateTs, durationMin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionData> instance, {
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
    if (data.containsKey('date_ts')) {
      context.handle(
        _dateTsMeta,
        dateTs.isAcceptableOrUnknown(data['date_ts']!, _dateTsMeta),
      );
    } else if (isInserting) {
      context.missing(_dateTsMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}user_id'],
          )!,
      dateTs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}date_ts'],
          )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
    );
  }

  @override
  $SessionTable createAlias(String alias) {
    return $SessionTable(attachedDatabase, alias);
  }
}

class SessionData extends DataClass implements Insertable<SessionData> {
  final int id;
  final int userId;
  final int dateTs;
  final int? durationMin;
  const SessionData({
    required this.id,
    required this.userId,
    required this.dateTs,
    this.durationMin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['date_ts'] = Variable<int>(dateTs);
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    return map;
  }

  SessionCompanion toCompanion(bool nullToAbsent) {
    return SessionCompanion(
      id: Value(id),
      userId: Value(userId),
      dateTs: Value(dateTs),
      durationMin:
          durationMin == null && nullToAbsent
              ? const Value.absent()
              : Value(durationMin),
    );
  }

  factory SessionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      dateTs: serializer.fromJson<int>(json['dateTs']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'dateTs': serializer.toJson<int>(dateTs),
      'durationMin': serializer.toJson<int?>(durationMin),
    };
  }

  SessionData copyWith({
    int? id,
    int? userId,
    int? dateTs,
    Value<int?> durationMin = const Value.absent(),
  }) => SessionData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    dateTs: dateTs ?? this.dateTs,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
  );
  SessionData copyWithCompanion(SessionCompanion data) {
    return SessionData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dateTs: data.dateTs.present ? data.dateTs.value : this.dateTs,
      durationMin:
          data.durationMin.present ? data.durationMin.value : this.durationMin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dateTs: $dateTs, ')
          ..write('durationMin: $durationMin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, dateTs, durationMin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dateTs == this.dateTs &&
          other.durationMin == this.durationMin);
}

class SessionCompanion extends UpdateCompanion<SessionData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> dateTs;
  final Value<int?> durationMin;
  const SessionCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dateTs = const Value.absent(),
    this.durationMin = const Value.absent(),
  });
  SessionCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int dateTs,
    this.durationMin = const Value.absent(),
  }) : userId = Value(userId),
       dateTs = Value(dateTs);
  static Insertable<SessionData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? dateTs,
    Expression<int>? durationMin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dateTs != null) 'date_ts': dateTs,
      if (durationMin != null) 'duration_min': durationMin,
    });
  }

  SessionCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? dateTs,
    Value<int?>? durationMin,
  }) {
    return SessionCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateTs: dateTs ?? this.dateTs,
      durationMin: durationMin ?? this.durationMin,
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
    if (dateTs.present) {
      map['date_ts'] = Variable<int>(dateTs.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dateTs: $dateTs, ')
          ..write('durationMin: $durationMin')
          ..write(')'))
        .toString();
  }
}

class $SessionExerciseTable extends SessionExercise
    with TableInfo<$SessionExerciseTable, SessionExerciseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExerciseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loadMeta = const VerificationMeta('load');
  @override
  late final GeneratedColumn<double> load = GeneratedColumn<double>(
    'load',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    exerciseId,
    sets,
    reps,
    load,
    rpe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercise';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExerciseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('load')) {
      context.handle(
        _loadMeta,
        load.isAcceptableOrUnknown(data['load']!, _loadMeta),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, exerciseId};
  @override
  SessionExerciseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExerciseData(
      sessionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}session_id'],
          )!,
      exerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}exercise_id'],
          )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      load: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}load'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
    );
  }

  @override
  $SessionExerciseTable createAlias(String alias) {
    return $SessionExerciseTable(attachedDatabase, alias);
  }
}

class SessionExerciseData extends DataClass
    implements Insertable<SessionExerciseData> {
  final int sessionId;
  final int exerciseId;
  final int? sets;
  final int? reps;
  final double? load;
  final double? rpe;
  const SessionExerciseData({
    required this.sessionId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.load,
    this.rpe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<int>(exerciseId);
    if (!nullToAbsent || sets != null) {
      map['sets'] = Variable<int>(sets);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || load != null) {
      map['load'] = Variable<double>(load);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    return map;
  }

  SessionExerciseCompanion toCompanion(bool nullToAbsent) {
    return SessionExerciseCompanion(
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      sets: sets == null && nullToAbsent ? const Value.absent() : Value(sets),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      load: load == null && nullToAbsent ? const Value.absent() : Value(load),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
    );
  }

  factory SessionExerciseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExerciseData(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      sets: serializer.fromJson<int?>(json['sets']),
      reps: serializer.fromJson<int?>(json['reps']),
      load: serializer.fromJson<double?>(json['load']),
      rpe: serializer.fromJson<double?>(json['rpe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'sets': serializer.toJson<int?>(sets),
      'reps': serializer.toJson<int?>(reps),
      'load': serializer.toJson<double?>(load),
      'rpe': serializer.toJson<double?>(rpe),
    };
  }

  SessionExerciseData copyWith({
    int? sessionId,
    int? exerciseId,
    Value<int?> sets = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<double?> load = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
  }) => SessionExerciseData(
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    sets: sets.present ? sets.value : this.sets,
    reps: reps.present ? reps.value : this.reps,
    load: load.present ? load.value : this.load,
    rpe: rpe.present ? rpe.value : this.rpe,
  );
  SessionExerciseData copyWithCompanion(SessionExerciseCompanion data) {
    return SessionExerciseData(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      sets: data.sets.present ? data.sets.value : this.sets,
      reps: data.reps.present ? data.reps.value : this.reps,
      load: data.load.present ? data.load.value : this.load,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseData(')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('load: $load, ')
          ..write('rpe: $rpe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, exerciseId, sets, reps, load, rpe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseData &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.sets == this.sets &&
          other.reps == this.reps &&
          other.load == this.load &&
          other.rpe == this.rpe);
}

class SessionExerciseCompanion extends UpdateCompanion<SessionExerciseData> {
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int?> sets;
  final Value<int?> reps;
  final Value<double?> load;
  final Value<double?> rpe;
  final Value<int> rowid;
  const SessionExerciseCompanion({
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.load = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExerciseCompanion.insert({
    required int sessionId,
    required int exerciseId,
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.load = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId);
  static Insertable<SessionExerciseData> custom({
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<double>? load,
    Expression<double>? rpe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (load != null) 'load': load,
      if (rpe != null) 'rpe': rpe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionExerciseCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? exerciseId,
    Value<int?>? sets,
    Value<int?>? reps,
    Value<double?>? load,
    Value<double?>? rpe,
    Value<int>? rowid,
  }) {
    return SessionExerciseCompanion(
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      load: load ?? this.load,
      rpe: rpe ?? this.rpe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (load.present) {
      map['load'] = Variable<double>(load.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('load: $load, ')
          ..write('rpe: $rpe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $ExerciseTable exercise = $ExerciseTable(this);
  late final $MuscleTable muscle = $MuscleTable(this);
  late final $ExerciseMuscleTable exerciseMuscle = $ExerciseMuscleTable(this);
  late final $EquipmentTable equipment = $EquipmentTable(this);
  late final $ExerciseEquipmentTable exerciseEquipment =
      $ExerciseEquipmentTable(this);
  late final $AppUserTable appUser = $AppUserTable(this);
  late final $UserFeedbackTable userFeedback = $UserFeedbackTable(this);
  late final $SessionTable session = $SessionTable(this);
  late final $SessionExerciseTable sessionExercise = $SessionExerciseTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercise,
    muscle,
    exerciseMuscle,
    equipment,
    exerciseEquipment,
    appUser,
    userFeedback,
    session,
    sessionExercise,
  ];
}

typedef $$ExerciseTableCreateCompanionBuilder =
    ExerciseCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      required int difficulty,
      Value<double> cardio,
    });
typedef $$ExerciseTableUpdateCompanionBuilder =
    ExerciseCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<int> difficulty,
      Value<double> cardio,
    });

class $$ExerciseTableFilterComposer extends Composer<_$AppDb, $ExerciseTable> {
  $$ExerciseTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cardio => $composableBuilder(
    column: $table.cardio,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseTableOrderingComposer
    extends Composer<_$AppDb, $ExerciseTable> {
  $$ExerciseTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cardio => $composableBuilder(
    column: $table.cardio,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseTableAnnotationComposer
    extends Composer<_$AppDb, $ExerciseTable> {
  $$ExerciseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cardio =>
      $composableBuilder(column: $table.cardio, builder: (column) => column);
}

class $$ExerciseTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExerciseTable,
          ExerciseData,
          $$ExerciseTableFilterComposer,
          $$ExerciseTableOrderingComposer,
          $$ExerciseTableAnnotationComposer,
          $$ExerciseTableCreateCompanionBuilder,
          $$ExerciseTableUpdateCompanionBuilder,
          (ExerciseData, BaseReferences<_$AppDb, $ExerciseTable, ExerciseData>),
          ExerciseData,
          PrefetchHooks Function()
        > {
  $$ExerciseTableTableManager(_$AppDb db, $ExerciseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ExerciseTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ExerciseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ExerciseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<double> cardio = const Value.absent(),
              }) => ExerciseCompanion(
                id: id,
                name: name,
                type: type,
                difficulty: difficulty,
                cardio: cardio,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                required int difficulty,
                Value<double> cardio = const Value.absent(),
              }) => ExerciseCompanion.insert(
                id: id,
                name: name,
                type: type,
                difficulty: difficulty,
                cardio: cardio,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExerciseTable,
      ExerciseData,
      $$ExerciseTableFilterComposer,
      $$ExerciseTableOrderingComposer,
      $$ExerciseTableAnnotationComposer,
      $$ExerciseTableCreateCompanionBuilder,
      $$ExerciseTableUpdateCompanionBuilder,
      (ExerciseData, BaseReferences<_$AppDb, $ExerciseTable, ExerciseData>),
      ExerciseData,
      PrefetchHooks Function()
    >;
typedef $$MuscleTableCreateCompanionBuilder =
    MuscleCompanion Function({Value<int> id, required String name});
typedef $$MuscleTableUpdateCompanionBuilder =
    MuscleCompanion Function({Value<int> id, Value<String> name});

class $$MuscleTableFilterComposer extends Composer<_$AppDb, $MuscleTable> {
  $$MuscleTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MuscleTableOrderingComposer extends Composer<_$AppDb, $MuscleTable> {
  $$MuscleTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MuscleTableAnnotationComposer extends Composer<_$AppDb, $MuscleTable> {
  $$MuscleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$MuscleTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MuscleTable,
          MuscleData,
          $$MuscleTableFilterComposer,
          $$MuscleTableOrderingComposer,
          $$MuscleTableAnnotationComposer,
          $$MuscleTableCreateCompanionBuilder,
          $$MuscleTableUpdateCompanionBuilder,
          (MuscleData, BaseReferences<_$AppDb, $MuscleTable, MuscleData>),
          MuscleData,
          PrefetchHooks Function()
        > {
  $$MuscleTableTableManager(_$AppDb db, $MuscleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MuscleTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MuscleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MuscleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => MuscleCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  MuscleCompanion.insert(id: id, name: name),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MuscleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MuscleTable,
      MuscleData,
      $$MuscleTableFilterComposer,
      $$MuscleTableOrderingComposer,
      $$MuscleTableAnnotationComposer,
      $$MuscleTableCreateCompanionBuilder,
      $$MuscleTableUpdateCompanionBuilder,
      (MuscleData, BaseReferences<_$AppDb, $MuscleTable, MuscleData>),
      MuscleData,
      PrefetchHooks Function()
    >;
typedef $$ExerciseMuscleTableCreateCompanionBuilder =
    ExerciseMuscleCompanion Function({
      required int exerciseId,
      required int muscleId,
      required double weight,
      Value<int> rowid,
    });
typedef $$ExerciseMuscleTableUpdateCompanionBuilder =
    ExerciseMuscleCompanion Function({
      Value<int> exerciseId,
      Value<int> muscleId,
      Value<double> weight,
      Value<int> rowid,
    });

class $$ExerciseMuscleTableFilterComposer
    extends Composer<_$AppDb, $ExerciseMuscleTable> {
  $$ExerciseMuscleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muscleId => $composableBuilder(
    column: $table.muscleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseMuscleTableOrderingComposer
    extends Composer<_$AppDb, $ExerciseMuscleTable> {
  $$ExerciseMuscleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muscleId => $composableBuilder(
    column: $table.muscleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseMuscleTableAnnotationComposer
    extends Composer<_$AppDb, $ExerciseMuscleTable> {
  $$ExerciseMuscleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get muscleId =>
      $composableBuilder(column: $table.muscleId, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);
}

class $$ExerciseMuscleTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExerciseMuscleTable,
          ExerciseMuscleData,
          $$ExerciseMuscleTableFilterComposer,
          $$ExerciseMuscleTableOrderingComposer,
          $$ExerciseMuscleTableAnnotationComposer,
          $$ExerciseMuscleTableCreateCompanionBuilder,
          $$ExerciseMuscleTableUpdateCompanionBuilder,
          (
            ExerciseMuscleData,
            BaseReferences<_$AppDb, $ExerciseMuscleTable, ExerciseMuscleData>,
          ),
          ExerciseMuscleData,
          PrefetchHooks Function()
        > {
  $$ExerciseMuscleTableTableManager(_$AppDb db, $ExerciseMuscleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ExerciseMuscleTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ExerciseMuscleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ExerciseMuscleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> exerciseId = const Value.absent(),
                Value<int> muscleId = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMuscleCompanion(
                exerciseId: exerciseId,
                muscleId: muscleId,
                weight: weight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int exerciseId,
                required int muscleId,
                required double weight,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMuscleCompanion.insert(
                exerciseId: exerciseId,
                muscleId: muscleId,
                weight: weight,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseMuscleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExerciseMuscleTable,
      ExerciseMuscleData,
      $$ExerciseMuscleTableFilterComposer,
      $$ExerciseMuscleTableOrderingComposer,
      $$ExerciseMuscleTableAnnotationComposer,
      $$ExerciseMuscleTableCreateCompanionBuilder,
      $$ExerciseMuscleTableUpdateCompanionBuilder,
      (
        ExerciseMuscleData,
        BaseReferences<_$AppDb, $ExerciseMuscleTable, ExerciseMuscleData>,
      ),
      ExerciseMuscleData,
      PrefetchHooks Function()
    >;
typedef $$EquipmentTableCreateCompanionBuilder =
    EquipmentCompanion Function({Value<int> id, required String name});
typedef $$EquipmentTableUpdateCompanionBuilder =
    EquipmentCompanion Function({Value<int> id, Value<String> name});

class $$EquipmentTableFilterComposer
    extends Composer<_$AppDb, $EquipmentTable> {
  $$EquipmentTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EquipmentTableOrderingComposer
    extends Composer<_$AppDb, $EquipmentTable> {
  $$EquipmentTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentTableAnnotationComposer
    extends Composer<_$AppDb, $EquipmentTable> {
  $$EquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$EquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $EquipmentTable,
          EquipmentData,
          $$EquipmentTableFilterComposer,
          $$EquipmentTableOrderingComposer,
          $$EquipmentTableAnnotationComposer,
          $$EquipmentTableCreateCompanionBuilder,
          $$EquipmentTableUpdateCompanionBuilder,
          (
            EquipmentData,
            BaseReferences<_$AppDb, $EquipmentTable, EquipmentData>,
          ),
          EquipmentData,
          PrefetchHooks Function()
        > {
  $$EquipmentTableTableManager(_$AppDb db, $EquipmentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$EquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$EquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$EquipmentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => EquipmentCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  EquipmentCompanion.insert(id: id, name: name),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $EquipmentTable,
      EquipmentData,
      $$EquipmentTableFilterComposer,
      $$EquipmentTableOrderingComposer,
      $$EquipmentTableAnnotationComposer,
      $$EquipmentTableCreateCompanionBuilder,
      $$EquipmentTableUpdateCompanionBuilder,
      (EquipmentData, BaseReferences<_$AppDb, $EquipmentTable, EquipmentData>),
      EquipmentData,
      PrefetchHooks Function()
    >;
typedef $$ExerciseEquipmentTableCreateCompanionBuilder =
    ExerciseEquipmentCompanion Function({
      required int exerciseId,
      required int equipmentId,
      Value<int> rowid,
    });
typedef $$ExerciseEquipmentTableUpdateCompanionBuilder =
    ExerciseEquipmentCompanion Function({
      Value<int> exerciseId,
      Value<int> equipmentId,
      Value<int> rowid,
    });

class $$ExerciseEquipmentTableFilterComposer
    extends Composer<_$AppDb, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get equipmentId => $composableBuilder(
    column: $table.equipmentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseEquipmentTableOrderingComposer
    extends Composer<_$AppDb, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get equipmentId => $composableBuilder(
    column: $table.equipmentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseEquipmentTableAnnotationComposer
    extends Composer<_$AppDb, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get equipmentId => $composableBuilder(
    column: $table.equipmentId,
    builder: (column) => column,
  );
}

class $$ExerciseEquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExerciseEquipmentTable,
          ExerciseEquipmentData,
          $$ExerciseEquipmentTableFilterComposer,
          $$ExerciseEquipmentTableOrderingComposer,
          $$ExerciseEquipmentTableAnnotationComposer,
          $$ExerciseEquipmentTableCreateCompanionBuilder,
          $$ExerciseEquipmentTableUpdateCompanionBuilder,
          (
            ExerciseEquipmentData,
            BaseReferences<
              _$AppDb,
              $ExerciseEquipmentTable,
              ExerciseEquipmentData
            >,
          ),
          ExerciseEquipmentData,
          PrefetchHooks Function()
        > {
  $$ExerciseEquipmentTableTableManager(
    _$AppDb db,
    $ExerciseEquipmentTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ExerciseEquipmentTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ExerciseEquipmentTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ExerciseEquipmentTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> exerciseId = const Value.absent(),
                Value<int> equipmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentCompanion(
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int exerciseId,
                required int equipmentId,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentCompanion.insert(
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseEquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExerciseEquipmentTable,
      ExerciseEquipmentData,
      $$ExerciseEquipmentTableFilterComposer,
      $$ExerciseEquipmentTableOrderingComposer,
      $$ExerciseEquipmentTableAnnotationComposer,
      $$ExerciseEquipmentTableCreateCompanionBuilder,
      $$ExerciseEquipmentTableUpdateCompanionBuilder,
      (
        ExerciseEquipmentData,
        BaseReferences<_$AppDb, $ExerciseEquipmentTable, ExerciseEquipmentData>,
      ),
      ExerciseEquipmentData,
      PrefetchHooks Function()
    >;
typedef $$AppUserTableCreateCompanionBuilder =
    AppUserCompanion Function({Value<int> id, Value<String?> name});
typedef $$AppUserTableUpdateCompanionBuilder =
    AppUserCompanion Function({Value<int> id, Value<String?> name});

class $$AppUserTableFilterComposer extends Composer<_$AppDb, $AppUserTable> {
  $$AppUserTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUserTableOrderingComposer extends Composer<_$AppDb, $AppUserTable> {
  $$AppUserTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUserTableAnnotationComposer
    extends Composer<_$AppDb, $AppUserTable> {
  $$AppUserTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$AppUserTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $AppUserTable,
          AppUserData,
          $$AppUserTableFilterComposer,
          $$AppUserTableOrderingComposer,
          $$AppUserTableAnnotationComposer,
          $$AppUserTableCreateCompanionBuilder,
          $$AppUserTableUpdateCompanionBuilder,
          (AppUserData, BaseReferences<_$AppDb, $AppUserTable, AppUserData>),
          AppUserData,
          PrefetchHooks Function()
        > {
  $$AppUserTableTableManager(_$AppDb db, $AppUserTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AppUserTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AppUserTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AppUserTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
              }) => AppUserCompanion(id: id, name: name),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
              }) => AppUserCompanion.insert(id: id, name: name),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUserTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $AppUserTable,
      AppUserData,
      $$AppUserTableFilterComposer,
      $$AppUserTableOrderingComposer,
      $$AppUserTableAnnotationComposer,
      $$AppUserTableCreateCompanionBuilder,
      $$AppUserTableUpdateCompanionBuilder,
      (AppUserData, BaseReferences<_$AppDb, $AppUserTable, AppUserData>),
      AppUserData,
      PrefetchHooks Function()
    >;
typedef $$UserFeedbackTableCreateCompanionBuilder =
    UserFeedbackCompanion Function({
      required int userId,
      required int exerciseId,
      required int liked,
      Value<int> difficult,
      Value<int> pleasant,
      Value<int> useless,
      required int ts,
      Value<int> rowid,
    });
typedef $$UserFeedbackTableUpdateCompanionBuilder =
    UserFeedbackCompanion Function({
      Value<int> userId,
      Value<int> exerciseId,
      Value<int> liked,
      Value<int> difficult,
      Value<int> pleasant,
      Value<int> useless,
      Value<int> ts,
      Value<int> rowid,
    });

class $$UserFeedbackTableFilterComposer
    extends Composer<_$AppDb, $UserFeedbackTable> {
  $$UserFeedbackTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get liked => $composableBuilder(
    column: $table.liked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficult => $composableBuilder(
    column: $table.difficult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pleasant => $composableBuilder(
    column: $table.pleasant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get useless => $composableBuilder(
    column: $table.useless,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserFeedbackTableOrderingComposer
    extends Composer<_$AppDb, $UserFeedbackTable> {
  $$UserFeedbackTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get liked => $composableBuilder(
    column: $table.liked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficult => $composableBuilder(
    column: $table.difficult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pleasant => $composableBuilder(
    column: $table.pleasant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get useless => $composableBuilder(
    column: $table.useless,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserFeedbackTableAnnotationComposer
    extends Composer<_$AppDb, $UserFeedbackTable> {
  $$UserFeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get liked =>
      $composableBuilder(column: $table.liked, builder: (column) => column);

  GeneratedColumn<int> get difficult =>
      $composableBuilder(column: $table.difficult, builder: (column) => column);

  GeneratedColumn<int> get pleasant =>
      $composableBuilder(column: $table.pleasant, builder: (column) => column);

  GeneratedColumn<int> get useless =>
      $composableBuilder(column: $table.useless, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);
}

class $$UserFeedbackTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserFeedbackTable,
          UserFeedbackData,
          $$UserFeedbackTableFilterComposer,
          $$UserFeedbackTableOrderingComposer,
          $$UserFeedbackTableAnnotationComposer,
          $$UserFeedbackTableCreateCompanionBuilder,
          $$UserFeedbackTableUpdateCompanionBuilder,
          (
            UserFeedbackData,
            BaseReferences<_$AppDb, $UserFeedbackTable, UserFeedbackData>,
          ),
          UserFeedbackData,
          PrefetchHooks Function()
        > {
  $$UserFeedbackTableTableManager(_$AppDb db, $UserFeedbackTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserFeedbackTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UserFeedbackTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$UserFeedbackTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> liked = const Value.absent(),
                Value<int> difficult = const Value.absent(),
                Value<int> pleasant = const Value.absent(),
                Value<int> useless = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFeedbackCompanion(
                userId: userId,
                exerciseId: exerciseId,
                liked: liked,
                difficult: difficult,
                pleasant: pleasant,
                useless: useless,
                ts: ts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required int exerciseId,
                required int liked,
                Value<int> difficult = const Value.absent(),
                Value<int> pleasant = const Value.absent(),
                Value<int> useless = const Value.absent(),
                required int ts,
                Value<int> rowid = const Value.absent(),
              }) => UserFeedbackCompanion.insert(
                userId: userId,
                exerciseId: exerciseId,
                liked: liked,
                difficult: difficult,
                pleasant: pleasant,
                useless: useless,
                ts: ts,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserFeedbackTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserFeedbackTable,
      UserFeedbackData,
      $$UserFeedbackTableFilterComposer,
      $$UserFeedbackTableOrderingComposer,
      $$UserFeedbackTableAnnotationComposer,
      $$UserFeedbackTableCreateCompanionBuilder,
      $$UserFeedbackTableUpdateCompanionBuilder,
      (
        UserFeedbackData,
        BaseReferences<_$AppDb, $UserFeedbackTable, UserFeedbackData>,
      ),
      UserFeedbackData,
      PrefetchHooks Function()
    >;
typedef $$SessionTableCreateCompanionBuilder =
    SessionCompanion Function({
      Value<int> id,
      required int userId,
      required int dateTs,
      Value<int?> durationMin,
    });
typedef $$SessionTableUpdateCompanionBuilder =
    SessionCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> dateTs,
      Value<int?> durationMin,
    });

class $$SessionTableFilterComposer extends Composer<_$AppDb, $SessionTable> {
  $$SessionTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateTs => $composableBuilder(
    column: $table.dateTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionTableOrderingComposer extends Composer<_$AppDb, $SessionTable> {
  $$SessionTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateTs => $composableBuilder(
    column: $table.dateTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionTableAnnotationComposer
    extends Composer<_$AppDb, $SessionTable> {
  $$SessionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get dateTs =>
      $composableBuilder(column: $table.dateTs, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );
}

class $$SessionTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SessionTable,
          SessionData,
          $$SessionTableFilterComposer,
          $$SessionTableOrderingComposer,
          $$SessionTableAnnotationComposer,
          $$SessionTableCreateCompanionBuilder,
          $$SessionTableUpdateCompanionBuilder,
          (SessionData, BaseReferences<_$AppDb, $SessionTable, SessionData>),
          SessionData,
          PrefetchHooks Function()
        > {
  $$SessionTableTableManager(_$AppDb db, $SessionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SessionTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SessionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SessionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> dateTs = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
              }) => SessionCompanion(
                id: id,
                userId: userId,
                dateTs: dateTs,
                durationMin: durationMin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required int dateTs,
                Value<int?> durationMin = const Value.absent(),
              }) => SessionCompanion.insert(
                id: id,
                userId: userId,
                dateTs: dateTs,
                durationMin: durationMin,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SessionTable,
      SessionData,
      $$SessionTableFilterComposer,
      $$SessionTableOrderingComposer,
      $$SessionTableAnnotationComposer,
      $$SessionTableCreateCompanionBuilder,
      $$SessionTableUpdateCompanionBuilder,
      (SessionData, BaseReferences<_$AppDb, $SessionTable, SessionData>),
      SessionData,
      PrefetchHooks Function()
    >;
typedef $$SessionExerciseTableCreateCompanionBuilder =
    SessionExerciseCompanion Function({
      required int sessionId,
      required int exerciseId,
      Value<int?> sets,
      Value<int?> reps,
      Value<double?> load,
      Value<double?> rpe,
      Value<int> rowid,
    });
typedef $$SessionExerciseTableUpdateCompanionBuilder =
    SessionExerciseCompanion Function({
      Value<int> sessionId,
      Value<int> exerciseId,
      Value<int?> sets,
      Value<int?> reps,
      Value<double?> load,
      Value<double?> rpe,
      Value<int> rowid,
    });

class $$SessionExerciseTableFilterComposer
    extends Composer<_$AppDb, $SessionExerciseTable> {
  $$SessionExerciseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get load => $composableBuilder(
    column: $table.load,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionExerciseTableOrderingComposer
    extends Composer<_$AppDb, $SessionExerciseTable> {
  $$SessionExerciseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get load => $composableBuilder(
    column: $table.load,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionExerciseTableAnnotationComposer
    extends Composer<_$AppDb, $SessionExerciseTable> {
  $$SessionExerciseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get load =>
      $composableBuilder(column: $table.load, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);
}

class $$SessionExerciseTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SessionExerciseTable,
          SessionExerciseData,
          $$SessionExerciseTableFilterComposer,
          $$SessionExerciseTableOrderingComposer,
          $$SessionExerciseTableAnnotationComposer,
          $$SessionExerciseTableCreateCompanionBuilder,
          $$SessionExerciseTableUpdateCompanionBuilder,
          (
            SessionExerciseData,
            BaseReferences<_$AppDb, $SessionExerciseTable, SessionExerciseData>,
          ),
          SessionExerciseData,
          PrefetchHooks Function()
        > {
  $$SessionExerciseTableTableManager(_$AppDb db, $SessionExerciseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$SessionExerciseTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SessionExerciseTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$SessionExerciseTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sessionId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int?> sets = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> load = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExerciseCompanion(
                sessionId: sessionId,
                exerciseId: exerciseId,
                sets: sets,
                reps: reps,
                load: load,
                rpe: rpe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sessionId,
                required int exerciseId,
                Value<int?> sets = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> load = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExerciseCompanion.insert(
                sessionId: sessionId,
                exerciseId: exerciseId,
                sets: sets,
                reps: reps,
                load: load,
                rpe: rpe,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionExerciseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SessionExerciseTable,
      SessionExerciseData,
      $$SessionExerciseTableFilterComposer,
      $$SessionExerciseTableOrderingComposer,
      $$SessionExerciseTableAnnotationComposer,
      $$SessionExerciseTableCreateCompanionBuilder,
      $$SessionExerciseTableUpdateCompanionBuilder,
      (
        SessionExerciseData,
        BaseReferences<_$AppDb, $SessionExerciseTable, SessionExerciseData>,
      ),
      SessionExerciseData,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$ExerciseTableTableManager get exercise =>
      $$ExerciseTableTableManager(_db, _db.exercise);
  $$MuscleTableTableManager get muscle =>
      $$MuscleTableTableManager(_db, _db.muscle);
  $$ExerciseMuscleTableTableManager get exerciseMuscle =>
      $$ExerciseMuscleTableTableManager(_db, _db.exerciseMuscle);
  $$EquipmentTableTableManager get equipment =>
      $$EquipmentTableTableManager(_db, _db.equipment);
  $$ExerciseEquipmentTableTableManager get exerciseEquipment =>
      $$ExerciseEquipmentTableTableManager(_db, _db.exerciseEquipment);
  $$AppUserTableTableManager get appUser =>
      $$AppUserTableTableManager(_db, _db.appUser);
  $$UserFeedbackTableTableManager get userFeedback =>
      $$UserFeedbackTableTableManager(_db, _db.userFeedback);
  $$SessionTableTableManager get session =>
      $$SessionTableTableManager(_db, _db.session);
  $$SessionExerciseTableTableManager get sessionExercise =>
      $$SessionExerciseTableTableManager(_db, _db.sessionExercise);
}
