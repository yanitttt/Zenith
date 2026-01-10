// lib/data/db/app_db.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'BDD_V3.db'));

    if (!await file.exists()) {
      final data = await rootBundle.load('assets/db/BDD_V3.db');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await file.writeAsBytes(bytes, flush: true);
    }
    return NativeDatabase.createInBackground(file);
  });
}

class EnumTextConverter extends TypeConverter<String, String> {
  final List<String> allowed;
  const EnumTextConverter(this.allowed);

  @override
  String fromSql(String fromDb) {
    if (!allowed.contains(fromDb)) {
      throw ArgumentError('Valeur "$fromDb" hors domaine autorisé: $allowed');
    }
    return fromDb;
  }

  @override
  String toSql(String value) {
    if (!allowed.contains(value)) {
      throw ArgumentError('Valeur "$value" hors domaine autorisé: $allowed');
    }
    return value;
  }
}

class GenderConverter extends TypeConverter<String, String> {
  const GenderConverter();

  static const _allowed = {'homme', 'femme'};

  static const _aliases = {
    'male': 'homme',
    'm': 'homme',
    'man': 'homme',
    'masculin': 'homme',
    'female': 'femme',
    'f': 'femme',
    'woman': 'femme',
    'feminin': 'femme',
  };

  String _normalize(String v) {
    final x = v.trim().toLowerCase();
    if (_allowed.contains(x)) return x;
    final mapped = _aliases[x];
    if (mapped != null) return mapped;
    throw ArgumentError('Valeur "$v" hors domaine autorisé: $_allowed');
  }

  @override
  String fromSql(String fromDb) => _normalize(fromDb);

  @override
  String toSql(String value) => _normalize(value);
}

const _convType = EnumTextConverter(['poly', 'iso']);
const _convLevel = EnumTextConverter(['debutant', 'intermediaire', 'avance']);

const _convGender = GenderConverter();
const _nullableGender = NullAwareTypeConverter.wrap(_convGender);

const _convMetabolism = EnumTextConverter(['rapide', 'lent']);
const _convRelationType = EnumTextConverter([
  'variation',
  'substitute',
  'progression',
  'regression',
]);

const _nullableLevel = NullAwareTypeConverter.wrap(_convLevel);
const _nullableMetabolism = NullAwareTypeConverter.wrap(_convMetabolism);

class Exercise extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('name')();
  TextColumn get type => text().named('type').map(_convType)(); // 'poly'|'iso'
  IntColumn get difficulty =>
      integer().named('difficulty').check(difficulty.isBetweenValues(1, 5))();
  RealColumn get cardio =>
      real().named('cardio').withDefault(const Constant(0.0))();

  TextColumn get description => text().named('description').nullable()();
  TextColumn get etapes => text().named('etapes').nullable()();
}

class Muscle extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name =>
      text().named('name').customConstraint('NOT NULL UNIQUE')();
}

class Equipment extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name =>
      text().named('name').customConstraint('NOT NULL UNIQUE')();
}

class Objective extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code =>
      text().named('code').customConstraint('NOT NULL UNIQUE')();
  TextColumn get name => text().named('name')();
}

class TrainingModality extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get objectiveId =>
      integer()
          .named('objective_id')
          .references(Objective, #id, onDelete: KeyAction.cascade)();
  TextColumn get level => text().named('level').map(_convLevel)(); // non-null
  TextColumn get name => text().named('name')();
  IntColumn get repMin => integer().named('rep_min').nullable()();
  IntColumn get repMax => integer().named('rep_max').nullable()();
  IntColumn get setMin => integer().named('set_min').nullable()();
  IntColumn get setMax => integer().named('set_max').nullable()();
  IntColumn get restMinSec => integer().named('rest_min_sec').nullable()();
  IntColumn get restMaxSec => integer().named('rest_max_sec').nullable()();
  RealColumn get rpeMin => real().named('rpe_min').nullable()();
  RealColumn get rpeMax => real().named('rpe_max').nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE(objective_id, level, name)'];
}

