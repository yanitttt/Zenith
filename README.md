# 💪 MuscuCoach — Application Flutter

> _Faire progresser ta musculation, c’est plus simple que tu ne le penses !_

MuscuCoach est une application mobile développée avec **Flutter** qui t’aide à suivre ta progression, recevoir des **recommandations personnalisées** d’exercices, et rester motivé à chaque entraînement.

---

## 🚀 Fonctionnalités principales

✅ **Recommandations intelligentes**
- L’application apprend de tes performances et te propose des exercices adaptés à ton niveau et à tes objectifs (force, masse, endurance).

✅ **Interface moderne et motivante**
- Une expérience fluide avec des écrans propres, des animations légères et un design minimaliste.

✅ **Suivi personnalisé**
- Visualise ton évolution (poids, répétitions, séries, etc.)
- Statistiques hebdomadaires pour suivre ta progression.

✅ **Thème clair et sombre**
- Confort visuel garanti, de jour comme de nuit.

---

## 🧩 Structure du projet

```bash
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Gestion du thème clair/sombre
│   └── widgets/
│       └── primary_button.dart     # Bouton principal réutilisable
│
├── features/
│   └── onboarding/
│       └── presentation/pages/
│           └── welcome_page.dart   # Écran d'accueil "Commencer"
│
└── main.dart                       # Point d'entrée de l'application
