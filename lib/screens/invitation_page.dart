// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/rsvp_form.dart';
import 'dart:math' as math;

class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key});

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage>
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
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFFF5F5F5),
                ],
              ),
            ),
          ),

          // Floating ketupat images
          ..._buildFloatingKetupat(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFestiveHeader(),
                  _buildInvitationContent(context),
                  const RSVPForm(),
                  const SizedBox(height: 40),
                ],
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
              opacity: 0.3, // More subtle than in welcome page
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

  Widget _buildFestiveHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/raya_header.png',
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: 220,
          color: Colors.black.withOpacity(0.3),
        ),
        Text(
          'Galok Raya Studio Belatuk',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInvitationContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Free tak?',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 36,
                  letterSpacing: 1.5,
                  color: const Color(0xFFE4A532),
                ),
          ),
          const SizedBox(height: 30),
          _buildInfoCard('Tarikh & Masa', '25 April 2025, 5:00 PM - 10:00 PM'),
          const SizedBox(height: 15),
          _buildInfoCard('Lokasi', 'Lailas Deli\nJalan Besar, Kuantan'),
          const SizedBox(height: 15),
          _buildInfoCard('Dianjurkan Oleh', 'Studio Belatuk'),
          const SizedBox(height: 30),
          _buildFestiveDecorator(),
          const SizedBox(height: 30),
          const Text(
            'Mohon RSVP segera ya!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE4A532).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF14654E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestiveDecorator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDecorativeIcon(Icons.star, const Color(0xFFE4A532)),
        const SizedBox(width: 10),
        Container(
          width: 100,
          height: 2,
          color: const Color(0xFFE4A532),
        ),
        const SizedBox(width: 10),
        _buildDecorativeIcon(Icons.mosque, const Color(0xFF14654E)),
        const SizedBox(width: 10),
        Container(
          width: 100,
          height: 2,
          color: const Color(0xFFE4A532),
        ),
        const SizedBox(width: 10),
        _buildDecorativeIcon(Icons.star, const Color(0xFFE4A532)),
      ],
    );
  }

  Widget _buildDecorativeIcon(IconData icon, Color color) {
    return Icon(
      icon,
      color: color,
      size: 24,
    );
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