class ExerciseMuscle extends Table {
  IntColumn get exerciseId =>
      integer()
          .named('exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get muscleId =>
      integer()
          .named('muscle_id')
          .references(Muscle, #id, onDelete: KeyAction.cascade)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {exerciseId, muscleId};
}

class ExerciseEquipment extends Table {
  IntColumn get exerciseId =>
      integer()
          .named('exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get equipmentId =>
      integer()
          .named('equipment_id')
          .references(Equipment, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {exerciseId, equipmentId};
}

class ExerciseObjective extends Table {
  IntColumn get exerciseId =>
      integer()
          .named('exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get objectiveId =>
      integer()
          .named('objective_id')
          .references(Objective, #id, onDelete: KeyAction.cascade)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {exerciseId, objectiveId};
}

class ExerciseRelation extends Table {
  @ReferenceName('asSrc')
  IntColumn get srcExerciseId =>
      integer()
          .named('src_exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('asDst')
  IntColumn get dstExerciseId =>
      integer()
          .named('dst_exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();

  TextColumn get relationType =>
      text().named('relation_type').map(_convRelationType)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {srcExerciseId, dstExerciseId, relationType};
}

class AppUser extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get age => integer().named('age').nullable()();
  RealColumn get weight => real().named('weight').nullable()();
  RealColumn get height => real().named('height').nullable()();

  TextColumn get gender =>
      text().named('gender').map(_nullableGender).nullable()();

  DateTimeColumn get birthDate => dateTime().named('birth_date').nullable()();

  TextColumn get level =>
      text().named('level').map(_nullableLevel).nullable()();
  TextColumn get metabolism =>
      text().named('metabolism').map(_nullableMetabolism).nullable()();

  TextColumn get nom => text().named('nom').nullable()();
  TextColumn get prenom => text().named('prenom').nullable()();

  IntColumn get singleton =>
      integer().named('singleton').withDefault(const Constant(1))();

  IntColumn get xp => integer().named('xp').withDefault(const Constant(0))();
  IntColumn get userLevel =>
      integer().named('user_level').withDefault(const Constant(1))();
  TextColumn get title => text().named('title').nullable()();
}

class GamificationBadge extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().named('name')();
  TextColumn get description => text().named('description')();
  TextColumn get iconAsset => text().named('icon_asset').nullable()();
  IntColumn get xpReward =>
      integer().named('xp_reward').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserBadge extends Table {
  IntColumn get userId =>
      integer()
          .named('user_id')
          .references(AppUser, #id, onDelete: KeyAction.cascade)();
  TextColumn get badgeId =>
      text()
          .named('badge_id')
          .references(GamificationBadge, #id, onDelete: KeyAction.cascade)();
  IntColumn get earnedDateTs => integer().named('earned_date_ts')();

  @override
  Set<Column> get primaryKey => {userId, badgeId};
}

class UserEquipment extends Table {
  IntColumn get userId =>
      integer()
          .named('user_id')
          .references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get equipmentId =>
      integer()
          .named('equipment_id')
          .references(Equipment, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {userId, equipmentId};
}

class UserGoal extends Table {
  IntColumn get userId =>
      integer()
          .named('user_id')
          .references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get objectiveId =>
      integer()
          .named('objective_id')
          .references(Objective, #id, onDelete: KeyAction.cascade)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {userId, objectiveId};
}

class UserTrainingDay extends Table {
  IntColumn get userId =>
      integer()
          .named('user_id')
          .references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayOfWeek =>
      integer().named('day_of_week').check(dayOfWeek.isBetweenValues(1, 7))();
  @override
  Set<Column> get primaryKey => {userId, dayOfWeek};
}

class UserFeedback extends Table {
  IntColumn get userId =>
      integer()
          .named('user_id')
          .references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer()
          .named('exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get sessionId =>
      integer()
          .named('session_id')
          .references(Session, #id, onDelete: KeyAction.cascade)
          .nullable()();
  IntColumn get liked => integer().named('liked')(); // 0/1
  IntColumn get difficult =>
      integer().named('difficult').withDefault(const Constant(0))();
  IntColumn get pleasant =>
      integer().named('pleasant').withDefault(const Constant(0))();
  IntColumn get useless =>
      integer().named('useless').withDefault(const Constant(0))();
  IntColumn get ts => integer().named('ts')(); // unix seconds
  @override
  Set<Column> get primaryKey => {userId, exerciseId, ts};
}

class Session extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer()
          .named('user_id')
          .references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get programDayId =>
      integer()
          .named('program_day_id')
          .references(ProgramDay, #id, onDelete: KeyAction.setNull)
          .nullable()();
  IntColumn get dateTs => integer().named('date_ts')();
  IntColumn get durationMin => integer().named('duration_min').nullable()();
  TextColumn get name => text().named('name').nullable()();
}

class SessionExercise extends Table {
  IntColumn get sessionId =>
      integer()
          .named('session_id')
          .references(Session, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer()
          .named('exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().named('position')(); // ordre 1,2,3...
  IntColumn get sets => integer().named('sets').nullable()();
  IntColumn get reps => integer().named('reps').nullable()();
  RealColumn get load => real().named('load').nullable()();
  RealColumn get rpe => real().named('rpe').nullable()();
  @override
  Set<Column> get primaryKey => {sessionId, exerciseId, position};
}

class WorkoutProgram extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('name')();
  TextColumn get description => text().named('description').nullable()();
  IntColumn get objectiveId =>
      integer()
          .named('objective_id')
          .references(Objective, #id, onDelete: KeyAction.setNull)
          .nullable()();
  TextColumn get level =>
      text().named('level').map(_nullableLevel).nullable()();
  IntColumn get durationWeeks => integer().named('duration_weeks').nullable()();
}

class ProgramDay extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId =>
      integer()
          .named('program_id')
          .references(WorkoutProgram, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().named('name')();
  IntColumn get dayOrder => integer().named('day_order')();
}

class ProgramDayExercise extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programDayId =>
      integer()
          .named('program_day_id')
          .references(ProgramDay, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer()
          .named('exercise_id')
          .references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().named('position')();
  IntColumn get modalityId =>
      integer()
          .named('modality_id')
          .references(TrainingModality, #id, onDelete: KeyAction.setNull)
          .nullable()();
  TextColumn get setsSuggestion => text().named('sets_suggestion').nullable()();
  TextColumn get repsSuggestion => text().named('reps_suggestion').nullable()();
  IntColumn get restSuggestionSec =>
      integer().named('rest_suggestion_sec').nullable()();

  TextColumn get previousSetsSuggestion =>
      text().named('previous_sets_suggestion').nullable()();
  TextColumn get previousRepsSuggestion =>
      text().named('previous_reps_suggestion').nullable()();
  IntColumn get previousRestSuggestion =>
      integer().named('previous_rest_suggestion').nullable()();

  TextColumn get notes => text().named('notes').nullable()();
  DateTimeColumn get scheduledDate =>
      dateTime().named('scheduled_date').nullable()();
}

class UserProgram extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer()
          .named('user_id')
          .references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get programId =>
      integer()
          .named('program_id')
          .references(WorkoutProgram, #id, onDelete: KeyAction.cascade)();
  IntColumn get startDateTs => integer().named('start_date_ts')();
  IntColumn get isActive =>
      integer().named('is_active').withDefault(const Constant(1))();
}

@DriftDatabase(
  tables: [
    Exercise,
    Muscle,
    Equipment,
    Objective,
    TrainingModality,
    ExerciseMuscle,
    ExerciseEquipment,
    ExerciseObjective,
    ExerciseRelation,
    AppUser,
    UserEquipment,
    UserGoal,
    UserTrainingDay,
    UserFeedback,
    Session,
    SessionExercise,
    WorkoutProgram,
    ProgramDay,
    ProgramDayExercise,
    ProgramDayExercise,
    UserProgram,
    GamificationBadge,
    UserBadge,
  ],
)
class AppDb extends _$AppDb {
  final bool _isTest;

  AppDb() : _isTest = false, super(_openConnection());

  AppDb.forTesting(super.executor) : _isTest = true;

  @override
  int get schemaVersion => 43;

Future<void> seedExerciseDetails() async {
      // 1. Back Squat
      await customStatement('''
        UPDATE exercise 
        SET description = 'L''exercice roi pour le bas du corps. Il développe une force globale impressionnante et sollicite principalement les quadriceps, les fessiers et le bas du dos.',
            etapes = '\n 1. Placez la barre sur vos trapèzes (pas sur la nuque).\n2. Pieds écartés largeur d''épaules, pointes légèrement vers l''extérieur.\n3. Inspirez et gainez les abdos.\n4. Descendez les fesses en arrière comme pour vous asseoir, en gardant le dos droit.\n5. Descendez jusqu''à ce que les cuisses soient parallèles au sol.\n6. Remontez en poussant sur les talons et expirez.'
        WHERE id = 1;
      ''');

      // 2. Développé couché
      await customStatement('''
        UPDATE exercise 
        SET description = 'Le mouvement de référence pour la force du haut du corps. Il cible massivement les pectoraux, avec une aide des triceps et des épaules.',
            etapes = '\n 1. Allongez-vous, les yeux sous la barre.\n2. Pieds bien à plat au sol pour la stabilité.\n3. Saisissez la barre avec une prise un peu plus large que les épaules.\n4. Décrochez la barre et descendez-la contrôlée vers le milieu de la poitrine.\n5. Poussez la barre vers le haut sans décoller les fesses du banc.'
        WHERE id = 2;
      ''');

      // 3. Soulevé de terre (Deadlift)
      await customStatement('''
        UPDATE exercise 
        SET description = 'Un test de force pure qui travaille toute la chaîne postérieure : ischios, fessiers, lombaires et trapèzes. Idéal pour la posture.',
            etapes = '\n 1. Pieds sous la barre (la barre touche les tibias).\n2. Poussez les fesses en arrière et saisissez la barre bras tendus.\n3. Bombez le torse, gardez le dos PLAT (très important).\n4. Poussez le sol avec vos jambes pour lever la barre.\n5. Une fois debout, verrouillez les hanches sans vous pencher en arrière.\n6. Redescendez en contrôlant la charge.'
        WHERE id = 3;
      ''');

      // 4. Pompes
      await customStatement('''
        UPDATE exercise 
        SET description = 'Un classique au poids du corps pour renforcer le torse, les bras et le gainage. Aucun matériel nécessaire.',
            etapes = '\n 1. Placez les mains au sol, largeur d''épaules.\n2. Corps aligné des talons à la tête (ne cambrez pas le dos).\n3. Descendez la poitrine jusqu''à frôler le sol.\n4. Les coudes doivent former une flèche (45°) avec le corps, pas un T.\n5. Repoussez le sol jusqu''à l''extension des bras.'
        WHERE id = 4;
      ''');

      // 5. Rowing haltère
      await customStatement('''
        UPDATE exercise 
        SET description = 'Exercice unilatéral excellent pour l''épaisseur du dos et pour corriger les déséquilibres musculaires.',
            etapes = '\n 1. Posez un genou et une main sur un banc plat.\n2. Le dos doit être plat et parallèle au sol.\n3. Saisissez l''haltère avec la main libre.\n4. Tirez le coude vers le plafond et vers la hanche (comme pour démarrer une tondeuse).\n5. Redescendez l''haltère lentement sans toucher le sol.'
        WHERE id = 5;
      ''');

      // 6. Tractions
      await customStatement('''
        UPDATE exercise 
        SET description = 'Le meilleur constructeur de dos au poids du corps. Il élargit le dos (forme en V) et renforce les biceps.',
            etapes = '\n 1. Suspendez-vous à la barre, mains plus larges que les épaules.\n2. Rétractez les omoplates (baissez les épaules).\n3. Tirez votre corps vers le haut jusqu''à ce que le menton dépasse la barre.\n4. Évitez de vous balancer (kipping).\n5. Redescendez en contrôlant le mouvement jusqu''à l''extension complète.'
        WHERE id = 6;
      ''');

      // 7. Tirage vertical (Lat Pulldown)
      await customStatement('''
        UPDATE exercise 
        SET description = 'Alternative aux tractions sur machine. Permet de cibler le grand dorsal avec une charge ajustable.',
            etapes = '\n 1. Réglez le siège pour avoir les genoux bloqués sous les boudins.\n2. Saisissez la barre prise large.\n3. Penchez-vous très légèrement en arrière, torse bombé.\n4. Tirez la barre vers le haut de vos pectoraux.\n5. Relâchez doucement sans laisser les poids claquer.'
        WHERE id = 7;
      ''');

      // 8. Presse à cuisses
      await customStatement('''
        UPDATE exercise 
        SET description = 'Permet de charger lourd sur les jambes sans la contrainte d''équilibre du squat. Cible quadriceps et fessiers.',
            etapes = '\n 1. Installez-vous dos et fesses bien collés au siège.\n2. Placez les pieds au centre du plateau, largeur d''épaules.\n3. Déverrouillez la sécurité.\n4. Fléchissez les jambes jusqu''à 90°.\n5. Poussez le plateau MAIS ne verrouillez jamais totalement les genoux en haut (gardez une légère flexion pour protéger l''articulation).'
        WHERE id = 8;
      ''');

      // 9. Corde à sauter
      await customStatement('''
        UPDATE exercise 
        SET description = 'Exercice cardio par excellence. Brûle énormément de calories, améliore la coordination et l''endurance.',
            etapes = '\n 1. Tenez les poignées fermement, coudes près du corps.\n2. Le mouvement de rotation vient des poignets, pas des épaules.\n3. Sautez sur la pointe des pieds, juste assez haut pour laisser passer la corde.\n4. Gardez les genoux souples à la réception.'
        WHERE id = 9;
      ''');

      // 10. Course tapis
      await customStatement('''
        UPDATE exercise 
        SET description = 'Cardio fondamental pour l''endurance cardiovasculaire et l''échauffement.',
            etapes = '\n 1. Démarrez le tapis à vitesse lente.\n2. Courez au centre du tapis.\n3. Gardez le dos droit et regardez loin devant (pas vos pieds).\n4. Ayez une foulée naturelle et légère.\n5. Évitez de vous tenir aux poignées, balancez les bras naturellement.'
        WHERE id = 10;
      ''');

      // 11. Gainage planche
      await customStatement('''
        UPDATE exercise 
        SET description = 'Exercice isométrique pour renforcer la sangle abdominale profonde (transverse) et protéger le dos.',
            etapes = '\n 1. En appui sur les avant-bras et les orteils.\n2. Coudes alignés sous les épaules.\n3. Contractez fort les fessiers et les abdominaux.\n4. Le corps doit former une ligne droite parfaite.\n5. Ne laissez pas le bassin tomber ni les fesses monter trop haut. Respirez calmement.'
        WHERE id = 11;
      ''');

      // 12. Curl biceps
      await customStatement('''
        UPDATE exercise 
        SET description = 'L''exercice d''isolation le plus populaire pour développer le volume des bras (biceps).',
            etapes = '\n 1. Debout, haltères ou barre en mains, paumes vers l''avant.\n2. Gardez les coudes collés aux côtes (ils ne doivent pas avancer).\n3. Levez la charge en contractant les biceps.\n4. Marquez une pause en haut.\n5. Redescendez lentement. Évitez de balancer le buste pour tricher.'
        WHERE id = 12;
      ''');
    
    debugPrint('--- Mises à jour des descriptions terminées ---');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');

      if (_isTest) return;

      await _ensureAppUserSingletonColumnAndIndex(); // <<--- AJOUT CLEF
      if (await _tableExists('app_user')) {
        await _addColumnIfMissing(
          'app_user',
          'singleton',
          'INTEGER NOT NULL DEFAULT 1',
        );

        await _addColumnIfMissing('app_user', 'birth_date', 'INTEGER');
      }

      if (await _tableExists('session')) {
        await _addColumnIfMissing(
          'session',
          'program_day_id',
          'INTEGER REFERENCES program_day(id) ON DELETE SET NULL',
        );

        await _addColumnIfMissing('session', 'name', 'TEXT');
      }

      if (await _tableExists('program_day_exercise')) {
        await _addColumnIfMissing(
          'program_day_exercise',
          'scheduled_date',
          'INTEGER',
        );

        await _addColumnIfMissing(
          'program_day_exercise',
          'previous_sets_suggestion',
          'TEXT',
        );
        await _addColumnIfMissing(
          'program_day_exercise',
          'previous_reps_suggestion',
          'TEXT',
        );
        await _addColumnIfMissing(
          'program_day_exercise',
          'previous_rest_suggestion',
          'INTEGER',
        );
      }
      
      if (await _tableExists('exercise')) {
        await _addColumnIfMissing(
          'exercise',
          'description',
          'TEXT',
        );
        await _addColumnIfMissing(
          'exercise',
          'etapes',
          'TEXT',
        );
      }

      await _ensureUserTrainingDayTable();

      if (await _tableExists('user_feedback')) {
        await _addColumnIfMissing(
          'user_feedback',
          'session_id',
          'INTEGER REFERENCES session(id) ON DELETE CASCADE',
        );
      }
      await customStatement('PRAGMA foreign_keys = ON;');
      await seedExerciseDetails();
    },

    onCreate: (m) async {
      await m.createAll();

      if (!_isTest) {
        await _createAllIndexes();
      }
    },
    onUpgrade: (m, from, to) async {
      debugPrint('[MIGRATION] onUpgrade appelé: version $from -> $to');

      if (_isTest) return;

      await _ensureAppUserSingletonColumnAndIndex();
      if (await _tableExists('app_user')) {
        await _addColumnIfMissing(
          'app_user',
          'singleton',
          'INTEGER NOT NULL DEFAULT 1',
        );

        await _addColumnIfMissing('app_user', 'birth_date', 'INTEGER');
      }

      await _addColumnIfMissing(
        'app_user',
        'singleton',
        'INTEGER NOT NULL DEFAULT 1',
      );

      if (await _tableExists('session')) {
        debugPrint(
          '[MIGRATION V40] Table session existe, ajout des colonnes...',
        );
        await _addColumnIfMissing(
          'session',
          'program_day_id',
          'INTEGER REFERENCES program_day(id) ON DELETE SET NULL',
        );

        debugPrint('[MIGRATION V40] Ajout de la colonne name à session...');
        await _addColumnIfMissing('session', 'name', 'TEXT');
        debugPrint('[MIGRATION V40] Colonne name ajoutée avec succès');
      }

      if (await _tableExists('program_day_exercise')) {
        await _addColumnIfMissing(
          'program_day_exercise',
          'scheduled_date',
          'INTEGER',
        );

        await _addColumnIfMissing(
          'program_day_exercise',
          'previous_sets_suggestion',
          'TEXT',
        );
        await _addColumnIfMissing(
          'program_day_exercise',
          'previous_reps_suggestion',
          'TEXT',
        );
        await _addColumnIfMissing(
          'program_day_exercise',
          'previous_rest_suggestion',
          'INTEGER',
        );
      }

      await _ensureExerciseRelationTable();
      await _ensureUserTrainingDayTable();

      // MIGRATION V41
      await _ensureGamificationTables();
      if (await _tableExists('app_user')) {
        await _addColumnIfMissing(
          'app_user',
          'xp',
          'INTEGER NOT NULL DEFAULT 0',
        );
        await _addColumnIfMissing(
          'app_user',
          'user_level',
          'INTEGER NOT NULL DEFAULT 1',
        );
        await _addColumnIfMissing('app_user', 'title', 'TEXT');
      }
      await _populateDefaultBadges();

      if (to >= 42) {
        await _populateBadgesV42();
      }

      if (await _tableExists('user_feedback')) {
        await _addColumnIfMissing(
          'user_feedback',
          'session_id',
          'INTEGER REFERENCES session(id) ON DELETE CASCADE',
        );
      }

      await _createAllIndexes();
    },
  );

  Future<void> _createSingletonIndexIfSafe() async {
    if (await _tableExists('app_user') &&
        await _columnExists('app_user', 'singleton')) {
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS ux_app_user_singleton ON app_user(singleton);',
      );
    }
  }

  Future<void> _createAllIndexes() async {
    await _createSingletonIndexIfSafe();
    Future<void> _idxIf(String table, String sql) async {
      if (await _tableExists(table)) {
        await customStatement(sql);
      }
    }

    await _idxIf(
      'exercise_muscle',
      'CREATE INDEX IF NOT EXISTS idx_ex_muscle  ON exercise_muscle(exercise_id);',
    );
    await _idxIf(
      'exercise_objective',
      'CREATE INDEX IF NOT EXISTS idx_ex_obj     ON exercise_objective(exercise_id);',
    );
    await _idxIf(
      'user_feedback',
      'CREATE INDEX IF NOT EXISTS idx_fb_user    ON user_feedback(user_id, ts);',
    );
    await _idxIf(
      'user_equipment',
      'CREATE INDEX IF NOT EXISTS idx_user_eq    ON user_equipment(user_id);',
    );
    await _idxIf(
      'user_goal',
      'CREATE INDEX IF NOT EXISTS idx_user_goal  ON user_goal(user_id);',
    );
    await _idxIf(
      'session',
      'CREATE INDEX IF NOT EXISTS idx_sess_user  ON session(user_id, date_ts);',
    );
    await _idxIf(
      'exercise_relation',
      'CREATE INDEX IF NOT EXISTS idx_rel_src    ON exercise_relation(src_exercise_id);',
    );
    await _idxIf(
      'training_modality',
      'CREATE INDEX IF NOT EXISTS idx_modality   ON training_modality(objective_id, level);',
    );
    await _idxIf(
      'program_day',
      'CREATE INDEX IF NOT EXISTS idx_prog_day   ON program_day(program_id);',
    );
    await _idxIf(
      'program_day_exercise',
      'CREATE INDEX IF NOT EXISTS idx_prog_ex  ON program_day_exercise(program_day_id);',
    );
    await _idxIf(
      'user_program',
      'CREATE INDEX IF NOT EXISTS idx_user_prog  ON user_program(user_id, is_active);',
    );
  }

  Future<String> integrityCheck() async {
    final row = await customSelect('PRAGMA integrity_check;').getSingle();
    return (row.data.values.first ?? '').toString();
  }

  Future<int> pragmaUserVersion() async {
    final row = await customSelect('PRAGMA user_version;').getSingle();
    final v = (row.data.values.first ?? '0').toString();
    return int.tryParse(v) ?? 0;
  }

  Future<bool> _tableExists(String table) async {
    final r =
        await customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name = ?;",
          variables: [Variable.withString(table)],
        ).get();
    return r.isNotEmpty;
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect("PRAGMA table_info('$table');").get();
    return rows.any((e) => (e.data['name'] ?? '').toString() == column);
  }

  Future<void> _addColumnIfMissing(
    String table,
    String column,
    String sqlType,
  ) async {
    if (!await _columnExists(table, column)) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $sqlType;');
    }
  }

  Future<void> _ensureExerciseRelationTable() async {
    if (!await _tableExists('exercise_relation')) {
      await customStatement('''
      CREATE TABLE IF NOT EXISTS exercise_relation (
        src_exercise_id INTEGER NOT NULL,
        dst_exercise_id INTEGER NOT NULL,
        relation_type   TEXT    NOT NULL,
        weight          REAL    NOT NULL,
        FOREIGN KEY (src_exercise_id) REFERENCES exercise (id) ON DELETE CASCADE,
        FOREIGN KEY (dst_exercise_id) REFERENCES exercise (id) ON DELETE CASCADE,
        PRIMARY KEY (src_exercise_id, dst_exercise_id, relation_type)
      );
    ''');
    }
  }

  Future<void> _ensureUserTrainingDayTable() async {
    if (!await _tableExists('user_training_day')) {
      await customStatement('''
      CREATE TABLE IF NOT EXISTS user_training_day (
        user_id     INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
        FOREIGN KEY (user_id) REFERENCES app_user (id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, day_of_week)
      );
    ''');
    }
  }

  Future<void> _ensureAppUserSingletonColumnAndIndex() async {
    if (await _tableExists('app_user')) {
      final hasSingleton = await _columnExists('app_user', 'singleton');
      if (!hasSingleton) {
        await customStatement(
          'ALTER TABLE app_user ADD COLUMN singleton INTEGER NOT NULL DEFAULT 1;',
        );
      }

      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS ux_app_user_singleton ON app_user(singleton);',
      );
    }
  }

  Future<void> _ensureGamificationTables() async {
    if (!await _tableExists('gamification_badge')) {
      await customStatement('''
        CREATE TABLE IF NOT EXISTS gamification_badge (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          icon_asset TEXT,
          xp_reward INTEGER NOT NULL DEFAULT 0
        );
      ''');
    }
    if (!await _tableExists('user_badge')) {
      await customStatement('''
        CREATE TABLE IF NOT EXISTS user_badge (
          user_id INTEGER NOT NULL,
          badge_id TEXT NOT NULL,
          earned_date_ts INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES app_user (id) ON DELETE CASCADE,
          FOREIGN KEY (badge_id) REFERENCES gamification_badge (id) ON DELETE CASCADE,
          PRIMARY KEY (user_id, badge_id)
        );
      ''');
    }
  }

  Future<void> _populateDefaultBadges() async {
    // Helper to insert ignore
    Future<void> _addBadge(String id, String name, String desc, int xp) async {
      final exists =
          await (select(gamificationBadge)
            ..where((b) => b.id.equals(id))).getSingleOrNull();
      if (exists == null) {
        await into(gamificationBadge).insert(
          GamificationBadgeCompanion.insert(
            id: id,
            name: name,
            description: desc,
            xpReward: Value(xp),
          ),
        );
      }
    }

    if (await _tableExists('gamification_badge')) {
      await _addBadge(
        'first_steps',
        'Premier Pas',
        'Terminer la première séance',
        50,
      );
      await _addBadge('early_bird', 'Lève-tôt', 'S\'entraîner avant 8h', 100);
      await _addBadge('night_owl', 'Nocturne', 'S\'entraîner après 22h', 100);
      await _addBadge(
        'spartan',
        'Spartiate',
        'Faire plus de 300 reps en une séance',
        200,
      );
      await _addBadge('marathon', 'Marathonien', 'Séance de plus de 2h', 300);
    }
  }

  Future<void> _populateBadgesV42() async {
    Future<void> _addBadge(String id, String name, String desc, int xp) async {
      final exists =
          await (select(gamificationBadge)
            ..where((b) => b.id.equals(id))).getSingleOrNull();
      if (exists == null) {
        await into(gamificationBadge).insert(
          GamificationBadgeCompanion.insert(
            id: id,
            name: name,
            description: desc,
            xpReward: Value(xp),
          ),
        );
      }
    }

    if (await _tableExists('gamification_badge')) {
      await _addBadge(
        'sunday_warrior',
        'Guerrier du Dimanche',
        'S\'entraîner le dimanche',
        150,
      );
      await _addBadge(
        'hulk',
        'Hulk',
        'Soulever plus de 5 tonnes (volume total)',
        500,
      );
      await _addBadge(
        'high_voltage',
        'Survolté',
        'Intensité moyenne > 8/10',
        300,
      );
    }
  }
}
