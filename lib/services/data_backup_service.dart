import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/db/app_db.dart';

/// Service gérant l'export et l'import des données utilisateur via JSON.
/// Permet la portabilité des données sans serveur ("Local First").
class DataBackupService {
  final AppDb db;

  DataBackupService(this.db);

  /// Génère le contenu JSON (Map) de la sauvegarde
  Future<Map<String, dynamic>> _generateBackupData() async {
    final data = <String, dynamic>{
      'version': 1,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': {},
    };

    // 1. Récupération des données
    final users = await db.select(db.appUser).get();
    final userGoals = await db.select(db.userGoal).get();
    final userEquipments = await db.select(db.userEquipment).get();
    final userTrainingDays = await db.select(db.userTrainingDay).get();
    final userFeedbacks = await db.select(db.userFeedback).get();
    final sessions = await db.select(db.session).get();
    final sessionExercises = await db.select(db.sessionExercise).get();
    final workoutPrograms = await db.select(db.workoutProgram).get();
    final programDays = await db.select(db.programDay).get();
    final programDayExercises = await db.select(db.programDayExercise).get();
    final userPrograms = await db.select(db.userProgram).get();
    final userBadges = await db.select(db.userBadge).get();

    // 2. Sérialisation
    data['data'] = {
      'app_user': users.map((e) => e.toJson()).toList(),
      'user_goal': userGoals.map((e) => e.toJson()).toList(),
      'user_equipment': userEquipments.map((e) => e.toJson()).toList(),
      'user_training_day': userTrainingDays.map((e) => e.toJson()).toList(),
      'user_feedback': userFeedbacks.map((e) => e.toJson()).toList(),
      'session': sessions.map((e) => e.toJson()).toList(),
      'session_exercise': sessionExercises.map((e) => e.toJson()).toList(),
      'workout_program': workoutPrograms.map((e) => e.toJson()).toList(),
      'program_day': programDays.map((e) => e.toJson()).toList(),
      'program_day_exercise':
          programDayExercises.map((e) => e.toJson()).toList(),
      'user_program': userPrograms.map((e) => e.toJson()).toList(),
      'user_badge': userBadges.map((e) => e.toJson()).toList(),
    };
    return data;
  }

