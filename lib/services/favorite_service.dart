import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_facility.dart';

class FavoriteService extends ChangeNotifier {
  FavoriteService._();

  // ==========================================
  // SINGLETON INSTANCE
  // ==========================================

  static final FavoriteService instance = FavoriteService._();

  // ==========================================
  // STORAGE CONFIGURATION
  // ==========================================

  static const String _storageKey = 'favorite_facility_ids';

  final SharedPreferencesAsync _preferences =
  SharedPreferencesAsync();

  final Set<String> _favoriteIds = <String>{};

  Future<void>? _initializing;

  // Antrean untuk memastikan proses penyimpanan berurutan.
  Future<void> _writeQueue = Future<void>.value();

  bool _isInitialized = false;

  // ==========================================
  // GETTERS
  // ==========================================

  bool get isInitialized => _isInitialized;

  Set<String> get favoriteIds =>
      Set<String>.unmodifiable(_favoriteIds);

  bool isFavorite(String facilityId) {
    return _favoriteIds.contains(facilityId);
  }

  // ==========================================
  // INITIALIZATION
  // ==========================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_initializing != null) {
      await _initializing;
      return;
    }

    final loading = _loadFavorites();

    _initializing = loading;

    try {
      await loading;
    } finally {
      if (identical(_initializing, loading)) {
        _initializing = null;
      }
    }
  }

  // ==========================================
  // LOAD FAVORITE DATA
  // ==========================================

  Future<void> _loadFavorites() async {
    try {
      final savedIds =
          await _preferences.getStringList(_storageKey) ??
              <String>[];

      _favoriteIds
        ..clear()
        ..addAll(
          savedIds.where((id) => id.trim().isNotEmpty),
        );

      debugPrint(
        '[FAVORITE] Berhasil memuat '
            '${_favoriteIds.length} fasilitas: $_favoriteIds',
      );
    } catch (error, stackTrace) {
      debugPrint('[FAVORITE] GAGAL MEMUAT DATA');
      debugPrint('Error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ==========================================
  // TOGGLE FAVORITE
  // ==========================================

  Future<bool> toggle(HealthFacility facility) async {
    await initialize();

    final facilityId = facility.id;

    final bool added;

    if (_favoriteIds.contains(facilityId)) {
      _favoriteIds.remove(facilityId);
      added = false;
    } else {
      _favoriteIds.add(facilityId);
      added = true;
    }

    try {
      await _saveFavorites();

      // Perbarui UI setelah penyimpanan berhasil.
      notifyListeners();

      debugPrint(
        '[FAVORITE] ${added ? "DITAMBAHKAN" : "DIHAPUS"}: '
            '${facility.name}',
      );

      return added;
    } catch (error) {
      // Kembalikan status sebelumnya jika gagal disimpan.
      if (added) {
        _favoriteIds.remove(facilityId);
      } else {
        _favoriteIds.add(facilityId);
      }

      notifyListeners();

      debugPrint(
        '[FAVORITE] Toggle gagal untuk ${facility.name}: $error',
      );

      rethrow;
    }
  }

  // ==========================================
  // REMOVE FAVORITE
  // ==========================================

  Future<void> remove(String facilityId) async {
    await initialize();

    if (!_favoriteIds.contains(facilityId)) {
      return;
    }

    // Hapus ID dan simpan data.
    _favoriteIds.remove(facilityId);

    try {
      await _saveFavorites();

      notifyListeners();

      debugPrint(
        '[FAVORITE] Berhasil menghapus ID: $facilityId',
      );
    } catch (error) {
      // Kembalikan ID jika penyimpanan gagal.
      _favoriteIds.add(facilityId);

      notifyListeners();

      debugPrint(
        '[FAVORITE] Gagal menghapus ID $facilityId: $error',
      );

      rethrow;
    }
  }

  // ==========================================
  // SAVE FAVORITE DATA
  // ==========================================

  Future<void> _saveFavorites() {
    // Ambil snapshot agar data tidak berubah selama proses simpan.
    final snapshot = List<String>.unmodifiable(
      _favoriteIds,
    );

    // Masukkan proses ke antrean.
    final operation = _writeQueue.then((_) async {
      // Simpan daftar ID favorit.
      await _preferences.setStringList(
        _storageKey,
        snapshot,
      );

      // Baca ulang data untuk memastikan penyimpanan berhasil.
      final savedIds =
          await _preferences.getStringList(_storageKey) ??
              <String>[];

      // Verifikasi isi data.
      if (!setEquals(
        savedIds.toSet(),
        snapshot.toSet(),
      )) {
        throw StateError(
          'Data Favorit tidak sesuai dengan data yang disimpan.',
        );
      }

      debugPrint(
        '[FAVORITE] BERHASIL MENYIMPAN '
            '${snapshot.length} data: $snapshot',
      );
    });

    // Pastikan antrean berikutnya tetap bisa berjalan
    // walaupun operasi sebelumnya mengalami kegagalan.
    _writeQueue = operation.then<void>(
          (_) {},
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          '[FAVORITE] Kesalahan pada antrean penyimpanan: $error',
        );
      },
    );

    return operation;
  }
}
