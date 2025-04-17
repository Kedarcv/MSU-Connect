import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar_event_model.dart';

class CalendarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<CalendarEventModel>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    try {
      Query query = _firestore.collection('calendar_events');

      if (startDate != null) {
        query = query.where('startDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('endDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      final snapshot = await query.orderBy('startDate').get();

      return snapshot.docs
          .map((doc) =>
              CalendarEventModel.fromJson({'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load calendar events: $e');
    }
  }

  static Future<CalendarEventModel> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('calendar_events').doc(eventId).get();
      if (!doc.exists) {
        throw Exception('Event not found');
      }
      return CalendarEventModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to load event: $e');
    }
  }

  static Future<void> addEvent(CalendarEventModel event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _firestore
          .collection('calendar_events')
          .doc(event.id)
          .set(event.toJson());
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }

  static Future<void> updateEvent(CalendarEventModel event) async {
    try {
      await _firestore
          .collection('calendar_events')
          .doc(event.id)
          .update(event.toJson());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('calendar_events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  static Future<List<CalendarEventModel>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      return getEvents(
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );
    } catch (e) {
      throw Exception('Failed to load upcoming events: $e');
    }
  }

  static Future<List<CalendarEventModel>> getAcademicDeadlines() async {
    try {
      return getEvents(type: 'deadline');
    } catch (e) {
      throw Exception('Failed to load academic deadlines: $e');
    }
  }
}