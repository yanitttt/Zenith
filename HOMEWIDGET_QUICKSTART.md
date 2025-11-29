# Quick Start : Widget d'Écran d'Accueil

## ⚡ 5 minutes pour avoir le widget !

### Étape 1 : Compiler
```bash
cd D:\BUT\BUT3\SAE\Code\recommandation_mobile
fvm flutter clean
fvm flutter pub get
fvm flutter run
```

### Étape 2 : Ajouter le widget
1. Appuyez **long** sur l'écran d'accueil de votre téléphone
2. Tapez sur **"Widgets"**
3. Cherchez **"SessionWidget"** ou **"Recommandation Mobile"**
4. **Glissez-déposez** sur l'écran d'accueil
5. ✅ C'est fait !

### Étape 3 : Personnaliser (optionnel)

**Pour mettre à jour le widget dans l'app** :

Dans `lib/main.dart` :
```dart
import 'services/home_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDb();

  // Initialiser le widget
  final widgetService = HomeWidgetService(db);
  await widgetService.initializeWidget();

  runApp(MyApp(db: db));
}
```

**Pour mettre à jour après une séance** :
```dart
final widgetService = HomeWidgetService(widget.db);
await widgetService.updateHomeWidget();
```

## 📋 Checklist

- [ ] Compilé et déployé
- [ ] Widget trouvé dans les widgets
- [ ] Widget ajouté à l'écran d'accueil
- [ ] Affiche la séance
- [ ] Clic ouvre l'app

## 🎨 Le widget affiche

```
Prochaine séance
Lundi 15 Novembre    60 min    PUSH

Squat
4 séries / 8 reps / 60kg de charge

Tapis
4 séries / 8 reps / 60kg de charge

           Suite →
```

## 💡 Astuces

- **Redimensionner** : Appuyez long et glissez les coins
- **Repositionner** : Appuyez long et glissez
- **Supprimer** : Appuyez long et "Supprimer"
- **Actualiser** : Rouvrez l'app pour mettre à jour

## ❓ Questions fréquentes

**Q: Le widget n'apparaît pas ?**
- Assurez-vous que l'app a compilé correctement
- Redémarrez le téléphone
- Cherchez bien le widget

**Q: Les données ne s'actualisent pas ?**
- Rouvrez l'app
- Attendez 30 secondes
- Redémarrez le téléphone

**Q: Le widget disparaît après redémarrage ?**
- C'est normal, vous devez l'ajouter à nouveau

## 📚 Documentation complète

Voir `HOMEWIDGET_SETUP_GUIDE.md` pour plus de détails.

---

**C'est tout !** Votre widget est maintenant sur votre écran d'accueil. 🎉
