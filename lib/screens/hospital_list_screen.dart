import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/health_facility.dart';
import 'facility_detail_screen.dart';
import '../services/favorite_service.dart';

class HospitalListScreen extends StatefulWidget {
  final List<HealthFacility> facilities;
  final Position? currentPosition;
  final FacilityType? initialType;
  final String initialQuery;
  final ValueChanged<FacilityType?>? onTypeChanged;
  final ValueChanged<String>? onSearchChanged;

  const HospitalListScreen({
    super.key,
    required this.facilities,
    this.currentPosition,
    this.initialType,
    this.initialQuery = '',
    this.onTypeChanged,
    this.onSearchChanged,
  });

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  late final TextEditingController _searchController;

  late String _searchQuery;
  FacilityType? _selectedType;

  @override
  void initState() {
    super.initState();

    _searchQuery = widget.initialQuery;
    _selectedType = widget.initialType;

    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void didUpdateWidget(covariant HospitalListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialType != widget.initialType) {
      _selectedType = widget.initialType;
    }

    if (oldWidget.initialQuery != widget.initialQuery) {
      _searchQuery = widget.initialQuery;
      _searchController.text = _searchQuery;
      _searchController.selection = TextSelection.collapsed(
        offset: _searchController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTER DAN PENCARIAN
  // ============================================================

  List<HealthFacility> get _filteredFacilities {
    final query = _searchQuery.trim().toLowerCase();

    final results = widget.facilities.where((facility) {
      final matchesType =
          _selectedType == null || facility.type == _selectedType;

      final matchesSearch =
          query.isEmpty ||
          facility.name.toLowerCase().contains(query) ||
          facility.address.toLowerCase().contains(query) ||
          facility.kelurahan.toLowerCase().contains(query) ||
          facility.type.label.toLowerCase().contains(query);

      return matchesType && matchesSearch;
    }).toList();

    // Jika GPS tersedia, urutkan fasilitas berdasarkan jarak.
    if (widget.currentPosition != null) {
      final withCoordinates = results
          .where((facility) => facility.hasCoordinates)
          .toList();

      final withoutCoordinates = results
          .where((facility) => !facility.hasCoordinates)
          .toList();

      withCoordinates.sort((a, b) {
        final distanceA = _calculateDistance(a);
        final distanceB = _calculateDistance(b);

        return (distanceA ?? double.infinity).compareTo(
          distanceB ?? double.infinity,
        );
      });

      return [...withCoordinates, ...withoutCoordinates];
    }

    return results;
  }

  double? _calculateDistance(HealthFacility facility) {
    if (widget.currentPosition == null || !facility.hasCoordinates) {
      return null;
    }

    return Geolocator.distanceBetween(
      widget.currentPosition!.latitude,
      widget.currentPosition!.longitude,
      facility.latitude!,
      facility.longitude!,
    );
  }

  String _formatDistance(double? distance) {
    if (distance == null) {
      return 'Jarak belum tersedia';
    }

    if (distance < 1000) {
      return '${distance.round()} meter';
    }

    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _toggleFavorite(HealthFacility facility) async {
    try {
      final added = await FavoriteService.instance.toggle(facility);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${facility.name} ditambahkan ke Favorit.'
                : '${facility.name} dihapus dari Favorit.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui daftar Favorit.'),
        ),
      );
    }
  }

  // ============================================================
  // KATEGORI
  // ============================================================

  void _selectType(FacilityType? type) {
    setState(() {
      _selectedType = type;
    });

    widget.onTypeChanged?.call(type);
  }

  IconData _getFacilityIcon(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Icons.local_hospital;

      case FacilityType.puskesmas:
        return Icons.health_and_safety;

      case FacilityType.clinic:
        return Icons.medical_services;
    }
  }

  Color _getFacilityColor(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;

      case FacilityType.puskesmas:
        return Colors.green;

      case FacilityType.clinic:
        return Colors.orange;
    }
  }

  // ============================================================
  // NAVIGASI DETAIL
  // ============================================================

  void _openFacilityDetail(HealthFacility facility) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => FacilityDetailScreen(
          facility: facility,
          currentPosition: widget.currentPosition,
        ),
      ),
    );
  }

  // ============================================================
  // CARD FASILITAS
  // ============================================================

  Widget _facilityCard(HealthFacility facility) {
    final distance = _calculateDistance(facility);
    final color = _getFacilityColor(facility.type);

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openFacilityDetail(facility),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(
                  _getFacilityIcon(facility.type),
                  color: color,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      facility.type.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      facility.kelurahan,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          Icons.near_me,
                          size: 14,
                          color: Colors.green.shade600,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            facility.hasCoordinates
                                ? _formatDistance(distance)
                                : 'Koordinat belum tersedia',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AnimatedBuilder(
                animation: FavoriteService.instance,
                builder: (context, child) {
                  final isFavorite =
                  FavoriteService.instance.isFavorite(facility.id);

                  return IconButton(
                    tooltip: isFavorite
                        ? 'Hapus dari Favorit'
                        : 'Tambahkan ke Favorit',
                    onPressed: () => _toggleFavorite(facility),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  );
                },
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final results = _filteredFacilities;

    final hospitalCount = widget.facilities
        .where((f) => f.type == FacilityType.hospital)
        .length;

    final puskesmasCount = widget.facilities
        .where((f) => f.type == FacilityType.puskesmas)
        .length;

    final clinicCount = widget.facilities
        .where((f) => f.type == FacilityType.clinic)
        .length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Fasilitas Kesehatan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123B64),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Kecamatan Kebon Jeruk, Jakarta Barat',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 18),

          // Ringkasan kategori fasilitas.
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Rumah Sakit',
                  hospitalCount,
                  Colors.red,
                  Icons.local_hospital,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _summaryItem(
                  'Puskesmas',
                  puskesmasCount,
                  Colors.green,
                  Icons.health_and_safety,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _summaryItem(
                  'Klinik',
                  clinicCount,
                  Colors.orange,
                  Icons.medical_services,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Kotak pencarian.
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });

              widget.onSearchChanged?.call(value);
            },
            decoration: InputDecoration(
              hintText: 'Cari nama atau kelurahan...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });

                        widget.onSearchChanged?.call('');
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Kategori Fasilitas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),

          const SizedBox(height: 10),

          // Filter kategori.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('Semua', null),
              _filterChip('Rumah Sakit', FacilityType.hospital),
              _filterChip('Puskesmas', FacilityType.puskesmas),
              _filterChip('Klinik', FacilityType.clinic),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Fasilitas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Text(
                '${results.length} ditemukan',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (results.isEmpty)
            _buildEmptyState()
          else
            ...results.map(_facilityCard),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),

          const SizedBox(height: 6),

          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String title, FacilityType? type) {
    return FilterChip(
      label: Text(title),
      selected: _selectedType == type,
      onSelected: (_) => _selectType(type),
      selectedColor: const Color(0xFFDCEBFA),
      checkmarkColor: const Color(0xFF1976D2),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          const Text(
            'Fasilitas tidak ditemukan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            'Coba gunakan kata kunci atau kategori lain.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
