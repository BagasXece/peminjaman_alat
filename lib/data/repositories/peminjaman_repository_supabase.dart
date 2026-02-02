import 'package:peminjaman_alat/core/network/supabase_client.dart';
import 'package:peminjaman_alat/domain/entities/peminjaman.dart';
import 'package:peminjaman_alat/domain/entities/peminjaman_item.dart';
import 'package:peminjaman_alat/domain/entities/alat.dart';
import 'package:peminjaman_alat/domain/entities/app_user.dart' as domain;
import 'package:peminjaman_alat/domain/repositories/peminjaman_repository.dart';

class PeminjamanRepositorySupabase implements PeminjamanRepository {
  final SupabaseService _supabase;
  final String _table = 'peminjaman';
  final String _itemTable = 'peminjaman_item';

  PeminjamanRepositorySupabase(this._supabase);

  // Stream untuk realtime
  Stream<List<Map<String, dynamic>>> get peminjamanStream => 
      _supabase.client.from(_table).stream(primaryKey: ['id_peminjaman']);

  @override
  Future<List<Peminjaman>> getAllPeminjaman({
    String? status,
    String? search,
    DateTime? from,
    DateTime? to,
    String? peminjamId,
  }) async {
    try {
      // Build filter builder first
      var query = _supabase.client
          .from(_table)
          .select('''
            *,
            peminjam:peminjam_id (id_user, email, display_name),
            petugas:disetujui_oleh (id_user, email, display_name),
            items:peminjaman_item (
              *,
              alat:alat_id (*, sub_kategori_alat:sub_kategori_id (nama, kategori_alat:kategori_id (nama))),
              pengembalian:pengembalian_item (id_pengembalian_item, dikembalikan_pada, terlambat_hari, total_denda, catatan)
            )
          ''')
          .filter('deleted_at', 'is', null);  // Use is_ not isFilter

      // Apply filters before transforms
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      
      if (peminjamId != null) {
        query = query.eq('peminjam_id', peminjamId);
      }

      if (from != null) {
        query = query.gte('created_at', from.toIso8601String());
      }

      if (to != null) {
        query = query.lte('created_at', to.toIso8601String());
      }

      // Apply transforms (order) at the end
      final response = await query.order('created_at', ascending: false);
      
      return (response as List).map((json) => _mapToPeminjaman(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data peminjaman: $e');
    }
  }

  @override
  Future<Peminjaman?> getPeminjamanById(String id) async {
    try {
      final response = await _supabase.client
          .from(_table)
          .select('''
            *,
            peminjam:peminjam_id (id_user, email, display_name),
            petugas:disetujui_oleh (id_user, email, display_name),
            items:peminjaman_item (
              *,
              alat:alat_id (*, sub_kategori_alat:sub_kategori_id (nama, kategori_alat:kategori_id (nama))),
              pengembalian:pengembalian_item (id_pengembalian_item, dikembalikan_pada, terlambat_hari, total_denda, catatan)
            )
          ''')
          .eq('id_peminjaman', id)
          .maybeSingle();

      if (response == null) return null;
      return _mapToPeminjaman(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail peminjaman: $e');
    }
  }

  @override
  Future<Peminjaman> createPeminjaman(String peminjamId) async {
    try {
      final response = await _supabase.client
          .from(_table)
          .insert({
            'peminjam_id': peminjamId,
            'status': 'menunggu',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return _mapToPeminjaman(response);
    } catch (e) {
      throw Exception('Gagal membuat peminjaman: $e');
    }
  }

  @override
  Future<Peminjaman> approvePeminjaman(String peminjamanId, String petugasId) async {
    try {
      final result = await _supabase.client.rpc(
        'flutter_approve_peminjaman',
        params: {
          'p_peminjaman_id': peminjamanId,
          'p_petugas_id': petugasId,
        },
      );
      
      if (result['status'] == 'error') {
        throw Exception(result['message']);
      }

      final updated = await getPeminjamanById(peminjamanId);
      if (updated == null) {
        throw Exception('Peminjaman tidak ditemukan setelah approve');
      }
      return updated;
    } catch (e) {
      throw Exception('Gagal approve peminjaman: $e');
    }
  }

  @override
  Future<Peminjaman> rejectOrcancelPeminjaman(String peminjamanId, String alasan) async {
    try {
      final result = await _supabase.client.rpc(
        'flutter_batalkan_peminjaman',
        params: {
          'p_peminjaman_id': peminjamanId,
          'p_alasan': alasan,
        },
      );
      
      if (result['status'] == 'error') {
        throw Exception(result['message']);
      }

      final updated = await getPeminjamanById(peminjamanId);
      if (updated == null) {
        throw Exception('Peminjaman tidak ditemukan setelah reject');
      }
      return updated;
    } catch (e) {
      throw Exception('Gagal reject peminjaman: $e');
    }
  }

  @override
  Future<void> addItemToPeminjaman(String peminjamanId, String alatId, DateTime jatuhTempo) async {
    try {
      final result = await _supabase.client.rpc(
        'flutter_tambah_peminjaman_item',
        params: {
          'p_peminjaman_id': peminjamanId,
          'p_alat_id': alatId,
          'p_jatuh_tempo': jatuhTempo.toIso8601String(),
        },
      );
      
      if (result['status'] == 'error') {
        throw Exception(result['message']);
      }
    } catch (e) {
      throw Exception('Gagal menambah item: $e');
    }
  }

  @override
  Future<void> removeItemFromPeminjaman(String itemId) async {
    try {
      final result = await _supabase.client.rpc(
        'flutter_hapus_item',
        params: {
          'p_peminjaman_item_id': itemId,
        },
      );
      
      if (result['status'] == 'error') {
        throw Exception(result['message']);
      }
    } catch (e) {
      throw Exception('Gagal menghapus item: $e');
    }
  }

  @override
  Future<Peminjaman> processPengembalian({
    required String peminjamanId,
    required List<String> itemIds,
    required String petugasId,
    String? catatan,
  }) async {
    try {
      final result = await _supabase.client.rpc(
        'flutter_proses_pengembalian',
        params: {
          'p_item_ids': itemIds,
          'p_catatan': catatan,
        },
      );
      
      if (result['status'] == 'error') {
        throw Exception(result['message']);
      }

      final updated = await getPeminjamanById(peminjamanId);
      if (updated == null) {
        throw Exception('Peminjaman tidak ditemukan setelah pengembalian');
      }
      return updated;
    } catch (e) {
      throw Exception('Gagal proses pengembalian: $e');
    }
  }

  @override
  Future<Peminjaman> perpanjangPeminjaman({
    required String itemId,
    required int tambahanHari,
    required String alasan,
    String? petugasId,
  }) async {
    try {
      final result = await _supabase.client.rpc(
        'flutter_perpanjang_peminjaman',
        params: {
          'p_peminjaman_item_id': itemId,
          'p_tambahan_hari': tambahanHari,
          'p_alasan': alasan,
        },
      );
      
      if (result['status'] == 'error') {
        throw Exception(result['message']);
      }

      // Get the peminjaman_id from the item to return updated peminjaman
      final itemResponse = await _supabase.client
          .from(_itemTable)
          .select('peminjaman_id')
          .eq('id_peminjaman_item', itemId)
          .single();
      
      final updated = await getPeminjamanById(itemResponse['peminjaman_id']);
      if (updated == null) {
        throw Exception('Peminjaman tidak ditemukan setelah perpanjangan');
      }
      return updated;
    } catch (e) {
      throw Exception('Gagal perpanjang peminjaman: $e');
    }
  }

  // Helper mapping method
  Peminjaman _mapToPeminjaman(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? []).map((itemJson) {
      final pengembalian = itemJson['pengembalian'] as Map<String, dynamic>?;
      final alatJson = itemJson['alat'] as Map<String, dynamic>?;
      
      Alat? alat;
      if (alatJson != null) {
        final subKategori = alatJson['sub_kategori_alat'] as Map<String, dynamic>?;
        final kategori = subKategori?['kategori_alat'] as Map<String, dynamic>?;
        
        alat = Alat(
          id: alatJson['id_alat'] as String,
          kode: alatJson['kode'] as String,
          nama: alatJson['nama'] as String,
          subKategoriId: alatJson['sub_kategori_id'] as String,
          kondisi: alatJson['kondisi'] as String,
          status: alatJson['status'] as String,
          lokasiSimpan: alatJson['lokasi'] as String?,
          deletedAt: alatJson['deleted_at'] != null 
              ? DateTime.parse(alatJson['deleted_at']) 
              : null,
          createdAt: DateTime.parse(alatJson['created_at']),
          updatedAt: alatJson['updated_at'] != null 
              ? DateTime.parse(alatJson['updated_at']) 
              : DateTime.now(),
          namaSubKategori: subKategori?['nama'] as String?,
          namaKategori: kategori?['nama'] as String?,
        );
      }

      return PeminjamanItem(
        id: itemJson['id_peminjaman_item'] as String,
        peminjamanId: itemJson['peminjaman_id'] as String,
        alatId: itemJson['alat_id'] as String,
        jatuhTempo: DateTime.parse(itemJson['jatuh_tempo']),
        status: itemJson['status'] as String,
        createdAt: DateTime.parse(itemJson['created_at']),
        updatedAt: itemJson['updated_at'] != null 
            ? DateTime.parse(itemJson['updated_at']) 
            : null,
        perpanjanganKe: itemJson['perpanjangan_ke'] ?? 0,
        alat: alat,
        dikembalikanPada: pengembalian?['dikembalikan_pada'] != null 
            ? DateTime.parse(pengembalian!['dikembalikan_pada']) 
            : null,
        terlambatHari: pengembalian?['terlambat_hari'] as int?,
        totalDenda: pengembalian?['total_denda'] as int?,
        catatanPengembalian: pengembalian?['catatan'] as String?,
      );
    }).toList();

    final peminjam = json['peminjam'] as Map<String, dynamic>?;
    final petugas = json['petugas'] as Map<String, dynamic>?;

    return Peminjaman(
      id: json['id_peminjaman'] as String,
      kodePeminjaman: json['kode_peminjaman'] as String?,
      peminjamId: json['peminjam_id'] as String,
      status: json['status'] as String,
      disetujuiOleh: json['disetujui_oleh'] as String?,
      disetujuiPada: json['disetujui_pada'] != null 
          ? DateTime.parse(json['disetujui_pada']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      version: json['version'] ?? 1,
      peminjam: peminjam != null 
          ? domain.AppUser(
              id: peminjam['id_user'] as String,
              email: peminjam['email'] as String,
              displayName: peminjam['display_name'] as String?,
              role: 'peminjam',
              createdAt: DateTime.now(),
            )
          : null,
      petugas: petugas != null 
          ? domain.AppUser(
              id: petugas['id_user'] as String,
              email: petugas['email'] as String,
              displayName: petugas['display_name'] as String?,
              role: 'petugas',
              createdAt: DateTime.now(),
            )
          : null,
      items: items,
    );
  }
}