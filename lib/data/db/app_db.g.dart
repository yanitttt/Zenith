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
  @override
  late final GeneratedColumnWithTypeConverter<String, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<String>($ExerciseTable.$convertertype);
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    check: () => ComparableExpr(difficulty).isBetweenValues(1, 5),
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
      type: $ExerciseTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
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

  static TypeConverter<String, String> $convertertype = _convType;
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
    {
      map['type'] = Variable<String>($ExerciseTable.$convertertype.toSql(type));
    }
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
      map['type'] = Variable<String>(
        $ExerciseTable.$convertertype.toSql(type.value),
      );
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
    $customConstraints: 'NOT NULL UNIQUE',
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
    $customConstraints: 'NOT NULL UNIQUE',
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

class $ObjectiveTable extends Objective
    with TableInfo<$ObjectiveTable, ObjectiveData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjectiveTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
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
  List<GeneratedColumn> get $columns => [id, code, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'objective';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObjectiveData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObjectiveData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObjectiveData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      code:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}code'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
    );
  }

  @override
  $ObjectiveTable createAlias(String alias) {
    return $ObjectiveTable(attachedDatabase, alias);
  }
}

class ObjectiveData extends DataClass implements Insertable<ObjectiveData> {
  final int id;
  final String code;
  final String name;
  const ObjectiveData({
    required this.id,
    required this.code,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    return map;
  }

  ObjectiveCompanion toCompanion(bool nullToAbsent) {
    return ObjectiveCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
    );
  }

  factory ObjectiveData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObjectiveData(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
    };
  }

  ObjectiveData copyWith({int? id, String? code, String? name}) =>
      ObjectiveData(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
      );
  ObjectiveData copyWithCompanion(ObjectiveCompanion data) {
    return ObjectiveData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObjectiveData(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObjectiveData &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name);
}

class ObjectiveCompanion extends UpdateCompanion<ObjectiveData> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  const ObjectiveCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
  });
  ObjectiveCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
  }) : code = Value(code),
       name = Value(name);
  static Insertable<ObjectiveData> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
    });
  }

  ObjectiveCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? name,
  }) {
    return ObjectiveCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjectiveCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TrainingModalityTable extends TrainingModality
    with TableInfo<$TrainingModalityTable, TrainingModalityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingModalityTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _objectiveIdMeta = const VerificationMeta(
    'objectiveId',
  );
  @override
  late final GeneratedColumn<int> objectiveId = GeneratedColumn<int>(
    'objective_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objective (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, String> level =
      GeneratedColumn<String>(
        'level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<String>($TrainingModalityTable.$converterlevel);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repMinMeta = const VerificationMeta('repMin');
  @override
  late final GeneratedColumn<int> repMin = GeneratedColumn<int>(
    'rep_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repMaxMeta = const VerificationMeta('repMax');
  @override
  late final GeneratedColumn<int> repMax = GeneratedColumn<int>(
    'rep_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setMinMeta = const VerificationMeta('setMin');
  @override
  late final GeneratedColumn<int> setMin = GeneratedColumn<int>(
    'set_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setMaxMeta = const VerificationMeta('setMax');
  @override
  late final GeneratedColumn<int> setMax = GeneratedColumn<int>(
    'set_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restMinSecMeta = const VerificationMeta(
    'restMinSec',
  );
  @override
  late final GeneratedColumn<int> restMinSec = GeneratedColumn<int>(
    'rest_min_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restMaxSecMeta = const VerificationMeta(
    'restMaxSec',
  );
  @override
  late final GeneratedColumn<int> restMaxSec = GeneratedColumn<int>(
    'rest_max_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMinMeta = const VerificationMeta('rpeMin');
  @override
  late final GeneratedColumn<double> rpeMin = GeneratedColumn<double>(
    'rpe_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMaxMeta = const VerificationMeta('rpeMax');
  @override
  late final GeneratedColumn<double> rpeMax = GeneratedColumn<double>(
    'rpe_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    objectiveId,
    level,
    name,
    repMin,
    repMax,
    setMin,
    setMax,
    restMinSec,
    restMaxSec,
    rpeMin,
    rpeMax,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_modality';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingModalityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('objective_id')) {
      context.handle(
        _objectiveIdMeta,
        objectiveId.isAcceptableOrUnknown(
          data['objective_id']!,
          _objectiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_objectiveIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rep_min')) {
      context.handle(
        _repMinMeta,
        repMin.isAcceptableOrUnknown(data['rep_min']!, _repMinMeta),
      );
    }
    if (data.containsKey('rep_max')) {
      context.handle(
        _repMaxMeta,
        repMax.isAcceptableOrUnknown(data['rep_max']!, _repMaxMeta),
      );
    }
    if (data.containsKey('set_min')) {
      context.handle(
        _setMinMeta,
        setMin.isAcceptableOrUnknown(data['set_min']!, _setMinMeta),
      );
    }
    if (data.containsKey('set_max')) {
      context.handle(
        _setMaxMeta,
        setMax.isAcceptableOrUnknown(data['set_max']!, _setMaxMeta),
      );
    }
    if (data.containsKey('rest_min_sec')) {
      context.handle(
        _restMinSecMeta,
        restMinSec.isAcceptableOrUnknown(
          data['rest_min_sec']!,
          _restMinSecMeta,
        ),
      );
    }
    if (data.containsKey('rest_max_sec')) {
      context.handle(
        _restMaxSecMeta,
        restMaxSec.isAcceptableOrUnknown(
          data['rest_max_sec']!,
          _restMaxSecMeta,
        ),
      );
    }
    if (data.containsKey('rpe_min')) {
      context.handle(
        _rpeMinMeta,
        rpeMin.isAcceptableOrUnknown(data['rpe_min']!, _rpeMinMeta),
      );
    }
    if (data.containsKey('rpe_max')) {
      context.handle(
        _rpeMaxMeta,
        rpeMax.isAcceptableOrUnknown(data['rpe_max']!, _rpeMaxMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingModalityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingModalityData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      objectiveId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}objective_id'],
          )!,
      level: $TrainingModalityTable.$converterlevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}level'],
        )!,
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      repMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_min'],
      ),
      repMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_max'],
      ),
      setMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_min'],
      ),
      setMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_max'],
      ),
      restMinSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_min_sec'],
      ),
      restMaxSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_max_sec'],
      ),
      rpeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe_min'],
      ),
      rpeMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe_max'],
      ),
    );
  }

  @override
  $TrainingModalityTable createAlias(String alias) {
    return $TrainingModalityTable(attachedDatabase, alias);
  }

  static TypeConverter<String, String> $converterlevel = _convLevel;
}

