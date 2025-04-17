// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../screens/thank_you_page.dart';

class RSVPForm extends StatefulWidget {
  const RSVPForm({super.key});

  @override
  State<RSVPForm> createState() => _RSVPFormState();
}

class _RSVPFormState extends State<RSVPForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  int _attendees = 1;
  String _arrivalTime = '5:00 PM'; // Default arrival time
  bool _isSubmitting = false;
  final FirestoreService _firestoreService = FirestoreService();

  // List of arrival time options
  final List<String> _arrivalTimeOptions = [
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Sedikit Maklumat',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  color: const Color(0xFF14654E),
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Supaya cukup tempat duduk dan makanan untuk semua',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nama anda';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _contactController,
                  label: 'Nombor Telefon',
                  icon: Icons.contact_mail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nombor telefon anda';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildAttendeesSelector(),
                const SizedBox(height: 20),
                _buildArrivalTimeDropdown(),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _messageController,
                  label: 'Ada Pesanan? Isikan disini (jika ada)',
                  icon: Icons.message,
                  maxLines: 3,
                ),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF14654E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE4A532)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF14654E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildAttendeesSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.group, color: Color(0xFF14654E)),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Jumlah Hadir',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF14654E),
                onPressed: () {
                  if (_attendees > 1) {
                    setState(() {
                      _attendees--;
                    });
                  }
                },
              ),
              Text(
                '$_attendees',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF14654E),
                onPressed: () {
                  setState(() {
                    _attendees++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalTimeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Color(0xFF14654E)),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Jangkaan waktu ketibaan',
              style: TextStyle(fontSize: 16),
            ),
          ),
          DropdownButton<String>(
            value: _arrivalTime,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF14654E)),
            elevation: 16,
            style: const TextStyle(
              color: Color(0xFF14654E),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            underline: Container(
              height: 0, // Remove the default underline
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _arrivalTime = newValue;
                });
              }
            },
            items: _arrivalTimeOptions
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF14654E),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
      ),
      child: _isSubmitting
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 10),
                Text('Menghantar...', style: TextStyle(fontSize: 18)),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Hantar RSVP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  void _submitForm() async {
    if (kDebugMode) {
      print('Submit button pressed');
    }

    if (_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print('Form validation passed');
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        await _firestoreService.submitRSVP(
          name: _nameController.text,
          contact: _contactController.text,
          attendees: _attendees,
          arrivalTime: _arrivalTime,
          message: _messageController.text,
        );

        if (kDebugMode) {
          print('RSVP submitted successfully');
        }

        if (mounted) {
          // Navigate to thank you page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ThankYouPage(),
            ),
          );
        }

        // Reset form after successful submission
        _nameController.clear();
        _contactController.clear();
        _messageController.clear();
        setState(() {
          _attendees = 1;
          _arrivalTime = '5:00 PM';
          _isSubmitting = false;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error submitting RSVP: $e');
        }

        setState(() {
          _isSubmitting = false;
        });

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maaf, ada masalah: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (kDebugMode) {
        print('Form validation failed');
      }
    }
  }
}
