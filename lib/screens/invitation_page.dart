import 'package:flutter/material.dart';
import '../widgets/rsvp_form.dart';

class InvitationPage extends StatelessWidget {
  const InvitationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
    );
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
