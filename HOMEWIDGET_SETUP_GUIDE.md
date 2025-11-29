# Guide d'Installation : Widget Android d'Écran d'Accueil

## Qu'est-ce que c'est ?

Un **widget natif Android** qui s'affiche directement sur l'écran d'accueil de votre téléphone pour montrer votre prochaine séance d'entraînement avec :
- ✅ Date et jour
- ✅ Durée de la séance
- ✅ Type de séance (PUSH, PULL, LEGS, etc.)
- ✅ Exercices de la séance
- ✅ Bouton pour ouvrir l'app

## Fichiers créés

### Fichiers Flutter (Dart)
```
lib/
└── services/
    └── home_widget_service.dart        # Service de gestion du widget
```

### Fichiers Android (Kotlin)
```
android/app/src/main/
├── kotlin/com/example/recommandation_mobile/
│   └── SessionWidgetProvider.kt        # Provider du widget
├── res/
│   ├── layout/
│   │   └── widget_session.xml          # Layout du widget
│   ├── drawable/
│   │   ├── widget_background.xml       # Background style
│   │   ├── widget_tag_background.xml   # Style du tag type séance
│   │   └── widget_button_background.xml # Style du bouton
│   ├── values/
│   │   └── strings.xml                 # Ressources texte
│   └── xml/
│       └── widget_session_info.xml     # Configuration du widget
└── AndroidManifest.xml                 # Déclaration du widget (modifié)
```

## Installation

### Étape 1 : Ajouter la dépendance

✅ **Déjà fait** dans `pubspec.yaml` :
```yaml
dependencies:
  home_widget: ^0.4.0
```

Si ce n'est pas fait, exécutez :
```bash
fvm flutter pub get
```

### Étape 2 : Compiler et déployer

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter build apk --debug
```

Ou pour utiliser directement sur l'émulateur :
```bash
fvm flutter run
```

### Étape 3 : Ajouter le widget sur l'écran d'accueil

1. Ouvrez votre téléphone/émulateur Android
2. Allez sur l'écran d'accueil
3. Appuyez long sur l'écran d'accueil
4. Sélectionnez "Widgets"
5. Recherchez "SessionWidget" ou "Recommandation Mobile"
6. Glissez-déposez le widget sur l'écran d'accueil
7. Le widget s'affiche avec les données par défaut

## Utilisation dans l'app Flutter

### Initialiser le widget au démarrage

**Fichier** : `lib/main.dart`

```dart
import 'services/home_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données
  final db = AppDb();

  // Initialiser le service de widget
  final widgetService = HomeWidgetService(db);
  await widgetService.initializeWidget();

  runApp(MyApp(db: db));
}
```

### Mettre à jour le widget après une action

**Exemple** : Après la création d'une séance

```dart
import 'services/home_widget_service.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final HomeWidgetService _widgetService;

  @override
  void initState() {
    super.initState();
    _widgetService = HomeWidgetService(widget.db);
  }

  Future<void> _createSession() async {
    // Créer la séance...

    // Mettre à jour le widget avec les nouvelles données
    await _widgetService.updateHomeWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _createSession,
          child: const Text('Créer une séance'),
        ),
      ),
    );
  }
}
```

### Demander à l'utilisateur de pincer le widget

```dart
import 'services/home_widget_service.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final widgetService = HomeWidgetService(db);
            final pinned = await widgetService.requestPinWidget();

            if (pinned) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Widget pincé sur l\'écran d\'accueil !')),
              );
            }
          },
          child: const Text('Ajouter le widget à l\'écran d\'accueil'),
        ),
      ),
    );
  }
}
```

## Architecture du widget

```
┌─────────────────────────────────┐
│    home_widget_service.dart     │  ← Gestion Flutter
│  (Sauvegarde données)           │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│    SharedPreferences            │  ← Stockage partagé
│  (home_widget utilise cela)     │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ SessionWidgetProvider.kt        │  ← Provider Android
│ (Lit les données et affiche)    │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│    widget_session.xml           │  ← Layout XML
│ (Affiche le widget sur écran)   │
└─────────────────────────────────┘
```

## Flux de données

```
App Flutter
    ↓
HomeWidgetService.updateHomeWidget()
    ↓
Sauvegarde dans SharedPreferences :
  - dayName
  - dayNumber
  - monthName
  - durationMinutes
  - sessionType
  - exercise1
  - exercise2
    ↓
SessionWidgetProvider.onUpdate()
    ↓
