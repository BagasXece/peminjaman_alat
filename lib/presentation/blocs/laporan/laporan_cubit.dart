// lib/presentation/blocs/laporan/laporan_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peminjaman_alat/core/network/supabase_client.dart';

// Models untuk masing-masing laporan
class LaporanPeminjaman {
  final String idPeminjaman;
  final String? kodePeminjaman;
  final DateTime? tanggalPengajuan;
  final String peminjamId;
  final String? namaPeminjam;
  final int totalItem;
  final String statusPeminjaman;
  final int totalDenda;
  final String? petugasId;
  final String? namaPetugas;

  LaporanPeminjaman({
    required this.idPeminjaman,
    this.kodePeminjaman,
    this.tanggalPengajuan,
    required this.peminjamId,
    this.namaPeminjam,
    required this.totalItem,
    required this.statusPeminjaman,
    required this.totalDenda,
    this.petugasId,
    this.namaPetugas,
  });

  factory LaporanPeminjaman.fromJson(Map<String, dynamic> json) {
    return LaporanPeminjaman(
      idPeminjaman: json['id_peminjaman'],
      kodePeminjaman: json['kode_peminjaman'],
      tanggalPengajuan: json['tanggal_pengajuan'] != null 
          ? DateTime.parse(json['tanggal_pengajuan']) 
          : null,
      peminjamId: json['peminjam_id'],
      namaPeminjam: json['nama_peminjam'],
      totalItem: json['total_item'] ?? 0,
      statusPeminjaman: json['status_peminjaman'] ?? '',
      totalDenda: json['total_denda'] ?? 0,
      petugasId: json['petugas_id'],
      namaPetugas: json['nama_petugas'],
    );
  }
}

class LaporanDenda {
  final String idPeminjaman;
  final String peminjamId;
  final String? namaPeminjam;
  final int totalItemTerlambat;
  final int totalDenda;
  final String statusPelunasan;
  final DateTime? tanggalUpdate;

  LaporanDenda({
    required this.idPeminjaman,
    required this.peminjamId,
    this.namaPeminjam,
    required this.totalItemTerlambat,
    required this.totalDenda,
    required this.statusPelunasan,
    this.tanggalUpdate,
  });

  factory LaporanDenda.fromJson(Map<String, dynamic> json) {
    return LaporanDenda(
      idPeminjaman: json['id_peminjaman'],
      peminjamId: json['peminjam_id'],
      namaPeminjam: json['nama_peminjam'],
      totalItemTerlambat: json['total_item_terlambat'] ?? 0,
      totalDenda: json['total_denda'] ?? 0,
      statusPelunasan: json['status_pelunasan'] ?? 'lunas',
      tanggalUpdate: json['tanggal_update'] != null 
          ? DateTime.parse(json['tanggal_update']) 
          : null,
    );
  }
}

class LaporanInventaris {
  final String idSubKategori;
  final String? namaKategori;
  final String? namaSubKategori;
  final int stokTotal;
  final int stokDipinjam;
  final int stokTersedia;

  LaporanInventaris({
    required this.idSubKategori,
    this.namaKategori,
    this.namaSubKategori,
    required this.stokTotal,
    required this.stokDipinjam,
    required this.stokTersedia,
  });

  factory LaporanInventaris.fromJson(Map<String, dynamic> json) {
    return LaporanInventaris(
      idSubKategori: json['id_sub_kategori'],
      namaKategori: json['nama_kategori'],
      namaSubKategori: json['nama_sub_kategori'],
      stokTotal: json['stok_total'] ?? 0,
      stokDipinjam: json['stok_dipinjam'] ?? 0,
      stokTersedia: json['stok_tersedia'] ?? 0,
    );
  }
}

class LaporanUser {
  final String idUser;
  final String email;
  final String? displayName;
  final String role;
  final int totalPeminjaman;
  final int peminjamanAktif;
  final int peminjamanSelesai;
  final DateTime? terakhirAktivitas;

