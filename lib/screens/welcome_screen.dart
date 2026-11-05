import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color primary = Color(0xFF1976D2);
  static const Color darkBlue = Color(0xFF123B64);
  static const Color background = Color(0xFFF5F8FC);

  void _startApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              color: primary,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SMART VILLAGE',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'HEALTH',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // MEDICAL ILLUSTRATION
                      const _HealthcareIllustration(),

                      const SizedBox(height: 20),

                      // TITLE
                      const Text(
                        'Sehat Bersama\nSmart Village',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // DESCRIPTION
                      const Text(
                        'Temukan lokasi rumah sakit, puskesmas, '
                            'dan klinik di sekitar Kecamatan Kebon Jeruk '
                            'dengan mudah melalui layanan berbasis lokasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // START BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () => _startApp(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mulai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Layanan Informasi Kesehatan Berbasis Lokasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// HEALTHCARE ILLUSTRATION
// ==========================================

class _HealthcareIllustration extends StatelessWidget {
  const _HealthcareIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BACKGROUND CIRCLE
          Container(
            width: 245,
            height: 245,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE1F0FE),
            ),
          ),

          // LEFT DECORATION
          Positioned(
            left: 2,
            top: 105,
            child: _smallCard(
              Icons.local_hospital,
              const Color(0xFF1976D2),
            ),
          ),

          // RIGHT DECORATION
          Positioned(
            right: 2,
            top: 55,
            child: _smallCard(
              Icons.location_on,
              const Color(0xFF22A06B),
            ),
          ),

          // HOSPITAL ILLUSTRATION
          Positioned(
            bottom: 20,
            child: Container(
              width: 190,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: primaryShadow,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: Color(0xFF1976D2),
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fasilitas Kesehatan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF123B64),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mudah ditemukan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LOCATION PIN
          const Positioned(
            top: 12,
            child: Icon(
              Icons.location_on,
              color: Color(0xFF1976D2),
              size: 52,
            ),
          ),

          // DECORATIVE GREEN CIRCLE
          Positioned(
            bottom: 10,
            right: 38,
            child: Container(
              width: 33,
              height: 33,
              decoration: const BoxDecoration(
                color: Color(0xFFC9EEDB),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 75,
            left: 45,
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Color(0xFF90CAF9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Color primaryShadow = Color(0x1A1976D2);

  Widget _smallCard(IconData icon, Color color) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 29,
      ),
    );
  }
}
