# Guide d'Instrumentation Performance 🚀

Ce document explique comment utiliser le module de performance pour mesurer l'impact des optimisations.

## 1. Activer le Mode Performance

Le mode performance est désactivé par défaut. Pour l'activer, vous devez compiler/lancer l'application avec un flag spécifique :

```bash
flutter run --profile --dart-define=PERF_MODE=true
```

> **Note :** Il est recommandé d'utiliser le mode `--profile` pour des mesures réalistes. Le mode debug impacte lourdement les performances.

## 2. Naviguer dans le "Performance Lab"

Une fois l'application lancée avec le flag :
1. Un nouvel onglet **"Perf"** (icône vitesse) apparaît dans la barre de navigation.
2. Cliquez dessus pour ouvrir le tableau de bord de performance.

## 3. Lancer un Scénario de Test

Dans l'écran Performance Lab :
- Appuyez sur **"Lancer Scénario A"**.
- L'application va simuler une charge de travail (calculs, réseau).
- À la fin, un rapport JSON est généré et le menu de partage s'ouvre.

## 4. Comparer les Résultats (Avant vs Après)

Pour valider une optimisation :

1. Notez le commit actuel (ou état "Avant").
2. Lancez le Scénario A et exportez le JSON (ex: `before.json`).
3. Appliquez vos modifications (optimisations).
4. Relancez le Scénario A et exportez le JSON (ex: `after.json`).
5. Comparez les clés suivantes :
   - `metrics.frames.global.p90_ms` : Doit diminuer.
   - `metrics.frames.global.jank_ratio` : Doit tendre vers 0.
   - `metrics.battery_samples.current_uA` : Vérifiez si la consommation instantanée baisse.

## 5. Métriques Disponibles

### Frames (Rendu)
- **p90_ms / p99_ms** : 90% (ou 99%) des frames sont rendues en moins de X ms.
- **jank_16ms_count** : Nombre de frames ayant raté la cible 60fps.

### Batterie & Ressources
- **current_uA** : Courant instantané en micro-ampères (si supporté par le device).
- **java_heap_mb** : Mémoire heap utilisée par la VM Dart/Android.
- **cpu_time_ticks** : Temps CPU consommé (relatif).

## Dépannage
- **Pas de données batterie ?** : Certains émulateurs ou devices ne remontent pas le courant (`current_uA`). Testez sur un device physique réel.
- **Menu Perf absent ?** : Vérifiez bien le `--dart-define=PERF_MODE=true`.
