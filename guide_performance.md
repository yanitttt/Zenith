
# Guide de Performance (Instrumentation)

Ce document explique comment utiliser le module de performance intégré pour mesurer, comparer et optimiser l'application.

## 1. Activation du Mode Performance

Le module de performance est **désactivé par défaut**. Pour l'activer, vous devez compiler ou lancer l'application avec le flag Dart :
`PERF_MODE=true`.

### Commandes de lancement
Pour des résultats fiables, utilisez toujours le mode **profile** (le mode debug fausse les mesures).

**Lancer en mode Profile :**
```bash
flutter run --profile --dart-define=PERF_MODE=true
```

**Construire un APK Profile :**
```bash
flutter build apk --profile --dart-define=PERF_MODE=true
```

Une fois l'application lancée avec ce flag, un petit bouton flottant violet ⚡ apparaît (en bas à droite) pour ouvrir le **Performance Lab**.

---

## 2. Utilisation du Performance Lab

1. Ouvrez l'app et cliquez sur le bouton ⚡.
2. Donnez un nom à votre scénario (ex: "Scroll Liste Accueil", "Ouvrir Détail").
3. Cliquez sur **DÉMARRER ENREGISTREMENT** (Bouton Vert -> Rouge).
4. Effectuez les actions que vous voulez mesurer dans l'application.
5. Revenez au Lab et cliquez sur **ARRÊTER & EXPORTER**.

L'application va générer un fichier JSON contenant toutes les métriques et vous proposera de le partager (ex: envoi par mail, enregistrer dans fichiers).

---

## 3. Analyse du Rapport JSON

Le fichier JSON contient plusieurs sections :

- `device_metrics` : Infos sur l'appareil, batterie (conso), CPU.
- `ui_metrics` : Statistiques de fluidité (Frames).
  - `avg_ms` : Durée moyenne d'une frame.
  - `jank_16ms_count` : Nombre de frames ayant dépassé 16ms (visuellement saccadé sur 60Hz).
  - `max_ms` : La pire frame enregistrée.
- `actions` : Temps d'exécution des méthodes instrumentées avec `Perf.measure()`.
- `memory_history` : Évolution de la mémoire durant la session.

### Exemple de JSON
```json
{
  "meta": {
    "scenario": "Test Scroll",
    "timestamp": "2024-12-20 14:00:00"
  },
  "ui_metrics": {
    "total_frames": 120,
    "avg_ms": "4.20",
    "p99_ms": "14.50",
    "jank_16ms_count": 0
  }
}
```

---

## 4. Ajouter de nouvelles mesures

### Mesurer une action métier (Code Dart)
Pour mesurer le temps d'exécution d'une fonction spécifique, utilisez `PerfCore`.

**Asynchrone :**
```dart
await PerfCore().measure("Chargement Données", () async {
  await api.getData();
});
```

**Synchrone :**
```dart
PerfCore().measureSync("Calcul Complexe", () {
  doHeavyMath();
});
```

### Trace Navigation
Pour mesurer le temps d'affichage d'un écran, vous pouvez lancer une mesure dans `initState` et la finir dans `addPostFrameCallback`.

---

## 5. Comparer "Avant" / "Après"

1. **Baseline** : Lancez l'application sur la branche `main` (ou version stable). Enregistrez un scénario précis (ex: "Ouvrir app -> Click premier item -> Retour"). Exportez le JSON (`report_baseline.json`).
2. **Optimisation** : Appliquez vos changements de code.
3. **Test** : Relancez le MÊME scénario exactement. Exportez le JSON (`report_test.json`).
4. **Conclusion** : Comparez `avg_ms`, `jank_count`, et la durée des actions.

Note : Assurez-vous d'avoir le même niveau de batterie (environ) et de ne pas être en charge si vous comparez la consommation énergétique.
