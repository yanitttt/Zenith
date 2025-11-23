# Widget SessionCard

Widget modulaire et réutilisable pour afficher une carte de séance d'entraînement.

## Fichiers

- **session_card.dart** : Contient le widget `SessionCard` et les modèles de données `SessionInfo` et `ExerciseItem`
- **README.md** : Cette documentation

## Modèles de données

### SessionInfo
Contient les informations générales d'une séance :
- `dayName` : Jour de la semaine (ex: "Lundi")
- `dayNumber` : Jour du mois (ex: 15)
- `monthName` : Mois de l'année (ex: "Novembre")
- `durationMinutes` : Durée en minutes (ex: 60)
- `sessionType` : Type de séance (ex: "PUSH", "PULL", "LEGS")
- `exercises` : Liste des exercices (`List<ExerciseItem>`)

### ExerciseItem
Contient les informations d'un exercice :
- `name` : Nom de l'exercice (ex: "Squat")
- `sets` : Nombre de séries (ex: "4 séries")
- `reps` : Nombre de répétitions (ex: "8 répétitions")
- `rest` : Temps de repos (ex: "1min de repos")
- `load` : Charge à lever (ex: "60kg de charge")
- `icon` : Icône à afficher (ex: `Icons.fitness_center`)

## Utilisation basique

```dart
import 'package:flutter/material.dart';
import 'lib/ui/widgets/session/session_card.dart';

final sessionInfo = SessionInfo(
  dayName: 'Lundi',
  dayNumber: 15,
  monthName: 'Novembre',
  durationMinutes: 60,
  sessionType: 'PUSH',
  exercises: [
    ExerciseItem(
      name: 'Squat',
      sets: '4 séries',
      reps: '8 répétitions',
      rest: '1min de repos',
      load: '60kg de charge',
      icon: Icons.fitness_center,
    ),
    ExerciseItem(
      name: 'Tapis',
      sets: '4 séries',
      reps: '8 répétitions',
      rest: '1min de repos',
      load: '60kg de charge',
      icon: Icons.self_improvement,
    ),
  ],
);

SessionCard(
  sessionInfo: sessionInfo,
  onNextPressed: () {
    // Action au clic du bouton "Suite"
    Navigator.push(context, ...);
  },
)
```

## Utilisation avec SessionService

Pour charger automatiquement les données depuis la base de données :

```dart
import 'package:flutter/material.dart';
import 'lib/services/session_service.dart';
import 'lib/ui/widgets/session/session_card.dart';

final sessionService = SessionService(db);
final sessionInfo = await sessionService.getRandomSessionInfo(exerciseCount: 4);

SessionCard(
  sessionInfo: sessionInfo,
  onNextPressed: () {
    // Navigation ou autre action
  },
)
```

## Personnalisation

### Couleurs
Les couleurs utilisées proviennent de `AppTheme` :
- Gold principal : `AppTheme.gold`
- Couleurs du thème sombre : Voir `lib/ui/theme/app_theme.dart`

Pour modifier les couleurs, éditez directement le fichier `session_card.dart` ou créez une variante.

### Exercices statiques vs dynamiques
- **Statiques** : Créez directement des `ExerciseItem` avec les données
- **Dynamiques** : Utilisez `SessionService` pour récupérer les exercices depuis la BD

### Nombre d'exercices
Contrôlez le nombre d'exercices avec le paramètre `exerciseCount` de `SessionService` :

```dart
final sessionInfo = await sessionService.getRandomSessionInfo(exerciseCount: 6);
```

## Architecture

```
lib/
├── ui/
│   ├── widgets/
│   │   └── session/
│   │       ├── session_card.dart (Widget + modèles)
│   │       └── README.md (Cette documentation)
│   └── pages/
│       └── session_preview_page.dart (Exemple d'utilisation)
├── services/
│   └── session_service.dart (Service de récupération des données)
└── data/
    └── models/
        └── session_model.dart (Modèles sérialisables pour JSON/stockage)
```

## Bonnes pratiques

1. **Réutilisabilité** : Le widget `SessionCard` ne dépend que de `SessionInfo`, pas de la source de données
2. **Modularité** : Séparez la logique de récupération (service) de l'affichage (widget)
3. **Testabilité** : Créez des `SessionInfo` pour les tests unitaires facilement
4. **Maintenabilité** : Tous les modèles sont dans des fichiers séparés

## Intégration dans l'app

### Option 1 : Dans la page Dashboard
```dart
// Dans dashboard_page.dart
final sessionService = SessionService(widget.db);
final sessionInfo = await sessionService.getRandomSessionInfo();

SessionCard(
  sessionInfo: sessionInfo,
  onNextPressed: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TrainingPage(sessionInfo: sessionInfo),
    ));
  },
)
```

### Option 2 : Page dédiée
```dart
// Naviguer vers session_preview_page.dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => SessionPreviewPage(db: widget.db),
));
```

## Support des icônes

Le `SessionService` mappe automatiquement les noms d'exercices aux icônes Material :
- Squat, Leg → `Icons.fitness_center`
- Bench, Press → `Icons.self_improvement`
- Curl, Pull → `Icons.open_in_full`
- Row, Lat → `Icons.trending_up`
- Deadlift, Lift → `Icons.speed`
- Plank, Core → `Icons.favorite`
- Dip, TRX → `Icons.catching_pokemon`
- Fly, Machine → `Icons.pan_tool`
- Autres → `Icons.fit_screen`

Vous pouvez ajouter d'autres mappages dans `SessionService._getExerciseIcon()`.

## Gestion des erreurs

Si les données ne peuvent pas être chargées, `SessionService` retourne une session par défaut :
- 2 exercices d'exemple (Squat, Tapis)
- Date : Lundi 15 Novembre
- Durée : 60 minutes
- Type : PUSH

## Performance

- Les exercices sont chargés de manière asynchrone
- L'UI reste fluide même avec beaucoup d'exercices (pagination optionnelle)
- Pas de rebuild inutile grâce à `const` constructors où possible

## Évolutions futures

- [ ] Support du drag & drop pour réordonner les exercices
- [ ] Intégration avec la page de séance active
- [ ] Cache des sessions générées
- [ ] Historique des séances complétées
- [ ] Animations d'entrée au chargement
- [ ] Support de plusieurs langues
