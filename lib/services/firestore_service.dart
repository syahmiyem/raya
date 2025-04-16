import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'rsvp_submissions';

  // Add RSVP data to Firestore
  Future<void> submitRSVP({
    required String name,
    required String contact,
    required int attendees,
    String? message,
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'name': name,
        'contact': contact,
        'attendees': attendees,
        'message': message ?? '',
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get all RSVPs - useful for admin dashboard
  Stream<QuerySnapshot> getRSVPs() {
    return _firestore
        .collection(_collection)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Get total number of attendees
  Future<int> getTotalAttendees() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data() as Map<String, dynamic>)['attendees'] as int;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}