class TrainingModalityData extends DataClass
    implements Insertable<TrainingModalityData> {
  final int id;
  final int objectiveId;
  final String level;
  final String name;
  final int? repMin;
  final int? repMax;
  final int? setMin;
  final int? setMax;
  final int? restMinSec;
  final int? restMaxSec;
  final double? rpeMin;
  final double? rpeMax;
  const TrainingModalityData({
    required this.id,
    required this.objectiveId,
    required this.level,
    required this.name,
    this.repMin,
    this.repMax,
    this.setMin,
    this.setMax,
    this.restMinSec,
    this.restMaxSec,
    this.rpeMin,
    this.rpeMax,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['objective_id'] = Variable<int>(objectiveId);
    {
      map['level'] = Variable<String>(
        $TrainingModalityTable.$converterlevel.toSql(level),
      );
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || repMin != null) {
      map['rep_min'] = Variable<int>(repMin);
    }
    if (!nullToAbsent || repMax != null) {
      map['rep_max'] = Variable<int>(repMax);
    }
    if (!nullToAbsent || setMin != null) {
      map['set_min'] = Variable<int>(setMin);
    }
    if (!nullToAbsent || setMax != null) {
      map['set_max'] = Variable<int>(setMax);
    }
    if (!nullToAbsent || restMinSec != null) {
      map['rest_min_sec'] = Variable<int>(restMinSec);
    }
    if (!nullToAbsent || restMaxSec != null) {
      map['rest_max_sec'] = Variable<int>(restMaxSec);
    }
    if (!nullToAbsent || rpeMin != null) {
      map['rpe_min'] = Variable<double>(rpeMin);
    }
    if (!nullToAbsent || rpeMax != null) {
      map['rpe_max'] = Variable<double>(rpeMax);
    }
    return map;
  }

  TrainingModalityCompanion toCompanion(bool nullToAbsent) {
    return TrainingModalityCompanion(
      id: Value(id),
      objectiveId: Value(objectiveId),
      level: Value(level),
      name: Value(name),
      repMin:
          repMin == null && nullToAbsent ? const Value.absent() : Value(repMin),
      repMax:
          repMax == null && nullToAbsent ? const Value.absent() : Value(repMax),
      setMin:
          setMin == null && nullToAbsent ? const Value.absent() : Value(setMin),
      setMax:
          setMax == null && nullToAbsent ? const Value.absent() : Value(setMax),
      restMinSec:
          restMinSec == null && nullToAbsent
              ? const Value.absent()
              : Value(restMinSec),
      restMaxSec:
          restMaxSec == null && nullToAbsent
              ? const Value.absent()
              : Value(restMaxSec),
      rpeMin:
          rpeMin == null && nullToAbsent ? const Value.absent() : Value(rpeMin),
      rpeMax:
          rpeMax == null && nullToAbsent ? const Value.absent() : Value(rpeMax),
    );
  }

  factory TrainingModalityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingModalityData(
      id: serializer.fromJson<int>(json['id']),
      objectiveId: serializer.fromJson<int>(json['objectiveId']),
      level: serializer.fromJson<String>(json['level']),
      name: serializer.fromJson<String>(json['name']),
      repMin: serializer.fromJson<int?>(json['repMin']),
      repMax: serializer.fromJson<int?>(json['repMax']),
      setMin: serializer.fromJson<int?>(json['setMin']),
      setMax: serializer.fromJson<int?>(json['setMax']),
      restMinSec: serializer.fromJson<int?>(json['restMinSec']),
      restMaxSec: serializer.fromJson<int?>(json['restMaxSec']),
      rpeMin: serializer.fromJson<double?>(json['rpeMin']),
      rpeMax: serializer.fromJson<double?>(json['rpeMax']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'objectiveId': serializer.toJson<int>(objectiveId),
      'level': serializer.toJson<String>(level),
      'name': serializer.toJson<String>(name),
      'repMin': serializer.toJson<int?>(repMin),
      'repMax': serializer.toJson<int?>(repMax),
      'setMin': serializer.toJson<int?>(setMin),
      'setMax': serializer.toJson<int?>(setMax),
      'restMinSec': serializer.toJson<int?>(restMinSec),
      'restMaxSec': serializer.toJson<int?>(restMaxSec),
      'rpeMin': serializer.toJson<double?>(rpeMin),
      'rpeMax': serializer.toJson<double?>(rpeMax),
    };
  }

  TrainingModalityData copyWith({
    int? id,
    int? objectiveId,
    String? level,
    String? name,
    Value<int?> repMin = const Value.absent(),
    Value<int?> repMax = const Value.absent(),
    Value<int?> setMin = const Value.absent(),
    Value<int?> setMax = const Value.absent(),
    Value<int?> restMinSec = const Value.absent(),
    Value<int?> restMaxSec = const Value.absent(),
    Value<double?> rpeMin = const Value.absent(),
    Value<double?> rpeMax = const Value.absent(),
  }) => TrainingModalityData(
    id: id ?? this.id,
    objectiveId: objectiveId ?? this.objectiveId,
    level: level ?? this.level,
    name: name ?? this.name,
    repMin: repMin.present ? repMin.value : this.repMin,
    repMax: repMax.present ? repMax.value : this.repMax,
    setMin: setMin.present ? setMin.value : this.setMin,
    setMax: setMax.present ? setMax.value : this.setMax,
    restMinSec: restMinSec.present ? restMinSec.value : this.restMinSec,
    restMaxSec: restMaxSec.present ? restMaxSec.value : this.restMaxSec,
    rpeMin: rpeMin.present ? rpeMin.value : this.rpeMin,
    rpeMax: rpeMax.present ? rpeMax.value : this.rpeMax,
  );
  TrainingModalityData copyWithCompanion(TrainingModalityCompanion data) {
    return TrainingModalityData(
      id: data.id.present ? data.id.value : this.id,
      objectiveId:
          data.objectiveId.present ? data.objectiveId.value : this.objectiveId,
      level: data.level.present ? data.level.value : this.level,
      name: data.name.present ? data.name.value : this.name,
      repMin: data.repMin.present ? data.repMin.value : this.repMin,
      repMax: data.repMax.present ? data.repMax.value : this.repMax,
      setMin: data.setMin.present ? data.setMin.value : this.setMin,
      setMax: data.setMax.present ? data.setMax.value : this.setMax,
      restMinSec:
          data.restMinSec.present ? data.restMinSec.value : this.restMinSec,
      restMaxSec:
          data.restMaxSec.present ? data.restMaxSec.value : this.restMaxSec,
      rpeMin: data.rpeMin.present ? data.rpeMin.value : this.rpeMin,
      rpeMax: data.rpeMax.present ? data.rpeMax.value : this.rpeMax,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingModalityData(')
          ..write('id: $id, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('setMin: $setMin, ')
          ..write('setMax: $setMax, ')
          ..write('restMinSec: $restMinSec, ')
          ..write('restMaxSec: $restMaxSec, ')
          ..write('rpeMin: $rpeMin, ')
          ..write('rpeMax: $rpeMax')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    objectiveId,
    level,
    name,
    repMin,
    repMax,
    setMin,
    setMax,
    restMinSec,
    restMaxSec,
    rpeMin,
    rpeMax,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingModalityData &&
          other.id == this.id &&
          other.objectiveId == this.objectiveId &&
          other.level == this.level &&
          other.name == this.name &&
          other.repMin == this.repMin &&
          other.repMax == this.repMax &&
          other.setMin == this.setMin &&
          other.setMax == this.setMax &&
          other.restMinSec == this.restMinSec &&
          other.restMaxSec == this.restMaxSec &&
          other.rpeMin == this.rpeMin &&
          other.rpeMax == this.rpeMax);
}

class TrainingModalityCompanion extends UpdateCompanion<TrainingModalityData> {
  final Value<int> id;
  final Value<int> objectiveId;
  final Value<String> level;
  final Value<String> name;
  final Value<int?> repMin;
  final Value<int?> repMax;
  final Value<int?> setMin;
  final Value<int?> setMax;
  final Value<int?> restMinSec;
  final Value<int?> restMaxSec;
  final Value<double?> rpeMin;
  final Value<double?> rpeMax;
  const TrainingModalityCompanion({
    this.id = const Value.absent(),
    this.objectiveId = const Value.absent(),
    this.level = const Value.absent(),
    this.name = const Value.absent(),
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
    this.setMin = const Value.absent(),
    this.setMax = const Value.absent(),
    this.restMinSec = const Value.absent(),
    this.restMaxSec = const Value.absent(),
    this.rpeMin = const Value.absent(),
    this.rpeMax = const Value.absent(),
  });
  TrainingModalityCompanion.insert({
    this.id = const Value.absent(),
    required int objectiveId,
    required String level,
    required String name,
    this.repMin = const Value.absent(),
    this.repMax = const Value.absent(),
    this.setMin = const Value.absent(),
    this.setMax = const Value.absent(),
    this.restMinSec = const Value.absent(),
    this.restMaxSec = const Value.absent(),
    this.rpeMin = const Value.absent(),
    this.rpeMax = const Value.absent(),
  }) : objectiveId = Value(objectiveId),
       level = Value(level),
       name = Value(name);
  static Insertable<TrainingModalityData> custom({
    Expression<int>? id,
    Expression<int>? objectiveId,
    Expression<String>? level,
    Expression<String>? name,
    Expression<int>? repMin,
    Expression<int>? repMax,
    Expression<int>? setMin,
    Expression<int>? setMax,
    Expression<int>? restMinSec,
    Expression<int>? restMaxSec,
    Expression<double>? rpeMin,
    Expression<double>? rpeMax,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (objectiveId != null) 'objective_id': objectiveId,
      if (level != null) 'level': level,
      if (name != null) 'name': name,
      if (repMin != null) 'rep_min': repMin,
      if (repMax != null) 'rep_max': repMax,
      if (setMin != null) 'set_min': setMin,
      if (setMax != null) 'set_max': setMax,
      if (restMinSec != null) 'rest_min_sec': restMinSec,
      if (restMaxSec != null) 'rest_max_sec': restMaxSec,
      if (rpeMin != null) 'rpe_min': rpeMin,
      if (rpeMax != null) 'rpe_max': rpeMax,
    });
  }

  TrainingModalityCompanion copyWith({
    Value<int>? id,
    Value<int>? objectiveId,
    Value<String>? level,
    Value<String>? name,
    Value<int?>? repMin,
    Value<int?>? repMax,
    Value<int?>? setMin,
    Value<int?>? setMax,
    Value<int?>? restMinSec,
    Value<int?>? restMaxSec,
    Value<double?>? rpeMin,
    Value<double?>? rpeMax,
  }) {
    return TrainingModalityCompanion(
      id: id ?? this.id,
      objectiveId: objectiveId ?? this.objectiveId,
      level: level ?? this.level,
      name: name ?? this.name,
      repMin: repMin ?? this.repMin,
      repMax: repMax ?? this.repMax,
      setMin: setMin ?? this.setMin,
      setMax: setMax ?? this.setMax,
      restMinSec: restMinSec ?? this.restMinSec,
      restMaxSec: restMaxSec ?? this.restMaxSec,
      rpeMin: rpeMin ?? this.rpeMin,
      rpeMax: rpeMax ?? this.rpeMax,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (objectiveId.present) {
      map['objective_id'] = Variable<int>(objectiveId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(
        $TrainingModalityTable.$converterlevel.toSql(level.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (repMin.present) {
      map['rep_min'] = Variable<int>(repMin.value);
    }
    if (repMax.present) {
      map['rep_max'] = Variable<int>(repMax.value);
    }
    if (setMin.present) {
      map['set_min'] = Variable<int>(setMin.value);
    }
    if (setMax.present) {
      map['set_max'] = Variable<int>(setMax.value);
    }
    if (restMinSec.present) {
      map['rest_min_sec'] = Variable<int>(restMinSec.value);
    }
    if (restMaxSec.present) {
      map['rest_max_sec'] = Variable<int>(restMaxSec.value);
    }
    if (rpeMin.present) {
      map['rpe_min'] = Variable<double>(rpeMin.value);
    }
    if (rpeMax.present) {
      map['rpe_max'] = Variable<double>(rpeMax.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingModalityCompanion(')
          ..write('id: $id, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('repMin: $repMin, ')
          ..write('repMax: $repMax, ')
          ..write('setMin: $setMin, ')
          ..write('setMax: $setMax, ')
          ..write('restMinSec: $restMinSec, ')
          ..write('restMaxSec: $restMaxSec, ')
          ..write('rpeMin: $rpeMin, ')
          ..write('rpeMax: $rpeMax')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES muscle (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipment (id) ON DELETE CASCADE',
    ),
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

class $ExerciseObjectiveTable extends ExerciseObjective
    with TableInfo<$ExerciseObjectiveTable, ExerciseObjectiveData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseObjectiveTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _objectiveIdMeta = const VerificationMeta(
    'objectiveId',
  );
  @override
  late final GeneratedColumn<int> objectiveId = GeneratedColumn<int>(
    'objective_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objective (id) ON DELETE CASCADE',
    ),
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
  List<GeneratedColumn> get $columns => [exerciseId, objectiveId, weight];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_objective';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseObjectiveData> instance, {
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
    if (data.containsKey('objective_id')) {
      context.handle(
        _objectiveIdMeta,
        objectiveId.isAcceptableOrUnknown(
          data['objective_id']!,
          _objectiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_objectiveIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {exerciseId, objectiveId};
  @override
  ExerciseObjectiveData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseObjectiveData(
      exerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}exercise_id'],
          )!,
      objectiveId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}objective_id'],
          )!,
      weight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}weight'],
          )!,
    );
  }

  @override
  $ExerciseObjectiveTable createAlias(String alias) {
    return $ExerciseObjectiveTable(attachedDatabase, alias);
  }
}

class ExerciseObjectiveData extends DataClass
    implements Insertable<ExerciseObjectiveData> {
  final int exerciseId;
  final int objectiveId;
  final double weight;
  const ExerciseObjectiveData({
    required this.exerciseId,
    required this.objectiveId,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<int>(exerciseId);
    map['objective_id'] = Variable<int>(objectiveId);
    map['weight'] = Variable<double>(weight);
    return map;
  }

  ExerciseObjectiveCompanion toCompanion(bool nullToAbsent) {
    return ExerciseObjectiveCompanion(
      exerciseId: Value(exerciseId),
      objectiveId: Value(objectiveId),
      weight: Value(weight),
    );
  }

  factory ExerciseObjectiveData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseObjectiveData(
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      objectiveId: serializer.fromJson<int>(json['objectiveId']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<int>(exerciseId),
      'objectiveId': serializer.toJson<int>(objectiveId),
      'weight': serializer.toJson<double>(weight),
    };
  }

  ExerciseObjectiveData copyWith({
    int? exerciseId,
    int? objectiveId,
    double? weight,
  }) => ExerciseObjectiveData(
    exerciseId: exerciseId ?? this.exerciseId,
    objectiveId: objectiveId ?? this.objectiveId,
    weight: weight ?? this.weight,
  );
  ExerciseObjectiveData copyWithCompanion(ExerciseObjectiveCompanion data) {
    return ExerciseObjectiveData(
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      objectiveId:
          data.objectiveId.present ? data.objectiveId.value : this.objectiveId,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseObjectiveData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, objectiveId, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseObjectiveData &&
          other.exerciseId == this.exerciseId &&
          other.objectiveId == this.objectiveId &&
          other.weight == this.weight);
}

class ExerciseObjectiveCompanion
    extends UpdateCompanion<ExerciseObjectiveData> {
  final Value<int> exerciseId;
  final Value<int> objectiveId;
  final Value<double> weight;
  final Value<int> rowid;
  const ExerciseObjectiveCompanion({
    this.exerciseId = const Value.absent(),
    this.objectiveId = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseObjectiveCompanion.insert({
    required int exerciseId,
    required int objectiveId,
    required double weight,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       objectiveId = Value(objectiveId),
       weight = Value(weight);
  static Insertable<ExerciseObjectiveData> custom({
    Expression<int>? exerciseId,
    Expression<int>? objectiveId,
    Expression<double>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (objectiveId != null) 'objective_id': objectiveId,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseObjectiveCompanion copyWith({
    Value<int>? exerciseId,
    Value<int>? objectiveId,
    Value<double>? weight,
    Value<int>? rowid,
  }) {
    return ExerciseObjectiveCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      objectiveId: objectiveId ?? this.objectiveId,
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
    if (objectiveId.present) {
      map['objective_id'] = Variable<int>(objectiveId.value);
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
    return (StringBuffer('ExerciseObjectiveCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('weight: $weight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseRelationTable extends ExerciseRelation
    with TableInfo<$ExerciseRelationTable, ExerciseRelationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseRelationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _srcExerciseIdMeta = const VerificationMeta(
    'srcExerciseId',
  );
  @override
  late final GeneratedColumn<int> srcExerciseId = GeneratedColumn<int>(
    'src_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dstExerciseIdMeta = const VerificationMeta(
    'dstExerciseId',
  );
  @override
  late final GeneratedColumn<int> dstExerciseId = GeneratedColumn<int>(
    'dst_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, String> relationType =
      GeneratedColumn<String>(
        'relation_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<String>($ExerciseRelationTable.$converterrelationType);
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
  List<GeneratedColumn> get $columns => [
    srcExerciseId,
    dstExerciseId,
    relationType,
    weight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_relation';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRelationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('src_exercise_id')) {
      context.handle(
        _srcExerciseIdMeta,
        srcExerciseId.isAcceptableOrUnknown(
          data['src_exercise_id']!,
          _srcExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_srcExerciseIdMeta);
    }
    if (data.containsKey('dst_exercise_id')) {
      context.handle(
        _dstExerciseIdMeta,
        dstExerciseId.isAcceptableOrUnknown(
          data['dst_exercise_id']!,
          _dstExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dstExerciseIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {
    srcExerciseId,
    dstExerciseId,
    relationType,
  };
  @override
  ExerciseRelationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRelationData(
      srcExerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}src_exercise_id'],
          )!,
      dstExerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}dst_exercise_id'],
          )!,
      relationType: $ExerciseRelationTable.$converterrelationType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}relation_type'],
        )!,
      ),
      weight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}weight'],
          )!,
    );
  }

  @override
  $ExerciseRelationTable createAlias(String alias) {
    return $ExerciseRelationTable(attachedDatabase, alias);
  }

  static TypeConverter<String, String> $converterrelationType =
      _convRelationType;
}

class ExerciseRelationData extends DataClass
    implements Insertable<ExerciseRelationData> {
  final int srcExerciseId;
  final int dstExerciseId;
  final String relationType;
  final double weight;
  const ExerciseRelationData({
    required this.srcExerciseId,
    required this.dstExerciseId,
    required this.relationType,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['src_exercise_id'] = Variable<int>(srcExerciseId);
    map['dst_exercise_id'] = Variable<int>(dstExerciseId);
    {
      map['relation_type'] = Variable<String>(
        $ExerciseRelationTable.$converterrelationType.toSql(relationType),
      );
    }
    map['weight'] = Variable<double>(weight);
    return map;
  }

  ExerciseRelationCompanion toCompanion(bool nullToAbsent) {
    return ExerciseRelationCompanion(
      srcExerciseId: Value(srcExerciseId),
      dstExerciseId: Value(dstExerciseId),
      relationType: Value(relationType),
      weight: Value(weight),
    );
  }

  factory ExerciseRelationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRelationData(
      srcExerciseId: serializer.fromJson<int>(json['srcExerciseId']),
      dstExerciseId: serializer.fromJson<int>(json['dstExerciseId']),
      relationType: serializer.fromJson<String>(json['relationType']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'srcExerciseId': serializer.toJson<int>(srcExerciseId),
      'dstExerciseId': serializer.toJson<int>(dstExerciseId),
      'relationType': serializer.toJson<String>(relationType),
      'weight': serializer.toJson<double>(weight),
    };
  }

  ExerciseRelationData copyWith({
    int? srcExerciseId,
    int? dstExerciseId,
    String? relationType,
    double? weight,
  }) => ExerciseRelationData(
    srcExerciseId: srcExerciseId ?? this.srcExerciseId,
    dstExerciseId: dstExerciseId ?? this.dstExerciseId,
    relationType: relationType ?? this.relationType,
    weight: weight ?? this.weight,
  );
  ExerciseRelationData copyWithCompanion(ExerciseRelationCompanion data) {
    return ExerciseRelationData(
      srcExerciseId:
          data.srcExerciseId.present
              ? data.srcExerciseId.value
              : this.srcExerciseId,
      dstExerciseId:
          data.dstExerciseId.present
              ? data.dstExerciseId.value
              : this.dstExerciseId,
      relationType:
          data.relationType.present
              ? data.relationType.value
              : this.relationType,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRelationData(')
          ..write('srcExerciseId: $srcExerciseId, ')
          ..write('dstExerciseId: $dstExerciseId, ')
          ..write('relationType: $relationType, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(srcExerciseId, dstExerciseId, relationType, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRelationData &&
          other.srcExerciseId == this.srcExerciseId &&
          other.dstExerciseId == this.dstExerciseId &&
          other.relationType == this.relationType &&
          other.weight == this.weight);
}

class ExerciseRelationCompanion extends UpdateCompanion<ExerciseRelationData> {
  final Value<int> srcExerciseId;
  final Value<int> dstExerciseId;
  final Value<String> relationType;
  final Value<double> weight;
  final Value<int> rowid;
  const ExerciseRelationCompanion({
    this.srcExerciseId = const Value.absent(),
    this.dstExerciseId = const Value.absent(),
    this.relationType = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseRelationCompanion.insert({
    required int srcExerciseId,
    required int dstExerciseId,
    required String relationType,
    required double weight,
    this.rowid = const Value.absent(),
  }) : srcExerciseId = Value(srcExerciseId),
       dstExerciseId = Value(dstExerciseId),
       relationType = Value(relationType),
       weight = Value(weight);
  static Insertable<ExerciseRelationData> custom({
    Expression<int>? srcExerciseId,
    Expression<int>? dstExerciseId,
    Expression<String>? relationType,
    Expression<double>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (srcExerciseId != null) 'src_exercise_id': srcExerciseId,
      if (dstExerciseId != null) 'dst_exercise_id': dstExerciseId,
      if (relationType != null) 'relation_type': relationType,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseRelationCompanion copyWith({
    Value<int>? srcExerciseId,
    Value<int>? dstExerciseId,
    Value<String>? relationType,
    Value<double>? weight,
    Value<int>? rowid,
  }) {
    return ExerciseRelationCompanion(
      srcExerciseId: srcExerciseId ?? this.srcExerciseId,
      dstExerciseId: dstExerciseId ?? this.dstExerciseId,
      relationType: relationType ?? this.relationType,
      weight: weight ?? this.weight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (srcExerciseId.present) {
      map['src_exercise_id'] = Variable<int>(srcExerciseId.value);
    }
    if (dstExerciseId.present) {
      map['dst_exercise_id'] = Variable<int>(dstExerciseId.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(
        $ExerciseRelationTable.$converterrelationType.toSql(relationType.value),
      );
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
    return (StringBuffer('ExerciseRelationCompanion(')
          ..write('srcExerciseId: $srcExerciseId, ')
          ..write('dstExerciseId: $dstExerciseId, ')
          ..write('relationType: $relationType, ')
          ..write('weight: $weight, ')
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
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, String> gender =
      GeneratedColumn<String>(
        'gender',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<String?>($AppUserTable.$convertergender);
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, String> level =
      GeneratedColumn<String>(
        'level',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<String?>($AppUserTable.$converterlevel);
  @override
  late final GeneratedColumnWithTypeConverter<String?, String> metabolism =
      GeneratedColumn<String>(
        'metabolism',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<String?>($AppUserTable.$convertermetabolism);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prenomMeta = const VerificationMeta('prenom');
  @override
  late final GeneratedColumn<String> prenom = GeneratedColumn<String>(
    'prenom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    age,
    weight,
    height,
    gender,
    birthDate,
    level,
    metabolism,
    nom,
    prenom,
    singleton,
  ];
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
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    }
    if (data.containsKey('prenom')) {
      context.handle(
        _prenomMeta,
        prenom.isAcceptableOrUnknown(data['prenom']!, _prenomMeta),
      );
    }
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
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
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      ),
      gender: $AppUserTable.$convertergender.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}gender'],
        ),
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      level: $AppUserTable.$converterlevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}level'],
        ),
      ),
      metabolism: $AppUserTable.$convertermetabolism.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metabolism'],
        ),
      ),
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      ),
      prenom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prenom'],
      ),
      singleton:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}singleton'],
          )!,
    );
  }

  @override
  $AppUserTable createAlias(String alias) {
    return $AppUserTable(attachedDatabase, alias);
  }

  static TypeConverter<String?, String?> $convertergender = _nullableGender;
  static TypeConverter<String?, String?> $converterlevel = _nullableLevel;
  static TypeConverter<String?, String?> $convertermetabolism =
      _nullableMetabolism;
}

class AppUserData extends DataClass implements Insertable<AppUserData> {
  final int id;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final DateTime? birthDate;
  final String? level;
  final String? metabolism;
  final String? nom;
  final String? prenom;
  final int singleton;
  const AppUserData({
    required this.id,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.birthDate,
    this.level,
    this.metabolism,
    this.nom,
    this.prenom,
    required this.singleton,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(
        $AppUserTable.$convertergender.toSql(gender),
      );
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(
        $AppUserTable.$converterlevel.toSql(level),
      );
    }
    if (!nullToAbsent || metabolism != null) {
      map['metabolism'] = Variable<String>(
        $AppUserTable.$convertermetabolism.toSql(metabolism),
      );
    }
    if (!nullToAbsent || nom != null) {
      map['nom'] = Variable<String>(nom);
    }
    if (!nullToAbsent || prenom != null) {
      map['prenom'] = Variable<String>(prenom);
    }
    map['singleton'] = Variable<int>(singleton);
    return map;
  }

  AppUserCompanion toCompanion(bool nullToAbsent) {
    return AppUserCompanion(
      id: Value(id),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      birthDate:
          birthDate == null && nullToAbsent
              ? const Value.absent()
              : Value(birthDate),
      level:
          level == null && nullToAbsent ? const Value.absent() : Value(level),
      metabolism:
          metabolism == null && nullToAbsent
              ? const Value.absent()
              : Value(metabolism),
      nom: nom == null && nullToAbsent ? const Value.absent() : Value(nom),
      prenom:
          prenom == null && nullToAbsent ? const Value.absent() : Value(prenom),
      singleton: Value(singleton),
    );
  }

  factory AppUserData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserData(
      id: serializer.fromJson<int>(json['id']),
      age: serializer.fromJson<int?>(json['age']),
      weight: serializer.fromJson<double?>(json['weight']),
      height: serializer.fromJson<double?>(json['height']),
      gender: serializer.fromJson<String?>(json['gender']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      level: serializer.fromJson<String?>(json['level']),
      metabolism: serializer.fromJson<String?>(json['metabolism']),
      nom: serializer.fromJson<String?>(json['nom']),
      prenom: serializer.fromJson<String?>(json['prenom']),
      singleton: serializer.fromJson<int>(json['singleton']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'age': serializer.toJson<int?>(age),
      'weight': serializer.toJson<double?>(weight),
      'height': serializer.toJson<double?>(height),
      'gender': serializer.toJson<String?>(gender),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'level': serializer.toJson<String?>(level),
      'metabolism': serializer.toJson<String?>(metabolism),
      'nom': serializer.toJson<String?>(nom),
      'prenom': serializer.toJson<String?>(prenom),
      'singleton': serializer.toJson<int>(singleton),
    };
  }

  AppUserData copyWith({
    int? id,
    Value<int?> age = const Value.absent(),
    Value<double?> weight = const Value.absent(),
    Value<double?> height = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> level = const Value.absent(),
    Value<String?> metabolism = const Value.absent(),
    Value<String?> nom = const Value.absent(),
    Value<String?> prenom = const Value.absent(),
    int? singleton,
  }) => AppUserData(
    id: id ?? this.id,
    age: age.present ? age.value : this.age,
    weight: weight.present ? weight.value : this.weight,
    height: height.present ? height.value : this.height,
    gender: gender.present ? gender.value : this.gender,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    level: level.present ? level.value : this.level,
    metabolism: metabolism.present ? metabolism.value : this.metabolism,
    nom: nom.present ? nom.value : this.nom,
    prenom: prenom.present ? prenom.value : this.prenom,
    singleton: singleton ?? this.singleton,
  );
  AppUserData copyWithCompanion(AppUserCompanion data) {
    return AppUserData(
      id: data.id.present ? data.id.value : this.id,
      age: data.age.present ? data.age.value : this.age,
      weight: data.weight.present ? data.weight.value : this.weight,
      height: data.height.present ? data.height.value : this.height,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      level: data.level.present ? data.level.value : this.level,
      metabolism:
          data.metabolism.present ? data.metabolism.value : this.metabolism,
      nom: data.nom.present ? data.nom.value : this.nom,
      prenom: data.prenom.present ? data.prenom.value : this.prenom,
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserData(')
          ..write('id: $id, ')
          ..write('age: $age, ')
          ..write('weight: $weight, ')
          ..write('height: $height, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('level: $level, ')
          ..write('metabolism: $metabolism, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('singleton: $singleton')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    age,
    weight,
    height,
    gender,
    birthDate,
    level,
    metabolism,
    nom,
    prenom,
    singleton,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserData &&
          other.id == this.id &&
          other.age == this.age &&
          other.weight == this.weight &&
          other.height == this.height &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.level == this.level &&
          other.metabolism == this.metabolism &&
          other.nom == this.nom &&
          other.prenom == this.prenom &&
          other.singleton == this.singleton);
}

class AppUserCompanion extends UpdateCompanion<AppUserData> {
  final Value<int> id;
  final Value<int?> age;
  final Value<double?> weight;
  final Value<double?> height;
  final Value<String?> gender;
  final Value<DateTime?> birthDate;
  final Value<String?> level;
  final Value<String?> metabolism;
  final Value<String?> nom;
  final Value<String?> prenom;
  final Value<int> singleton;
  const AppUserCompanion({
    this.id = const Value.absent(),
    this.age = const Value.absent(),
    this.weight = const Value.absent(),
    this.height = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.level = const Value.absent(),
    this.metabolism = const Value.absent(),
    this.nom = const Value.absent(),
    this.prenom = const Value.absent(),
    this.singleton = const Value.absent(),
  });
  AppUserCompanion.insert({
    this.id = const Value.absent(),
    this.age = const Value.absent(),
    this.weight = const Value.absent(),
    this.height = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.level = const Value.absent(),
    this.metabolism = const Value.absent(),
    this.nom = const Value.absent(),
    this.prenom = const Value.absent(),
    this.singleton = const Value.absent(),
  });
  static Insertable<AppUserData> custom({
    Expression<int>? id,
    Expression<int>? age,
    Expression<double>? weight,
    Expression<double>? height,
    Expression<String>? gender,
    Expression<DateTime>? birthDate,
    Expression<String>? level,
    Expression<String>? metabolism,
    Expression<String>? nom,
    Expression<String>? prenom,
    Expression<int>? singleton,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (age != null) 'age': age,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (level != null) 'level': level,
      if (metabolism != null) 'metabolism': metabolism,
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      if (singleton != null) 'singleton': singleton,
    });
  }

  AppUserCompanion copyWith({
    Value<int>? id,
    Value<int?>? age,
    Value<double?>? weight,
    Value<double?>? height,
    Value<String?>? gender,
    Value<DateTime?>? birthDate,
    Value<String?>? level,
    Value<String?>? metabolism,
    Value<String?>? nom,
    Value<String?>? prenom,
    Value<int>? singleton,
  }) {
    return AppUserCompanion(
      id: id ?? this.id,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      level: level ?? this.level,
      metabolism: metabolism ?? this.metabolism,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      singleton: singleton ?? this.singleton,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(
        $AppUserTable.$convertergender.toSql(gender.value),
      );
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(
        $AppUserTable.$converterlevel.toSql(level.value),
      );
    }
    if (metabolism.present) {
      map['metabolism'] = Variable<String>(
        $AppUserTable.$convertermetabolism.toSql(metabolism.value),
      );
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prenom.present) {
      map['prenom'] = Variable<String>(prenom.value);
    }
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUserCompanion(')
          ..write('id: $id, ')
          ..write('age: $age, ')
          ..write('weight: $weight, ')
          ..write('height: $height, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('level: $level, ')
          ..write('metabolism: $metabolism, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('singleton: $singleton')
          ..write(')'))
        .toString();
  }
}

class $UserEquipmentTable extends UserEquipment
    with TableInfo<$UserEquipmentTable, UserEquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserEquipmentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_user (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipment (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [userId, equipmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEquipmentData> instance, {
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
  Set<GeneratedColumn> get $primaryKey => {userId, equipmentId};
  @override
  UserEquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEquipmentData(
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}user_id'],
          )!,
      equipmentId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}equipment_id'],
          )!,
    );
  }

  @override
  $UserEquipmentTable createAlias(String alias) {
    return $UserEquipmentTable(attachedDatabase, alias);
  }
}

class UserEquipmentData extends DataClass
    implements Insertable<UserEquipmentData> {
  final int userId;
  final int equipmentId;
  const UserEquipmentData({required this.userId, required this.equipmentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['equipment_id'] = Variable<int>(equipmentId);
    return map;
  }

  UserEquipmentCompanion toCompanion(bool nullToAbsent) {
    return UserEquipmentCompanion(
      userId: Value(userId),
      equipmentId: Value(equipmentId),
    );
  }

  factory UserEquipmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEquipmentData(
      userId: serializer.fromJson<int>(json['userId']),
      equipmentId: serializer.fromJson<int>(json['equipmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'equipmentId': serializer.toJson<int>(equipmentId),
    };
  }

  UserEquipmentData copyWith({int? userId, int? equipmentId}) =>
      UserEquipmentData(
        userId: userId ?? this.userId,
        equipmentId: equipmentId ?? this.equipmentId,
      );
  UserEquipmentData copyWithCompanion(UserEquipmentCompanion data) {
    return UserEquipmentData(
      userId: data.userId.present ? data.userId.value : this.userId,
      equipmentId:
          data.equipmentId.present ? data.equipmentId.value : this.equipmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEquipmentData(')
          ..write('userId: $userId, ')
          ..write('equipmentId: $equipmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, equipmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEquipmentData &&
          other.userId == this.userId &&
          other.equipmentId == this.equipmentId);
}

class UserEquipmentCompanion extends UpdateCompanion<UserEquipmentData> {
  final Value<int> userId;
  final Value<int> equipmentId;
  final Value<int> rowid;
  const UserEquipmentCompanion({
    this.userId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserEquipmentCompanion.insert({
    required int userId,
    required int equipmentId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       equipmentId = Value(equipmentId);
  static Insertable<UserEquipmentData> custom({
    Expression<int>? userId,
    Expression<int>? equipmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserEquipmentCompanion copyWith({
    Value<int>? userId,
    Value<int>? equipmentId,
    Value<int>? rowid,
  }) {
    return UserEquipmentCompanion(
      userId: userId ?? this.userId,
      equipmentId: equipmentId ?? this.equipmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
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
    return (StringBuffer('UserEquipmentCompanion(')
          ..write('userId: $userId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserGoalTable extends UserGoal
    with TableInfo<$UserGoalTable, UserGoalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGoalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_user (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _objectiveIdMeta = const VerificationMeta(
    'objectiveId',
  );
  @override
  late final GeneratedColumn<int> objectiveId = GeneratedColumn<int>(
    'objective_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objective (id) ON DELETE CASCADE',
    ),
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
  List<GeneratedColumn> get $columns => [userId, objectiveId, weight];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_goal';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGoalData> instance, {
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
    if (data.containsKey('objective_id')) {
      context.handle(
        _objectiveIdMeta,
        objectiveId.isAcceptableOrUnknown(
          data['objective_id']!,
          _objectiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_objectiveIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {userId, objectiveId};
  @override
  UserGoalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGoalData(
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}user_id'],
          )!,
      objectiveId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}objective_id'],
          )!,
      weight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}weight'],
          )!,
    );
  }

  @override
  $UserGoalTable createAlias(String alias) {
    return $UserGoalTable(attachedDatabase, alias);
  }
}

class UserGoalData extends DataClass implements Insertable<UserGoalData> {
  final int userId;
  final int objectiveId;
  final double weight;
  const UserGoalData({
    required this.userId,
    required this.objectiveId,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['objective_id'] = Variable<int>(objectiveId);
    map['weight'] = Variable<double>(weight);
    return map;
  }

  UserGoalCompanion toCompanion(bool nullToAbsent) {
    return UserGoalCompanion(
      userId: Value(userId),
      objectiveId: Value(objectiveId),
      weight: Value(weight),
    );
  }

  factory UserGoalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGoalData(
      userId: serializer.fromJson<int>(json['userId']),
      objectiveId: serializer.fromJson<int>(json['objectiveId']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'objectiveId': serializer.toJson<int>(objectiveId),
      'weight': serializer.toJson<double>(weight),
    };
  }

  UserGoalData copyWith({int? userId, int? objectiveId, double? weight}) =>
      UserGoalData(
        userId: userId ?? this.userId,
        objectiveId: objectiveId ?? this.objectiveId,
        weight: weight ?? this.weight,
      );
  UserGoalData copyWithCompanion(UserGoalCompanion data) {
    return UserGoalData(
      userId: data.userId.present ? data.userId.value : this.userId,
      objectiveId:
          data.objectiveId.present ? data.objectiveId.value : this.objectiveId,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGoalData(')
          ..write('userId: $userId, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, objectiveId, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGoalData &&
          other.userId == this.userId &&
          other.objectiveId == this.objectiveId &&
          other.weight == this.weight);
}

class UserGoalCompanion extends UpdateCompanion<UserGoalData> {
  final Value<int> userId;
  final Value<int> objectiveId;
  final Value<double> weight;
  final Value<int> rowid;
  const UserGoalCompanion({
    this.userId = const Value.absent(),
    this.objectiveId = const Value.absent(),
    this.weight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserGoalCompanion.insert({
    required int userId,
    required int objectiveId,
    required double weight,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       objectiveId = Value(objectiveId),
       weight = Value(weight);
  static Insertable<UserGoalData> custom({
    Expression<int>? userId,
    Expression<int>? objectiveId,
    Expression<double>? weight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (objectiveId != null) 'objective_id': objectiveId,
      if (weight != null) 'weight': weight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserGoalCompanion copyWith({
    Value<int>? userId,
    Value<int>? objectiveId,
    Value<double>? weight,
    Value<int>? rowid,
  }) {
    return UserGoalCompanion(
      userId: userId ?? this.userId,
      objectiveId: objectiveId ?? this.objectiveId,
      weight: weight ?? this.weight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (objectiveId.present) {
      map['objective_id'] = Variable<int>(objectiveId.value);
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
    return (StringBuffer('UserGoalCompanion(')
          ..write('userId: $userId, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('weight: $weight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserTrainingDayTable extends UserTrainingDay
    with TableInfo<$UserTrainingDayTable, UserTrainingDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTrainingDayTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_user (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    check: () => ComparableExpr(dayOfWeek).isBetweenValues(1, 7),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, dayOfWeek];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_training_day';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserTrainingDayData> instance, {
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
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, dayOfWeek};
  @override
  UserTrainingDayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTrainingDayData(
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}user_id'],
          )!,
      dayOfWeek:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}day_of_week'],
          )!,
    );
  }

  @override
  $UserTrainingDayTable createAlias(String alias) {
    return $UserTrainingDayTable(attachedDatabase, alias);
  }
}

class UserTrainingDayData extends DataClass
    implements Insertable<UserTrainingDayData> {
  final int userId;
  final int dayOfWeek;
  const UserTrainingDayData({required this.userId, required this.dayOfWeek});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    return map;
  }

  UserTrainingDayCompanion toCompanion(bool nullToAbsent) {
    return UserTrainingDayCompanion(
      userId: Value(userId),
      dayOfWeek: Value(dayOfWeek),
    );
  }

  factory UserTrainingDayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTrainingDayData(
      userId: serializer.fromJson<int>(json['userId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
    };
  }

  UserTrainingDayData copyWith({int? userId, int? dayOfWeek}) =>
      UserTrainingDayData(
        userId: userId ?? this.userId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      );
  UserTrainingDayData copyWithCompanion(UserTrainingDayCompanion data) {
    return UserTrainingDayData(
      userId: data.userId.present ? data.userId.value : this.userId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTrainingDayData(')
          ..write('userId: $userId, ')
          ..write('dayOfWeek: $dayOfWeek')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, dayOfWeek);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTrainingDayData &&
          other.userId == this.userId &&
          other.dayOfWeek == this.dayOfWeek);
}

class UserTrainingDayCompanion extends UpdateCompanion<UserTrainingDayData> {
  final Value<int> userId;
  final Value<int> dayOfWeek;
  final Value<int> rowid;
  const UserTrainingDayCompanion({
    this.userId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTrainingDayCompanion.insert({
    required int userId,
    required int dayOfWeek,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       dayOfWeek = Value(dayOfWeek);
  static Insertable<UserTrainingDayData> custom({
    Expression<int>? userId,
    Expression<int>? dayOfWeek,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTrainingDayCompanion copyWith({
    Value<int>? userId,
    Value<int>? dayOfWeek,
    Value<int>? rowid,
  }) {
    return UserTrainingDayCompanion(
      userId: userId ?? this.userId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTrainingDayCompanion(')
          ..write('userId: $userId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutProgramTable extends WorkoutProgram
    with TableInfo<$WorkoutProgramTable, WorkoutProgramData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutProgramTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _objectiveIdMeta = const VerificationMeta(
    'objectiveId',
  );
  @override
  late final GeneratedColumn<int> objectiveId = GeneratedColumn<int>(
    'objective_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objective (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, String> level =
      GeneratedColumn<String>(
        'level',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<String?>($WorkoutProgramTable.$converterlevel);
  static const VerificationMeta _durationWeeksMeta = const VerificationMeta(
    'durationWeeks',
  );
  @override
  late final GeneratedColumn<int> durationWeeks = GeneratedColumn<int>(
    'duration_weeks',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    objectiveId,
    level,
    durationWeeks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_program';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutProgramData> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('objective_id')) {
      context.handle(
        _objectiveIdMeta,
        objectiveId.isAcceptableOrUnknown(
          data['objective_id']!,
          _objectiveIdMeta,
        ),
      );
    }
    if (data.containsKey('duration_weeks')) {
      context.handle(
        _durationWeeksMeta,
        durationWeeks.isAcceptableOrUnknown(
          data['duration_weeks']!,
          _durationWeeksMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutProgramData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutProgramData(
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
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      objectiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}objective_id'],
      ),
      level: $WorkoutProgramTable.$converterlevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}level'],
        ),
      ),
      durationWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_weeks'],
      ),
    );
  }

  @override
  $WorkoutProgramTable createAlias(String alias) {
    return $WorkoutProgramTable(attachedDatabase, alias);
  }

  static TypeConverter<String?, String?> $converterlevel = _nullableLevel;
}

class WorkoutProgramData extends DataClass
    implements Insertable<WorkoutProgramData> {
  final int id;
  final String name;
  final String? description;
  final int? objectiveId;
  final String? level;
  final int? durationWeeks;
  const WorkoutProgramData({
    required this.id,
    required this.name,
    this.description,
    this.objectiveId,
    this.level,
    this.durationWeeks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || objectiveId != null) {
      map['objective_id'] = Variable<int>(objectiveId);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(
        $WorkoutProgramTable.$converterlevel.toSql(level),
      );
    }
    if (!nullToAbsent || durationWeeks != null) {
      map['duration_weeks'] = Variable<int>(durationWeeks);
    }
    return map;
  }

  WorkoutProgramCompanion toCompanion(bool nullToAbsent) {
    return WorkoutProgramCompanion(
      id: Value(id),
      name: Value(name),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      objectiveId:
          objectiveId == null && nullToAbsent
              ? const Value.absent()
              : Value(objectiveId),
      level:
          level == null && nullToAbsent ? const Value.absent() : Value(level),
      durationWeeks:
          durationWeeks == null && nullToAbsent
              ? const Value.absent()
              : Value(durationWeeks),
    );
  }

  factory WorkoutProgramData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutProgramData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      objectiveId: serializer.fromJson<int?>(json['objectiveId']),
      level: serializer.fromJson<String?>(json['level']),
      durationWeeks: serializer.fromJson<int?>(json['durationWeeks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'objectiveId': serializer.toJson<int?>(objectiveId),
      'level': serializer.toJson<String?>(level),
      'durationWeeks': serializer.toJson<int?>(durationWeeks),
    };
  }

  WorkoutProgramData copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<int?> objectiveId = const Value.absent(),
    Value<String?> level = const Value.absent(),
    Value<int?> durationWeeks = const Value.absent(),
  }) => WorkoutProgramData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    objectiveId: objectiveId.present ? objectiveId.value : this.objectiveId,
    level: level.present ? level.value : this.level,
    durationWeeks:
        durationWeeks.present ? durationWeeks.value : this.durationWeeks,
  );
  WorkoutProgramData copyWithCompanion(WorkoutProgramCompanion data) {
    return WorkoutProgramData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      objectiveId:
          data.objectiveId.present ? data.objectiveId.value : this.objectiveId,
      level: data.level.present ? data.level.value : this.level,
      durationWeeks:
          data.durationWeeks.present
              ? data.durationWeeks.value
              : this.durationWeeks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutProgramData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('level: $level, ')
          ..write('durationWeeks: $durationWeeks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, objectiveId, level, durationWeeks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutProgramData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.objectiveId == this.objectiveId &&
          other.level == this.level &&
          other.durationWeeks == this.durationWeeks);
}

class WorkoutProgramCompanion extends UpdateCompanion<WorkoutProgramData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> objectiveId;
  final Value<String?> level;
  final Value<int?> durationWeeks;
  const WorkoutProgramCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.objectiveId = const Value.absent(),
    this.level = const Value.absent(),
    this.durationWeeks = const Value.absent(),
  });
  WorkoutProgramCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.objectiveId = const Value.absent(),
    this.level = const Value.absent(),
    this.durationWeeks = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WorkoutProgramData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? objectiveId,
    Expression<String>? level,
    Expression<int>? durationWeeks,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (objectiveId != null) 'objective_id': objectiveId,
      if (level != null) 'level': level,
      if (durationWeeks != null) 'duration_weeks': durationWeeks,
    });
  }

  WorkoutProgramCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int?>? objectiveId,
    Value<String?>? level,
    Value<int?>? durationWeeks,
  }) {
    return WorkoutProgramCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      objectiveId: objectiveId ?? this.objectiveId,
      level: level ?? this.level,
      durationWeeks: durationWeeks ?? this.durationWeeks,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (objectiveId.present) {
      map['objective_id'] = Variable<int>(objectiveId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(
        $WorkoutProgramTable.$converterlevel.toSql(level.value),
      );
    }
    if (durationWeeks.present) {
      map['duration_weeks'] = Variable<int>(durationWeeks.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutProgramCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('level: $level, ')
          ..write('durationWeeks: $durationWeeks')
          ..write(')'))
        .toString();
  }
}

class $ProgramDayTable extends ProgramDay
    with TableInfo<$ProgramDayTable, ProgramDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramDayTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_program (id) ON DELETE CASCADE',
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
  static const VerificationMeta _dayOrderMeta = const VerificationMeta(
    'dayOrder',
  );
  @override
  late final GeneratedColumn<int> dayOrder = GeneratedColumn<int>(
    'day_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, programId, name, dayOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_day';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramDayData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('day_order')) {
      context.handle(
        _dayOrderMeta,
        dayOrder.isAcceptableOrUnknown(data['day_order']!, _dayOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramDayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramDayData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      programId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}program_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      dayOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}day_order'],
          )!,
    );
  }

  @override
  $ProgramDayTable createAlias(String alias) {
    return $ProgramDayTable(attachedDatabase, alias);
  }
}

class ProgramDayData extends DataClass implements Insertable<ProgramDayData> {
  final int id;
  final int programId;
  final String name;
  final int dayOrder;
  const ProgramDayData({
    required this.id,
    required this.programId,
    required this.name,
    required this.dayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['program_id'] = Variable<int>(programId);
    map['name'] = Variable<String>(name);
    map['day_order'] = Variable<int>(dayOrder);
    return map;
  }

  ProgramDayCompanion toCompanion(bool nullToAbsent) {
    return ProgramDayCompanion(
      id: Value(id),
      programId: Value(programId),
      name: Value(name),
      dayOrder: Value(dayOrder),
    );
  }

  factory ProgramDayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramDayData(
      id: serializer.fromJson<int>(json['id']),
      programId: serializer.fromJson<int>(json['programId']),
      name: serializer.fromJson<String>(json['name']),
      dayOrder: serializer.fromJson<int>(json['dayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'programId': serializer.toJson<int>(programId),
      'name': serializer.toJson<String>(name),
      'dayOrder': serializer.toJson<int>(dayOrder),
    };
  }

  ProgramDayData copyWith({
    int? id,
    int? programId,
    String? name,
    int? dayOrder,
  }) => ProgramDayData(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    name: name ?? this.name,
    dayOrder: dayOrder ?? this.dayOrder,
  );
  ProgramDayData copyWithCompanion(ProgramDayCompanion data) {
    return ProgramDayData(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      name: data.name.present ? data.name.value : this.name,
      dayOrder: data.dayOrder.present ? data.dayOrder.value : this.dayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayData(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('name: $name, ')
          ..write('dayOrder: $dayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, programId, name, dayOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramDayData &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.name == this.name &&
          other.dayOrder == this.dayOrder);
}

class ProgramDayCompanion extends UpdateCompanion<ProgramDayData> {
  final Value<int> id;
  final Value<int> programId;
  final Value<String> name;
  final Value<int> dayOrder;
  const ProgramDayCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.name = const Value.absent(),
    this.dayOrder = const Value.absent(),
  });
  ProgramDayCompanion.insert({
    this.id = const Value.absent(),
    required int programId,
    required String name,
    required int dayOrder,
  }) : programId = Value(programId),
       name = Value(name),
       dayOrder = Value(dayOrder);
  static Insertable<ProgramDayData> custom({
    Expression<int>? id,
    Expression<int>? programId,
    Expression<String>? name,
    Expression<int>? dayOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (name != null) 'name': name,
      if (dayOrder != null) 'day_order': dayOrder,
    });
  }

  ProgramDayCompanion copyWith({
    Value<int>? id,
    Value<int>? programId,
    Value<String>? name,
    Value<int>? dayOrder,
  }) {
    return ProgramDayCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      name: name ?? this.name,
      dayOrder: dayOrder ?? this.dayOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dayOrder.present) {
      map['day_order'] = Variable<int>(dayOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('name: $name, ')
          ..write('dayOrder: $dayOrder')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_user (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _programDayIdMeta = const VerificationMeta(
    'programDayId',
  );
  @override
  late final GeneratedColumn<int> programDayId = GeneratedColumn<int>(
    'program_day_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES program_day (id) ON DELETE SET NULL',
    ),
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
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    programDayId,
    dateTs,
    durationMin,
    name,
  ];
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
    if (data.containsKey('program_day_id')) {
      context.handle(
        _programDayIdMeta,
        programDayId.isAcceptableOrUnknown(
          data['program_day_id']!,
          _programDayIdMeta,
        ),
      );
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
      programDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}program_day_id'],
      ),
      dateTs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}date_ts'],
          )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
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
  final int? programDayId;
  final int dateTs;
  final int? durationMin;
  final String? name;
  const SessionData({
    required this.id,
    required this.userId,
    this.programDayId,
    required this.dateTs,
    this.durationMin,
    this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || programDayId != null) {
      map['program_day_id'] = Variable<int>(programDayId);
    }
    map['date_ts'] = Variable<int>(dateTs);
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  SessionCompanion toCompanion(bool nullToAbsent) {
    return SessionCompanion(
      id: Value(id),
      userId: Value(userId),
      programDayId:
          programDayId == null && nullToAbsent
              ? const Value.absent()
              : Value(programDayId),
      dateTs: Value(dateTs),
      durationMin:
          durationMin == null && nullToAbsent
              ? const Value.absent()
              : Value(durationMin),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
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
      programDayId: serializer.fromJson<int?>(json['programDayId']),
      dateTs: serializer.fromJson<int>(json['dateTs']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'programDayId': serializer.toJson<int?>(programDayId),
      'dateTs': serializer.toJson<int>(dateTs),
      'durationMin': serializer.toJson<int?>(durationMin),
      'name': serializer.toJson<String?>(name),
    };
  }

  SessionData copyWith({
    int? id,
    int? userId,
    Value<int?> programDayId = const Value.absent(),
    int? dateTs,
    Value<int?> durationMin = const Value.absent(),
    Value<String?> name = const Value.absent(),
  }) => SessionData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    programDayId: programDayId.present ? programDayId.value : this.programDayId,
    dateTs: dateTs ?? this.dateTs,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    name: name.present ? name.value : this.name,
  );
  SessionData copyWithCompanion(SessionCompanion data) {
    return SessionData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      programDayId:
          data.programDayId.present
              ? data.programDayId.value
              : this.programDayId,
      dateTs: data.dateTs.present ? data.dateTs.value : this.dateTs,
      durationMin:
          data.durationMin.present ? data.durationMin.value : this.durationMin,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('programDayId: $programDayId, ')
          ..write('dateTs: $dateTs, ')
          ..write('durationMin: $durationMin, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, programDayId, dateTs, durationMin, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.programDayId == this.programDayId &&
          other.dateTs == this.dateTs &&
          other.durationMin == this.durationMin &&
          other.name == this.name);
}

class SessionCompanion extends UpdateCompanion<SessionData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int?> programDayId;
  final Value<int> dateTs;
  final Value<int?> durationMin;
  final Value<String?> name;
  const SessionCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.programDayId = const Value.absent(),
    this.dateTs = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.name = const Value.absent(),
  });
  SessionCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.programDayId = const Value.absent(),
    required int dateTs,
    this.durationMin = const Value.absent(),
    this.name = const Value.absent(),
  }) : userId = Value(userId),
       dateTs = Value(dateTs);
  static Insertable<SessionData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? programDayId,
    Expression<int>? dateTs,
    Expression<int>? durationMin,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (programDayId != null) 'program_day_id': programDayId,
      if (dateTs != null) 'date_ts': dateTs,
      if (durationMin != null) 'duration_min': durationMin,
      if (name != null) 'name': name,
    });
  }

  SessionCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int?>? programDayId,
    Value<int>? dateTs,
    Value<int?>? durationMin,
    Value<String?>? name,
  }) {
    return SessionCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      programDayId: programDayId ?? this.programDayId,
      dateTs: dateTs ?? this.dateTs,
      durationMin: durationMin ?? this.durationMin,
      name: name ?? this.name,
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
    if (programDayId.present) {
      map['program_day_id'] = Variable<int>(programDayId.value);
    }
    if (dateTs.present) {
      map['date_ts'] = Variable<int>(dateTs.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('programDayId: $programDayId, ')
          ..write('dateTs: $dateTs, ')
          ..write('durationMin: $durationMin, ')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_user (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES session (id) ON DELETE CASCADE',
    ),
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
    sessionId,
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
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
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
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
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
  final int? sessionId;
  final int liked;
  final int difficult;
  final int pleasant;
  final int useless;
  final int ts;
  const UserFeedbackData({
    required this.userId,
    required this.exerciseId,
    this.sessionId,
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
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
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
      sessionId:
          sessionId == null && nullToAbsent
              ? const Value.absent()
              : Value(sessionId),
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
      sessionId: serializer.fromJson<int?>(json['sessionId']),
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
      'sessionId': serializer.toJson<int?>(sessionId),
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
    Value<int?> sessionId = const Value.absent(),
    int? liked,
    int? difficult,
    int? pleasant,
    int? useless,
    int? ts,
  }) => UserFeedbackData(
    userId: userId ?? this.userId,
    exerciseId: exerciseId ?? this.exerciseId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
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
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
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
          ..write('sessionId: $sessionId, ')
          ..write('liked: $liked, ')
          ..write('difficult: $difficult, ')
          ..write('pleasant: $pleasant, ')
          ..write('useless: $useless, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    exerciseId,
    sessionId,
    liked,
    difficult,
    pleasant,
    useless,
    ts,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFeedbackData &&
          other.userId == this.userId &&
          other.exerciseId == this.exerciseId &&
          other.sessionId == this.sessionId &&
          other.liked == this.liked &&
          other.difficult == this.difficult &&
          other.pleasant == this.pleasant &&
          other.useless == this.useless &&
          other.ts == this.ts);
}

class UserFeedbackCompanion extends UpdateCompanion<UserFeedbackData> {
  final Value<int> userId;
  final Value<int> exerciseId;
  final Value<int?> sessionId;
  final Value<int> liked;
  final Value<int> difficult;
  final Value<int> pleasant;
  final Value<int> useless;
  final Value<int> ts;
  final Value<int> rowid;
  const UserFeedbackCompanion({
    this.userId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sessionId = const Value.absent(),
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
    this.sessionId = const Value.absent(),
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
    Expression<int>? sessionId,
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
      if (sessionId != null) 'session_id': sessionId,
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
    Value<int?>? sessionId,
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
      sessionId: sessionId ?? this.sessionId,
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
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
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
          ..write('sessionId: $sessionId, ')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES session (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
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
    position,
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
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
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
  Set<GeneratedColumn> get $primaryKey => {sessionId, exerciseId, position};
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
      position:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}position'],
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
  final int position;
  final int? sets;
  final int? reps;
  final double? load;
  final double? rpe;
  const SessionExerciseData({
    required this.sessionId,
    required this.exerciseId,
    required this.position,
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
    map['position'] = Variable<int>(position);
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
      position: Value(position),
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
      position: serializer.fromJson<int>(json['position']),
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
      'position': serializer.toJson<int>(position),
      'sets': serializer.toJson<int?>(sets),
      'reps': serializer.toJson<int?>(reps),
      'load': serializer.toJson<double?>(load),
      'rpe': serializer.toJson<double?>(rpe),
    };
  }

  SessionExerciseData copyWith({
    int? sessionId,
    int? exerciseId,
    int? position,
    Value<int?> sets = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<double?> load = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
  }) => SessionExerciseData(
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
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
      position: data.position.present ? data.position.value : this.position,
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
          ..write('position: $position, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('load: $load, ')
          ..write('rpe: $rpe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, exerciseId, position, sets, reps, load, rpe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseData &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.sets == this.sets &&
          other.reps == this.reps &&
          other.load == this.load &&
          other.rpe == this.rpe);
}

class SessionExerciseCompanion extends UpdateCompanion<SessionExerciseData> {
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int> position;
  final Value<int?> sets;
  final Value<int?> reps;
  final Value<double?> load;
  final Value<double?> rpe;
  final Value<int> rowid;
  const SessionExerciseCompanion({
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.load = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExerciseCompanion.insert({
    required int sessionId,
    required int exerciseId,
    required int position,
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.load = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<SessionExerciseData> custom({
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? position,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<double>? load,
    Expression<double>? rpe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
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
    Value<int>? position,
    Value<int?>? sets,
    Value<int?>? reps,
    Value<double?>? load,
    Value<double?>? rpe,
    Value<int>? rowid,
  }) {
    return SessionExerciseCompanion(
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
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
    if (position.present) {
      map['position'] = Variable<int>(position.value);
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
          ..write('position: $position, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('load: $load, ')
          ..write('rpe: $rpe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramDayExerciseTable extends ProgramDayExercise
    with TableInfo<$ProgramDayExerciseTable, ProgramDayExerciseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramDayExerciseTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _programDayIdMeta = const VerificationMeta(
    'programDayId',
  );
  @override
  late final GeneratedColumn<int> programDayId = GeneratedColumn<int>(
    'program_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES program_day (id) ON DELETE CASCADE',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modalityIdMeta = const VerificationMeta(
    'modalityId',
  );
  @override
  late final GeneratedColumn<int> modalityId = GeneratedColumn<int>(
    'modality_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_modality (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _setsSuggestionMeta = const VerificationMeta(
    'setsSuggestion',
  );
  @override
  late final GeneratedColumn<String> setsSuggestion = GeneratedColumn<String>(
    'sets_suggestion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsSuggestionMeta = const VerificationMeta(
    'repsSuggestion',
  );
  @override
  late final GeneratedColumn<String> repsSuggestion = GeneratedColumn<String>(
    'reps_suggestion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSuggestionSecMeta = const VerificationMeta(
    'restSuggestionSec',
  );
  @override
  late final GeneratedColumn<int> restSuggestionSec = GeneratedColumn<int>(
    'rest_suggestion_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousSetsSuggestionMeta =
      const VerificationMeta('previousSetsSuggestion');
  @override
  late final GeneratedColumn<String> previousSetsSuggestion =
      GeneratedColumn<String>(
        'previous_sets_suggestion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousRepsSuggestionMeta =
      const VerificationMeta('previousRepsSuggestion');
  @override
  late final GeneratedColumn<String> previousRepsSuggestion =
      GeneratedColumn<String>(
        'previous_reps_suggestion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousRestSuggestionMeta =
      const VerificationMeta('previousRestSuggestion');
  @override
  late final GeneratedColumn<int> previousRestSuggestion = GeneratedColumn<int>(
    'previous_rest_suggestion',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    programDayId,
    exerciseId,
    position,
    modalityId,
    setsSuggestion,
    repsSuggestion,
    restSuggestionSec,
    previousSetsSuggestion,
    previousRepsSuggestion,
    previousRestSuggestion,
    notes,
    scheduledDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_day_exercise';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramDayExerciseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_day_id')) {
      context.handle(
        _programDayIdMeta,
        programDayId.isAcceptableOrUnknown(
          data['program_day_id']!,
          _programDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_programDayIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('modality_id')) {
      context.handle(
        _modalityIdMeta,
        modalityId.isAcceptableOrUnknown(data['modality_id']!, _modalityIdMeta),
      );
    }
    if (data.containsKey('sets_suggestion')) {
      context.handle(
        _setsSuggestionMeta,
        setsSuggestion.isAcceptableOrUnknown(
          data['sets_suggestion']!,
          _setsSuggestionMeta,
        ),
      );
    }
    if (data.containsKey('reps_suggestion')) {
      context.handle(
        _repsSuggestionMeta,
        repsSuggestion.isAcceptableOrUnknown(
          data['reps_suggestion']!,
          _repsSuggestionMeta,
        ),
      );
    }
    if (data.containsKey('rest_suggestion_sec')) {
      context.handle(
        _restSuggestionSecMeta,
        restSuggestionSec.isAcceptableOrUnknown(
          data['rest_suggestion_sec']!,
          _restSuggestionSecMeta,
        ),
      );
    }
    if (data.containsKey('previous_sets_suggestion')) {
      context.handle(
        _previousSetsSuggestionMeta,
        previousSetsSuggestion.isAcceptableOrUnknown(
          data['previous_sets_suggestion']!,
          _previousSetsSuggestionMeta,
        ),
      );
    }
    if (data.containsKey('previous_reps_suggestion')) {
      context.handle(
        _previousRepsSuggestionMeta,
        previousRepsSuggestion.isAcceptableOrUnknown(
          data['previous_reps_suggestion']!,
          _previousRepsSuggestionMeta,
        ),
      );
    }
    if (data.containsKey('previous_rest_suggestion')) {
      context.handle(
        _previousRestSuggestionMeta,
        previousRestSuggestion.isAcceptableOrUnknown(
          data['previous_rest_suggestion']!,
          _previousRestSuggestionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramDayExerciseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramDayExerciseData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      programDayId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}program_day_id'],
          )!,
      exerciseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}exercise_id'],
          )!,
      position:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}position'],
          )!,
      modalityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modality_id'],
      ),
      setsSuggestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sets_suggestion'],
      ),
      repsSuggestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reps_suggestion'],
      ),
      restSuggestionSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_suggestion_sec'],
      ),
      previousSetsSuggestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_sets_suggestion'],
      ),
      previousRepsSuggestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_reps_suggestion'],
      ),
      previousRestSuggestion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_rest_suggestion'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
    );
  }

  @override
  $ProgramDayExerciseTable createAlias(String alias) {
    return $ProgramDayExerciseTable(attachedDatabase, alias);
  }
}

class ProgramDayExerciseData extends DataClass
    implements Insertable<ProgramDayExerciseData> {
  final int id;
  final int programDayId;
  final int exerciseId;
  final int position;
  final int? modalityId;
  final String? setsSuggestion;
  final String? repsSuggestion;
  final int? restSuggestionSec;
  final String? previousSetsSuggestion;
  final String? previousRepsSuggestion;
  final int? previousRestSuggestion;
  final String? notes;
  final DateTime? scheduledDate;
  const ProgramDayExerciseData({
    required this.id,
    required this.programDayId,
    required this.exerciseId,
    required this.position,
    this.modalityId,
    this.setsSuggestion,
    this.repsSuggestion,
    this.restSuggestionSec,
    this.previousSetsSuggestion,
    this.previousRepsSuggestion,
    this.previousRestSuggestion,
    this.notes,
    this.scheduledDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['program_day_id'] = Variable<int>(programDayId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || modalityId != null) {
      map['modality_id'] = Variable<int>(modalityId);
    }
    if (!nullToAbsent || setsSuggestion != null) {
      map['sets_suggestion'] = Variable<String>(setsSuggestion);
    }
    if (!nullToAbsent || repsSuggestion != null) {
      map['reps_suggestion'] = Variable<String>(repsSuggestion);
    }
    if (!nullToAbsent || restSuggestionSec != null) {
      map['rest_suggestion_sec'] = Variable<int>(restSuggestionSec);
    }
    if (!nullToAbsent || previousSetsSuggestion != null) {
      map['previous_sets_suggestion'] = Variable<String>(
        previousSetsSuggestion,
      );
    }
    if (!nullToAbsent || previousRepsSuggestion != null) {
      map['previous_reps_suggestion'] = Variable<String>(
        previousRepsSuggestion,
      );
    }
    if (!nullToAbsent || previousRestSuggestion != null) {
      map['previous_rest_suggestion'] = Variable<int>(previousRestSuggestion);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    return map;
  }

  ProgramDayExerciseCompanion toCompanion(bool nullToAbsent) {
    return ProgramDayExerciseCompanion(
      id: Value(id),
      programDayId: Value(programDayId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      modalityId:
          modalityId == null && nullToAbsent
              ? const Value.absent()
              : Value(modalityId),
      setsSuggestion:
          setsSuggestion == null && nullToAbsent
              ? const Value.absent()
              : Value(setsSuggestion),
      repsSuggestion:
          repsSuggestion == null && nullToAbsent
              ? const Value.absent()
              : Value(repsSuggestion),
      restSuggestionSec:
          restSuggestionSec == null && nullToAbsent
              ? const Value.absent()
              : Value(restSuggestionSec),
      previousSetsSuggestion:
          previousSetsSuggestion == null && nullToAbsent
              ? const Value.absent()
              : Value(previousSetsSuggestion),
      previousRepsSuggestion:
          previousRepsSuggestion == null && nullToAbsent
              ? const Value.absent()
              : Value(previousRepsSuggestion),
      previousRestSuggestion:
          previousRestSuggestion == null && nullToAbsent
              ? const Value.absent()
              : Value(previousRestSuggestion),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      scheduledDate:
          scheduledDate == null && nullToAbsent
              ? const Value.absent()
              : Value(scheduledDate),
    );
  }

  factory ProgramDayExerciseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramDayExerciseData(
      id: serializer.fromJson<int>(json['id']),
      programDayId: serializer.fromJson<int>(json['programDayId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      modalityId: serializer.fromJson<int?>(json['modalityId']),
      setsSuggestion: serializer.fromJson<String?>(json['setsSuggestion']),
      repsSuggestion: serializer.fromJson<String?>(json['repsSuggestion']),
      restSuggestionSec: serializer.fromJson<int?>(json['restSuggestionSec']),
      previousSetsSuggestion: serializer.fromJson<String?>(
        json['previousSetsSuggestion'],
      ),
      previousRepsSuggestion: serializer.fromJson<String?>(
        json['previousRepsSuggestion'],
      ),
      previousRestSuggestion: serializer.fromJson<int?>(
        json['previousRestSuggestion'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'programDayId': serializer.toJson<int>(programDayId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'position': serializer.toJson<int>(position),
      'modalityId': serializer.toJson<int?>(modalityId),
      'setsSuggestion': serializer.toJson<String?>(setsSuggestion),
      'repsSuggestion': serializer.toJson<String?>(repsSuggestion),
      'restSuggestionSec': serializer.toJson<int?>(restSuggestionSec),
      'previousSetsSuggestion': serializer.toJson<String?>(
        previousSetsSuggestion,
      ),
      'previousRepsSuggestion': serializer.toJson<String?>(
        previousRepsSuggestion,
      ),
      'previousRestSuggestion': serializer.toJson<int?>(previousRestSuggestion),
      'notes': serializer.toJson<String?>(notes),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
    };
  }

  ProgramDayExerciseData copyWith({
    int? id,
    int? programDayId,
    int? exerciseId,
    int? position,
    Value<int?> modalityId = const Value.absent(),
    Value<String?> setsSuggestion = const Value.absent(),
    Value<String?> repsSuggestion = const Value.absent(),
    Value<int?> restSuggestionSec = const Value.absent(),
    Value<String?> previousSetsSuggestion = const Value.absent(),
    Value<String?> previousRepsSuggestion = const Value.absent(),
    Value<int?> previousRestSuggestion = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> scheduledDate = const Value.absent(),
  }) => ProgramDayExerciseData(
    id: id ?? this.id,
    programDayId: programDayId ?? this.programDayId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    modalityId: modalityId.present ? modalityId.value : this.modalityId,
    setsSuggestion:
        setsSuggestion.present ? setsSuggestion.value : this.setsSuggestion,
    repsSuggestion:
        repsSuggestion.present ? repsSuggestion.value : this.repsSuggestion,
    restSuggestionSec:
        restSuggestionSec.present
            ? restSuggestionSec.value
            : this.restSuggestionSec,
    previousSetsSuggestion:
        previousSetsSuggestion.present
            ? previousSetsSuggestion.value
            : this.previousSetsSuggestion,
    previousRepsSuggestion:
        previousRepsSuggestion.present
            ? previousRepsSuggestion.value
            : this.previousRepsSuggestion,
    previousRestSuggestion:
        previousRestSuggestion.present
            ? previousRestSuggestion.value
            : this.previousRestSuggestion,
    notes: notes.present ? notes.value : this.notes,
    scheduledDate:
        scheduledDate.present ? scheduledDate.value : this.scheduledDate,
  );
  ProgramDayExerciseData copyWithCompanion(ProgramDayExerciseCompanion data) {
    return ProgramDayExerciseData(
      id: data.id.present ? data.id.value : this.id,
      programDayId:
          data.programDayId.present
              ? data.programDayId.value
              : this.programDayId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      modalityId:
          data.modalityId.present ? data.modalityId.value : this.modalityId,
      setsSuggestion:
          data.setsSuggestion.present
              ? data.setsSuggestion.value
              : this.setsSuggestion,
      repsSuggestion:
          data.repsSuggestion.present
              ? data.repsSuggestion.value
              : this.repsSuggestion,
      restSuggestionSec:
          data.restSuggestionSec.present
              ? data.restSuggestionSec.value
              : this.restSuggestionSec,
      previousSetsSuggestion:
          data.previousSetsSuggestion.present
              ? data.previousSetsSuggestion.value
              : this.previousSetsSuggestion,
      previousRepsSuggestion:
          data.previousRepsSuggestion.present
              ? data.previousRepsSuggestion.value
              : this.previousRepsSuggestion,
      previousRestSuggestion:
          data.previousRestSuggestion.present
              ? data.previousRestSuggestion.value
              : this.previousRestSuggestion,
      notes: data.notes.present ? data.notes.value : this.notes,
      scheduledDate:
          data.scheduledDate.present
              ? data.scheduledDate.value
              : this.scheduledDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayExerciseData(')
          ..write('id: $id, ')
          ..write('programDayId: $programDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('modalityId: $modalityId, ')
          ..write('setsSuggestion: $setsSuggestion, ')
          ..write('repsSuggestion: $repsSuggestion, ')
          ..write('restSuggestionSec: $restSuggestionSec, ')
          ..write('previousSetsSuggestion: $previousSetsSuggestion, ')
          ..write('previousRepsSuggestion: $previousRepsSuggestion, ')
          ..write('previousRestSuggestion: $previousRestSuggestion, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    programDayId,
    exerciseId,
    position,
    modalityId,
    setsSuggestion,
    repsSuggestion,
    restSuggestionSec,
    previousSetsSuggestion,
    previousRepsSuggestion,
    previousRestSuggestion,
    notes,
    scheduledDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramDayExerciseData &&
          other.id == this.id &&
          other.programDayId == this.programDayId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.modalityId == this.modalityId &&
          other.setsSuggestion == this.setsSuggestion &&
          other.repsSuggestion == this.repsSuggestion &&
          other.restSuggestionSec == this.restSuggestionSec &&
          other.previousSetsSuggestion == this.previousSetsSuggestion &&
          other.previousRepsSuggestion == this.previousRepsSuggestion &&
          other.previousRestSuggestion == this.previousRestSuggestion &&
          other.notes == this.notes &&
          other.scheduledDate == this.scheduledDate);
}

class ProgramDayExerciseCompanion
    extends UpdateCompanion<ProgramDayExerciseData> {
  final Value<int> id;
  final Value<int> programDayId;
  final Value<int> exerciseId;
  final Value<int> position;
  final Value<int?> modalityId;
  final Value<String?> setsSuggestion;
  final Value<String?> repsSuggestion;
  final Value<int?> restSuggestionSec;
  final Value<String?> previousSetsSuggestion;
  final Value<String?> previousRepsSuggestion;
  final Value<int?> previousRestSuggestion;
  final Value<String?> notes;
  final Value<DateTime?> scheduledDate;
  const ProgramDayExerciseCompanion({
    this.id = const Value.absent(),
    this.programDayId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.modalityId = const Value.absent(),
    this.setsSuggestion = const Value.absent(),
    this.repsSuggestion = const Value.absent(),
    this.restSuggestionSec = const Value.absent(),
    this.previousSetsSuggestion = const Value.absent(),
    this.previousRepsSuggestion = const Value.absent(),
    this.previousRestSuggestion = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledDate = const Value.absent(),
  });
  ProgramDayExerciseCompanion.insert({
    this.id = const Value.absent(),
    required int programDayId,
    required int exerciseId,
    required int position,
    this.modalityId = const Value.absent(),
    this.setsSuggestion = const Value.absent(),
    this.repsSuggestion = const Value.absent(),
    this.restSuggestionSec = const Value.absent(),
    this.previousSetsSuggestion = const Value.absent(),
    this.previousRepsSuggestion = const Value.absent(),
    this.previousRestSuggestion = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledDate = const Value.absent(),
  }) : programDayId = Value(programDayId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<ProgramDayExerciseData> custom({
    Expression<int>? id,
    Expression<int>? programDayId,
    Expression<int>? exerciseId,
    Expression<int>? position,
    Expression<int>? modalityId,
    Expression<String>? setsSuggestion,
    Expression<String>? repsSuggestion,
    Expression<int>? restSuggestionSec,
    Expression<String>? previousSetsSuggestion,
    Expression<String>? previousRepsSuggestion,
    Expression<int>? previousRestSuggestion,
    Expression<String>? notes,
    Expression<DateTime>? scheduledDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programDayId != null) 'program_day_id': programDayId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (modalityId != null) 'modality_id': modalityId,
      if (setsSuggestion != null) 'sets_suggestion': setsSuggestion,
      if (repsSuggestion != null) 'reps_suggestion': repsSuggestion,
      if (restSuggestionSec != null) 'rest_suggestion_sec': restSuggestionSec,
      if (previousSetsSuggestion != null)
        'previous_sets_suggestion': previousSetsSuggestion,
      if (previousRepsSuggestion != null)
        'previous_reps_suggestion': previousRepsSuggestion,
      if (previousRestSuggestion != null)
        'previous_rest_suggestion': previousRestSuggestion,
      if (notes != null) 'notes': notes,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
    });
  }

  ProgramDayExerciseCompanion copyWith({
    Value<int>? id,
    Value<int>? programDayId,
    Value<int>? exerciseId,
    Value<int>? position,
    Value<int?>? modalityId,
    Value<String?>? setsSuggestion,
    Value<String?>? repsSuggestion,
    Value<int?>? restSuggestionSec,
    Value<String?>? previousSetsSuggestion,
    Value<String?>? previousRepsSuggestion,
    Value<int?>? previousRestSuggestion,
    Value<String?>? notes,
    Value<DateTime?>? scheduledDate,
  }) {
    return ProgramDayExerciseCompanion(
      id: id ?? this.id,
      programDayId: programDayId ?? this.programDayId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      modalityId: modalityId ?? this.modalityId,
      setsSuggestion: setsSuggestion ?? this.setsSuggestion,
      repsSuggestion: repsSuggestion ?? this.repsSuggestion,
      restSuggestionSec: restSuggestionSec ?? this.restSuggestionSec,
      previousSetsSuggestion:
          previousSetsSuggestion ?? this.previousSetsSuggestion,
      previousRepsSuggestion:
          previousRepsSuggestion ?? this.previousRepsSuggestion,
      previousRestSuggestion:
          previousRestSuggestion ?? this.previousRestSuggestion,
      notes: notes ?? this.notes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (programDayId.present) {
      map['program_day_id'] = Variable<int>(programDayId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (modalityId.present) {
      map['modality_id'] = Variable<int>(modalityId.value);
    }
    if (setsSuggestion.present) {
      map['sets_suggestion'] = Variable<String>(setsSuggestion.value);
    }
    if (repsSuggestion.present) {
      map['reps_suggestion'] = Variable<String>(repsSuggestion.value);
    }
    if (restSuggestionSec.present) {
      map['rest_suggestion_sec'] = Variable<int>(restSuggestionSec.value);
    }
    if (previousSetsSuggestion.present) {
      map['previous_sets_suggestion'] = Variable<String>(
        previousSetsSuggestion.value,
      );
    }
    if (previousRepsSuggestion.present) {
      map['previous_reps_suggestion'] = Variable<String>(
        previousRepsSuggestion.value,
      );
    }
    if (previousRestSuggestion.present) {
      map['previous_rest_suggestion'] = Variable<int>(
        previousRestSuggestion.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramDayExerciseCompanion(')
          ..write('id: $id, ')
          ..write('programDayId: $programDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('modalityId: $modalityId, ')
          ..write('setsSuggestion: $setsSuggestion, ')
          ..write('repsSuggestion: $repsSuggestion, ')
          ..write('restSuggestionSec: $restSuggestionSec, ')
          ..write('previousSetsSuggestion: $previousSetsSuggestion, ')
          ..write('previousRepsSuggestion: $previousRepsSuggestion, ')
          ..write('previousRestSuggestion: $previousRestSuggestion, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate')
          ..write(')'))
        .toString();
  }
}

class $UserProgramTable extends UserProgram
    with TableInfo<$UserProgramTable, UserProgramData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgramTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES app_user (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_program (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startDateTsMeta = const VerificationMeta(
    'startDateTs',
  );
  @override
  late final GeneratedColumn<int> startDateTs = GeneratedColumn<int>(
    'start_date_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    programId,
    startDateTs,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_program';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgramData> instance, {
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
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('start_date_ts')) {
      context.handle(
        _startDateTsMeta,
        startDateTs.isAcceptableOrUnknown(
          data['start_date_ts']!,
          _startDateTsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startDateTsMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProgramData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgramData(
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
      programId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}program_id'],
          )!,
      startDateTs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}start_date_ts'],
          )!,
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_active'],
          )!,
    );
  }

  @override
  $UserProgramTable createAlias(String alias) {
    return $UserProgramTable(attachedDatabase, alias);
  }
}

class UserProgramData extends DataClass implements Insertable<UserProgramData> {
  final int id;
  final int userId;
  final int programId;
  final int startDateTs;
  final int isActive;
  const UserProgramData({
    required this.id,
    required this.userId,
    required this.programId,
    required this.startDateTs,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['program_id'] = Variable<int>(programId);
    map['start_date_ts'] = Variable<int>(startDateTs);
    map['is_active'] = Variable<int>(isActive);
    return map;
  }

  UserProgramCompanion toCompanion(bool nullToAbsent) {
    return UserProgramCompanion(
      id: Value(id),
      userId: Value(userId),
      programId: Value(programId),
      startDateTs: Value(startDateTs),
      isActive: Value(isActive),
    );
  }

  factory UserProgramData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgramData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      programId: serializer.fromJson<int>(json['programId']),
      startDateTs: serializer.fromJson<int>(json['startDateTs']),
      isActive: serializer.fromJson<int>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'programId': serializer.toJson<int>(programId),
      'startDateTs': serializer.toJson<int>(startDateTs),
      'isActive': serializer.toJson<int>(isActive),
    };
  }

  UserProgramData copyWith({
    int? id,
    int? userId,
    int? programId,
    int? startDateTs,
    int? isActive,
  }) => UserProgramData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    programId: programId ?? this.programId,
    startDateTs: startDateTs ?? this.startDateTs,
    isActive: isActive ?? this.isActive,
  );
  UserProgramData copyWithCompanion(UserProgramCompanion data) {
    return UserProgramData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      programId: data.programId.present ? data.programId.value : this.programId,
      startDateTs:
          data.startDateTs.present ? data.startDateTs.value : this.startDateTs,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgramData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('programId: $programId, ')
          ..write('startDateTs: $startDateTs, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, programId, startDateTs, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgramData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.programId == this.programId &&
          other.startDateTs == this.startDateTs &&
          other.isActive == this.isActive);
}

class UserProgramCompanion extends UpdateCompanion<UserProgramData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> programId;
  final Value<int> startDateTs;
  final Value<int> isActive;
  const UserProgramCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.programId = const Value.absent(),
    this.startDateTs = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  UserProgramCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int programId,
    required int startDateTs,
    this.isActive = const Value.absent(),
  }) : userId = Value(userId),
       programId = Value(programId),
       startDateTs = Value(startDateTs);
  static Insertable<UserProgramData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? programId,
    Expression<int>? startDateTs,
    Expression<int>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (programId != null) 'program_id': programId,
      if (startDateTs != null) 'start_date_ts': startDateTs,
      if (isActive != null) 'is_active': isActive,
    });
  }

  UserProgramCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? programId,
    Value<int>? startDateTs,
    Value<int>? isActive,
  }) {
    return UserProgramCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      programId: programId ?? this.programId,
      startDateTs: startDateTs ?? this.startDateTs,
      isActive: isActive ?? this.isActive,
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
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (startDateTs.present) {
      map['start_date_ts'] = Variable<int>(startDateTs.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgramCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('programId: $programId, ')
          ..write('startDateTs: $startDateTs, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $ExerciseTable exercise = $ExerciseTable(this);
  late final $MuscleTable muscle = $MuscleTable(this);
  late final $EquipmentTable equipment = $EquipmentTable(this);
  late final $ObjectiveTable objective = $ObjectiveTable(this);
  late final $TrainingModalityTable trainingModality = $TrainingModalityTable(
    this,
  );
  late final $ExerciseMuscleTable exerciseMuscle = $ExerciseMuscleTable(this);
  late final $ExerciseEquipmentTable exerciseEquipment =
      $ExerciseEquipmentTable(this);
  late final $ExerciseObjectiveTable exerciseObjective =
      $ExerciseObjectiveTable(this);
  late final $ExerciseRelationTable exerciseRelation = $ExerciseRelationTable(
    this,
  );
  late final $AppUserTable appUser = $AppUserTable(this);
  late final $UserEquipmentTable userEquipment = $UserEquipmentTable(this);
  late final $UserGoalTable userGoal = $UserGoalTable(this);
  late final $UserTrainingDayTable userTrainingDay = $UserTrainingDayTable(
    this,
  );
  late final $WorkoutProgramTable workoutProgram = $WorkoutProgramTable(this);
  late final $ProgramDayTable programDay = $ProgramDayTable(this);
  late final $SessionTable session = $SessionTable(this);
  late final $UserFeedbackTable userFeedback = $UserFeedbackTable(this);
  late final $SessionExerciseTable sessionExercise = $SessionExerciseTable(
    this,
  );
  late final $ProgramDayExerciseTable programDayExercise =
      $ProgramDayExerciseTable(this);
  late final $UserProgramTable userProgram = $UserProgramTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercise,
    muscle,
    equipment,
    objective,
    trainingModality,
    exerciseMuscle,
    exerciseEquipment,
    exerciseObjective,
    exerciseRelation,
    appUser,
    userEquipment,
    userGoal,
    userTrainingDay,
    workoutProgram,
    programDay,
    session,
    userFeedback,
    sessionExercise,
    programDayExercise,
    userProgram,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'objective',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('training_modality', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_muscle', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'muscle',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_muscle', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_equipment', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'equipment',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_equipment', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_objective', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'objective',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_objective', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_relation', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_relation', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'app_user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_equipment', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'equipment',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_equipment', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'app_user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_goal', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'objective',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_goal', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'app_user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_training_day', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'objective',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_program', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_program',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('program_day', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'app_user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'program_day',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'app_user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_feedback', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_feedback', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_feedback', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercise', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercise', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'program_day',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('program_day_exercise', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('program_day_exercise', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'training_modality',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('program_day_exercise', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'app_user',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_program', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_program',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_program', kind: UpdateKind.delete)],
    ),
  ]);
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

final class $$ExerciseTableReferences
    extends BaseReferences<_$AppDb, $ExerciseTable, ExerciseData> {
  $$ExerciseTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMuscleTable, List<ExerciseMuscleData>>
  _exerciseMuscleRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscle,
    aliasName: $_aliasNameGenerator(
      db.exercise.id,
      db.exerciseMuscle.exerciseId,
    ),
  );

  $$ExerciseMuscleTableProcessedTableManager get exerciseMuscleRefs {
    final manager = $$ExerciseMuscleTableTableManager(
      $_db,
      $_db.exerciseMuscle,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseMuscleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseEquipmentTable,
    List<ExerciseEquipmentData>
  >
  _exerciseEquipmentRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseEquipment,
    aliasName: $_aliasNameGenerator(
      db.exercise.id,
      db.exerciseEquipment.exerciseId,
    ),
  );

  $$ExerciseEquipmentTableProcessedTableManager get exerciseEquipmentRefs {
    final manager = $$ExerciseEquipmentTableTableManager(
      $_db,
      $_db.exerciseEquipment,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseEquipmentRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseObjectiveTable,
    List<ExerciseObjectiveData>
  >
  _exerciseObjectiveRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseObjective,
    aliasName: $_aliasNameGenerator(
      db.exercise.id,
      db.exerciseObjective.exerciseId,
    ),
  );

  $$ExerciseObjectiveTableProcessedTableManager get exerciseObjectiveRefs {
    final manager = $$ExerciseObjectiveTableTableManager(
      $_db,
      $_db.exerciseObjective,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseObjectiveRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseRelationTable, List<ExerciseRelationData>>
  _asSrcTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseRelation,
    aliasName: $_aliasNameGenerator(
      db.exercise.id,
      db.exerciseRelation.srcExerciseId,
    ),
  );

  $$ExerciseRelationTableProcessedTableManager get asSrc {
    final manager = $$ExerciseRelationTableTableManager(
      $_db,
      $_db.exerciseRelation,
    ).filter((f) => f.srcExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_asSrcTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseRelationTable, List<ExerciseRelationData>>
  _asDstTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseRelation,
    aliasName: $_aliasNameGenerator(
      db.exercise.id,
      db.exerciseRelation.dstExerciseId,
    ),
  );

  $$ExerciseRelationTableProcessedTableManager get asDst {
    final manager = $$ExerciseRelationTableTableManager(
      $_db,
      $_db.exerciseRelation,
    ).filter((f) => f.dstExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_asDstTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserFeedbackTable, List<UserFeedbackData>>
  _userFeedbackRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userFeedback,
    aliasName: $_aliasNameGenerator(db.exercise.id, db.userFeedback.exerciseId),
  );

  $$UserFeedbackTableProcessedTableManager get userFeedbackRefs {
    final manager = $$UserFeedbackTableTableManager(
      $_db,
      $_db.userFeedback,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userFeedbackRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionExerciseTable, List<SessionExerciseData>>
  _sessionExerciseRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.sessionExercise,
    aliasName: $_aliasNameGenerator(
      db.exercise.id,
      db.sessionExercise.exerciseId,
    ),
  );

  $$SessionExerciseTableProcessedTableManager get sessionExerciseRefs {
    final manager = $$SessionExerciseTableTableManager(
      $_db,
      $_db.sessionExercise,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExerciseRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramDayExerciseTable,
    List<ProgramDayExerciseData>
  >
  _programDayExerciseRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.programDayExercise,
    aliasName: $_aliasNameGenerator(
      db.exercise.id,
      db.programDayExercise.exerciseId,
    ),
  );

  $$ProgramDayExerciseTableProcessedTableManager get programDayExerciseRefs {
    final manager = $$ProgramDayExerciseTableTableManager(
      $_db,
      $_db.programDayExercise,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programDayExerciseRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnWithTypeConverterFilters<String, String, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cardio => $composableBuilder(
    column: $table.cardio,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMuscleRefs(
    Expression<bool> Function($$ExerciseMuscleTableFilterComposer f) f,
  ) {
    final $$ExerciseMuscleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscle,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseEquipmentRefs(
    Expression<bool> Function($$ExerciseEquipmentTableFilterComposer f) f,
  ) {
    final $$ExerciseEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipment,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.exerciseEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseObjectiveRefs(
    Expression<bool> Function($$ExerciseObjectiveTableFilterComposer f) f,
  ) {
    final $$ExerciseObjectiveTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseObjective,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseObjectiveTableFilterComposer(
            $db: $db,
            $table: $db.exerciseObjective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> asSrc(
    Expression<bool> Function($$ExerciseRelationTableFilterComposer f) f,
  ) {
    final $$ExerciseRelationTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRelation,
      getReferencedColumn: (t) => t.srcExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRelationTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRelation,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> asDst(
    Expression<bool> Function($$ExerciseRelationTableFilterComposer f) f,
  ) {
    final $$ExerciseRelationTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRelation,
      getReferencedColumn: (t) => t.dstExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRelationTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRelation,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userFeedbackRefs(
    Expression<bool> Function($$UserFeedbackTableFilterComposer f) f,
  ) {
    final $$UserFeedbackTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFeedback,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFeedbackTableFilterComposer(
            $db: $db,
            $table: $db.userFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionExerciseRefs(
    Expression<bool> Function($$SessionExerciseTableFilterComposer f) f,
  ) {
    final $$SessionExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExerciseTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programDayExerciseRefs(
    Expression<bool> Function($$ProgramDayExerciseTableFilterComposer f) f,
  ) {
    final $$ProgramDayExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDayExercise,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayExerciseTableFilterComposer(
            $db: $db,
            $table: $db.programDayExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  GeneratedColumnWithTypeConverter<String, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cardio =>
      $composableBuilder(column: $table.cardio, builder: (column) => column);

  Expression<T> exerciseMuscleRefs<T extends Object>(
    Expression<T> Function($$ExerciseMuscleTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMuscleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscle,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseEquipmentRefs<T extends Object>(
    Expression<T> Function($$ExerciseEquipmentTableAnnotationComposer a) f,
  ) {
    final $$ExerciseEquipmentTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseEquipment,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseEquipmentTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseEquipment,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> exerciseObjectiveRefs<T extends Object>(
    Expression<T> Function($$ExerciseObjectiveTableAnnotationComposer a) f,
  ) {
    final $$ExerciseObjectiveTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseObjective,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseObjectiveTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseObjective,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> asSrc<T extends Object>(
    Expression<T> Function($$ExerciseRelationTableAnnotationComposer a) f,
  ) {
    final $$ExerciseRelationTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRelation,
      getReferencedColumn: (t) => t.srcExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRelationTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRelation,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> asDst<T extends Object>(
    Expression<T> Function($$ExerciseRelationTableAnnotationComposer a) f,
  ) {
    final $$ExerciseRelationTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRelation,
      getReferencedColumn: (t) => t.dstExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRelationTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRelation,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userFeedbackRefs<T extends Object>(
    Expression<T> Function($$UserFeedbackTableAnnotationComposer a) f,
  ) {
    final $$UserFeedbackTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFeedback,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFeedbackTableAnnotationComposer(
            $db: $db,
            $table: $db.userFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionExerciseRefs<T extends Object>(
    Expression<T> Function($$SessionExerciseTableAnnotationComposer a) f,
  ) {
    final $$SessionExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> programDayExerciseRefs<T extends Object>(
    Expression<T> Function($$ProgramDayExerciseTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayExerciseTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programDayExercise,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramDayExerciseTableAnnotationComposer(
                $db: $db,
                $table: $db.programDayExercise,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (ExerciseData, $$ExerciseTableReferences),
          ExerciseData,
          PrefetchHooks Function({
            bool exerciseMuscleRefs,
            bool exerciseEquipmentRefs,
            bool exerciseObjectiveRefs,
            bool asSrc,
            bool asDst,
            bool userFeedbackRefs,
            bool sessionExerciseRefs,
            bool programDayExerciseRefs,
          })
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
                          $$ExerciseTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            exerciseMuscleRefs = false,
            exerciseEquipmentRefs = false,
            exerciseObjectiveRefs = false,
            asSrc = false,
            asDst = false,
            userFeedbackRefs = false,
            sessionExerciseRefs = false,
            programDayExerciseRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseMuscleRefs) db.exerciseMuscle,
                if (exerciseEquipmentRefs) db.exerciseEquipment,
                if (exerciseObjectiveRefs) db.exerciseObjective,
                if (asSrc) db.exerciseRelation,
                if (asDst) db.exerciseRelation,
                if (userFeedbackRefs) db.userFeedback,
                if (sessionExerciseRefs) db.sessionExercise,
                if (programDayExerciseRefs) db.programDayExercise,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseMuscleRefs)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      ExerciseMuscleData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences
                          ._exerciseMuscleRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseMuscleRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.exerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (exerciseEquipmentRefs)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      ExerciseEquipmentData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences
                          ._exerciseEquipmentRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseEquipmentRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.exerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (exerciseObjectiveRefs)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      ExerciseObjectiveData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences
                          ._exerciseObjectiveRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseObjectiveRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.exerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (asSrc)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      ExerciseRelationData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences._asSrcTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(db, table, p0).asSrc,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.srcExerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (asDst)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      ExerciseRelationData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences._asDstTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(db, table, p0).asDst,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.dstExerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (userFeedbackRefs)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      UserFeedbackData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences
                          ._userFeedbackRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(
                                db,
                                table,
                                p0,
                              ).userFeedbackRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.exerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (sessionExerciseRefs)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      SessionExerciseData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences
                          ._sessionExerciseRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExerciseRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.exerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (programDayExerciseRefs)
                    await $_getPrefetchedData<
                      ExerciseData,
                      $ExerciseTable,
                      ProgramDayExerciseData
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseTableReferences
                          ._programDayExerciseRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ExerciseTableReferences(
                                db,
                                table,
                                p0,
                              ).programDayExerciseRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.exerciseId == item.id,
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
      (ExerciseData, $$ExerciseTableReferences),
      ExerciseData,
      PrefetchHooks Function({
        bool exerciseMuscleRefs,
        bool exerciseEquipmentRefs,
        bool exerciseObjectiveRefs,
        bool asSrc,
        bool asDst,
        bool userFeedbackRefs,
        bool sessionExerciseRefs,
        bool programDayExerciseRefs,
      })
    >;
typedef $$MuscleTableCreateCompanionBuilder =
    MuscleCompanion Function({Value<int> id, required String name});
typedef $$MuscleTableUpdateCompanionBuilder =
    MuscleCompanion Function({Value<int> id, Value<String> name});

final class $$MuscleTableReferences
    extends BaseReferences<_$AppDb, $MuscleTable, MuscleData> {
  $$MuscleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMuscleTable, List<ExerciseMuscleData>>
  _exerciseMuscleRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscle,
    aliasName: $_aliasNameGenerator(db.muscle.id, db.exerciseMuscle.muscleId),
  );

  $$ExerciseMuscleTableProcessedTableManager get exerciseMuscleRefs {
    final manager = $$ExerciseMuscleTableTableManager(
      $_db,
      $_db.exerciseMuscle,
    ).filter((f) => f.muscleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseMuscleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> exerciseMuscleRefs(
    Expression<bool> Function($$ExerciseMuscleTableFilterComposer f) f,
  ) {
    final $$ExerciseMuscleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscle,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  Expression<T> exerciseMuscleRefs<T extends Object>(
    Expression<T> Function($$ExerciseMuscleTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMuscleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscle,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (MuscleData, $$MuscleTableReferences),
          MuscleData,
          PrefetchHooks Function({bool exerciseMuscleRefs})
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
                          $$MuscleTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({exerciseMuscleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseMuscleRefs) db.exerciseMuscle,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseMuscleRefs)
                    await $_getPrefetchedData<
                      MuscleData,
                      $MuscleTable,
                      ExerciseMuscleData
                    >(
                      currentTable: table,
                      referencedTable: $$MuscleTableReferences
                          ._exerciseMuscleRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MuscleTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseMuscleRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.muscleId == item.id,
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
      (MuscleData, $$MuscleTableReferences),
      MuscleData,
      PrefetchHooks Function({bool exerciseMuscleRefs})
    >;
typedef $$EquipmentTableCreateCompanionBuilder =
    EquipmentCompanion Function({Value<int> id, required String name});
typedef $$EquipmentTableUpdateCompanionBuilder =
    EquipmentCompanion Function({Value<int> id, Value<String> name});

final class $$EquipmentTableReferences
    extends BaseReferences<_$AppDb, $EquipmentTable, EquipmentData> {
  $$EquipmentTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ExerciseEquipmentTable,
    List<ExerciseEquipmentData>
  >
  _exerciseEquipmentRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseEquipment,
    aliasName: $_aliasNameGenerator(
      db.equipment.id,
      db.exerciseEquipment.equipmentId,
    ),
  );

  $$ExerciseEquipmentTableProcessedTableManager get exerciseEquipmentRefs {
    final manager = $$ExerciseEquipmentTableTableManager(
      $_db,
      $_db.exerciseEquipment,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseEquipmentRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserEquipmentTable, List<UserEquipmentData>>
  _userEquipmentRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userEquipment,
    aliasName: $_aliasNameGenerator(
      db.equipment.id,
      db.userEquipment.equipmentId,
    ),
  );

  $$UserEquipmentTableProcessedTableManager get userEquipmentRefs {
    final manager = $$UserEquipmentTableTableManager(
      $_db,
      $_db.userEquipment,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userEquipmentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> exerciseEquipmentRefs(
    Expression<bool> Function($$ExerciseEquipmentTableFilterComposer f) f,
  ) {
    final $$ExerciseEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipment,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.exerciseEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userEquipmentRefs(
    Expression<bool> Function($$UserEquipmentTableFilterComposer f) f,
  ) {
    final $$UserEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userEquipment,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.userEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  Expression<T> exerciseEquipmentRefs<T extends Object>(
    Expression<T> Function($$ExerciseEquipmentTableAnnotationComposer a) f,
  ) {
    final $$ExerciseEquipmentTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseEquipment,
          getReferencedColumn: (t) => t.equipmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseEquipmentTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseEquipment,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userEquipmentRefs<T extends Object>(
    Expression<T> Function($$UserEquipmentTableAnnotationComposer a) f,
  ) {
    final $$UserEquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userEquipment,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserEquipmentTableAnnotationComposer(
            $db: $db,
            $table: $db.userEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (EquipmentData, $$EquipmentTableReferences),
          EquipmentData,
          PrefetchHooks Function({
            bool exerciseEquipmentRefs,
            bool userEquipmentRefs,
          })
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
                          $$EquipmentTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            exerciseEquipmentRefs = false,
            userEquipmentRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseEquipmentRefs) db.exerciseEquipment,
                if (userEquipmentRefs) db.userEquipment,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseEquipmentRefs)
                    await $_getPrefetchedData<
                      EquipmentData,
                      $EquipmentTable,
                      ExerciseEquipmentData
                    >(
                      currentTable: table,
                      referencedTable: $$EquipmentTableReferences
                          ._exerciseEquipmentRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$EquipmentTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseEquipmentRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.equipmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (userEquipmentRefs)
                    await $_getPrefetchedData<
                      EquipmentData,
                      $EquipmentTable,
                      UserEquipmentData
                    >(
                      currentTable: table,
                      referencedTable: $$EquipmentTableReferences
                          ._userEquipmentRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$EquipmentTableReferences(
                                db,
                                table,
                                p0,
                              ).userEquipmentRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.equipmentId == item.id,
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
      (EquipmentData, $$EquipmentTableReferences),
      EquipmentData,
      PrefetchHooks Function({
        bool exerciseEquipmentRefs,
        bool userEquipmentRefs,
      })
    >;
typedef $$ObjectiveTableCreateCompanionBuilder =
    ObjectiveCompanion Function({
      Value<int> id,
      required String code,
      required String name,
    });
typedef $$ObjectiveTableUpdateCompanionBuilder =
    ObjectiveCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> name,
    });

final class $$ObjectiveTableReferences
    extends BaseReferences<_$AppDb, $ObjectiveTable, ObjectiveData> {
  $$ObjectiveTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrainingModalityTable, List<TrainingModalityData>>
  _trainingModalityRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.trainingModality,
    aliasName: $_aliasNameGenerator(
      db.objective.id,
      db.trainingModality.objectiveId,
    ),
  );

  $$TrainingModalityTableProcessedTableManager get trainingModalityRefs {
    final manager = $$TrainingModalityTableTableManager(
      $_db,
      $_db.trainingModality,
    ).filter((f) => f.objectiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trainingModalityRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseObjectiveTable,
    List<ExerciseObjectiveData>
  >
  _exerciseObjectiveRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.exerciseObjective,
    aliasName: $_aliasNameGenerator(
      db.objective.id,
      db.exerciseObjective.objectiveId,
    ),
  );

  $$ExerciseObjectiveTableProcessedTableManager get exerciseObjectiveRefs {
    final manager = $$ExerciseObjectiveTableTableManager(
      $_db,
      $_db.exerciseObjective,
    ).filter((f) => f.objectiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseObjectiveRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserGoalTable, List<UserGoalData>>
  _userGoalRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userGoal,
    aliasName: $_aliasNameGenerator(db.objective.id, db.userGoal.objectiveId),
  );

  $$UserGoalTableProcessedTableManager get userGoalRefs {
    final manager = $$UserGoalTableTableManager(
      $_db,
      $_db.userGoal,
    ).filter((f) => f.objectiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userGoalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutProgramTable, List<WorkoutProgramData>>
  _workoutProgramRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.workoutProgram,
    aliasName: $_aliasNameGenerator(
      db.objective.id,
      db.workoutProgram.objectiveId,
    ),
  );

  $$WorkoutProgramTableProcessedTableManager get workoutProgramRefs {
    final manager = $$WorkoutProgramTableTableManager(
      $_db,
      $_db.workoutProgram,
    ).filter((f) => f.objectiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutProgramRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObjectiveTableFilterComposer
    extends Composer<_$AppDb, $ObjectiveTable> {
  $$ObjectiveTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trainingModalityRefs(
    Expression<bool> Function($$TrainingModalityTableFilterComposer f) f,
  ) {
    final $$TrainingModalityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingModality,
      getReferencedColumn: (t) => t.objectiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingModalityTableFilterComposer(
            $db: $db,
            $table: $db.trainingModality,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseObjectiveRefs(
    Expression<bool> Function($$ExerciseObjectiveTableFilterComposer f) f,
  ) {
    final $$ExerciseObjectiveTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseObjective,
      getReferencedColumn: (t) => t.objectiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseObjectiveTableFilterComposer(
            $db: $db,
            $table: $db.exerciseObjective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userGoalRefs(
    Expression<bool> Function($$UserGoalTableFilterComposer f) f,
  ) {
    final $$UserGoalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGoal,
      getReferencedColumn: (t) => t.objectiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGoalTableFilterComposer(
            $db: $db,
            $table: $db.userGoal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutProgramRefs(
    Expression<bool> Function($$WorkoutProgramTableFilterComposer f) f,
  ) {
    final $$WorkoutProgramTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.objectiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableFilterComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectiveTableOrderingComposer
    extends Composer<_$AppDb, $ObjectiveTable> {
  $$ObjectiveTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObjectiveTableAnnotationComposer
    extends Composer<_$AppDb, $ObjectiveTable> {
  $$ObjectiveTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> trainingModalityRefs<T extends Object>(
    Expression<T> Function($$TrainingModalityTableAnnotationComposer a) f,
  ) {
    final $$TrainingModalityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingModality,
      getReferencedColumn: (t) => t.objectiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingModalityTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingModality,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseObjectiveRefs<T extends Object>(
    Expression<T> Function($$ExerciseObjectiveTableAnnotationComposer a) f,
  ) {
    final $$ExerciseObjectiveTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseObjective,
          getReferencedColumn: (t) => t.objectiveId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseObjectiveTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseObjective,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userGoalRefs<T extends Object>(
    Expression<T> Function($$UserGoalTableAnnotationComposer a) f,
  ) {
    final $$UserGoalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGoal,
      getReferencedColumn: (t) => t.objectiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGoalTableAnnotationComposer(
            $db: $db,
            $table: $db.userGoal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutProgramRefs<T extends Object>(
    Expression<T> Function($$WorkoutProgramTableAnnotationComposer a) f,
  ) {
    final $$WorkoutProgramTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.objectiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectiveTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ObjectiveTable,
          ObjectiveData,
          $$ObjectiveTableFilterComposer,
          $$ObjectiveTableOrderingComposer,
          $$ObjectiveTableAnnotationComposer,
          $$ObjectiveTableCreateCompanionBuilder,
          $$ObjectiveTableUpdateCompanionBuilder,
          (ObjectiveData, $$ObjectiveTableReferences),
          ObjectiveData,
          PrefetchHooks Function({
            bool trainingModalityRefs,
            bool exerciseObjectiveRefs,
            bool userGoalRefs,
            bool workoutProgramRefs,
          })
        > {
  $$ObjectiveTableTableManager(_$AppDb db, $ObjectiveTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ObjectiveTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ObjectiveTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ObjectiveTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => ObjectiveCompanion(id: id, code: code, name: name),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String name,
              }) => ObjectiveCompanion.insert(id: id, code: code, name: name),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ObjectiveTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            trainingModalityRefs = false,
            exerciseObjectiveRefs = false,
            userGoalRefs = false,
            workoutProgramRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trainingModalityRefs) db.trainingModality,
                if (exerciseObjectiveRefs) db.exerciseObjective,
                if (userGoalRefs) db.userGoal,
                if (workoutProgramRefs) db.workoutProgram,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trainingModalityRefs)
                    await $_getPrefetchedData<
                      ObjectiveData,
                      $ObjectiveTable,
                      TrainingModalityData
                    >(
                      currentTable: table,
                      referencedTable: $$ObjectiveTableReferences
                          ._trainingModalityRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ObjectiveTableReferences(
                                db,
                                table,
                                p0,
                              ).trainingModalityRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.objectiveId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (exerciseObjectiveRefs)
                    await $_getPrefetchedData<
                      ObjectiveData,
                      $ObjectiveTable,
                      ExerciseObjectiveData
                    >(
                      currentTable: table,
                      referencedTable: $$ObjectiveTableReferences
                          ._exerciseObjectiveRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ObjectiveTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseObjectiveRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.objectiveId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (userGoalRefs)
                    await $_getPrefetchedData<
                      ObjectiveData,
                      $ObjectiveTable,
                      UserGoalData
                    >(
                      currentTable: table,
                      referencedTable: $$ObjectiveTableReferences
                          ._userGoalRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ObjectiveTableReferences(
                                db,
                                table,
                                p0,
                              ).userGoalRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.objectiveId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (workoutProgramRefs)
                    await $_getPrefetchedData<
                      ObjectiveData,
                      $ObjectiveTable,
                      WorkoutProgramData
                    >(
                      currentTable: table,
                      referencedTable: $$ObjectiveTableReferences
                          ._workoutProgramRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ObjectiveTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutProgramRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.objectiveId == item.id,
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

typedef $$ObjectiveTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ObjectiveTable,
      ObjectiveData,
      $$ObjectiveTableFilterComposer,
      $$ObjectiveTableOrderingComposer,
      $$ObjectiveTableAnnotationComposer,
      $$ObjectiveTableCreateCompanionBuilder,
      $$ObjectiveTableUpdateCompanionBuilder,
      (ObjectiveData, $$ObjectiveTableReferences),
      ObjectiveData,
      PrefetchHooks Function({
        bool trainingModalityRefs,
        bool exerciseObjectiveRefs,
        bool userGoalRefs,
        bool workoutProgramRefs,
      })
    >;
typedef $$TrainingModalityTableCreateCompanionBuilder =
    TrainingModalityCompanion Function({
      Value<int> id,
      required int objectiveId,
      required String level,
      required String name,
      Value<int?> repMin,
      Value<int?> repMax,
      Value<int?> setMin,
      Value<int?> setMax,
      Value<int?> restMinSec,
      Value<int?> restMaxSec,
      Value<double?> rpeMin,
      Value<double?> rpeMax,
    });
typedef $$TrainingModalityTableUpdateCompanionBuilder =
    TrainingModalityCompanion Function({
      Value<int> id,
      Value<int> objectiveId,
      Value<String> level,
      Value<String> name,
      Value<int?> repMin,
      Value<int?> repMax,
      Value<int?> setMin,
      Value<int?> setMax,
      Value<int?> restMinSec,
      Value<int?> restMaxSec,
      Value<double?> rpeMin,
      Value<double?> rpeMax,
    });

final class $$TrainingModalityTableReferences
    extends
        BaseReferences<_$AppDb, $TrainingModalityTable, TrainingModalityData> {
  $$TrainingModalityTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ObjectiveTable _objectiveIdTable(_$AppDb db) =>
      db.objective.createAlias(
        $_aliasNameGenerator(db.trainingModality.objectiveId, db.objective.id),
      );

  $$ObjectiveTableProcessedTableManager get objectiveId {
    final $_column = $_itemColumn<int>('objective_id')!;

    final manager = $$ObjectiveTableTableManager(
      $_db,
      $_db.objective,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objectiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ProgramDayExerciseTable,
    List<ProgramDayExerciseData>
  >
  _programDayExerciseRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.programDayExercise,
    aliasName: $_aliasNameGenerator(
      db.trainingModality.id,
      db.programDayExercise.modalityId,
    ),
  );

  $$ProgramDayExerciseTableProcessedTableManager get programDayExerciseRefs {
    final manager = $$ProgramDayExerciseTableTableManager(
      $_db,
      $_db.programDayExercise,
    ).filter((f) => f.modalityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programDayExerciseRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingModalityTableFilterComposer
    extends Composer<_$AppDb, $TrainingModalityTable> {
  $$TrainingModalityTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, String> get level =>
      $composableBuilder(
        column: $table.level,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMin => $composableBuilder(
    column: $table.repMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMax => $composableBuilder(
    column: $table.repMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setMin => $composableBuilder(
    column: $table.setMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setMax => $composableBuilder(
    column: $table.setMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restMinSec => $composableBuilder(
    column: $table.restMinSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restMaxSec => $composableBuilder(
    column: $table.restMaxSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpeMin => $composableBuilder(
    column: $table.rpeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpeMax => $composableBuilder(
    column: $table.rpeMax,
    builder: (column) => ColumnFilters(column),
  );

  $$ObjectiveTableFilterComposer get objectiveId {
    final $$ObjectiveTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableFilterComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> programDayExerciseRefs(
    Expression<bool> Function($$ProgramDayExerciseTableFilterComposer f) f,
  ) {
    final $$ProgramDayExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDayExercise,
      getReferencedColumn: (t) => t.modalityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayExerciseTableFilterComposer(
            $db: $db,
            $table: $db.programDayExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingModalityTableOrderingComposer
    extends Composer<_$AppDb, $TrainingModalityTable> {
  $$TrainingModalityTableOrderingComposer({
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

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMin => $composableBuilder(
    column: $table.repMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMax => $composableBuilder(
    column: $table.repMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setMin => $composableBuilder(
    column: $table.setMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setMax => $composableBuilder(
    column: $table.setMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restMinSec => $composableBuilder(
    column: $table.restMinSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restMaxSec => $composableBuilder(
    column: $table.restMaxSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpeMin => $composableBuilder(
    column: $table.rpeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpeMax => $composableBuilder(
    column: $table.rpeMax,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObjectiveTableOrderingComposer get objectiveId {
    final $$ObjectiveTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableOrderingComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingModalityTableAnnotationComposer
    extends Composer<_$AppDb, $TrainingModalityTable> {
  $$TrainingModalityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get repMin =>
      $composableBuilder(column: $table.repMin, builder: (column) => column);

  GeneratedColumn<int> get repMax =>
      $composableBuilder(column: $table.repMax, builder: (column) => column);

  GeneratedColumn<int> get setMin =>
      $composableBuilder(column: $table.setMin, builder: (column) => column);

  GeneratedColumn<int> get setMax =>
      $composableBuilder(column: $table.setMax, builder: (column) => column);

  GeneratedColumn<int> get restMinSec => $composableBuilder(
    column: $table.restMinSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restMaxSec => $composableBuilder(
    column: $table.restMaxSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rpeMin =>
      $composableBuilder(column: $table.rpeMin, builder: (column) => column);

  GeneratedColumn<double> get rpeMax =>
      $composableBuilder(column: $table.rpeMax, builder: (column) => column);

  $$ObjectiveTableAnnotationComposer get objectiveId {
    final $$ObjectiveTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableAnnotationComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> programDayExerciseRefs<T extends Object>(
    Expression<T> Function($$ProgramDayExerciseTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayExerciseTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programDayExercise,
          getReferencedColumn: (t) => t.modalityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramDayExerciseTableAnnotationComposer(
                $db: $db,
                $table: $db.programDayExercise,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TrainingModalityTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TrainingModalityTable,
          TrainingModalityData,
          $$TrainingModalityTableFilterComposer,
          $$TrainingModalityTableOrderingComposer,
          $$TrainingModalityTableAnnotationComposer,
          $$TrainingModalityTableCreateCompanionBuilder,
          $$TrainingModalityTableUpdateCompanionBuilder,
          (TrainingModalityData, $$TrainingModalityTableReferences),
          TrainingModalityData,
          PrefetchHooks Function({
            bool objectiveId,
            bool programDayExerciseRefs,
          })
        > {
  $$TrainingModalityTableTableManager(_$AppDb db, $TrainingModalityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$TrainingModalityTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TrainingModalityTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$TrainingModalityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> objectiveId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> repMin = const Value.absent(),
                Value<int?> repMax = const Value.absent(),
                Value<int?> setMin = const Value.absent(),
                Value<int?> setMax = const Value.absent(),
                Value<int?> restMinSec = const Value.absent(),
                Value<int?> restMaxSec = const Value.absent(),
                Value<double?> rpeMin = const Value.absent(),
                Value<double?> rpeMax = const Value.absent(),
              }) => TrainingModalityCompanion(
                id: id,
                objectiveId: objectiveId,
                level: level,
                name: name,
                repMin: repMin,
                repMax: repMax,
                setMin: setMin,
                setMax: setMax,
                restMinSec: restMinSec,
                restMaxSec: restMaxSec,
                rpeMin: rpeMin,
                rpeMax: rpeMax,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int objectiveId,
                required String level,
                required String name,
                Value<int?> repMin = const Value.absent(),
                Value<int?> repMax = const Value.absent(),
                Value<int?> setMin = const Value.absent(),
                Value<int?> setMax = const Value.absent(),
                Value<int?> restMinSec = const Value.absent(),
                Value<int?> restMaxSec = const Value.absent(),
                Value<double?> rpeMin = const Value.absent(),
                Value<double?> rpeMax = const Value.absent(),
              }) => TrainingModalityCompanion.insert(
                id: id,
                objectiveId: objectiveId,
                level: level,
                name: name,
                repMin: repMin,
                repMax: repMax,
                setMin: setMin,
                setMax: setMax,
                restMinSec: restMinSec,
                restMaxSec: restMaxSec,
                rpeMin: rpeMin,
                rpeMax: rpeMax,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TrainingModalityTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            objectiveId = false,
            programDayExerciseRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (programDayExerciseRefs) db.programDayExercise,
              ],
              addJoins: <
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
                if (objectiveId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.objectiveId,
                            referencedTable: $$TrainingModalityTableReferences
                                ._objectiveIdTable(db),
                            referencedColumn:
                                $$TrainingModalityTableReferences
                                    ._objectiveIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (programDayExerciseRefs)
                    await $_getPrefetchedData<
                      TrainingModalityData,
                      $TrainingModalityTable,
                      ProgramDayExerciseData
                    >(
                      currentTable: table,
                      referencedTable: $$TrainingModalityTableReferences
                          ._programDayExerciseRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$TrainingModalityTableReferences(
                                db,
                                table,
                                p0,
                              ).programDayExerciseRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.modalityId == item.id,
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

typedef $$TrainingModalityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TrainingModalityTable,
      TrainingModalityData,
      $$TrainingModalityTableFilterComposer,
      $$TrainingModalityTableOrderingComposer,
      $$TrainingModalityTableAnnotationComposer,
      $$TrainingModalityTableCreateCompanionBuilder,
      $$TrainingModalityTableUpdateCompanionBuilder,
      (TrainingModalityData, $$TrainingModalityTableReferences),
      TrainingModalityData,
      PrefetchHooks Function({bool objectiveId, bool programDayExerciseRefs})
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

final class $$ExerciseMuscleTableReferences
    extends BaseReferences<_$AppDb, $ExerciseMuscleTable, ExerciseMuscleData> {
  $$ExerciseMuscleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTable _exerciseIdTable(_$AppDb db) => db.exercise.createAlias(
    $_aliasNameGenerator(db.exerciseMuscle.exerciseId, db.exercise.id),
  );

  $$ExerciseTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MuscleTable _muscleIdTable(_$AppDb db) => db.muscle.createAlias(
    $_aliasNameGenerator(db.exerciseMuscle.muscleId, db.muscle.id),
  );

  $$MuscleTableProcessedTableManager get muscleId {
    final $_column = $_itemColumn<int>('muscle_id')!;

    final manager = $$MuscleTableTableManager(
      $_db,
      $_db.muscle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muscleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMuscleTableFilterComposer
    extends Composer<_$AppDb, $ExerciseMuscleTable> {
  $$ExerciseMuscleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseTableFilterComposer get exerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableFilterComposer get muscleId {
    final $$MuscleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableFilterComposer(
            $db: $db,
            $table: $db.muscle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseTableOrderingComposer get exerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableOrderingComposer get muscleId {
    final $$MuscleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableOrderingComposer(
            $db: $db,
            $table: $db.muscle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  $$ExerciseTableAnnotationComposer get exerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableAnnotationComposer get muscleId {
    final $$MuscleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableAnnotationComposer(
            $db: $db,
            $table: $db.muscle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (ExerciseMuscleData, $$ExerciseMuscleTableReferences),
          ExerciseMuscleData,
          PrefetchHooks Function({bool exerciseId, bool muscleId})
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
                          $$ExerciseMuscleTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({exerciseId = false, muscleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (exerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$ExerciseMuscleTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn:
                                $$ExerciseMuscleTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (muscleId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.muscleId,
                            referencedTable: $$ExerciseMuscleTableReferences
                                ._muscleIdTable(db),
                            referencedColumn:
                                $$ExerciseMuscleTableReferences
                                    ._muscleIdTable(db)
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
      (ExerciseMuscleData, $$ExerciseMuscleTableReferences),
      ExerciseMuscleData,
      PrefetchHooks Function({bool exerciseId, bool muscleId})
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

final class $$ExerciseEquipmentTableReferences
    extends
        BaseReferences<
          _$AppDb,
          $ExerciseEquipmentTable,
          ExerciseEquipmentData
        > {
  $$ExerciseEquipmentTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTable _exerciseIdTable(_$AppDb db) => db.exercise.createAlias(
    $_aliasNameGenerator(db.exerciseEquipment.exerciseId, db.exercise.id),
  );

  $$ExerciseTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentTable _equipmentIdTable(_$AppDb db) =>
      db.equipment.createAlias(
        $_aliasNameGenerator(db.exerciseEquipment.equipmentId, db.equipment.id),
      );

  $$EquipmentTableProcessedTableManager get equipmentId {
    final $_column = $_itemColumn<int>('equipment_id')!;

    final manager = $$EquipmentTableTableManager(
      $_db,
      $_db.equipment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseEquipmentTableFilterComposer
    extends Composer<_$AppDb, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ExerciseTableFilterComposer get exerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableFilterComposer get equipmentId {
    final $$EquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableFilterComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  $$ExerciseTableOrderingComposer get exerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableOrderingComposer get equipmentId {
    final $$EquipmentTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableOrderingComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  $$ExerciseTableAnnotationComposer get exerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableAnnotationComposer get equipmentId {
    final $$EquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableAnnotationComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (ExerciseEquipmentData, $$ExerciseEquipmentTableReferences),
          ExerciseEquipmentData,
          PrefetchHooks Function({bool exerciseId, bool equipmentId})
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
                          $$ExerciseEquipmentTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({exerciseId = false, equipmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (exerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$ExerciseEquipmentTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn:
                                $$ExerciseEquipmentTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (equipmentId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.equipmentId,
                            referencedTable: $$ExerciseEquipmentTableReferences
                                ._equipmentIdTable(db),
                            referencedColumn:
                                $$ExerciseEquipmentTableReferences
                                    ._equipmentIdTable(db)
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
      (ExerciseEquipmentData, $$ExerciseEquipmentTableReferences),
      ExerciseEquipmentData,
      PrefetchHooks Function({bool exerciseId, bool equipmentId})
    >;
typedef $$ExerciseObjectiveTableCreateCompanionBuilder =
    ExerciseObjectiveCompanion Function({
      required int exerciseId,
      required int objectiveId,
      required double weight,
      Value<int> rowid,
    });
typedef $$ExerciseObjectiveTableUpdateCompanionBuilder =
    ExerciseObjectiveCompanion Function({
      Value<int> exerciseId,
      Value<int> objectiveId,
      Value<double> weight,
      Value<int> rowid,
    });

final class $$ExerciseObjectiveTableReferences
    extends
        BaseReferences<
          _$AppDb,
          $ExerciseObjectiveTable,
          ExerciseObjectiveData
        > {
  $$ExerciseObjectiveTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTable _exerciseIdTable(_$AppDb db) => db.exercise.createAlias(
    $_aliasNameGenerator(db.exerciseObjective.exerciseId, db.exercise.id),
  );

  $$ExerciseTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ObjectiveTable _objectiveIdTable(_$AppDb db) =>
      db.objective.createAlias(
        $_aliasNameGenerator(db.exerciseObjective.objectiveId, db.objective.id),
      );

  $$ObjectiveTableProcessedTableManager get objectiveId {
    final $_column = $_itemColumn<int>('objective_id')!;

    final manager = $$ObjectiveTableTableManager(
      $_db,
      $_db.objective,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objectiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseObjectiveTableFilterComposer
    extends Composer<_$AppDb, $ExerciseObjectiveTable> {
  $$ExerciseObjectiveTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseTableFilterComposer get exerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectiveTableFilterComposer get objectiveId {
    final $$ObjectiveTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableFilterComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseObjectiveTableOrderingComposer
    extends Composer<_$AppDb, $ExerciseObjectiveTable> {
  $$ExerciseObjectiveTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseTableOrderingComposer get exerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectiveTableOrderingComposer get objectiveId {
    final $$ObjectiveTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableOrderingComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseObjectiveTableAnnotationComposer
    extends Composer<_$AppDb, $ExerciseObjectiveTable> {
  $$ExerciseObjectiveTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  $$ExerciseTableAnnotationComposer get exerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectiveTableAnnotationComposer get objectiveId {
    final $$ObjectiveTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableAnnotationComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseObjectiveTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExerciseObjectiveTable,
          ExerciseObjectiveData,
          $$ExerciseObjectiveTableFilterComposer,
          $$ExerciseObjectiveTableOrderingComposer,
          $$ExerciseObjectiveTableAnnotationComposer,
          $$ExerciseObjectiveTableCreateCompanionBuilder,
          $$ExerciseObjectiveTableUpdateCompanionBuilder,
          (ExerciseObjectiveData, $$ExerciseObjectiveTableReferences),
          ExerciseObjectiveData,
          PrefetchHooks Function({bool exerciseId, bool objectiveId})
        > {
  $$ExerciseObjectiveTableTableManager(
    _$AppDb db,
    $ExerciseObjectiveTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ExerciseObjectiveTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ExerciseObjectiveTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ExerciseObjectiveTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> exerciseId = const Value.absent(),
                Value<int> objectiveId = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseObjectiveCompanion(
                exerciseId: exerciseId,
                objectiveId: objectiveId,
                weight: weight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int exerciseId,
                required int objectiveId,
                required double weight,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseObjectiveCompanion.insert(
                exerciseId: exerciseId,
                objectiveId: objectiveId,
                weight: weight,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ExerciseObjectiveTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({exerciseId = false, objectiveId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (exerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$ExerciseObjectiveTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn:
                                $$ExerciseObjectiveTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (objectiveId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.objectiveId,
                            referencedTable: $$ExerciseObjectiveTableReferences
                                ._objectiveIdTable(db),
                            referencedColumn:
                                $$ExerciseObjectiveTableReferences
                                    ._objectiveIdTable(db)
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

typedef $$ExerciseObjectiveTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExerciseObjectiveTable,
      ExerciseObjectiveData,
      $$ExerciseObjectiveTableFilterComposer,
      $$ExerciseObjectiveTableOrderingComposer,
      $$ExerciseObjectiveTableAnnotationComposer,
      $$ExerciseObjectiveTableCreateCompanionBuilder,
      $$ExerciseObjectiveTableUpdateCompanionBuilder,
      (ExerciseObjectiveData, $$ExerciseObjectiveTableReferences),
      ExerciseObjectiveData,
      PrefetchHooks Function({bool exerciseId, bool objectiveId})
    >;
typedef $$ExerciseRelationTableCreateCompanionBuilder =
    ExerciseRelationCompanion Function({
      required int srcExerciseId,
      required int dstExerciseId,
      required String relationType,
      required double weight,
      Value<int> rowid,
    });
typedef $$ExerciseRelationTableUpdateCompanionBuilder =
    ExerciseRelationCompanion Function({
      Value<int> srcExerciseId,
      Value<int> dstExerciseId,
      Value<String> relationType,
      Value<double> weight,
      Value<int> rowid,
    });

final class $$ExerciseRelationTableReferences
    extends
        BaseReferences<_$AppDb, $ExerciseRelationTable, ExerciseRelationData> {
  $$ExerciseRelationTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTable _srcExerciseIdTable(_$AppDb db) =>
      db.exercise.createAlias(
        $_aliasNameGenerator(db.exerciseRelation.srcExerciseId, db.exercise.id),
      );

  $$ExerciseTableProcessedTableManager get srcExerciseId {
    final $_column = $_itemColumn<int>('src_exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_srcExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseTable _dstExerciseIdTable(_$AppDb db) =>
      db.exercise.createAlias(
        $_aliasNameGenerator(db.exerciseRelation.dstExerciseId, db.exercise.id),
      );

  $$ExerciseTableProcessedTableManager get dstExerciseId {
    final $_column = $_itemColumn<int>('dst_exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dstExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseRelationTableFilterComposer
    extends Composer<_$AppDb, $ExerciseRelationTable> {
  $$ExerciseRelationTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, String> get relationType =>
      $composableBuilder(
        column: $table.relationType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseTableFilterComposer get srcExerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcExerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableFilterComposer get dstExerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstExerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseRelationTableOrderingComposer
    extends Composer<_$AppDb, $ExerciseRelationTable> {
  $$ExerciseRelationTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseTableOrderingComposer get srcExerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcExerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableOrderingComposer get dstExerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstExerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseRelationTableAnnotationComposer
    extends Composer<_$AppDb, $ExerciseRelationTable> {
  $$ExerciseRelationTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, String> get relationType =>
      $composableBuilder(
        column: $table.relationType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  $$ExerciseTableAnnotationComposer get srcExerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcExerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableAnnotationComposer get dstExerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstExerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseRelationTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExerciseRelationTable,
          ExerciseRelationData,
          $$ExerciseRelationTableFilterComposer,
          $$ExerciseRelationTableOrderingComposer,
          $$ExerciseRelationTableAnnotationComposer,
          $$ExerciseRelationTableCreateCompanionBuilder,
          $$ExerciseRelationTableUpdateCompanionBuilder,
          (ExerciseRelationData, $$ExerciseRelationTableReferences),
          ExerciseRelationData,
          PrefetchHooks Function({bool srcExerciseId, bool dstExerciseId})
        > {
  $$ExerciseRelationTableTableManager(_$AppDb db, $ExerciseRelationTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$ExerciseRelationTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ExerciseRelationTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ExerciseRelationTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> srcExerciseId = const Value.absent(),
                Value<int> dstExerciseId = const Value.absent(),
                Value<String> relationType = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseRelationCompanion(
                srcExerciseId: srcExerciseId,
                dstExerciseId: dstExerciseId,
                relationType: relationType,
                weight: weight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int srcExerciseId,
                required int dstExerciseId,
                required String relationType,
                required double weight,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseRelationCompanion.insert(
                srcExerciseId: srcExerciseId,
                dstExerciseId: dstExerciseId,
                relationType: relationType,
                weight: weight,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ExerciseRelationTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            srcExerciseId = false,
            dstExerciseId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (srcExerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.srcExerciseId,
                            referencedTable: $$ExerciseRelationTableReferences
                                ._srcExerciseIdTable(db),
                            referencedColumn:
                                $$ExerciseRelationTableReferences
                                    ._srcExerciseIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (dstExerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.dstExerciseId,
                            referencedTable: $$ExerciseRelationTableReferences
                                ._dstExerciseIdTable(db),
                            referencedColumn:
                                $$ExerciseRelationTableReferences
                                    ._dstExerciseIdTable(db)
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

typedef $$ExerciseRelationTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExerciseRelationTable,
      ExerciseRelationData,
      $$ExerciseRelationTableFilterComposer,
      $$ExerciseRelationTableOrderingComposer,
      $$ExerciseRelationTableAnnotationComposer,
      $$ExerciseRelationTableCreateCompanionBuilder,
      $$ExerciseRelationTableUpdateCompanionBuilder,
      (ExerciseRelationData, $$ExerciseRelationTableReferences),
      ExerciseRelationData,
      PrefetchHooks Function({bool srcExerciseId, bool dstExerciseId})
    >;
typedef $$AppUserTableCreateCompanionBuilder =
    AppUserCompanion Function({
      Value<int> id,
      Value<int?> age,
      Value<double?> weight,
      Value<double?> height,
      Value<String?> gender,
      Value<DateTime?> birthDate,
      Value<String?> level,
      Value<String?> metabolism,
      Value<String?> nom,
      Value<String?> prenom,
      Value<int> singleton,
    });
typedef $$AppUserTableUpdateCompanionBuilder =
    AppUserCompanion Function({
      Value<int> id,
      Value<int?> age,
      Value<double?> weight,
      Value<double?> height,
      Value<String?> gender,
      Value<DateTime?> birthDate,
      Value<String?> level,
      Value<String?> metabolism,
      Value<String?> nom,
      Value<String?> prenom,
      Value<int> singleton,
    });

final class $$AppUserTableReferences
    extends BaseReferences<_$AppDb, $AppUserTable, AppUserData> {
  $$AppUserTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserEquipmentTable, List<UserEquipmentData>>
  _userEquipmentRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userEquipment,
    aliasName: $_aliasNameGenerator(db.appUser.id, db.userEquipment.userId),
  );

  $$UserEquipmentTableProcessedTableManager get userEquipmentRefs {
    final manager = $$UserEquipmentTableTableManager(
      $_db,
      $_db.userEquipment,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userEquipmentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserGoalTable, List<UserGoalData>>
  _userGoalRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userGoal,
    aliasName: $_aliasNameGenerator(db.appUser.id, db.userGoal.userId),
  );

  $$UserGoalTableProcessedTableManager get userGoalRefs {
    final manager = $$UserGoalTableTableManager(
      $_db,
      $_db.userGoal,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userGoalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserTrainingDayTable, List<UserTrainingDayData>>
  _userTrainingDayRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userTrainingDay,
    aliasName: $_aliasNameGenerator(db.appUser.id, db.userTrainingDay.userId),
  );

  $$UserTrainingDayTableProcessedTableManager get userTrainingDayRefs {
    final manager = $$UserTrainingDayTableTableManager(
      $_db,
      $_db.userTrainingDay,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userTrainingDayRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionTable, List<SessionData>>
  _sessionRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.session,
    aliasName: $_aliasNameGenerator(db.appUser.id, db.session.userId),
  );

  $$SessionTableProcessedTableManager get sessionRefs {
    final manager = $$SessionTableTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserFeedbackTable, List<UserFeedbackData>>
  _userFeedbackRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userFeedback,
    aliasName: $_aliasNameGenerator(db.appUser.id, db.userFeedback.userId),
  );

  $$UserFeedbackTableProcessedTableManager get userFeedbackRefs {
    final manager = $$UserFeedbackTableTableManager(
      $_db,
      $_db.userFeedback,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userFeedbackRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserProgramTable, List<UserProgramData>>
  _userProgramRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userProgram,
    aliasName: $_aliasNameGenerator(db.appUser.id, db.userProgram.userId),
  );

  $$UserProgramTableProcessedTableManager get userProgramRefs {
    final manager = $$UserProgramTableTableManager(
      $_db,
      $_db.userProgram,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProgramRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, String> get gender =>
      $composableBuilder(
        column: $table.gender,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, String> get level =>
      $composableBuilder(
        column: $table.level,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String?, String, String> get metabolism =>
      $composableBuilder(
        column: $table.metabolism,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userEquipmentRefs(
    Expression<bool> Function($$UserEquipmentTableFilterComposer f) f,
  ) {
    final $$UserEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userEquipment,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.userEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userGoalRefs(
    Expression<bool> Function($$UserGoalTableFilterComposer f) f,
  ) {
    final $$UserGoalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGoal,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGoalTableFilterComposer(
            $db: $db,
            $table: $db.userGoal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userTrainingDayRefs(
    Expression<bool> Function($$UserTrainingDayTableFilterComposer f) f,
  ) {
    final $$UserTrainingDayTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTrainingDay,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTrainingDayTableFilterComposer(
            $db: $db,
            $table: $db.userTrainingDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionRefs(
    Expression<bool> Function($$SessionTableFilterComposer f) f,
  ) {
    final $$SessionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userFeedbackRefs(
    Expression<bool> Function($$UserFeedbackTableFilterComposer f) f,
  ) {
    final $$UserFeedbackTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFeedback,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFeedbackTableFilterComposer(
            $db: $db,
            $table: $db.userFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userProgramRefs(
    Expression<bool> Function($$UserProgramTableFilterComposer f) f,
  ) {
    final $$UserProgramTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgram,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramTableFilterComposer(
            $db: $db,
            $table: $db.userProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metabolism => $composableBuilder(
    column: $table.metabolism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
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

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, String> get metabolism =>
      $composableBuilder(
        column: $table.metabolism,
        builder: (column) => column,
      );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get prenom =>
      $composableBuilder(column: $table.prenom, builder: (column) => column);

  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  Expression<T> userEquipmentRefs<T extends Object>(
    Expression<T> Function($$UserEquipmentTableAnnotationComposer a) f,
  ) {
    final $$UserEquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userEquipment,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserEquipmentTableAnnotationComposer(
            $db: $db,
            $table: $db.userEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userGoalRefs<T extends Object>(
    Expression<T> Function($$UserGoalTableAnnotationComposer a) f,
  ) {
    final $$UserGoalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGoal,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserGoalTableAnnotationComposer(
            $db: $db,
            $table: $db.userGoal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userTrainingDayRefs<T extends Object>(
    Expression<T> Function($$UserTrainingDayTableAnnotationComposer a) f,
  ) {
    final $$UserTrainingDayTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTrainingDay,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTrainingDayTableAnnotationComposer(
            $db: $db,
            $table: $db.userTrainingDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionRefs<T extends Object>(
    Expression<T> Function($$SessionTableAnnotationComposer a) f,
  ) {
    final $$SessionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userFeedbackRefs<T extends Object>(
    Expression<T> Function($$UserFeedbackTableAnnotationComposer a) f,
  ) {
    final $$UserFeedbackTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFeedback,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFeedbackTableAnnotationComposer(
            $db: $db,
            $table: $db.userFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userProgramRefs<T extends Object>(
    Expression<T> Function($$UserProgramTableAnnotationComposer a) f,
  ) {
    final $$UserProgramTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgram,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (AppUserData, $$AppUserTableReferences),
          AppUserData,
          PrefetchHooks Function({
            bool userEquipmentRefs,
            bool userGoalRefs,
            bool userTrainingDayRefs,
            bool sessionRefs,
            bool userFeedbackRefs,
            bool userProgramRefs,
          })
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
                Value<int?> age = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> metabolism = const Value.absent(),
                Value<String?> nom = const Value.absent(),
                Value<String?> prenom = const Value.absent(),
                Value<int> singleton = const Value.absent(),
              }) => AppUserCompanion(
                id: id,
                age: age,
                weight: weight,
                height: height,
                gender: gender,
                birthDate: birthDate,
                level: level,
                metabolism: metabolism,
                nom: nom,
                prenom: prenom,
                singleton: singleton,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> metabolism = const Value.absent(),
                Value<String?> nom = const Value.absent(),
                Value<String?> prenom = const Value.absent(),
                Value<int> singleton = const Value.absent(),
              }) => AppUserCompanion.insert(
                id: id,
                age: age,
                weight: weight,
                height: height,
                gender: gender,
                birthDate: birthDate,
                level: level,
                metabolism: metabolism,
                nom: nom,
                prenom: prenom,
                singleton: singleton,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AppUserTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            userEquipmentRefs = false,
            userGoalRefs = false,
            userTrainingDayRefs = false,
            sessionRefs = false,
            userFeedbackRefs = false,
            userProgramRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userEquipmentRefs) db.userEquipment,
                if (userGoalRefs) db.userGoal,
                if (userTrainingDayRefs) db.userTrainingDay,
                if (sessionRefs) db.session,
                if (userFeedbackRefs) db.userFeedback,
                if (userProgramRefs) db.userProgram,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userEquipmentRefs)
                    await $_getPrefetchedData<
                      AppUserData,
                      $AppUserTable,
                      UserEquipmentData
                    >(
                      currentTable: table,
                      referencedTable: $$AppUserTableReferences
                          ._userEquipmentRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AppUserTableReferences(
                                db,
                                table,
                                p0,
                              ).userEquipmentRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                  if (userGoalRefs)
                    await $_getPrefetchedData<
                      AppUserData,
                      $AppUserTable,
                      UserGoalData
                    >(
                      currentTable: table,
                      referencedTable: $$AppUserTableReferences
                          ._userGoalRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AppUserTableReferences(
                                db,
                                table,
                                p0,
                              ).userGoalRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                  if (userTrainingDayRefs)
                    await $_getPrefetchedData<
                      AppUserData,
                      $AppUserTable,
                      UserTrainingDayData
                    >(
                      currentTable: table,
                      referencedTable: $$AppUserTableReferences
                          ._userTrainingDayRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AppUserTableReferences(
                                db,
                                table,
                                p0,
                              ).userTrainingDayRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                  if (sessionRefs)
                    await $_getPrefetchedData<
                      AppUserData,
                      $AppUserTable,
                      SessionData
                    >(
                      currentTable: table,
                      referencedTable: $$AppUserTableReferences
                          ._sessionRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AppUserTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                  if (userFeedbackRefs)
                    await $_getPrefetchedData<
                      AppUserData,
                      $AppUserTable,
                      UserFeedbackData
                    >(
                      currentTable: table,
                      referencedTable: $$AppUserTableReferences
                          ._userFeedbackRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AppUserTableReferences(
                                db,
                                table,
                                p0,
                              ).userFeedbackRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                  if (userProgramRefs)
                    await $_getPrefetchedData<
                      AppUserData,
                      $AppUserTable,
                      UserProgramData
                    >(
                      currentTable: table,
                      referencedTable: $$AppUserTableReferences
                          ._userProgramRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AppUserTableReferences(
                                db,
                                table,
                                p0,
                              ).userProgramRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (AppUserData, $$AppUserTableReferences),
      AppUserData,
      PrefetchHooks Function({
        bool userEquipmentRefs,
        bool userGoalRefs,
        bool userTrainingDayRefs,
        bool sessionRefs,
        bool userFeedbackRefs,
        bool userProgramRefs,
      })
    >;
typedef $$UserEquipmentTableCreateCompanionBuilder =
    UserEquipmentCompanion Function({
      required int userId,
      required int equipmentId,
      Value<int> rowid,
    });
typedef $$UserEquipmentTableUpdateCompanionBuilder =
    UserEquipmentCompanion Function({
      Value<int> userId,
      Value<int> equipmentId,
      Value<int> rowid,
    });

final class $$UserEquipmentTableReferences
    extends BaseReferences<_$AppDb, $UserEquipmentTable, UserEquipmentData> {
  $$UserEquipmentTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AppUserTable _userIdTable(_$AppDb db) => db.appUser.createAlias(
    $_aliasNameGenerator(db.userEquipment.userId, db.appUser.id),
  );

  $$AppUserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUserTableTableManager(
      $_db,
      $_db.appUser,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentTable _equipmentIdTable(_$AppDb db) =>
      db.equipment.createAlias(
        $_aliasNameGenerator(db.userEquipment.equipmentId, db.equipment.id),
      );

  $$EquipmentTableProcessedTableManager get equipmentId {
    final $_column = $_itemColumn<int>('equipment_id')!;

    final manager = $$EquipmentTableTableManager(
      $_db,
      $_db.equipment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserEquipmentTableFilterComposer
    extends Composer<_$AppDb, $UserEquipmentTable> {
  $$UserEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AppUserTableFilterComposer get userId {
    final $$AppUserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableFilterComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableFilterComposer get equipmentId {
    final $$EquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableFilterComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserEquipmentTableOrderingComposer
    extends Composer<_$AppDb, $UserEquipmentTable> {
  $$UserEquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AppUserTableOrderingComposer get userId {
    final $$AppUserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableOrderingComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableOrderingComposer get equipmentId {
    final $$EquipmentTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableOrderingComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserEquipmentTableAnnotationComposer
    extends Composer<_$AppDb, $UserEquipmentTable> {
  $$UserEquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AppUserTableAnnotationComposer get userId {
    final $$AppUserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableAnnotationComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableAnnotationComposer get equipmentId {
    final $$EquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableAnnotationComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserEquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserEquipmentTable,
          UserEquipmentData,
          $$UserEquipmentTableFilterComposer,
          $$UserEquipmentTableOrderingComposer,
          $$UserEquipmentTableAnnotationComposer,
          $$UserEquipmentTableCreateCompanionBuilder,
          $$UserEquipmentTableUpdateCompanionBuilder,
          (UserEquipmentData, $$UserEquipmentTableReferences),
          UserEquipmentData,
          PrefetchHooks Function({bool userId, bool equipmentId})
        > {
  $$UserEquipmentTableTableManager(_$AppDb db, $UserEquipmentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserEquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$UserEquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UserEquipmentTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> equipmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserEquipmentCompanion(
                userId: userId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required int equipmentId,
                Value<int> rowid = const Value.absent(),
              }) => UserEquipmentCompanion.insert(
                userId: userId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UserEquipmentTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({userId = false, equipmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                            referencedTable: $$UserEquipmentTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$UserEquipmentTableReferences
                                    ._userIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (equipmentId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.equipmentId,
                            referencedTable: $$UserEquipmentTableReferences
                                ._equipmentIdTable(db),
                            referencedColumn:
                                $$UserEquipmentTableReferences
                                    ._equipmentIdTable(db)
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

typedef $$UserEquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserEquipmentTable,
      UserEquipmentData,
      $$UserEquipmentTableFilterComposer,
      $$UserEquipmentTableOrderingComposer,
      $$UserEquipmentTableAnnotationComposer,
      $$UserEquipmentTableCreateCompanionBuilder,
      $$UserEquipmentTableUpdateCompanionBuilder,
      (UserEquipmentData, $$UserEquipmentTableReferences),
      UserEquipmentData,
      PrefetchHooks Function({bool userId, bool equipmentId})
    >;
typedef $$UserGoalTableCreateCompanionBuilder =
    UserGoalCompanion Function({
      required int userId,
      required int objectiveId,
      required double weight,
      Value<int> rowid,
    });
typedef $$UserGoalTableUpdateCompanionBuilder =
    UserGoalCompanion Function({
      Value<int> userId,
      Value<int> objectiveId,
      Value<double> weight,
      Value<int> rowid,
    });

final class $$UserGoalTableReferences
    extends BaseReferences<_$AppDb, $UserGoalTable, UserGoalData> {
  $$UserGoalTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUserTable _userIdTable(_$AppDb db) => db.appUser.createAlias(
    $_aliasNameGenerator(db.userGoal.userId, db.appUser.id),
  );

  $$AppUserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUserTableTableManager(
      $_db,
      $_db.appUser,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ObjectiveTable _objectiveIdTable(_$AppDb db) =>
      db.objective.createAlias(
        $_aliasNameGenerator(db.userGoal.objectiveId, db.objective.id),
      );

  $$ObjectiveTableProcessedTableManager get objectiveId {
    final $_column = $_itemColumn<int>('objective_id')!;

    final manager = $$ObjectiveTableTableManager(
      $_db,
      $_db.objective,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objectiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserGoalTableFilterComposer extends Composer<_$AppDb, $UserGoalTable> {
  $$UserGoalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUserTableFilterComposer get userId {
    final $$AppUserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableFilterComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectiveTableFilterComposer get objectiveId {
    final $$ObjectiveTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableFilterComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserGoalTableOrderingComposer
    extends Composer<_$AppDb, $UserGoalTable> {
  $$UserGoalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUserTableOrderingComposer get userId {
    final $$AppUserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableOrderingComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectiveTableOrderingComposer get objectiveId {
    final $$ObjectiveTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableOrderingComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserGoalTableAnnotationComposer
    extends Composer<_$AppDb, $UserGoalTable> {
  $$UserGoalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  $$AppUserTableAnnotationComposer get userId {
    final $$AppUserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableAnnotationComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectiveTableAnnotationComposer get objectiveId {
    final $$ObjectiveTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableAnnotationComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserGoalTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserGoalTable,
          UserGoalData,
          $$UserGoalTableFilterComposer,
          $$UserGoalTableOrderingComposer,
          $$UserGoalTableAnnotationComposer,
          $$UserGoalTableCreateCompanionBuilder,
          $$UserGoalTableUpdateCompanionBuilder,
          (UserGoalData, $$UserGoalTableReferences),
          UserGoalData,
          PrefetchHooks Function({bool userId, bool objectiveId})
        > {
  $$UserGoalTableTableManager(_$AppDb db, $UserGoalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserGoalTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UserGoalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UserGoalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> objectiveId = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGoalCompanion(
                userId: userId,
                objectiveId: objectiveId,
                weight: weight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required int objectiveId,
                required double weight,
                Value<int> rowid = const Value.absent(),
              }) => UserGoalCompanion.insert(
                userId: userId,
                objectiveId: objectiveId,
                weight: weight,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UserGoalTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({userId = false, objectiveId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                            referencedTable: $$UserGoalTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$UserGoalTableReferences._userIdTable(db).id,
                          )
                          as T;
                }
                if (objectiveId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.objectiveId,
                            referencedTable: $$UserGoalTableReferences
                                ._objectiveIdTable(db),
                            referencedColumn:
                                $$UserGoalTableReferences
                                    ._objectiveIdTable(db)
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

typedef $$UserGoalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserGoalTable,
      UserGoalData,
      $$UserGoalTableFilterComposer,
      $$UserGoalTableOrderingComposer,
      $$UserGoalTableAnnotationComposer,
      $$UserGoalTableCreateCompanionBuilder,
      $$UserGoalTableUpdateCompanionBuilder,
      (UserGoalData, $$UserGoalTableReferences),
      UserGoalData,
      PrefetchHooks Function({bool userId, bool objectiveId})
    >;
typedef $$UserTrainingDayTableCreateCompanionBuilder =
    UserTrainingDayCompanion Function({
      required int userId,
      required int dayOfWeek,
      Value<int> rowid,
    });
typedef $$UserTrainingDayTableUpdateCompanionBuilder =
    UserTrainingDayCompanion Function({
      Value<int> userId,
      Value<int> dayOfWeek,
      Value<int> rowid,
    });

final class $$UserTrainingDayTableReferences
    extends
        BaseReferences<_$AppDb, $UserTrainingDayTable, UserTrainingDayData> {
  $$UserTrainingDayTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AppUserTable _userIdTable(_$AppDb db) => db.appUser.createAlias(
    $_aliasNameGenerator(db.userTrainingDay.userId, db.appUser.id),
  );

  $$AppUserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUserTableTableManager(
      $_db,
      $_db.appUser,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserTrainingDayTableFilterComposer
    extends Composer<_$AppDb, $UserTrainingDayTable> {
  $$UserTrainingDayTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUserTableFilterComposer get userId {
    final $$AppUserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableFilterComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserTrainingDayTableOrderingComposer
    extends Composer<_$AppDb, $UserTrainingDayTable> {
  $$UserTrainingDayTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUserTableOrderingComposer get userId {
    final $$AppUserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableOrderingComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserTrainingDayTableAnnotationComposer
    extends Composer<_$AppDb, $UserTrainingDayTable> {
  $$UserTrainingDayTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  $$AppUserTableAnnotationComposer get userId {
    final $$AppUserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableAnnotationComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserTrainingDayTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserTrainingDayTable,
          UserTrainingDayData,
          $$UserTrainingDayTableFilterComposer,
          $$UserTrainingDayTableOrderingComposer,
          $$UserTrainingDayTableAnnotationComposer,
          $$UserTrainingDayTableCreateCompanionBuilder,
          $$UserTrainingDayTableUpdateCompanionBuilder,
          (UserTrainingDayData, $$UserTrainingDayTableReferences),
          UserTrainingDayData,
          PrefetchHooks Function({bool userId})
        > {
  $$UserTrainingDayTableTableManager(_$AppDb db, $UserTrainingDayTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$UserTrainingDayTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UserTrainingDayTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$UserTrainingDayTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTrainingDayCompanion(
                userId: userId,
                dayOfWeek: dayOfWeek,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required int dayOfWeek,
                Value<int> rowid = const Value.absent(),
              }) => UserTrainingDayCompanion.insert(
                userId: userId,
                dayOfWeek: dayOfWeek,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UserTrainingDayTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                            referencedTable: $$UserTrainingDayTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$UserTrainingDayTableReferences
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

typedef $$UserTrainingDayTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserTrainingDayTable,
      UserTrainingDayData,
      $$UserTrainingDayTableFilterComposer,
      $$UserTrainingDayTableOrderingComposer,
      $$UserTrainingDayTableAnnotationComposer,
      $$UserTrainingDayTableCreateCompanionBuilder,
      $$UserTrainingDayTableUpdateCompanionBuilder,
      (UserTrainingDayData, $$UserTrainingDayTableReferences),
      UserTrainingDayData,
      PrefetchHooks Function({bool userId})
    >;
typedef $$WorkoutProgramTableCreateCompanionBuilder =
    WorkoutProgramCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<int?> objectiveId,
      Value<String?> level,
      Value<int?> durationWeeks,
    });
typedef $$WorkoutProgramTableUpdateCompanionBuilder =
    WorkoutProgramCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<int?> objectiveId,
      Value<String?> level,
      Value<int?> durationWeeks,
    });

final class $$WorkoutProgramTableReferences
    extends BaseReferences<_$AppDb, $WorkoutProgramTable, WorkoutProgramData> {
  $$WorkoutProgramTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ObjectiveTable _objectiveIdTable(_$AppDb db) =>
      db.objective.createAlias(
        $_aliasNameGenerator(db.workoutProgram.objectiveId, db.objective.id),
      );

  $$ObjectiveTableProcessedTableManager? get objectiveId {
    final $_column = $_itemColumn<int>('objective_id');
    if ($_column == null) return null;
    final manager = $$ObjectiveTableTableManager(
      $_db,
      $_db.objective,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objectiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProgramDayTable, List<ProgramDayData>>
  _programDayRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.programDay,
    aliasName: $_aliasNameGenerator(
      db.workoutProgram.id,
      db.programDay.programId,
    ),
  );

  $$ProgramDayTableProcessedTableManager get programDayRefs {
    final manager = $$ProgramDayTableTableManager(
      $_db,
      $_db.programDay,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_programDayRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserProgramTable, List<UserProgramData>>
  _userProgramRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userProgram,
    aliasName: $_aliasNameGenerator(
      db.workoutProgram.id,
      db.userProgram.programId,
    ),
  );

  $$UserProgramTableProcessedTableManager get userProgramRefs {
    final manager = $$UserProgramTableTableManager(
      $_db,
      $_db.userProgram,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProgramRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutProgramTableFilterComposer
    extends Composer<_$AppDb, $WorkoutProgramTable> {
  $$WorkoutProgramTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, String> get level =>
      $composableBuilder(
        column: $table.level,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnFilters(column),
  );

  $$ObjectiveTableFilterComposer get objectiveId {
    final $$ObjectiveTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableFilterComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> programDayRefs(
    Expression<bool> Function($$ProgramDayTableFilterComposer f) f,
  ) {
    final $$ProgramDayTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableFilterComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userProgramRefs(
    Expression<bool> Function($$UserProgramTableFilterComposer f) f,
  ) {
    final $$UserProgramTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgram,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramTableFilterComposer(
            $db: $db,
            $table: $db.userProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutProgramTableOrderingComposer
    extends Composer<_$AppDb, $WorkoutProgramTable> {
  $$WorkoutProgramTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObjectiveTableOrderingComposer get objectiveId {
    final $$ObjectiveTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableOrderingComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutProgramTableAnnotationComposer
    extends Composer<_$AppDb, $WorkoutProgramTable> {
  $$WorkoutProgramTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<String?, String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => column,
  );

  $$ObjectiveTableAnnotationComposer get objectiveId {
    final $$ObjectiveTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveId,
      referencedTable: $db.objective,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectiveTableAnnotationComposer(
            $db: $db,
            $table: $db.objective,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> programDayRefs<T extends Object>(
    Expression<T> Function($$ProgramDayTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableAnnotationComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userProgramRefs<T extends Object>(
    Expression<T> Function($$UserProgramTableAnnotationComposer a) f,
  ) {
    final $$UserProgramTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgram,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutProgramTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $WorkoutProgramTable,
          WorkoutProgramData,
          $$WorkoutProgramTableFilterComposer,
          $$WorkoutProgramTableOrderingComposer,
          $$WorkoutProgramTableAnnotationComposer,
          $$WorkoutProgramTableCreateCompanionBuilder,
          $$WorkoutProgramTableUpdateCompanionBuilder,
          (WorkoutProgramData, $$WorkoutProgramTableReferences),
          WorkoutProgramData,
          PrefetchHooks Function({
            bool objectiveId,
            bool programDayRefs,
            bool userProgramRefs,
          })
        > {
  $$WorkoutProgramTableTableManager(_$AppDb db, $WorkoutProgramTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WorkoutProgramTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$WorkoutProgramTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$WorkoutProgramTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> objectiveId = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<int?> durationWeeks = const Value.absent(),
              }) => WorkoutProgramCompanion(
                id: id,
                name: name,
                description: description,
                objectiveId: objectiveId,
                level: level,
                durationWeeks: durationWeeks,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int?> objectiveId = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<int?> durationWeeks = const Value.absent(),
              }) => WorkoutProgramCompanion.insert(
                id: id,
                name: name,
                description: description,
                objectiveId: objectiveId,
                level: level,
                durationWeeks: durationWeeks,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$WorkoutProgramTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            objectiveId = false,
            programDayRefs = false,
            userProgramRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (programDayRefs) db.programDay,
                if (userProgramRefs) db.userProgram,
              ],
              addJoins: <
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
                if (objectiveId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.objectiveId,
                            referencedTable: $$WorkoutProgramTableReferences
                                ._objectiveIdTable(db),
                            referencedColumn:
                                $$WorkoutProgramTableReferences
                                    ._objectiveIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (programDayRefs)
                    await $_getPrefetchedData<
                      WorkoutProgramData,
                      $WorkoutProgramTable,
                      ProgramDayData
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutProgramTableReferences
                          ._programDayRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$WorkoutProgramTableReferences(
                                db,
                                table,
                                p0,
                              ).programDayRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.programId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (userProgramRefs)
                    await $_getPrefetchedData<
                      WorkoutProgramData,
                      $WorkoutProgramTable,
                      UserProgramData
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutProgramTableReferences
                          ._userProgramRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$WorkoutProgramTableReferences(
                                db,
                                table,
                                p0,
                              ).userProgramRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.programId == item.id,
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

typedef $$WorkoutProgramTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $WorkoutProgramTable,
      WorkoutProgramData,
      $$WorkoutProgramTableFilterComposer,
      $$WorkoutProgramTableOrderingComposer,
      $$WorkoutProgramTableAnnotationComposer,
      $$WorkoutProgramTableCreateCompanionBuilder,
      $$WorkoutProgramTableUpdateCompanionBuilder,
      (WorkoutProgramData, $$WorkoutProgramTableReferences),
      WorkoutProgramData,
      PrefetchHooks Function({
        bool objectiveId,
        bool programDayRefs,
        bool userProgramRefs,
      })
    >;
typedef $$ProgramDayTableCreateCompanionBuilder =
    ProgramDayCompanion Function({
      Value<int> id,
      required int programId,
      required String name,
      required int dayOrder,
    });
typedef $$ProgramDayTableUpdateCompanionBuilder =
    ProgramDayCompanion Function({
      Value<int> id,
      Value<int> programId,
      Value<String> name,
      Value<int> dayOrder,
    });

final class $$ProgramDayTableReferences
    extends BaseReferences<_$AppDb, $ProgramDayTable, ProgramDayData> {
  $$ProgramDayTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutProgramTable _programIdTable(_$AppDb db) =>
      db.workoutProgram.createAlias(
        $_aliasNameGenerator(db.programDay.programId, db.workoutProgram.id),
      );

  $$WorkoutProgramTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$WorkoutProgramTableTableManager(
      $_db,
      $_db.workoutProgram,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SessionTable, List<SessionData>>
  _sessionRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.session,
    aliasName: $_aliasNameGenerator(db.programDay.id, db.session.programDayId),
  );

  $$SessionTableProcessedTableManager get sessionRefs {
    final manager = $$SessionTableTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.programDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgramDayExerciseTable,
    List<ProgramDayExerciseData>
  >
  _programDayExerciseRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.programDayExercise,
    aliasName: $_aliasNameGenerator(
      db.programDay.id,
      db.programDayExercise.programDayId,
    ),
  );

  $$ProgramDayExerciseTableProcessedTableManager get programDayExerciseRefs {
    final manager = $$ProgramDayExerciseTableTableManager(
      $_db,
      $_db.programDayExercise,
    ).filter((f) => f.programDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _programDayExerciseRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProgramDayTableFilterComposer
    extends Composer<_$AppDb, $ProgramDayTable> {
  $$ProgramDayTableFilterComposer({
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

  ColumnFilters<int> get dayOrder => $composableBuilder(
    column: $table.dayOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutProgramTableFilterComposer get programId {
    final $$WorkoutProgramTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableFilterComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionRefs(
    Expression<bool> Function($$SessionTableFilterComposer f) f,
  ) {
    final $$SessionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.programDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> programDayExerciseRefs(
    Expression<bool> Function($$ProgramDayExerciseTableFilterComposer f) f,
  ) {
    final $$ProgramDayExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.programDayExercise,
      getReferencedColumn: (t) => t.programDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayExerciseTableFilterComposer(
            $db: $db,
            $table: $db.programDayExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramDayTableOrderingComposer
    extends Composer<_$AppDb, $ProgramDayTable> {
  $$ProgramDayTableOrderingComposer({
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

  ColumnOrderings<int> get dayOrder => $composableBuilder(
    column: $table.dayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutProgramTableOrderingComposer get programId {
    final $$WorkoutProgramTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableOrderingComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayTableAnnotationComposer
    extends Composer<_$AppDb, $ProgramDayTable> {
  $$ProgramDayTableAnnotationComposer({
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

  GeneratedColumn<int> get dayOrder =>
      $composableBuilder(column: $table.dayOrder, builder: (column) => column);

  $$WorkoutProgramTableAnnotationComposer get programId {
    final $$WorkoutProgramTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionRefs<T extends Object>(
    Expression<T> Function($$SessionTableAnnotationComposer a) f,
  ) {
    final $$SessionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.programDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> programDayExerciseRefs<T extends Object>(
    Expression<T> Function($$ProgramDayExerciseTableAnnotationComposer a) f,
  ) {
    final $$ProgramDayExerciseTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.programDayExercise,
          getReferencedColumn: (t) => t.programDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgramDayExerciseTableAnnotationComposer(
                $db: $db,
                $table: $db.programDayExercise,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProgramDayTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProgramDayTable,
          ProgramDayData,
          $$ProgramDayTableFilterComposer,
          $$ProgramDayTableOrderingComposer,
          $$ProgramDayTableAnnotationComposer,
          $$ProgramDayTableCreateCompanionBuilder,
          $$ProgramDayTableUpdateCompanionBuilder,
          (ProgramDayData, $$ProgramDayTableReferences),
          ProgramDayData,
          PrefetchHooks Function({
            bool programId,
            bool sessionRefs,
            bool programDayExerciseRefs,
          })
        > {
  $$ProgramDayTableTableManager(_$AppDb db, $ProgramDayTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ProgramDayTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ProgramDayTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ProgramDayTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> programId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> dayOrder = const Value.absent(),
              }) => ProgramDayCompanion(
                id: id,
                programId: programId,
                name: name,
                dayOrder: dayOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int programId,
                required String name,
                required int dayOrder,
              }) => ProgramDayCompanion.insert(
                id: id,
                programId: programId,
                name: name,
                dayOrder: dayOrder,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ProgramDayTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            programId = false,
            sessionRefs = false,
            programDayExerciseRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionRefs) db.session,
                if (programDayExerciseRefs) db.programDayExercise,
              ],
              addJoins: <
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
                if (programId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.programId,
                            referencedTable: $$ProgramDayTableReferences
                                ._programIdTable(db),
                            referencedColumn:
                                $$ProgramDayTableReferences
                                    ._programIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionRefs)
                    await $_getPrefetchedData<
                      ProgramDayData,
                      $ProgramDayTable,
                      SessionData
                    >(
                      currentTable: table,
                      referencedTable: $$ProgramDayTableReferences
                          ._sessionRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ProgramDayTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.programDayId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (programDayExerciseRefs)
                    await $_getPrefetchedData<
                      ProgramDayData,
                      $ProgramDayTable,
                      ProgramDayExerciseData
                    >(
                      currentTable: table,
                      referencedTable: $$ProgramDayTableReferences
                          ._programDayExerciseRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ProgramDayTableReferences(
                                db,
                                table,
                                p0,
                              ).programDayExerciseRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.programDayId == item.id,
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

typedef $$ProgramDayTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProgramDayTable,
      ProgramDayData,
      $$ProgramDayTableFilterComposer,
      $$ProgramDayTableOrderingComposer,
      $$ProgramDayTableAnnotationComposer,
      $$ProgramDayTableCreateCompanionBuilder,
      $$ProgramDayTableUpdateCompanionBuilder,
      (ProgramDayData, $$ProgramDayTableReferences),
      ProgramDayData,
      PrefetchHooks Function({
        bool programId,
        bool sessionRefs,
        bool programDayExerciseRefs,
      })
    >;
typedef $$SessionTableCreateCompanionBuilder =
    SessionCompanion Function({
      Value<int> id,
      required int userId,
      Value<int?> programDayId,
      required int dateTs,
      Value<int?> durationMin,
      Value<String?> name,
    });
typedef $$SessionTableUpdateCompanionBuilder =
    SessionCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int?> programDayId,
      Value<int> dateTs,
      Value<int?> durationMin,
      Value<String?> name,
    });

final class $$SessionTableReferences
    extends BaseReferences<_$AppDb, $SessionTable, SessionData> {
  $$SessionTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUserTable _userIdTable(_$AppDb db) => db.appUser.createAlias(
    $_aliasNameGenerator(db.session.userId, db.appUser.id),
  );

  $$AppUserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUserTableTableManager(
      $_db,
      $_db.appUser,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProgramDayTable _programDayIdTable(_$AppDb db) =>
      db.programDay.createAlias(
        $_aliasNameGenerator(db.session.programDayId, db.programDay.id),
      );

  $$ProgramDayTableProcessedTableManager? get programDayId {
    final $_column = $_itemColumn<int>('program_day_id');
    if ($_column == null) return null;
    final manager = $$ProgramDayTableTableManager(
      $_db,
      $_db.programDay,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$UserFeedbackTable, List<UserFeedbackData>>
  _userFeedbackRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userFeedback,
    aliasName: $_aliasNameGenerator(db.session.id, db.userFeedback.sessionId),
  );

  $$UserFeedbackTableProcessedTableManager get userFeedbackRefs {
    final manager = $$UserFeedbackTableTableManager(
      $_db,
      $_db.userFeedback,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userFeedbackRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionExerciseTable, List<SessionExerciseData>>
  _sessionExerciseRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.sessionExercise,
    aliasName: $_aliasNameGenerator(
      db.session.id,
      db.sessionExercise.sessionId,
    ),
  );

  $$SessionExerciseTableProcessedTableManager get sessionExerciseRefs {
    final manager = $$SessionExerciseTableTableManager(
      $_db,
      $_db.sessionExercise,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExerciseRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<int> get dateTs => $composableBuilder(
    column: $table.dateTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUserTableFilterComposer get userId {
    final $$AppUserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableFilterComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProgramDayTableFilterComposer get programDayId {
    final $$ProgramDayTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programDayId,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableFilterComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> userFeedbackRefs(
    Expression<bool> Function($$UserFeedbackTableFilterComposer f) f,
  ) {
    final $$UserFeedbackTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFeedback,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFeedbackTableFilterComposer(
            $db: $db,
            $table: $db.userFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionExerciseRefs(
    Expression<bool> Function($$SessionExerciseTableFilterComposer f) f,
  ) {
    final $$SessionExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExerciseTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<int> get dateTs => $composableBuilder(
    column: $table.dateTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUserTableOrderingComposer get userId {
    final $$AppUserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableOrderingComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProgramDayTableOrderingComposer get programDayId {
    final $$ProgramDayTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programDayId,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableOrderingComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<int> get dateTs =>
      $composableBuilder(column: $table.dateTs, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$AppUserTableAnnotationComposer get userId {
    final $$AppUserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableAnnotationComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProgramDayTableAnnotationComposer get programDayId {
    final $$ProgramDayTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programDayId,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableAnnotationComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> userFeedbackRefs<T extends Object>(
    Expression<T> Function($$UserFeedbackTableAnnotationComposer a) f,
  ) {
    final $$UserFeedbackTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFeedback,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFeedbackTableAnnotationComposer(
            $db: $db,
            $table: $db.userFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionExerciseRefs<T extends Object>(
    Expression<T> Function($$SessionExerciseTableAnnotationComposer a) f,
  ) {
    final $$SessionExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (SessionData, $$SessionTableReferences),
          SessionData,
          PrefetchHooks Function({
            bool userId,
            bool programDayId,
            bool userFeedbackRefs,
            bool sessionExerciseRefs,
          })
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
                Value<int?> programDayId = const Value.absent(),
                Value<int> dateTs = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<String?> name = const Value.absent(),
              }) => SessionCompanion(
                id: id,
                userId: userId,
                programDayId: programDayId,
                dateTs: dateTs,
                durationMin: durationMin,
                name: name,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                Value<int?> programDayId = const Value.absent(),
                required int dateTs,
                Value<int?> durationMin = const Value.absent(),
                Value<String?> name = const Value.absent(),
              }) => SessionCompanion.insert(
                id: id,
                userId: userId,
                programDayId: programDayId,
                dateTs: dateTs,
                durationMin: durationMin,
                name: name,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SessionTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            userId = false,
            programDayId = false,
            userFeedbackRefs = false,
            sessionExerciseRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userFeedbackRefs) db.userFeedback,
                if (sessionExerciseRefs) db.sessionExercise,
              ],
              addJoins: <
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
                            referencedTable: $$SessionTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$SessionTableReferences._userIdTable(db).id,
                          )
                          as T;
                }
                if (programDayId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.programDayId,
                            referencedTable: $$SessionTableReferences
                                ._programDayIdTable(db),
                            referencedColumn:
                                $$SessionTableReferences
                                    ._programDayIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userFeedbackRefs)
                    await $_getPrefetchedData<
                      SessionData,
                      $SessionTable,
                      UserFeedbackData
                    >(
                      currentTable: table,
                      referencedTable: $$SessionTableReferences
                          ._userFeedbackRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SessionTableReferences(
                                db,
                                table,
                                p0,
                              ).userFeedbackRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (sessionExerciseRefs)
                    await $_getPrefetchedData<
                      SessionData,
                      $SessionTable,
                      SessionExerciseData
                    >(
                      currentTable: table,
                      referencedTable: $$SessionTableReferences
                          ._sessionExerciseRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SessionTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExerciseRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionId == item.id,
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
      (SessionData, $$SessionTableReferences),
      SessionData,
      PrefetchHooks Function({
        bool userId,
        bool programDayId,
        bool userFeedbackRefs,
        bool sessionExerciseRefs,
      })
    >;
typedef $$UserFeedbackTableCreateCompanionBuilder =
    UserFeedbackCompanion Function({
      required int userId,
      required int exerciseId,
      Value<int?> sessionId,
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
      Value<int?> sessionId,
      Value<int> liked,
      Value<int> difficult,
      Value<int> pleasant,
      Value<int> useless,
      Value<int> ts,
      Value<int> rowid,
    });

final class $$UserFeedbackTableReferences
    extends BaseReferences<_$AppDb, $UserFeedbackTable, UserFeedbackData> {
  $$UserFeedbackTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUserTable _userIdTable(_$AppDb db) => db.appUser.createAlias(
    $_aliasNameGenerator(db.userFeedback.userId, db.appUser.id),
  );

  $$AppUserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUserTableTableManager(
      $_db,
      $_db.appUser,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseTable _exerciseIdTable(_$AppDb db) => db.exercise.createAlias(
    $_aliasNameGenerator(db.userFeedback.exerciseId, db.exercise.id),
  );

  $$ExerciseTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionTable _sessionIdTable(_$AppDb db) => db.session.createAlias(
    $_aliasNameGenerator(db.userFeedback.sessionId, db.session.id),
  );

  $$SessionTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$SessionTableTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserFeedbackTableFilterComposer
    extends Composer<_$AppDb, $UserFeedbackTable> {
  $$UserFeedbackTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  $$AppUserTableFilterComposer get userId {
    final $$AppUserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableFilterComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableFilterComposer get exerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionTableFilterComposer get sessionId {
    final $$SessionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$AppUserTableOrderingComposer get userId {
    final $$AppUserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableOrderingComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableOrderingComposer get exerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionTableOrderingComposer get sessionId {
    final $$SessionTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableOrderingComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$AppUserTableAnnotationComposer get userId {
    final $$AppUserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableAnnotationComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableAnnotationComposer get exerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionTableAnnotationComposer get sessionId {
    final $$SessionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (UserFeedbackData, $$UserFeedbackTableReferences),
          UserFeedbackData,
          PrefetchHooks Function({bool userId, bool exerciseId, bool sessionId})
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
                Value<int?> sessionId = const Value.absent(),
                Value<int> liked = const Value.absent(),
                Value<int> difficult = const Value.absent(),
                Value<int> pleasant = const Value.absent(),
                Value<int> useless = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFeedbackCompanion(
                userId: userId,
                exerciseId: exerciseId,
                sessionId: sessionId,
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
                Value<int?> sessionId = const Value.absent(),
                required int liked,
                Value<int> difficult = const Value.absent(),
                Value<int> pleasant = const Value.absent(),
                Value<int> useless = const Value.absent(),
                required int ts,
                Value<int> rowid = const Value.absent(),
              }) => UserFeedbackCompanion.insert(
                userId: userId,
                exerciseId: exerciseId,
                sessionId: sessionId,
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
                          $$UserFeedbackTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            userId = false,
            exerciseId = false,
            sessionId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                            referencedTable: $$UserFeedbackTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$UserFeedbackTableReferences
                                    ._userIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (exerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$UserFeedbackTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn:
                                $$UserFeedbackTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (sessionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$UserFeedbackTableReferences
                                ._sessionIdTable(db),
                            referencedColumn:
                                $$UserFeedbackTableReferences
                                    ._sessionIdTable(db)
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
      (UserFeedbackData, $$UserFeedbackTableReferences),
      UserFeedbackData,
      PrefetchHooks Function({bool userId, bool exerciseId, bool sessionId})
    >;
typedef $$SessionExerciseTableCreateCompanionBuilder =
    SessionExerciseCompanion Function({
      required int sessionId,
      required int exerciseId,
      required int position,
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
      Value<int> position,
      Value<int?> sets,
      Value<int?> reps,
      Value<double?> load,
      Value<double?> rpe,
      Value<int> rowid,
    });

final class $$SessionExerciseTableReferences
    extends
        BaseReferences<_$AppDb, $SessionExerciseTable, SessionExerciseData> {
  $$SessionExerciseTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionTable _sessionIdTable(_$AppDb db) => db.session.createAlias(
    $_aliasNameGenerator(db.sessionExercise.sessionId, db.session.id),
  );

  $$SessionTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionTableTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseTable _exerciseIdTable(_$AppDb db) => db.exercise.createAlias(
    $_aliasNameGenerator(db.sessionExercise.exerciseId, db.exercise.id),
  );

  $$ExerciseTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionExerciseTableFilterComposer
    extends Composer<_$AppDb, $SessionExerciseTable> {
  $$SessionExerciseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
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

  $$SessionTableFilterComposer get sessionId {
    final $$SessionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableFilterComposer get exerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
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

  $$SessionTableOrderingComposer get sessionId {
    final $$SessionTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableOrderingComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableOrderingComposer get exerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get load =>
      $composableBuilder(column: $table.load, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  $$SessionTableAnnotationComposer get sessionId {
    final $$SessionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionTableAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableAnnotationComposer get exerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (SessionExerciseData, $$SessionExerciseTableReferences),
          SessionExerciseData,
          PrefetchHooks Function({bool sessionId, bool exerciseId})
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
                Value<int> position = const Value.absent(),
                Value<int?> sets = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> load = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExerciseCompanion(
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
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
                required int position,
                Value<int?> sets = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> load = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExerciseCompanion.insert(
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
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
                          $$SessionExerciseTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (sessionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$SessionExerciseTableReferences
                                ._sessionIdTable(db),
                            referencedColumn:
                                $$SessionExerciseTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (exerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$SessionExerciseTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn:
                                $$SessionExerciseTableReferences
                                    ._exerciseIdTable(db)
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
      (SessionExerciseData, $$SessionExerciseTableReferences),
      SessionExerciseData,
      PrefetchHooks Function({bool sessionId, bool exerciseId})
    >;
typedef $$ProgramDayExerciseTableCreateCompanionBuilder =
    ProgramDayExerciseCompanion Function({
      Value<int> id,
      required int programDayId,
      required int exerciseId,
      required int position,
      Value<int?> modalityId,
      Value<String?> setsSuggestion,
      Value<String?> repsSuggestion,
      Value<int?> restSuggestionSec,
      Value<String?> previousSetsSuggestion,
      Value<String?> previousRepsSuggestion,
      Value<int?> previousRestSuggestion,
      Value<String?> notes,
      Value<DateTime?> scheduledDate,
    });
typedef $$ProgramDayExerciseTableUpdateCompanionBuilder =
    ProgramDayExerciseCompanion Function({
      Value<int> id,
      Value<int> programDayId,
      Value<int> exerciseId,
      Value<int> position,
      Value<int?> modalityId,
      Value<String?> setsSuggestion,
      Value<String?> repsSuggestion,
      Value<int?> restSuggestionSec,
      Value<String?> previousSetsSuggestion,
      Value<String?> previousRepsSuggestion,
      Value<int?> previousRestSuggestion,
      Value<String?> notes,
      Value<DateTime?> scheduledDate,
    });

final class $$ProgramDayExerciseTableReferences
    extends
        BaseReferences<
          _$AppDb,
          $ProgramDayExerciseTable,
          ProgramDayExerciseData
        > {
  $$ProgramDayExerciseTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProgramDayTable _programDayIdTable(_$AppDb db) =>
      db.programDay.createAlias(
        $_aliasNameGenerator(
          db.programDayExercise.programDayId,
          db.programDay.id,
        ),
      );

  $$ProgramDayTableProcessedTableManager get programDayId {
    final $_column = $_itemColumn<int>('program_day_id')!;

    final manager = $$ProgramDayTableTableManager(
      $_db,
      $_db.programDay,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseTable _exerciseIdTable(_$AppDb db) => db.exercise.createAlias(
    $_aliasNameGenerator(db.programDayExercise.exerciseId, db.exercise.id),
  );

  $$ExerciseTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableManager(
      $_db,
      $_db.exercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrainingModalityTable _modalityIdTable(_$AppDb db) =>
      db.trainingModality.createAlias(
        $_aliasNameGenerator(
          db.programDayExercise.modalityId,
          db.trainingModality.id,
        ),
      );

  $$TrainingModalityTableProcessedTableManager? get modalityId {
    final $_column = $_itemColumn<int>('modality_id');
    if ($_column == null) return null;
    final manager = $$TrainingModalityTableTableManager(
      $_db,
      $_db.trainingModality,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modalityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgramDayExerciseTableFilterComposer
    extends Composer<_$AppDb, $ProgramDayExerciseTable> {
  $$ProgramDayExerciseTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setsSuggestion => $composableBuilder(
    column: $table.setsSuggestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repsSuggestion => $composableBuilder(
    column: $table.repsSuggestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSuggestionSec => $composableBuilder(
    column: $table.restSuggestionSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousSetsSuggestion => $composableBuilder(
    column: $table.previousSetsSuggestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousRepsSuggestion => $composableBuilder(
    column: $table.previousRepsSuggestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousRestSuggestion => $composableBuilder(
    column: $table.previousRestSuggestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  $$ProgramDayTableFilterComposer get programDayId {
    final $$ProgramDayTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programDayId,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableFilterComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableFilterComposer get exerciseId {
    final $$ExerciseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableFilterComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrainingModalityTableFilterComposer get modalityId {
    final $$TrainingModalityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modalityId,
      referencedTable: $db.trainingModality,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingModalityTableFilterComposer(
            $db: $db,
            $table: $db.trainingModality,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayExerciseTableOrderingComposer
    extends Composer<_$AppDb, $ProgramDayExerciseTable> {
  $$ProgramDayExerciseTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setsSuggestion => $composableBuilder(
    column: $table.setsSuggestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repsSuggestion => $composableBuilder(
    column: $table.repsSuggestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSuggestionSec => $composableBuilder(
    column: $table.restSuggestionSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousSetsSuggestion => $composableBuilder(
    column: $table.previousSetsSuggestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousRepsSuggestion => $composableBuilder(
    column: $table.previousRepsSuggestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousRestSuggestion => $composableBuilder(
    column: $table.previousRestSuggestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProgramDayTableOrderingComposer get programDayId {
    final $$ProgramDayTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programDayId,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableOrderingComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableOrderingComposer get exerciseId {
    final $$ExerciseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableOrderingComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrainingModalityTableOrderingComposer get modalityId {
    final $$TrainingModalityTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modalityId,
      referencedTable: $db.trainingModality,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingModalityTableOrderingComposer(
            $db: $db,
            $table: $db.trainingModality,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayExerciseTableAnnotationComposer
    extends Composer<_$AppDb, $ProgramDayExerciseTable> {
  $$ProgramDayExerciseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get setsSuggestion => $composableBuilder(
    column: $table.setsSuggestion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repsSuggestion => $composableBuilder(
    column: $table.repsSuggestion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSuggestionSec => $composableBuilder(
    column: $table.restSuggestionSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousSetsSuggestion => $composableBuilder(
    column: $table.previousSetsSuggestion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousRepsSuggestion => $composableBuilder(
    column: $table.previousRepsSuggestion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previousRestSuggestion => $composableBuilder(
    column: $table.previousRestSuggestion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  $$ProgramDayTableAnnotationComposer get programDayId {
    final $$ProgramDayTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programDayId,
      referencedTable: $db.programDay,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramDayTableAnnotationComposer(
            $db: $db,
            $table: $db.programDay,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseTableAnnotationComposer get exerciseId {
    final $$ExerciseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableAnnotationComposer(
            $db: $db,
            $table: $db.exercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrainingModalityTableAnnotationComposer get modalityId {
    final $$TrainingModalityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modalityId,
      referencedTable: $db.trainingModality,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingModalityTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingModality,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgramDayExerciseTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProgramDayExerciseTable,
          ProgramDayExerciseData,
          $$ProgramDayExerciseTableFilterComposer,
          $$ProgramDayExerciseTableOrderingComposer,
          $$ProgramDayExerciseTableAnnotationComposer,
          $$ProgramDayExerciseTableCreateCompanionBuilder,
          $$ProgramDayExerciseTableUpdateCompanionBuilder,
          (ProgramDayExerciseData, $$ProgramDayExerciseTableReferences),
          ProgramDayExerciseData,
          PrefetchHooks Function({
            bool programDayId,
            bool exerciseId,
            bool modalityId,
          })
        > {
  $$ProgramDayExerciseTableTableManager(
    _$AppDb db,
    $ProgramDayExerciseTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ProgramDayExerciseTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ProgramDayExerciseTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ProgramDayExerciseTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> programDayId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> modalityId = const Value.absent(),
                Value<String?> setsSuggestion = const Value.absent(),
                Value<String?> repsSuggestion = const Value.absent(),
                Value<int?> restSuggestionSec = const Value.absent(),
                Value<String?> previousSetsSuggestion = const Value.absent(),
                Value<String?> previousRepsSuggestion = const Value.absent(),
                Value<int?> previousRestSuggestion = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
              }) => ProgramDayExerciseCompanion(
                id: id,
                programDayId: programDayId,
                exerciseId: exerciseId,
                position: position,
                modalityId: modalityId,
                setsSuggestion: setsSuggestion,
                repsSuggestion: repsSuggestion,
                restSuggestionSec: restSuggestionSec,
                previousSetsSuggestion: previousSetsSuggestion,
                previousRepsSuggestion: previousRepsSuggestion,
                previousRestSuggestion: previousRestSuggestion,
                notes: notes,
                scheduledDate: scheduledDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int programDayId,
                required int exerciseId,
                required int position,
                Value<int?> modalityId = const Value.absent(),
                Value<String?> setsSuggestion = const Value.absent(),
                Value<String?> repsSuggestion = const Value.absent(),
                Value<int?> restSuggestionSec = const Value.absent(),
                Value<String?> previousSetsSuggestion = const Value.absent(),
                Value<String?> previousRepsSuggestion = const Value.absent(),
                Value<int?> previousRestSuggestion = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
              }) => ProgramDayExerciseCompanion.insert(
                id: id,
                programDayId: programDayId,
                exerciseId: exerciseId,
                position: position,
                modalityId: modalityId,
                setsSuggestion: setsSuggestion,
                repsSuggestion: repsSuggestion,
                restSuggestionSec: restSuggestionSec,
                previousSetsSuggestion: previousSetsSuggestion,
                previousRepsSuggestion: previousRepsSuggestion,
                previousRestSuggestion: previousRestSuggestion,
                notes: notes,
                scheduledDate: scheduledDate,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ProgramDayExerciseTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            programDayId = false,
            exerciseId = false,
            modalityId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (programDayId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.programDayId,
                            referencedTable: $$ProgramDayExerciseTableReferences
                                ._programDayIdTable(db),
                            referencedColumn:
                                $$ProgramDayExerciseTableReferences
                                    ._programDayIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (exerciseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$ProgramDayExerciseTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn:
                                $$ProgramDayExerciseTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (modalityId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.modalityId,
                            referencedTable: $$ProgramDayExerciseTableReferences
                                ._modalityIdTable(db),
                            referencedColumn:
                                $$ProgramDayExerciseTableReferences
                                    ._modalityIdTable(db)
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

typedef $$ProgramDayExerciseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProgramDayExerciseTable,
      ProgramDayExerciseData,
      $$ProgramDayExerciseTableFilterComposer,
      $$ProgramDayExerciseTableOrderingComposer,
      $$ProgramDayExerciseTableAnnotationComposer,
      $$ProgramDayExerciseTableCreateCompanionBuilder,
      $$ProgramDayExerciseTableUpdateCompanionBuilder,
      (ProgramDayExerciseData, $$ProgramDayExerciseTableReferences),
      ProgramDayExerciseData,
      PrefetchHooks Function({
        bool programDayId,
        bool exerciseId,
        bool modalityId,
      })
    >;
typedef $$UserProgramTableCreateCompanionBuilder =
    UserProgramCompanion Function({
      Value<int> id,
      required int userId,
      required int programId,
      required int startDateTs,
      Value<int> isActive,
    });
typedef $$UserProgramTableUpdateCompanionBuilder =
    UserProgramCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> programId,
      Value<int> startDateTs,
      Value<int> isActive,
    });

final class $$UserProgramTableReferences
    extends BaseReferences<_$AppDb, $UserProgramTable, UserProgramData> {
  $$UserProgramTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUserTable _userIdTable(_$AppDb db) => db.appUser.createAlias(
    $_aliasNameGenerator(db.userProgram.userId, db.appUser.id),
  );

  $$AppUserTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUserTableTableManager(
      $_db,
      $_db.appUser,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutProgramTable _programIdTable(_$AppDb db) =>
      db.workoutProgram.createAlias(
        $_aliasNameGenerator(db.userProgram.programId, db.workoutProgram.id),
      );

  $$WorkoutProgramTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$WorkoutProgramTableTableManager(
      $_db,
      $_db.workoutProgram,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserProgramTableFilterComposer
    extends Composer<_$AppDb, $UserProgramTable> {
  $$UserProgramTableFilterComposer({
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

  ColumnFilters<int> get startDateTs => $composableBuilder(
    column: $table.startDateTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUserTableFilterComposer get userId {
    final $$AppUserTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableFilterComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutProgramTableFilterComposer get programId {
    final $$WorkoutProgramTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableFilterComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgramTableOrderingComposer
    extends Composer<_$AppDb, $UserProgramTable> {
  $$UserProgramTableOrderingComposer({
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

  ColumnOrderings<int> get startDateTs => $composableBuilder(
    column: $table.startDateTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUserTableOrderingComposer get userId {
    final $$AppUserTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableOrderingComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutProgramTableOrderingComposer get programId {
    final $$WorkoutProgramTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableOrderingComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgramTableAnnotationComposer
    extends Composer<_$AppDb, $UserProgramTable> {
  $$UserProgramTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startDateTs => $composableBuilder(
    column: $table.startDateTs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$AppUserTableAnnotationComposer get userId {
    final $$AppUserTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUser,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUserTableAnnotationComposer(
            $db: $db,
            $table: $db.appUser,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutProgramTableAnnotationComposer get programId {
    final $$WorkoutProgramTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.workoutProgram,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutProgramTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutProgram,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgramTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserProgramTable,
          UserProgramData,
          $$UserProgramTableFilterComposer,
          $$UserProgramTableOrderingComposer,
          $$UserProgramTableAnnotationComposer,
          $$UserProgramTableCreateCompanionBuilder,
          $$UserProgramTableUpdateCompanionBuilder,
          (UserProgramData, $$UserProgramTableReferences),
          UserProgramData,
          PrefetchHooks Function({bool userId, bool programId})
        > {
  $$UserProgramTableTableManager(_$AppDb db, $UserProgramTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserProgramTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UserProgramTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$UserProgramTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> programId = const Value.absent(),
                Value<int> startDateTs = const Value.absent(),
                Value<int> isActive = const Value.absent(),
              }) => UserProgramCompanion(
                id: id,
                userId: userId,
                programId: programId,
                startDateTs: startDateTs,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required int programId,
                required int startDateTs,
                Value<int> isActive = const Value.absent(),
              }) => UserProgramCompanion.insert(
                id: id,
                userId: userId,
                programId: programId,
                startDateTs: startDateTs,
                isActive: isActive,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UserProgramTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({userId = false, programId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                            referencedTable: $$UserProgramTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$UserProgramTableReferences
                                    ._userIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (programId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.programId,
                            referencedTable: $$UserProgramTableReferences
                                ._programIdTable(db),
                            referencedColumn:
                                $$UserProgramTableReferences
                                    ._programIdTable(db)
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

typedef $$UserProgramTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserProgramTable,
      UserProgramData,
      $$UserProgramTableFilterComposer,
      $$UserProgramTableOrderingComposer,
      $$UserProgramTableAnnotationComposer,
      $$UserProgramTableCreateCompanionBuilder,
      $$UserProgramTableUpdateCompanionBuilder,
      (UserProgramData, $$UserProgramTableReferences),
      UserProgramData,
      PrefetchHooks Function({bool userId, bool programId})
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$ExerciseTableTableManager get exercise =>
      $$ExerciseTableTableManager(_db, _db.exercise);
  $$MuscleTableTableManager get muscle =>
      $$MuscleTableTableManager(_db, _db.muscle);
  $$EquipmentTableTableManager get equipment =>
      $$EquipmentTableTableManager(_db, _db.equipment);
  $$ObjectiveTableTableManager get objective =>
      $$ObjectiveTableTableManager(_db, _db.objective);
  $$TrainingModalityTableTableManager get trainingModality =>
      $$TrainingModalityTableTableManager(_db, _db.trainingModality);
  $$ExerciseMuscleTableTableManager get exerciseMuscle =>
      $$ExerciseMuscleTableTableManager(_db, _db.exerciseMuscle);
  $$ExerciseEquipmentTableTableManager get exerciseEquipment =>
      $$ExerciseEquipmentTableTableManager(_db, _db.exerciseEquipment);
  $$ExerciseObjectiveTableTableManager get exerciseObjective =>
      $$ExerciseObjectiveTableTableManager(_db, _db.exerciseObjective);
  $$ExerciseRelationTableTableManager get exerciseRelation =>
      $$ExerciseRelationTableTableManager(_db, _db.exerciseRelation);
  $$AppUserTableTableManager get appUser =>
      $$AppUserTableTableManager(_db, _db.appUser);
  $$UserEquipmentTableTableManager get userEquipment =>
      $$UserEquipmentTableTableManager(_db, _db.userEquipment);
  $$UserGoalTableTableManager get userGoal =>
      $$UserGoalTableTableManager(_db, _db.userGoal);
  $$UserTrainingDayTableTableManager get userTrainingDay =>
      $$UserTrainingDayTableTableManager(_db, _db.userTrainingDay);
  $$WorkoutProgramTableTableManager get workoutProgram =>
      $$WorkoutProgramTableTableManager(_db, _db.workoutProgram);
  $$ProgramDayTableTableManager get programDay =>
      $$ProgramDayTableTableManager(_db, _db.programDay);
  $$SessionTableTableManager get session =>
      $$SessionTableTableManager(_db, _db.session);
  $$UserFeedbackTableTableManager get userFeedback =>
      $$UserFeedbackTableTableManager(_db, _db.userFeedback);
  $$SessionExerciseTableTableManager get sessionExercise =>
      $$SessionExerciseTableTableManager(_db, _db.sessionExercise);
  $$ProgramDayExerciseTableTableManager get programDayExercise =>
      $$ProgramDayExerciseTableTableManager(_db, _db.programDayExercise);
  $$UserProgramTableTableManager get userProgram =>
      $$UserProgramTableTableManager(_db, _db.userProgram);
}
