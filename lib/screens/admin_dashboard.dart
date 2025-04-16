import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/admin_rsvp_list.dart';
import '../widgets/admin_stats_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  int _totalAttendees = 0;
  int _totalRSVPs = 0;
  bool _isLoading = true;

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

      // We'll count RSVPs in the stream builder, but initialize to 0
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading admin data: $e');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AdminStatsCard(
                              title: 'Total RSVPs',
                              value: _totalRSVPs.toString(),
                              icon: Icons.how_to_reg,
                              color: const Color(0xFF14654E),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AdminStatsCard(
                              title: 'Total Attendees',
                              value: _totalAttendees.toString(),
                              icon: Icons.groups,
                              color: const Color(0xFFE4A532),
                            ),
                          ),
                        ],
                      ),
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
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestoreService.getRSVPs(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No RSVPs yet'),
                              ),
                            );
                          }

                          // Update the RSVP count
                          final docs = snapshot.data!.docs;
                          _totalRSVPs = docs.length;

                          return AdminRSVPList(rsvpDocs: docs);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
