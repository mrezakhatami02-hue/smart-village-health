enum FacilityType {
  hospital('Rumah Sakit'),
  puskesmas('Puskesmas'),
  clinic('Klinik');

  const FacilityType(this.label);

  final String label;
}

class HealthFacility {
  final String id;
  final String name;
  final FacilityType type;
  final String address;

  // Informasi wilayah administratif
  final String kelurahan;

  // Koordinat boleh kosong jika belum diverifikasi
  final double? latitude;
  final double? longitude;

  // Informasi tambahan fasilitas
  final String? phone;
  final String openingHours;
  final List<String> services;

  // Sumber atau keterangan koordinat
  final String? coordinateNote;

  const HealthFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.kelurahan,
    this.latitude,
    this.longitude,
    this.phone,
    this.openingHours = 'Informasi perlu dikonfirmasi',
    this.services = const [],
    this.coordinateNote,
  });

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;
}
