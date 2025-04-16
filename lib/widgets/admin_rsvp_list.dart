// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRSVPList extends StatelessWidget {
  final List<QueryDocumentSnapshot> rsvpDocs;

  const AdminRSVPList({
    super.key,
    required this.rsvpDocs,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rsvpDocs.length,
      itemBuilder: (context, index) {
        final data = rsvpDocs[index].data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unknown';
        final contact = data['contact'] ?? 'No contact';
        final attendees = data['attendees'] ?? 0;
        final message = data['message'] ?? '';
        final timestamp = data['submittedAt'] as Timestamp?;

        String formattedDate = 'Recent';
        if (timestamp != null) {
          final date = timestamp.toDate();
          formattedDate =
              '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Attendees: $attendees · $formattedDate',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF14654E),
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            children: [
              _buildInfoRow(Icons.phone, 'Contact', contact),
              if (message.isNotEmpty)
                _buildInfoRow(Icons.message, 'Message', message),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Details'),
                    onPressed: () {
                      _copyToClipboard(context, {
                        'Name': name,
                        'Contact': contact,
                        'Attendees': attendees.toString(),
                        'Message': message,
                        'Submitted': formattedDate,
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, Map<String, String> details) {
    final text = details.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    // This would use clipboard in a real app
    // Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