  /// Exporte toutes les données utilisateur et ouvre le panneau de partage.
  Future<void> exportData() async {
    try {
      final data = await _generateBackupData();
      final directory = await getTemporaryDirectory();
      final dateStr =
          DateTime.now()
              .toIso8601String()
              .replaceAll(':', '-')
              .split('.')
              .first;
      final file = File('${directory.path}/zenith_backup_$dateStr.json');

      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);

      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'Mes données Zénith ($dateStr)');
    } catch (e, st) {
      debugPrint('DataBackupService: Erreur Share -> $e');
      debugPrint(st.toString());
      throw Exception('Impossible de partager les données : $e');
    }
  }

  /// Sauvegarde le fichier directement dans le dossier Téléchargements (Android).
  /// Retourne le chemin complet du fichier sauvegardé.
  Future<String> saveToDownloads() async {
    try {
      final data = await _generateBackupData();

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !downloadsDir.existsSync()) {
        // Fallback temp si downloads inaccessible (ne devrait pas arriver sur Android standard)
        downloadsDir = await getTemporaryDirectory();
      }

      final dateStr =
          DateTime.now()
              .toIso8601String()
              .replaceAll(':', '-')
              .split('.')
              .first;

      final filePath = '${downloadsDir.path}/zenith_backup_$dateStr.json';
      final file = File(filePath);

      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e, st) {
      debugPrint('DataBackupService: Erreur SaveLocal -> $e');
      debugPrint(st.toString());
      throw Exception('Impossible de sauvegarder en local : $e');
    }
  }

  /// Importe des données depuis un fichier JSON.
  /// Retourne true si succès, false si annulé.
  /// Throws Exception si erreur.
  Future<bool> importData() async {
    try {
      // 1. Picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> jsonRoot = jsonDecode(content);

      if (!jsonRoot.containsKey('data') || jsonRoot['data'] is! Map) {
        throw Exception('Format de fichier invalide (racine "data" manquante)');
      }

      final dataMap = jsonRoot['data'] as Map<String, dynamic>;

      // 2. Transaction (Delete All + Insert All)
      await db.transaction(() async {
        // A. Nettoyage (Ordre dépendant des FK si besoin, mais drift gère souvent via cascade)
        // On supprime tout pour repartir propre.
        await db.delete(db.sessionExercise).go();
        await db.delete(db.userFeedback).go();
        await db.delete(db.programDayExercise).go();
        await db.delete(db.session).go();
        await db.delete(db.userProgram).go();
        await db.delete(db.programDay).go();
        await db.delete(db.workoutProgram).go();
        await db.delete(db.userBadge).go();
        await db.delete(db.userGoal).go();
        await db.delete(db.userEquipment).go();
        await db.delete(db.userTrainingDay).go();
        await db.delete(db.appUser).go();

        // B. Insertion explicite (Mapping JSON -> DataClass -> Insert)
        // Note: AppUserData.fromJson, WorkoutProgramData.fromJson, etc. sont générés par Drift.

        if (dataMap['app_user'] != null) {
          final list =
              (dataMap['app_user'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.appUser,
              list.map((e) => AppUserData.fromJson(e)).toList(),
            );
          });
        }

        // On insère le reste
        // Programmes
        if (dataMap['workout_program'] != null) {
          final list =
              (dataMap['workout_program'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.workoutProgram,
              list.map((e) => WorkoutProgramData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['program_day'] != null) {
          final list =
              (dataMap['program_day'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.programDay,
              list.map((e) => ProgramDayData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['program_day_exercise'] != null) {
          final list =
              (dataMap['program_day_exercise'] as List)
                  .cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.programDayExercise,
              list.map((e) => ProgramDayExerciseData.fromJson(e)).toList(),
            );
          });
        }

        // Sessions
        if (dataMap['session'] != null) {
          final list =
              (dataMap['session'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.session,
              list.map((e) => SessionData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['session_exercise'] != null) {
          final list =
              (dataMap['session_exercise'] as List)
                  .cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.sessionExercise,
              list.map((e) => SessionExerciseData.fromJson(e)).toList(),
            );
          });
        }

        // User relations
        if (dataMap['user_goal'] != null) {
          final list =
              (dataMap['user_goal'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.userGoal,
              list.map((e) => UserGoalData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['user_equipment'] != null) {
          final list =
              (dataMap['user_equipment'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.userEquipment,
              list.map((e) => UserEquipmentData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['user_training_day'] != null) {
          final list =
              (dataMap['user_training_day'] as List)
                  .cast<Map<String, dynamic>>();
          await db.batch((batch) {
            // Note: Si des conflits uniques existent (user_id/day), le mode par défaut est insert.
            // Comme on a tout vidé, pas de conflit.
            batch.insertAll(
              db.userTrainingDay,
              list.map((e) => UserTrainingDayData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['user_feedback'] != null) {
          final list =
              (dataMap['user_feedback'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.userFeedback,
              list.map((e) => UserFeedbackData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['user_program'] != null) {
          final list =
              (dataMap['user_program'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.userProgram,
              list.map((e) => UserProgramData.fromJson(e)).toList(),
            );
          });
        }

        if (dataMap['user_badge'] != null) {
          final list =
              (dataMap['user_badge'] as List).cast<Map<String, dynamic>>();
          await db.batch((batch) {
            batch.insertAll(
              db.userBadge,
              list.map((e) => UserBadgeData.fromJson(e)).toList(),
            );
          });
        }
      });

      return true;
    } catch (e, st) {
      debugPrint('DataBackupService: Erreur Import -> $e');
      debugPrint(st.toString());
      rethrow;
    }
  }
}