  LaporanUser({
    required this.idUser,
    required this.email,
    this.displayName,
    required this.role,
    required this.totalPeminjaman,
    required this.peminjamanAktif,
    required this.peminjamanSelesai,
    this.terakhirAktivitas,
  });

  factory LaporanUser.fromJson(Map<String, dynamic> json) {
    return LaporanUser(
      idUser: json['id_user'],
      email: json['email'],
      displayName: json['display_name'],
      role: json['role'] ?? 'peminjam',
      totalPeminjaman: json['total_peminjaman'] ?? 0,
      peminjamanAktif: json['peminjaman_aktif'] ?? 0,
      peminjamanSelesai: json['peminjaman_selesai'] ?? 0,
      terakhirAktivitas: json['terakhir_aktivitas'] != null 
          ? DateTime.parse(json['terakhir_aktivitas']) 
          : null,
    );
  }
}

// States
abstract class LaporanState {}

class LaporanInitial extends LaporanState {}

class LaporanLoading extends LaporanState {}

class LaporanPeminjamanLoaded extends LaporanState {
  final List<LaporanPeminjaman> data;
  LaporanPeminjamanLoaded(this.data);
}

class LaporanDendaLoaded extends LaporanState {
  final List<LaporanDenda> data;
  LaporanDendaLoaded(this.data);
}

class LaporanInventarisLoaded extends LaporanState {
  final List<LaporanInventaris> data;
  LaporanInventarisLoaded(this.data);
}

class LaporanUserLoaded extends LaporanState {
  final List<LaporanUser> data;
  LaporanUserLoaded(this.data);
}

class LaporanError extends LaporanState {
  final String message;
  LaporanError(this.message);
}

class LaporanCubit extends Cubit<LaporanState> {
  final SupabaseService _supabaseService;

  LaporanCubit(this._supabaseService) : super(LaporanInitial());

  Future<void> loadLaporanPeminjaman() async {
    emit(LaporanLoading());
    try {
      final response = await _supabaseService.client
          .from('v_laporan_peminjaman')
          .select()
          .order('tanggal_pengajuan', ascending: false);

      final data = (response as List<dynamic>)
          .map((e) => LaporanPeminjaman.fromJson(e))
          .toList();
      
      emit(LaporanPeminjamanLoaded(data));
    } catch (e) {
      emit(LaporanError('Gagal memuat laporan peminjaman: ${e.toString()}'));
    }
  }

  Future<void> loadLaporanDenda() async {
    emit(LaporanLoading());
    try {
      final response = await _supabaseService.client
          .from('v_laporan_denda')
          .select()
          .order('tanggal_update', ascending: false);

      final data = (response as List<dynamic>)
          .map((e) => LaporanDenda.fromJson(e))
          .toList();
      
      emit(LaporanDendaLoaded(data));
    } catch (e) {
      emit(LaporanError('Gagal memuat laporan denda: ${e.toString()}'));
    }
  }

  Future<void> loadLaporanInventaris() async {
    emit(LaporanLoading());
    try {
      final response = await _supabaseService.client
          .from('v_laporan_inventaris')
          .select()
          .order('nama_kategori', ascending: true);

      final data = (response as List<dynamic>)
          .map((e) => LaporanInventaris.fromJson(e))
          .toList();
      
      emit(LaporanInventarisLoaded(data));
    } catch (e) {
      emit(LaporanError('Gagal memuat laporan inventaris: ${e.toString()}'));
    }
  }

  Future<void> loadLaporanUser() async {
    emit(LaporanLoading());
    try {
      final response = await _supabaseService.client
          .from('v_laporan_user')
          .select()
          .order('total_peminjaman', ascending: false);

      final data = (response as List<dynamic>)
          .map((e) => LaporanUser.fromJson(e))
          .toList();
      
      emit(LaporanUserLoaded(data));
    } catch (e) {
      emit(LaporanError('Gagal memuat laporan user: ${e.toString()}'));
    }
  }
}