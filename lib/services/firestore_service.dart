import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final CollectionReference _rsvpCollection =
      FirebaseFirestore.instance.collection('rsvps');

  // Submit a new RSVP with improved error handling
  Future<void> submitRSVP({
    required String name,
    required String contact,
    required int attendees,
    required String arrivalTime,
    String? message,
  }) async {
    try {
      if (kDebugMode) {
        print('Submitting RSVP data to Firebase:');
        print('Name: $name');
        print('Contact: $contact');
        print('Attendees: $attendees');
        print('Arrival Time: $arrivalTime');
        print('Message: ${message ?? ""}');
      }

      final rsvpData = {
        'name': name,
        'contact': contact,
        'attendees': attendees,
        'arrivalTime': arrivalTime,
        'message': message ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add the document and wait for confirmation
      final docRef = await _rsvpCollection.add(rsvpData);

      if (kDebugMode) {
        print('RSVP successfully added with ID: ${docRef.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting RSVP: $e');
      }
      // Re-throw the error to be handled by the calling code
      throw Exception('Failed to submit RSVP: $e');
    }
  }

  // Get all RSVPs as a stream for real-time updates
  Stream<QuerySnapshot> getRSVPs() {
    return _rsvpCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Get total number of attendees
  Future<int> getTotalAttendees() async {
    try {
      QuerySnapshot querySnapshot = await _rsvpCollection.get();
      int total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['attendees'] as int? ?? 1);
      }
      return total;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting total attendees: $e');
      }
      return 0;
    }
  }

  // Delete an RSVP
  Future<void> deleteRSVP(String rsvpId) async {
    try {
      await _rsvpCollection.doc(rsvpId).delete();
      if (kDebugMode) {
        print('RSVP successfully deleted: $rsvpId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting RSVP: $e');
      }
      throw Exception('Failed to delete RSVP: $e');
    }
  }
}
