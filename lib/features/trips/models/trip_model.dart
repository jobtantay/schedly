class Trip {
  final String tripId;
  final String userId;
  final String title;
  final String? destination;
  final double? latitude;
  final double? longitude;
  final DateTime? startDate;
  final DateTime? endDate;
  final double budget;
  final String status;
  final bool isArchived;
  final String? notes;
  final DateTime createdAt;

  Trip({
    required this.tripId,
    required this.userId,
    required this.title,
    this.destination,
    this.latitude,
    this.longitude,
    this.startDate,
    this.endDate,
    required this.budget,
    required this.status,
    required this.isArchived,
    this.notes,
    required this.createdAt,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      tripId: map['trip_id'],
      userId: map['user_id'],
      title: map['title'],
      destination: map['destination'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : null,
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : null,
      budget: (map['budget'] as num?)?.toDouble() ?? 0,
      status: map['status'] ?? 'planning',
      isArchived: map['is_archived'] ?? false,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}