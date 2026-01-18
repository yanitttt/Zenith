class EquipmentService {
  /// Retourne le chemin de l'image pour un équipement donné.
  /// Les IDs doivent correspondre aux fichiers dans assets/images/exercises/
  /// Format : equipement-{id}.png
  static String getIconPath(int equipmentId) {
    // Liste des IDs connus pour éviter des erreurs de chargement si l'ID n'existe pas
    // IDs 1 à 9 sont confirmés présents dans les assets
    if (equipmentId >= 1 && equipmentId <= 9) {
      return 'assets/images/exercises/equipement-$equipmentId.png';
    }
    // Image par défaut si l'ID n'est pas trouvé (fallback)
    return 'assets/images/exercises/default.jpg';
  }
}
