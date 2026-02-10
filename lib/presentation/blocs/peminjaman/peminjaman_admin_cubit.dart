// lib/presentation/blocs/peminjaman/peminjaman_admin_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/peminjaman.dart';
import '../../../data/repositories/peminjaman_repository_supabase.dart';

part 'peminjaman_admin_state.dart';

class PeminjamanAdminCubit extends Cubit<PeminjamanAdminState> {
  final PeminjamanRepositorySupabase _repo;
  StreamSubscription? _peminjamanSubscription;
  Timer? _autoRefreshTimer;

  PeminjamanAdminCubit(this._repo) : super(PeminjamanAdminInitial()) {
    _initRealtime();
    // Auto refresh setiap 30 detik untuk update status terlambat
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (state is PeminjamanAdminListLoaded) {
        loadPeminjaman();
      }
    });
  }

  void _initRealtime() {
    // Listen perubahan pada tabel peminjaman
    _peminjamanSubscription = _repo.peminjamanStream.listen((_) {
      if (state is PeminjamanAdminListLoaded || state is PeminjamanAdminDetailLoaded) {
        loadPeminjaman();
      }
    });
  }

  @override
  Future<void> close() {
    _peminjamanSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    return super.close();
  }

  Future<void> loadPeminjaman({
    String? status,
    String? search,
    DateTime? from,
    DateTime? to,
  }) async {
    emit(PeminjamanAdminLoading());
    try {
      final list = await _repo.getAllPeminjaman(
        status: status, 
        search: search,
        from: from,
        to: to,
      );
      
      // Hitung statistik
      final stats = _calculateStats(list);
      
      emit(PeminjamanAdminListLoaded(
        list, 
        stats: stats,
        currentFilter: status,
      ));
    } catch (e) {
      emit(PeminjamanAdminError(e.toString()));
    }
  }

  Map<String, int> _calculateStats(List<Peminjaman> list) {
    return {
      'total': list.length,
      'menunggu': list.where((p) => p.status == 'menunggu').length,
      'disetujui': list.where((p) => p.status == 'disetujui').length,
      'sebagian': list.where((p) => p.status == 'sebagian').length,
      'selesai': list.where((p) => p.status == 'selesai').length,
      'ditolak': list.where((p) => p.status == 'ditolak').length,
    };
  }

  Future<void> loadDetail(String id) async {
    emit(PeminjamanAdminLoading());
    try {
      final detail = await _repo.getPeminjamanById(id);
      if (detail != null) {
        emit(PeminjamanAdminDetailLoaded(detail));
      } else {
        emit(PeminjamanAdminError('Data tidak ditemukan'));
      }
    } catch (e) {
      emit(PeminjamanAdminError(e.toString()));
    }
  }

  Future<void> approve(String id) async {
    emit(PeminjamanAdminActionLoading());
    try {
      final result = await _repo.approvePeminjaman(id, 'current_user_id'); // Ambil dari auth
      emit(PeminjamanAdminSuccess('Peminjaman berhasil disetujui'));
      await loadDetail(id);
    } catch (e) {
      emit(PeminjamanAdminError(e.toString()));
      // Refresh untuk memastikan data konsisten
      await loadPeminjaman();
    }
  }

  Future<void> rejectOrcancel(String peminjamanId, String alasan) async {
    if (alasan.trim().isEmpty) {
      emit(PeminjamanAdminError('Alasan penolakan wajib diisi'));
      return;
    }

    emit(PeminjamanAdminActionLoading());
    try {
      await _repo.rejectOrcancelPeminjaman(peminjamanId, alasan);
      emit(PeminjamanAdminSuccess('Peminjaman ditolak: $alasan'));
      await loadDetail(peminjamanId);
    } catch (e) {
      emit(PeminjamanAdminError(e.toString()));
    }
  }

  Future<void> processReturn(String peminjamanId, List<String> itemIds, {String? catatan}) async {
    if (itemIds.isEmpty) {
      emit(PeminjamanAdminError('Pilih minimal 1 alat yang dikembalikan'));
      return;
    }

    emit(PeminjamanAdminActionLoading());
    try {
      await _repo.processPengembalian(
        peminjamanId: peminjamanId,
        itemIds: itemIds,
        catatan: catatan,
      );
      emit(PeminjamanAdminSuccess('Pengembalian berhasil diproses'));
      await loadDetail(peminjamanId);
    } catch (e) {
      emit(PeminjamanAdminError(e.toString()));
    }
  }

  Future<void> extend(String peminjamanId, String itemId, int hari, String alasan) async {
    if (hari <= 0 || hari > 7) {
      emit(PeminjamanAdminError('Perpanjangan hanya 1-7 hari'));
      return;
    }
    if (alasan.trim().isEmpty) {
      emit(PeminjamanAdminError('Alasan perpanjangan wajib diisi'));
      return;
    }

    emit(PeminjamanAdminActionLoading());
    try {
      await _repo.perpanjangPeminjaman(
        itemId: itemId, 
        tambahanHari: hari, 
        alasan: alasan,
      );
      emit(PeminjamanAdminSuccess('Perpanjangan berhasil'));
      await loadDetail(peminjamanId);
    } catch (e) {
      emit(PeminjamanAdminError(e.toString()));
    }
  }
}