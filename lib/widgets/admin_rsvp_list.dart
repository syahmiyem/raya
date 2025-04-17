// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRSVPList extends StatelessWidget {
  final List<QueryDocumentSnapshot> rsvpDocs;
  final Function(String) onDelete;

  const AdminRSVPList({
    super.key,
    required this.rsvpDocs,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rsvpDocs.length,
      itemBuilder: (context, index) {
        return _RSVPCard(
          doc: rsvpDocs[index],
          onDelete: onDelete,
        );
      },
    );
  }
}

class _RSVPCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final Function(String) onDelete;

  const _RSVPCard({
    required this.doc,
    required this.onDelete,
  });

  @override
  State<_RSVPCard> createState() => _RSVPCardState();
}

class _RSVPCardState extends State<_RSVPCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'No Name';
    final contact = data['contact'] as String? ?? 'No Contact';
    final attendees = data['attendees'] as int? ?? 1;
    final arrivalTime = data['arrivalTime'] as String? ?? '5:00 PM';
    final message = data['message'] as String? ?? '';
    final timestamp = data['timestamp'] as Timestamp?;

    // Format the timestamp
    String formattedDate = 'Pending';
    if (timestamp != null) {
      final date = timestamp.toDate();
      formattedDate =
          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          // Header with name and delete button - always visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF14654E),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14654E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$attendees pax',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE4A532),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => widget.onDelete(widget.doc.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Details - visible only when expanded
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.phone, 'Contact', contact),
                  _buildInfoRow(Icons.access_time, 'Arrival Time', arrivalTime),
                  if (message.isNotEmpty)
                    _buildInfoRow(Icons.message, 'Message', message),
                  _buildInfoRow(
                      Icons.calendar_today, 'Submitted', formattedDate),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFFE4A532),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