Lit depuis SharedPreferences
    ↓
Affiche sur l'écran d'accueil
```

## Personnalisation

### Modifier le design du widget

**Fichier** : `android/app/src/main/res/layout/widget_session.xml`

- Modifiez les couleurs, tailles, fonts
- Ajoutez/supprimez des éléments
- Changez le layout (LinearLayout → ConstraintLayout, etc.)

### Modifier les couleurs

**Fichiers** :
- `drawable/widget_background.xml` → Fond du widget
- `drawable/widget_tag_background.xml` → Color du tag PUSH/PULL
- `drawable/widget_button_background.xml` → Couleur du bouton

Exemple :
```xml
<solid android:color="#D9BE77" />  <!-- Change cette couleur -->
```

### Ajouter plus d'exercices

**Fichier** : `android/app/src/main/res/layout/widget_session.xml`

Duplique le bloc exercice et ajoute les IDs correspondants.

**Fichier** : `lib/services/home_widget_service.dart`

Augmente `exerciseCount` et ajoute le stockage des données:
```dart
final sessionInfo = await sessionService.getRandomSessionInfo(exerciseCount: 4);

// Ajouter après les exercices 1 et 2
if (sessionInfo.exercises.length > 2) {
  final ex3 = sessionInfo.exercises[2];
  await HomeWidget.saveWidgetData<String>(
    'exercise3',
    '${ex3.name}\n${ex3.sets} / ${ex3.reps} / ${ex3.load}',
  );
}
```

## Troubleshooting

### ❌ Le widget n'apparaît pas après installation

**Solution** :
1. Vérifiez que la dépendance `home_widget` est installée
2. Compilez à nouveau : `fvm flutter clean && fvm flutter pub get`
3. Redémarrez l'émulateur/téléphone
4. Allez dans les widgets et cherchez le widget

### ❌ Le widget affiche "Chargement..."

**Solution** :
1. Vérifiez que `HomeWidgetService.initializeWidget()` est appelée au démarrage
2. Vérifiez les logs : `adb logcat`
3. Mettez à jour manuellement :
   ```dart
   final service = HomeWidgetService(db);
   await service.updateHomeWidget();
   ```

### ❌ Le widget ne se met pas à jour

**Solution** :
1. Vérifiez que `updateHomeWidget()` est appelée
2. Vérifiez les permissions dans `AndroidManifest.xml`
3. Redémarrez l'app

### ❌ Erreur de compilation Android

**Solution** :
1. Vérifiez les fichiers XML sont corrects
2. Vérifiez les IDs dans `widget_session.xml`
3. Vérifiez que `SessionWidgetProvider.kt` compile
4. Exécutez `./gradlew clean` dans `android/`

## Performance

- ✅ Mise à jour asynchrone (pas de blocage UI)
- ✅ Stockage efficace en SharedPreferences
- ✅ Pas de base de données lourde
- ✅ Widget léger (utilise RemoteViews)

## Limites

- ⚠️ Le widget ne peut afficher que du texte et des images
- ⚠️ Pas d'animations complexes
- ⚠️ Pas de WebViews ou composants Flutter
- ⚠️ Mis à jour manuellement (pas de mise à jour auto)

## Prochaines étapes

1. **Mise à jour automatique** : Ajouter un service pour mettre à jour périodiquement
2. **Clic sur les exercices** : Permettre de naviguer vers un exercice
3. **Plusieurs widgets** : Créer d'autres widgets (stats, progressions)
4. **Widget iOS** : Implémenter sur iOS avec WidgetKit

## Ressources

- [home_widget documentation](https://pub.dev/packages/home_widget)
- [Google Codelabs - Flutter Home Screen Widgets](https://codelabs.developers.google.com/flutter-home-screen-widgets)
- [Android AppWidget Documentation](https://developer.android.com/guide/topics/appwidgets)

## Checklist

- [ ] home_widget ajouté à pubspec.yaml
- [ ] SessionWidgetProvider.kt créé et compilé
- [ ] Layouts XML créés
- [ ] Configuration du widget (widget_session_info.xml)
- [ ] AndroidManifest.xml mis à jour
- [ ] HomeWidgetService créé en Flutter
- [ ] Initialisé au démarrage (main.dart)
- [ ] Widget compilé et déployé
- [ ] Widget visible sur l'écran d'accueil
- [ ] Mise à jour fonctionne

---

**Version** : 1.0
**Date** : 16 Novembre 2025
**Status** : Prêt pour utilisation
