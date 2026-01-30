enum UserRole {
  admin,
  petugas,
  peminjam;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.petugas:
        return 'Petugas';
      case UserRole.peminjam:
        return 'Peminjam';
    }
  }

  bool get canMaageUsers => this == UserRole.admin;
  bool get canManageInventory => this == UserRole.admin || this == UserRole.petugas;
  bool get canApprove => this == UserRole.admin || this == UserRole.petugas;
  bool get canBorrow => this == UserRole.peminjam;
}