// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'invitation_page.dart';
import 'admin_dashboard.dart';
import 'dart:math' as math;

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  int _adminTapCount = 0;
  final int _requiredTaps = 5;

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

  void _checkForAdminAccess() {
    setState(() {
      _adminTapCount++;
    });

    if (_adminTapCount >= _requiredTaps) {
      // Reset tap count
      _adminTapCount = 0;

      // Navigate to admin dashboard
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _checkForAdminAccess,
        child: Container(
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
          child: Stack(
            children: [
              // Floating ketupat images
              ..._buildFloatingKetupat(),

              // Main content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Studio Belatuk Logo
                      Image.asset(
                        'assets/images/Studio Belatuk Logo Registered White.png',
                        width: 200, // Adjust size as needed
                        height: 200, // Adjust size as needed
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20), // Reduced from 40 to 20

                      // Main invitation text
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 30),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFE4A532),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Ingin menjemput anda sekeluarga untuk sama meraikan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF14654E),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'STUDIO BELATUK GALOK RAYA',
                              style: TextStyle(
                                fontSize: 30, // Reduced from 36 to 30
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Color(0xFFE4A532),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            // Join button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  _createPageRouteWithTransition(
                                    const InvitationPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF14654E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'JOIN',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
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
            ],
          ),
        ),
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
              opacity: 0.7,
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

  // Custom page transition effect (opening a card from right to left)
  PageRouteBuilder _createPageRouteWithTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Create a hinge-like opening animation
        var hingeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        // Transform to create opening card effect from right to left
        return Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective effect
            ..rotateY((1.0 - hingeAnimation.value) *
                1.5), // Rotate from right (positive angle)
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
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
