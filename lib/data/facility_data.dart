import '../models/health_facility.dart';

// Inventaris fasilitas kesehatan di Kecamatan Kebon Jeruk, Jakarta Barat.
// Koordinat baru diisi berdasarkan pin Google Maps yang diberikan pengguna;
// verifikasi lapangan tetap disarankan.
const List<HealthFacility> facilityData = [
  // ============================================================
  // 1. RUMAH SAKIT
  // ============================================================
  HealthFacility(
    id: 'RS001',
    name: 'Siloam Hospitals Kebon Jeruk',
    type: FacilityType.hospital,
    address: 'Jl. Raya Perjuangan Kav. 8, Kebon Jeruk',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.190548076961612,
    longitude: 106.76360374232868,
    phone: '021-25677888',
    services: [
      'IGD 24 Jam',
      'Rawat Jalan',
      'Rawat Inap',
      'Penyakit Dalam',
      'Kesehatan Anak',
      'Bedah',
      'Radiologi',
      'Laboratorium',
    ],
    coordinateNote:
    'Koordinat berasal dari sumber pendukung dan tetap perlu pemeriksaan lapangan.',
  ),
  HealthFacility(
    id: 'RS002',
    name: 'Rumah Sakit Anggrek Mas',
    type: FacilityType.hospital,
    address: 'Jl. Anggrek No. 2B, Kelapa Dua',
    kelurahan: 'Kelapa Dua',
    latitude: -6.2030719,
    longitude: 106.7726612,
    phone: '021-5305720',
    coordinateNote:
    'Koordinat referensi dari Medicastore; verifikasi lapangan tetap disarankan.',
    services: [
      'IGD 24 Jam',
      'Poliklinik',
      'Rawat Inap',
      'Laboratorium',
      'Radiologi',
      'Hemodialisis',
    ],
  ),
  HealthFacility(
    id: 'RS003',
    name: 'RS EMC Grha Kedoya',
    type: FacilityType.hospital,
    address: 'Jalan Panjang Arteri No. 26, RT.15/RW.7, Kedoya Utara, Kebon Jeruk, Jakarta Barat 11520',
    kelurahan: 'Kedoya Utara',
    latitude: -6.168292,
    longitude: 106.764438,
    phone: '150789',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: [
      'IGD',
      'Medical Check Up',
      'PET/CT Scan',
      'Endoskopi',
      'Hemodialisis',
      'Hiperbarik',
      'Kateterisasi Laboratorium',
      'Radiologi',
      'Poliklinik Spesialis',
    ],
  ),
  HealthFacility(
    id: 'RS004',
    name: 'RS Cendana',
    type: FacilityType.hospital,
    address: 'Jl. Kedoya Pesing, RT.7/RW.3, Kedoya Selatan, Kebon Jeruk, Jakarta Barat 11520',
    kelurahan: 'Kedoya Selatan',
    latitude: -6.187478,
    longitude: 106.761634,
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'RS005',
    name: 'RS Ukrida',
    type: FacilityType.hospital,
    address: 'Jl. Arjuna Utara No. 6, Duri Kepa',
    kelurahan: 'Duri Kepa',
    latitude: -6.185612333,
    longitude: 106.78102,
    phone: '021-39723777',
    services: ['Pelayanan Rumah Sakit Umum'],
    coordinateNote:
    'Koordinat berasal dari sumber sekunder dan perlu pemeriksaan lapangan.',
  ),
  HealthFacility(
    id: 'RS006',
    name: 'RSIA Metro Hospitals Kebon Jeruk',
    type: FacilityType.hospital,
    address: 'Jl. Duri Raya No. 22, RT.2/RW.7, Duri Kepa, Kebon Jeruk, Jakarta Barat 11510',
    kelurahan: 'Duri Kepa',
    latitude: -6.1856113,
    longitude: 106.7714665,
    coordinateNote:
    'Alamat dan kelurahan tercantum pada daftar fasilitas kesehatan; koordinat berasal dari sumber sekunder dan perlu pemeriksaan lapangan.',
  ),
  HealthFacility(
    id: 'RS007',
    name: 'RS Mata JEC @ Kedoya',
    type: FacilityType.hospital,
    address: 'Jl. Terusan Arjuna Utara No. 1, Kedoya Selatan, Kebon Jeruk, Jakarta Barat 11520',
    kelurahan: 'Kedoya Selatan',
    latitude: -6.189793,
    longitude: 106.761525,
    phone: '0804-122-1000',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: [
      'Pemeriksaan Mata',
      'Katarak',
      'Layanan Kornea dan Retina',
      'Glaukoma',
      'Bedah Refraktif',
      'Kesehatan Mata Anak',
      'Neuro-Oftalmologi',
    ],
  ),

  HealthFacility(
    id: 'RS008',
    name: 'RS Medika Permata Hijau',
    type: FacilityType.hospital,
    address: 'Jl. Raya Kebayoran Lama No. 64, RT.6/RW.8, Sukabumi Selatan, Kebon Jeruk, Jakarta Barat 11560',
    kelurahan: 'Sukabumi Selatan',
    latitude: -6.218305,
    longitude: 106.777861,
    phone: '021-5347411',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna. '
        'SIRS Kemenkes mencatat rumah sakit ini sebagai RS Umum Eka Permata Hijau; '
        'verifikasi lapangan tetap disarankan.',
  ),

  // ============================================================
  // 2. PUSKESMAS
  // ============================================================
  HealthFacility(
    id: 'PKM001',
    name: 'Puskesmas Kecamatan Kebon Jeruk',
    type: FacilityType.puskesmas,
    address: 'Jl. Raya Kebon Jeruk No. 2, RT.9/RW.1, Kebon Jeruk, Jakarta Barat 11510',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.198765,
    longitude: 106.765256,
    phone: '021-5309838',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: [
      'Pelayanan Kesehatan Primer',
      'Pemeriksaan Umum',
    ],
  ),
  HealthFacility(
    id: 'PKM002',
    name: 'Puskesmas Kelurahan Duri Kepa',
    type: FacilityType.puskesmas,
    address: 'Jl. Angsana Raya No. 1, RT.15/RW.7, Duri Kepa',
    kelurahan: 'Duri Kepa',
    latitude: -6.18055,
    longitude: 106.77554,
    phone: '021-56944087',
    services: ['Pelayanan Kesehatan Primer'],
    coordinateNote:
    'Koordinat berasal dari sumber sekunder dan perlu pemeriksaan lapangan.',
  ),
  HealthFacility(
    id: 'PKM003',
    name: 'Puskesmas Kelurahan Kebon Jeruk',
    type: FacilityType.puskesmas,
    address: 'Jl. Karmel Raya No. 2, RT.2/RW.4, Kebon Jeruk',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.190305,
    longitude: 106.778964,
    phone: '021-53679240',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: ['Pelayanan Kesehatan Primer'],
  ),
  HealthFacility(
    id: 'PKM004',
    name: 'Puskesmas Kelurahan Kedoya Selatan',
    type: FacilityType.puskesmas,
    address: 'Jl. Kedoya Pesing No. 47, RT.1/RW.3, Kedoya Selatan',
    kelurahan: 'Kedoya Selatan',
    latitude: -6.179947,
    longitude: 106.759666,
    phone: '021-58303182',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: ['Pelayanan Kesehatan Primer'],
  ),
  HealthFacility(
    id: 'PKM005',
    name: 'Puskesmas Kelurahan Kedoya Utara',
    type: FacilityType.puskesmas,
    address: 'Jl. Daan Mogot No. 1, RT.003/RW.02, Kedoya Utara',
    kelurahan: 'Kedoya Utara',
    latitude: -6.1605429,
    longitude: 106.7683403,
    phone: '021-56943877',
    services: ['Pelayanan Kesehatan Primer'],
    coordinateNote:
    'Koordinat berasal dari sumber sekunder dan perlu pemeriksaan lapangan.',
  ),
  HealthFacility(
    id: 'PKM006',
    name: 'Puskesmas Kelurahan Kelapa Dua',
    type: FacilityType.puskesmas,
    address: 'Jl. Raya Kelapa Dua No. 32, RT.2/RW.2, Kelapa Dua',
    kelurahan: 'Kelapa Dua',
    latitude: -6.208118,
    longitude: 106.769309,
    phone: '021-5301349',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: ['Pelayanan Kesehatan Primer'],
  ),
  HealthFacility(
    id: 'PKM007',
    name: 'Puskesmas Kelurahan Sukabumi Selatan',
    type: FacilityType.puskesmas,
    address: 'Jl. Raya Sukabumi Selatan, RT.6/RW.6, Sukabumi Selatan',
    kelurahan: 'Sukabumi Selatan',
    latitude: -6.218050,
    longitude: 106.769772,
    phone: '021-5361034',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: ['Pelayanan Kesehatan Primer'],
  ),
  HealthFacility(
    id: 'PKM008',
    name: 'Puskesmas Kelurahan Sukabumi Utara',
    type: FacilityType.puskesmas,
    address: 'Jl. Harun Raya, RT.9/RW.7, Sukabumi Utara',
    kelurahan: 'Sukabumi Utara',
    latitude: -6.203186,
    longitude: 106.774301,
    phone: '021-5362526',
    coordinateNote:
    'Koordinat mengikuti pin Google Maps yang diberikan pengguna; '
        'verifikasi lapangan tetap disarankan.',
    services: ['Pelayanan Kesehatan Primer'],
  ),

  // ============================================================
  // 3. KLINIK
  // ============================================================
  HealthFacility(
    id: 'KL001',
    name: 'Klinik Pratama RCTI',
    type: FacilityType.clinic,
    address: 'Jl. Raya Perjuangan No. 1, Kebon Jeruk',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.1948,
    longitude: 106.7667,
    openingHours: '09.00–17.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL002',
    name: 'Klinik Pratama Teratai Kebon Jeruk',
    type: FacilityType.clinic,
    address: 'Jl. Kebon Jeruk Raya No. 68, RT 001/RW 011',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.195500428293177,
    longitude: 106.76993555508862,
    openingHours: '08.00–20.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Kesehatan Gigi'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL003',
    name: 'Klinik Kecantikan Pratama Estetika Evitderma',
    type: FacilityType.clinic,
    address: 'Plaza Prisma Kedoya Blok A No. 7, Jl. Raya Perjuangan',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.191248607088434,
    longitude: 106.75804764032364,
    openingHours: '09.00–17.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Estetika', 'Farmasi'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL004',
    name: 'Klinik Pratama Estetika dr. Affandi',
    type: FacilityType.clinic,
    address: 'Jl. Panjang No. 37B, Kebon Jeruk',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.19279,
    longitude: 106.76918,
    openingHours: '09.00–20.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Estetika'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL005',
    name: 'Klinik Pratama Surya Utama',
    type: FacilityType.clinic,
    address: 'GKI Surya Utama, Jl. Surya Utama Blok W No. 1–3',
    kelurahan: 'Kedoya Utara',
    latitude: -6.1696863237557125,
    longitude: 106.76431328058243,
    openingHours: 'Senin–Sabtu 08.00–12.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Kesehatan Gigi'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL006',
    name: 'Klinik Dr. Sander B Daya Medika',
    type: FacilityType.clinic,
    address: 'Ruko Agave Blok A1, Jl. Tomang Tol Raya No. 16–18, Kedoya Selatan',
    kelurahan: 'Kedoya Selatan',
    latitude: -6.189660,
    longitude: 106.763955,
    phone: '021-5812781',
    openingHours: 'Setiap hari 07.00–20.00 WIB (situs klinik)',
    services: [
      'Pemeriksaan Umum',
      'Kesehatan Gigi',
      'Laboratorium',
      'Radiologi',
      'Farmasi',
      'Medical Check Up',
    ],
    coordinateNote:
    'Koordinat tercantum pada data Dinkes DKI; alamat dan jam operasional juga dicocokkan dengan situs klinik.',
  ),
  HealthFacility(
    id: 'KL007',
    name: 'FG Dental & Wellness Clinic',
    type: FacilityType.clinic,
    address: 'Taman Kedoya Permai, Jl. Trapesium Blok A9 No. 5',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.192322562242814,
    longitude: 106.75766347837434,
    openingHours: '09.00–15.00 WIB (data Dinkes DKI; konfirmasi sebelum berkunjung)',
    services: ['Pemeriksaan Umum', 'Kesehatan Gigi'],
    coordinateNote:
    'Kelurahan dan koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL008',
    name: 'Klinik Pratama Kimia Farma 254 Pos Pengumben',
    type: FacilityType.clinic,
    address: 'Jl. Pos Pengumben Raya No. I, Sukabumi Selatan',
    kelurahan: 'Sukabumi Selatan',
    latitude: -6.216873673202346,
    longitude: 106.76982522010803,
    openingHours: '08.00–22.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Kesehatan Gigi', 'Farmasi'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL009',
    name: 'Klinik Viva Medika Centro City',
    type: FacilityType.clinic,
    address: 'Apartemen Centro City, Jl. Macan Kav. 4–5 Blok S16–S20',
    kelurahan: 'Kedoya Utara',
    latitude: -6.16385174721122,
    longitude: 106.77190331342074,
    phone: '021-29666764',
    openingHours: '08.00–21.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Kesehatan Gigi', 'Farmasi'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; alamat dan telepon dicocokkan dengan situs Viva Medika.',
  ),
  HealthFacility(
    id: 'KL010',
    name: 'Klinik Arjuna',
    type: FacilityType.clinic,
    address: 'Jl. Arjuna Utara No. 7 F & G, Duri Kepa',
    kelurahan: 'Duri Kepa',
    latitude: -6.185751655971594,
    longitude: 106.78000031659569,
    openingHours: '07.00–20.00 WIB (data Dinkes DKI)',
    services: [
      'Pemeriksaan Umum',
      'Kesehatan Gigi',
      'Spesialis Mata',
      'THT',
      'Laboratorium',
    ],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL011',
    name: 'Klinik Utama ACR Care',
    type: FacilityType.clinic,
    address: 'Jl. Raya Pos Pengumben No. 12A–B, RT 004/RW 005',
    kelurahan: 'Sukabumi Selatan',
    latitude: -6.216962998775699,
    longitude: 106.76660757511854,
    openingHours: '09.00–20.00 WIB (data Dinkes DKI)',
    services: ['Pelayanan Spesialis', 'Pemeriksaan Umum'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL012',
    name: 'Klinik Catherine',
    type: FacilityType.clinic,
    address: 'Jl. Mangga Raya, Ruko Greenville Blok C No. 3A',
    kelurahan: 'Duri Kepa',
    latitude: -6.172956660925873,
    longitude: 106.7775838990611,
    openingHours: '07.00–20.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Estetika'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL013',
    name: 'Q Derma',
    type: FacilityType.clinic,
    address: 'Jl. Kebon Jeruk Raya No. 3A, RT 008/RW 005',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.1988417,
    longitude: 106.7807151,
    openingHours: '09.00–19.00 WIB (data Dinkes DKI)',
    services: ['Pemeriksaan Umum', 'Kecantikan', 'Farmasi'],
    coordinateNote:
    'Koordinat tercantum pada data fasilitas kesehatan Dinkes DKI; verifikasi lapangan tetap disarankan.',
  ),
  HealthFacility(
    id: 'KL014',
    name: 'Klinik Utama GP+ Kebon Jeruk',
    type: FacilityType.clinic,
    address: 'The Vida Office Building, Level 7 Unit 10, Jl. Raya Perjuangan No. 8, Kebon Jeruk, Jakarta Barat 11530',
    kelurahan: 'Kebon Jeruk',
    latitude: -6.190902,
    longitude: 106.7596006,
    phone: '081219744752',
    coordinateNote:
    'Koordinat diambil dari tautan Google Maps resmi GP+ Medical & Paincare untuk The Vida Office Building; titik pin klinik perlu dicocokkan dengan unit gedung.',
    openingHours: 'Senin–Jumat 10.00–18.00 WIB; Sabtu berdasarkan janji temu',
    services: [
      'KIE Pasien dan Keluarga',
      'Konseling Medik',
      'Pelayanan Medik Spesialistik',
      'Pelayanan Kefarmasian',
    ],
  ),
];
