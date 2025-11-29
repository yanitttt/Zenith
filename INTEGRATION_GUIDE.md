# Guide d'Intégration du Widget SessionCard

Ce guide montre comment intégrer rapidement le widget `SessionCard` dans votre application.

## 1️⃣ Intégration simple (5 minutes)

### Étape 1 : Ajouter le widget au Dashboard

**Fichier** : `lib/ui/pages/dashboard_page.dart`

Remplacez la ligne :
```dart
import '../widgets/favorites/favorites_card.dart';
```

Par :
```dart
import '../widgets/favorites/favorites_card.dart';
import '../widgets/session/session_card.dart';
import '../../services/session_service.dart';
```

### Étape 2 : Ajouter une variable de state

Dans `_DashboardPageState`, ajoutez :
```dart
SessionInfo? _nextSession;
```

### Étape 3 : Charger les données

Dans `_loadDashboardData()`, avant le `setState` final, ajoutez :
```dart
// Charger la prochaine séance
final sessionService = SessionService(widget.db);
final sessionInfo = await sessionService.getRandomSessionInfo(exerciseCount: 4);
```

Puis mettez à jour le setState :
```dart
if (mounted) {
  setState(() {
    _userName = prenom;
    _randomExercises = randomExercises;
    _nextSession = sessionInfo;  // AJOUTEZ CETTE LIGNE
    _isLoading = false;
  });
}
```

### Étape 4 : Afficher le widget

Dans la méthode `build()`, après `CalendarCard`, ajoutez :
```dart
if (_nextSession != null)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SessionCard(
      sessionInfo: _nextSession!,
      onNextPressed: () {
        // Redirection vers la page de séance
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Début de la séance...'))
        // );
      },
    ),
  ),
const SizedBox(height: 16),
```

---

## 2️⃣ Intégration avancée (Navigation)

Si vous voulez naviguer vers une page de séance :

```dart
onNextPressed: () {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => TrainingPage(
      sessionInfo: _nextSession!,
      db: widget.db,
    ),
  ));
},
```

---

## 3️⃣ Utiliser une page dédiée

**Alternative simple** : Créer une page d'accueil séances

```dart
// lib/ui/pages/sessions_page.dart
import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../widgets/session/session_card.dart';
import '../../services/session_service.dart';

class SessionsPage extends StatefulWidget {
  final AppDb db;
  const SessionsPage({super.key, required this.db});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late final SessionService _sessionService;
  SessionInfo? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _sessionService = SessionService(widget.db);
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await _sessionService.getRandomSessionInfo(exerciseCount: 6);
    if (mounted) {
      setState(() {
        _session = session;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Mes séances'),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : _session == null
              ? const Center(child: Text('Erreur chargement'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SessionCard(
                    sessionInfo: _session!,
                    onNextPressed: () {
                      // Navigation ou action
                    },
                  ),
                ),
    );
  }
}
```

---

## 4️⃣ Personnaliser les exercices

### Options :

**A) Exercices aléatoires (défaut)**
```dart
final session = await sessionService.getRandomSessionInfo(exerciseCount: 4);
```

**B) Exercices spécifiques**
```dart
final sessionInfo = SessionInfo(
  dayName: 'Lundi',
  dayNumber: 15,
  monthName: 'Novembre',
  durationMinutes: 60,
  sessionType: 'PUSH',
  exercises: [
    const ExerciseItem(
      name: 'Bench Press',
      sets: '4 séries',
      reps: '8 répétitions',
      rest: '2min de repos',
      load: '80kg de charge',
      icon: Icons.fitness_center,
    ),
    // ... autres exercices
  ],
);
```

**C) Depuis la BD personnalisée**
```dart
final exerciseRepo = ExerciseRepository(widget.db);
final exercices = await exerciseRepo.suggestForUser(userId, limit: 6);

final exerciseItems = exercices.map((e) => ExerciseItem(
  name: e.name,
  sets: '4 séries',
  reps: '8 répétitions',
  rest: '1min',
  load: '60kg',
  icon: Icons.fitness_center,
)).toList();
```

---

## 5️⃣ Tester rapidement

### Méthode 1 : Page de test
```dart
// lib/main.dart
void main() {
  runApp(
    MaterialApp(
      home: SessionPreviewPage(db: appDb),  // Voir le widget en action
    ),
  );
}
```

### Méthode 2 : Hot reload
1. Lancez l'app
2. Faites des modifications
3. Sauvegardez → Hot reload automatique

---

## 6️⃣ Troubleshooting

### ❌ Erreur : "SessionService not found"
**Solution** : Vérifiez que vous avez créé le fichier `lib/services/session_service.dart`

### ❌ Widget vide ou données null
**Solution** : Vérifiez que `_nextSession` est bien initialisé
```dart
if (_nextSession != null)
  SessionCard(...),
```

### ❌ Exercices tous identiques
**Solution** : `SessionService.getRandomSessionInfo()` remélange à chaque appel
Pour obtenir une séance fixe, créez directement `SessionInfo()`

### ❌ Icônes bizarres
**Solution** : Le mappage d'icônes dans `SessionService._getExerciseIcon()` n'est pas complet
Vous pouvez ajouter vos propres mappages ou spécifier l'icône directement

---

## 7️⃣ Checklist d'intégration

- [ ] Fichiers créés (widget, service, pages)
- [ ] Imports ajoutés
- [ ] Code de chargement implémenté
- [ ] Widget affiché
- [ ] Navigation configurée (optionnel)
- [ ] Tests effectués
- [ ] Pas d'erreurs à la compilation

---

## 8️⃣ Fichiers à vérifier

```
lib/
├── ui/
│   ├── widgets/
│   │   └── session/
│   │       ├── session_card.dart ✅
│   │       └── README.md ✅
│   └── pages/
│       ├── dashboard_page.dart (À modifier)
│       └── session_preview_page.dart ✅
├── services/
│   └── session_service.dart ✅
└── data/
    └── models/
        └── session_model.dart ✅
```

---

## 9️⃣ Ressources

- **Widget documentation** : `lib/ui/widgets/session/README.md`
- **Service documentation** : `lib/services/session_service.dart` (commentaires)
- **Résumé complet** : `WIDGET_SESSION_SUMMARY.md`
- **Page d'exemple** : `lib/ui/pages/session_preview_page.dart`

---

## 🔟 Besoin d'aide ?

Consultez les fichiers source commentés ou la documentation complète dans les fichiers créés.

**Prêt ?** Lancez la compilation et testez ! 🚀
