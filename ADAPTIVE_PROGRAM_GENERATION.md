# Système de Génération Adaptative de Programme

## Vue d'ensemble

Le système adapte automatiquement les programmes d'entraînement en fonction des performances réelles de l'utilisateur après chaque séance complétée.

## Fonctionnement

### 1. Collecte des données (durant la séance)

Quand l'utilisateur effectue une séance, le système enregistre pour chaque exercice :
- **Séries effectuées** (nombre réel vs suggéré)
- **Répétitions effectuées** (nombre réel vs suggéré)
- **Charge utilisée** (en kg)
- **RPE (Rate of Perceived Exertion)** : effort perçu sur 10

Ces données sont stockées dans la table `session_exercise`.

### 2. Régénération automatique après la séance

Dès qu'une séance est terminée, le système :

1. **Identifie les jours complétés** : ceux qui ont une session enregistrée
2. **Conserve les jours passés** : pour l'historique et l'analyse
3. **Régénère UNIQUEMENT les jours futurs** : ceux non encore effectués

### 3. Algorithme d'adaptation

Pour chaque exercice, l'algorithme calcule deux ajustements :

#### A. Ajustement basé sur les performances (`_calculatePerformanceAdjustment`)

Analyse les 5 dernières sessions de l'exercice :

**Critères RPE (effort perçu) :**
- **RPE > 8.5** → Ajustement -0.5 (trop difficile)
  - ⚠️ L'exercice sera moins recommandé
  - Le système favorisera des alternatives plus faciles

- **RPE 7.5-8.5** → Ajustement -0.2 (difficile mais gérable)
  - Légère baisse de priorité

- **RPE 6.5-7.5** → Zone optimale
  - Si progression → +0.1
  - Sinon → neutre (0.0)

- **RPE 5.5-6.5** → Ajustement +0.2 (facile)
  - L'exercice est favorisé

- **RPE < 5.5** → Ajustement +0.5 (trop facile)
  - ✅ L'exercice sera fortement recommandé
  - Idéal pour la progression

**Bonus progression :**
- Si la charge augmente de >20% ET RPE < 8.0 → Bonus +0.2
- Récompense la progression contrôlée

#### B. Ajustement basé sur les feedbacks (`_calculateFeedbackAdjustment`)

Analyse les feedbacks des 30 derniers jours :

- **Exercice aimé (liked=1)** → +0.3
- **Exercice pas aimé (liked=0)** → -0.2
- **Marqué comme difficile** → -0.2
- **Marqué comme inutile** → -0.4 (forte pénalité)
- **Marqué comme plaisant** → +0.1

### 4. Calcul du score final

```dart
score = baseScore × difficultyBonus × (1 + performanceAdj) × (1 + feedbackAdj)
```

Où :
- `baseScore` : affinité avec l'objectif de l'utilisateur (prise de masse, perte de poids, etc.)
- `difficultyBonus` : bonus si la difficulté est adaptée au niveau
- `performanceAdj` : -1.0 à +1.0 selon RPE et progression
- `feedbackAdj` : -1.0 à +0.5 selon les feedbacks

### 5. Sélection des nouveaux exercices

Pour chaque jour futur :
1. Les exercices sont triés par score décroissant
2. Sélection de 4 exercices poly-articulaires (prioritaires)
3. Sélection de 2 exercices d'isolation
4. Mélange aléatoire pour varier les séances

## Exemples concrets

### Scénario 1 : Exercice trop difficile

**Situation :**
- Exercice : "Squat barre"
- RPE moyen des 5 dernières sessions : 9.2
- Charge : 100kg → 95kg (régression)

**Résultat :**
- Ajustement performance : -0.5
- L'exercice ne sera plus recommandé dans les prochains jours
- Le système proposera des alternatives (squat goblet, presse à cuisses, etc.)

### Scénario 2 : Bonne progression

**Situation :**
- Exercice : "Développé couché"
- RPE moyen : 7.0 (zone optimale)
- Charge : 60kg → 70kg (+16%)
- Feedback : aimé, plaisant

**Résultat :**
- Ajustement performance : +0.1 (zone optimale avec légère progression)
- Ajustement feedback : +0.4 (aimé + plaisant)
- Score multiplié par 1.1 × 1.4 = 1.54
- L'exercice sera fortement recommandé dans les prochaines séances

### Scénario 3 : Exercice trop facile

**Situation :**
- Exercice : "Curl biceps"
- RPE moyen : 4.5
- Charge stable : 12kg
- Feedback : marqué comme "inutile"

**Résultat :**
- Ajustement performance : +0.5 (trop facile)
- Ajustement feedback : -0.4 (inutile)
- Score multiplié par 1.5 × 0.6 = 0.9
- L'exercice sera remplacé par un exercice plus challengeant

## Interface utilisateur

Après avoir terminé une séance, l'utilisateur voit :

1. ✅ **"Séance enregistrée avec succès !"** (SnackBar or)
2. 🔄 **"Adaptation du programme en cours..."** (SnackBar bleu, 2s)
3. ✅ **"Programme adapté à tes performances !"** (SnackBar or, 2s)

Les prochains jours du programme sont automatiquement mis à jour avec les exercices adaptés.

## Avantages du système

### Pour l'utilisateur
- ✅ **Adaptation automatique** : pas besoin de changer manuellement le programme
- ✅ **Évite les plateaux** : le système détecte quand un exercice devient trop facile
- ✅ **Prévient les blessures** : réduit les exercices trop difficiles (RPE > 8.5)
- ✅ **Personnalisation continue** : le programme évolue avec l'utilisateur

### Pour le système
- 📊 **Apprentissage continu** : plus l'utilisateur s'entraîne, plus le système devient précis
- 🎯 **Optimisation de l'objectif** : maintient l'utilisateur dans sa zone optimale
- 🔄 **Variété** : mélange aléatoire pour éviter la monotonie

## Code source

### Fichiers modifiés

1. **`lib/data/db/app_db.dart`**
   - Ajout de `sessionId` dans `UserFeedback` (ligne 257)
   - Migration automatique (version 37)

2. **`lib/services/recommendation_service.dart`**
   - `_calculatePerformanceAdjustment()` (ligne 371)
   - `_calculateFeedbackAdjustment()` (ligne 457)
   - `_applyAdaptiveAdjustments()` (ligne 509)

3. **`lib/services/program_generator_service.dart`**
   - `regenerateFutureDays()` (ligne 548)

4. **`lib/ui/pages/workout_program_page.dart`**
   - Appel automatique de `regenerateFutureDays()` après session (ligne 235)

## Logs de débogage

Pour suivre le processus de régénération :

```dart
[PROGRAM_REGEN] Début régénération des jours futurs pour programme 1
[PROGRAM_REGEN] Jour 1 (Haut du corps) est complété
[PROGRAM_REGEN] 2 jours à régénérer
[PROGRAM_REGEN] Régénération jour 2 (Bas du corps)
[PROGRAM_REGEN] Jour 2 régénéré avec 6 exercices
[PROGRAM_REGEN] Régénération terminée avec succès
```

## Désactivation (si nécessaire)

Pour désactiver la régénération automatique, commenter la ligne 235 dans `workout_program_page.dart` :

```dart
// await _programService.regenerateFutureDays(
//   userId: userId,
//   programId: _currentProgram!.id,
// );
```
