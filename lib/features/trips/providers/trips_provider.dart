import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip_model.dart';

class TripsProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Trip> upcomingTrips = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchUpcomingTrips() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('trips')
          .select()
          .eq('user_id', userId)
          .eq('is_archived', false)
          .gte('end_date', today)
          .order('start_date', ascending: true);

      upcomingTrips = (response as List)
          .map((row) => Trip.fromMap(row))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load trips. Please try again.';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTrip({
    required String title,
    String? destination,
    double? latitude,
    double? longitude,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser!.id;

      await _supabase.from('trips').insert({
        'user_id': userId,
        'title': title,
        'destination': destination,
        'latitude': latitude,
        'longitude': longitude,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'budget': budget,
        'status': 'planning',
      });

      isLoading = false;
      notifyListeners();

      // Refresh the upcoming trips list so the new trip shows up immediately
      await fetchUpcomingTrips();

      return true;
    } catch (e) {
      errorMessage = 'Failed to create trip. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Checklist
  List<Map<String, dynamic>> checklistItems = [];

  Future<void> fetchChecklist(String tripId) async {
    try {
      final response = await _supabase
          .from('checklist_items')
          .select()
          .eq('trip_id', tripId)
          .order('created_at', ascending: true);

      checklistItems = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      // silently fail — checklist is non-critical
    }
  }

  Future<void> addChecklistItem(String tripId, String label) async {
    try {
      final response = await _supabase
          .from('checklist_items')
          .insert({
            'trip_id': tripId,
            'label': label,
            'is_checked': false,
          })
          .select()
          .single();

      checklistItems.add(response);
      notifyListeners();
    } catch (e) {
      // silently fail
    }
  }

  Future<void> toggleChecklistItem(String itemId, bool currentValue) async {
    try {
      await _supabase
          .from('checklist_items')
          .update({'is_checked': !currentValue})
          .eq('item_id', itemId);

      final index = checklistItems
          .indexWhere((item) => item['item_id'] == itemId);
      if (index != -1) {
        checklistItems[index]['is_checked'] = !currentValue;
        notifyListeners();
      }
    } catch (e) {
      // silently fail
    }
  }

  Future<void> deleteChecklistItem(String itemId) async {
    try {
      await _supabase
          .from('checklist_items')
          .delete()
          .eq('item_id', itemId);

      checklistItems.removeWhere((item) => item['item_id'] == itemId);
      notifyListeners();
    } catch (e) {
      // silently fail
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _supabase
          .from('trips')
          .delete()
          .eq('trip_id', tripId);

      upcomingTrips.removeWhere((t) => t.tripId == tripId);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete trip.';
      notifyListeners();
    }
  }
  
List<Trip> tripHistory = [];

Future<void> fetchTripHistory() async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final userId = _supabase.auth.currentUser!.id;
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _supabase
        .from('trips')
        .select()
        .eq('user_id', userId)
        .or('end_date.lt.$today,status.eq.completed')
        .order('end_date', ascending: false);

    tripHistory = (response as List)
        .map((row) => Trip.fromMap(row))
        .toList();

    isLoading = false;
    notifyListeners();
  } catch (e) {
    errorMessage = 'Failed to load trip history.';
    isLoading = false;
    notifyListeners();
  }
}

List<Trip> allTrips = [];

Future<void> fetchAllTrips() async {
  try {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: true);

    allTrips = (response as List)
        .map((row) => Trip.fromMap(row))
        .toList();

    notifyListeners();
  } catch (e) {
    // silently fail
  }
}

Future<bool> updateTrip({
  required String tripId,
  required String title,
  String? destination,
  double? latitude,
  double? longitude,
  required DateTime startDate,
  required DateTime endDate,
  required double budget,
}) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    await _supabase.from('trips').update({
      'title': title,
      'destination': destination,
      'latitude': latitude,
      'longitude': longitude,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'budget': budget,
    }).eq('trip_id', tripId);

    // Update local list too
    final index = upcomingTrips.indexWhere((t) => t.tripId == tripId);
    if (index != -1) {
      upcomingTrips[index] = Trip(
        tripId: tripId,
        userId: upcomingTrips[index].userId,
        title: title,
        destination: destination,
        latitude: latitude,
        longitude: longitude,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        status: upcomingTrips[index].status,
        isArchived: upcomingTrips[index].isArchived,
        notes: upcomingTrips[index].notes,
        createdAt: upcomingTrips[index].createdAt,
      );
    }

    isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    errorMessage = 'Failed to update trip.';
    isLoading = false;
    notifyListeners();
    return false;
  }
}

}