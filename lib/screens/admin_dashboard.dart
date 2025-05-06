// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/admin_rsvp_list.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

// For web export
import 'dart:html' as html;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  int _totalAttendees = 0;
  int _totalRSVPs = 0;
  bool _isLoading = true;
  Map<String, int> _arrivalTimeDistribution = {
    '5:00 PM': 0,
    '6:00 PM': 0,
    '7:00 PM': 0,
    '8:00 PM': 0,
    '9:00 PM': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _totalAttendees = await _firestoreService.getTotalAttendees();
      // Reset arrival time distribution
      _arrivalTimeDistribution = {
        '5:00 PM': 0,
        '6:00 PM': 0,
        '7:00 PM': 0,
        '8:00 PM': 0,
        '9:00 PM': 0,
      };

      // We'll count RSVPs in the stream builder, but initialize to 0
      _totalRSVPs = 0;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle RSVP deletion
  Future<void> _deleteRSVP(String rsvpId) async {
    try {
      // Show a confirmation dialog
      final shouldDelete = await _showDeleteConfirmationDialog();
      if (shouldDelete != true) return;

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // Delete the RSVP
      await _firestoreService.deleteRSVP(rsvpId);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RSVP deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh data after deletion
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting RSVP: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show confirmation dialog before deleting
  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Are you sure you want to delete this RSVP?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Function to handle deletion of all RSVPs
  Future<void> _deleteAllRSVPs() async {
    try {
      // Show a confirmation dialog
      final shouldDelete = await _showDeleteAllConfirmationDialog();
      if (shouldDelete != true) return;

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // Get all RSVPs
      final snapshot =
          await FirebaseFirestore.instance.collection('rsvps').get();

      // Create a batch to delete all documents efficiently
      final batch = FirebaseFirestore.instance.batch();

      // Add each document to the batch deletion
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch deletion
      await batch.commit();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All RSVPs deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh data after deletion
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting RSVPs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show confirmation dialog before deleting all RSVPs
  Future<bool?> _showDeleteAllConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Confirmation'),
        content: const Text(
          'Are you sure you want to delete ALL RSVPs? This action cannot be undone.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  // Update the arrival time distribution map
  Map<String, int> _calculateArrivalTimeDistribution(
      List<QueryDocumentSnapshot> docs) {
    final distribution = {
      '5:00 PM': 0,
      '6:00 PM': 0,
      '7:00 PM': 0,
      '8:00 PM': 0,
      '9:00 PM': 0,
    };

    // Calculate the distribution
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final arrivalTime = data['arrivalTime'] as String? ?? '5:00 PM';
      final attendees = data['attendees'] as int? ?? 1;

      if (distribution.containsKey(arrivalTime)) {
        distribution[arrivalTime] =
            (distribution[arrivalTime] ?? 0) + attendees;
      }
    }

    return distribution;
  }

  Future<void> _exportRSVPsToTxt() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get all RSVPs from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('rsvps').get();

      // Format the data
      final buffer = StringBuffer();
      buffer.write('Studio Belatuk Galok Raya - RSVP List\n');
      buffer.write(
          'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}\n\n');
      buffer.write('Total RSVPs: ${snapshot.docs.length}\n');
      buffer.write('Total Attendees: $_totalAttendees\n\n');
      buffer.write('----------------------------------------\n\n');

      // Add each RSVP to the text
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        buffer.write('RSVP #${i + 1}\n');
        buffer.write('Name: ${data['name'] ?? 'N/A'}\n');
        buffer.write('Contact: ${data['contact'] ?? 'N/A'}\n');
        buffer.write('Number of Attendees: ${data['attendees'] ?? 1}\n');
        buffer.write('Expected Arrival: ${data['arrivalTime'] ?? 'N/A'}\n');
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          buffer.write('Message: ${data['message']}\n');
        }
        buffer.write(
            'Submitted on: ${data['timestamp'] != null ? DateFormat('yyyy-MM-dd HH:mm').format((data['timestamp'] as Timestamp).toDate()) : 'N/A'}\n');
        buffer.write('----------------------------------------\n\n');
      }

      final txt = buffer.toString();

      // Download the file (for web)
      if (kIsWeb) {
        // For web: Create blob and trigger download
        final bytes = html.Blob([txt]);
        final url = html.Url.createObjectUrlFromBlob(bytes);
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RSVP list downloaded successfully')),
        );
      } else {
        // For mobile, we'd need additional packages
        // This would require adding path_provider and share_plus packages
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Export is only available on web platform')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting RSVP data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF14654E),
        foregroundColor: Colors.white,
        actions: [
          // Delete all button
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete All RSVPs',
            onPressed: _deleteAllRSVPs,
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export RSVPs',
            onPressed: _exportRSVPsToTxt,
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getRSVPs(),
                builder: (context, snapshot) {
                  // Handle loading, error, and empty states
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Calculate total RSVPs
                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;
                    _totalRSVPs = docs.length;
                  } else {
                    _totalRSVPs = 0;
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatsCard(
                                  title: 'Total RSVPs',
                                  value: _totalRSVPs.toString(),
                                  icon: Icons.how_to_reg,
                                  color: const Color(0xFF14654E),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatsCard(
                                  title: 'Total Pax',
                                  value: _totalAttendees.toString(),
                                  icon: Icons.groups,
                                  color: const Color(0xFFE4A532),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Arrival Time Distribution',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14654E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty)
                            _buildArrivalTimeTable(
                                _calculateArrivalTimeDistribution(
                                    snapshot.data!.docs))
                          else
                            _buildArrivalTimeTable(_arrivalTimeDistribution),
                          const SizedBox(height: 24),
                          const Text(
                            'RSVP Submissions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14654E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No RSVPs yet'),
                              ),
                            )
                          else
                            AdminRSVPList(
                              rsvpDocs: snapshot.data!.docs,
                              onDelete: _deleteRSVP,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Simple stats card
  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Table for arrival time distribution
  Widget _buildArrivalTimeTable(Map<String, int> distribution) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF14654E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Pax',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...['5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM', '9:00 PM']
              .map((time) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      time,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${distribution[time] ?? 0}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE4A532),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
