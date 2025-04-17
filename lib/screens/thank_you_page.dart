// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({
    super.key,
  });

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage>
    with TickerProviderStateMixin {
  // Controllers for floating ketupat animations
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _positionAnimations;

  // Generate evenly distributed positions for ketupat
  final List<FloatingKetupat> _ketupatList = _generateDistributedKetupatList(8);

  // Generate evenly distributed ketupat positions
  static List<FloatingKetupat> _generateDistributedKetupatList(int count) {
    List<FloatingKetupat> result = [];

    // Define screen grid sections
    int rows = 3;
    int cols = 3;

    // Keep track of which grid cells are occupied
    Set<String> occupiedCells = {};

    for (int i = 0; i < count; i++) {
      int attempts = 0;
      late int row;
      late int col;
      String cellKey;

      // Try to find an unoccupied cell
      do {
        if (attempts > 20) {
          // If too many attempts, reset some cells to allow placing more ketupat
          if (occupiedCells.length > count / 2) {
            occupiedCells.clear();
          }
        }

        row = math.Random().nextInt(rows);
        col = math.Random().nextInt(cols);
        cellKey = "$row-$col";
        attempts++;
      } while (occupiedCells.contains(cellKey) && attempts < 30);

      occupiedCells.add(cellKey);

      // Calculate position within the cell (with some randomness)
      double cellWidth = 1.0 / cols;
      double cellHeight = 1.0 / rows;

      // Position within cell (add some randomness but keep within cell bounds)
      double xOffset =
          math.Random().nextDouble() * 0.6 + 0.2; // 0.2-0.8 range within cell
      double yOffset =
          math.Random().nextDouble() * 0.6 + 0.2; // 0.2-0.8 range within cell

      double x = (col * cellWidth) + (cellWidth * xOffset);
      double y = (row * cellHeight) + (cellHeight * yOffset);

      // Clamp values to ensure they're within screen bounds (0.05-0.95)
      x = math.max(0.05, math.min(0.95, x));
      y = math.max(0.05, math.min(0.95, y));

      result.add(FloatingKetupat(
        x: x,
        y: y,
        size: math.Random().nextDouble() * 40 + 50, // Random size between 50-90
        speed: math.Random().nextDouble() * 5 + 5, // Random speed
      ));
    }

    return result;
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _animationControllers = List.generate(
      _ketupatList.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(seconds: _ketupatList[index].speed.round() + 10),
      )..repeat(reverse: true),
    );

    // Initialize position animations
    _positionAnimations = List.generate(
      _ketupatList.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationControllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF14654E).withOpacity(0.9),
                  const Color(0xFF14654E).withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Floating ketupat images
          ..._buildFloatingKetupat(),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success checkmark animation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF14654E),
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Thank you message
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFE4A532),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Terima Kasih!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14654E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Kami akan menjangkakan kehadiran anda.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF333333),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Jangan lupa tarikh dan lokasi!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14654E),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Event reminder options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                context,
                                title: 'Tambah ke\nKalendar',
                                icon: Icons.calendar_today,
                                onTap: () => _addToCalendar(),
                              ),
                              _buildActionButton(
                                context,
                                title: 'Navigasi ke\nLokasi',
                                icon: Icons.map,
                                onTap: _openMaps,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // WhatsApp contact button
                          ElevatedButton.icon(
                            onPressed: _openWhatsApp,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color(0xFF25D366), // WhatsApp green
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.chat),
                            label: const Text(
                              'Ada Soalan? Hubungi Kami',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Done button
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pop(); // Pop twice to go back to event details
                            },
                            child: const Text(
                              'Kembali',
                              style: TextStyle(
                                color: Color(0xFF14654E),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the floating ketupat images
  List<Widget> _buildFloatingKetupat() {
    return List.generate(_ketupatList.length, (index) {
      return AnimatedBuilder(
        animation: _animationControllers[index],
        builder: (context, child) {
          return Positioned(
            left: _ketupatList[index].x * MediaQuery.of(context).size.width +
                30 * math.sin(_positionAnimations[index].value * 2 * math.pi),
            top: _ketupatList[index].y * MediaQuery.of(context).size.height +
                30 * math.cos(_positionAnimations[index].value * 2 * math.pi),
            child: Opacity(
              opacity: 0.5, // Semi-transparent ketupat
              child: Transform.rotate(
                angle: _positionAnimations[index].value * 2 * math.pi / 10,
                child: Image.asset(
                  'assets/images/ketupat.png',
                  width: _ketupatList[index].size,
                  height: _ketupatList[index].size,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE4A532).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE4A532),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: const Color(0xFFE4A532),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF14654E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCalendar() async {
    final eventStartTime = DateTime(2025, 4, 25, 17, 0); // 5:00 PM
    final eventEndTime = DateTime(2025, 4, 25, 22, 0); // 10:00 PM

    // Try platform-specific calendar intent first
    final title = 'Galok Raya Studio Belatuk';
    final location = 'Lailas Deli, Jalan Besar, Kuantan';
    final description = 'You are invited to Galok Raya Studio Belatuk';

    // For iOS, use different format
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final url = Uri.parse('calshow://');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        return;
      }
    }

    // For Android, try intent
    final androidIntent = Uri.parse('content://com.android.calendar/events');
    if (await canLaunchUrl(androidIntent)) {
      try {
        await launchUrl(androidIntent);
        return;
      } catch (e) {
        // Fall back to web if direct intent fails
      }
    }

    // Fall back to Google Calendar web as last resort
    final startDate = eventStartTime
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .substring(0, 15);
    final endDate = eventEndTime
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .substring(0, 15);

    final url =
        Uri.parse('https://www.google.com/calendar/render?action=TEMPLATE'
            '&text=$title'
            '&dates=$startDate/$endDate'
            '&details=$description'
            '&location=$location');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openMaps() async {
    // Direct link to Lailas Deli in Kuantan
    final googleMapsUrl =
        Uri.parse('https://maps.app.goo.gl/ke5ZGRiRaLjafsxT6');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _openWhatsApp() async {
    final whatsappUrl = Uri.parse('https://belatuk.wasap.my/');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }
}

// Class to store ketupat properties
class FloatingKetupat {
  final double x; // x position ratio (0-1)
  final double y; // y position ratio (0-1)
  final double size; // size of the ketupat
  final double speed; // animation speed

  FloatingKetupat({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}
