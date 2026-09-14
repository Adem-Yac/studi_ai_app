/// Constantes de mise en page partagées.
abstract final class AppLayout {
  /// Marge horizontale extérieure (DESIGN.md: 1.25rem).
  static const double screenMargin = 20;

  /// Largeur max de contenu (mobile-first, centré sur tablette).
  static const double maxContentWidth = 620;

  /// Espace réservé sous les listes pour la bottom nav flottante.
  static const double bottomNavClearance = 108;

  /// Rayons squircle standards.
  static const double radiusCard = 20;
  static const double radiusInput = 16;
  static const double radiusPill = 999;
}
