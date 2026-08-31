import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/trips_provider.dart';
import '../models/trip_model.dart';
import '../../../core/constants/app_colors.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripsProvider>().fetchAllTrips();
    });
  }

  // Returns all trips that overlap with a given day
  List<Trip> _getTripsForDay(DateTime day, List<Trip> allTrips) {
    return allTrips.where((trip) {
      if (trip.startDate == null || trip.endDate == null) return false;
      final tripStart = DateTime(
          trip.startDate!.year, trip.startDate!.month, trip.startDate!.day);
      final tripEnd = DateTime(
          trip.endDate!.year, trip.endDate!.month, trip.endDate!.day);
      final checkDay = DateTime(day.year, day.month, day.day);
      return !checkDay.isBefore(tripStart) && !checkDay.isAfter(tripEnd);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tripsProvider = context.watch<TripsProvider>();
    final allTrips = tripsProvider.allTrips;
    final selectedTrips = _selectedDay != null
        ? _getTripsForDay(_selectedDay!, allTrips)
        : _getTripsForDay(_focusedDay, allTrips);

    return Column(
      children: [
        // Calendar widget
        TableCalendar<Trip>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => _getTripsForDay(day, allTrips),
          calendarStyle: CalendarStyle(
            // Today
            todayDecoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            // Selected day
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(color: Colors.white),
            // Event dots
            markerDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: AppColors.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
        ),

        const Divider(height: 1),

        // Trips for selected day
        Expanded(
          child: selectedTrips.isEmpty
              ? Center(
                  child: Text(
                    'No trips on this day',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: selectedTrips.length,
                  itemBuilder: (context, index) {
                    final trip = selectedTrips[index];
                    return _CalendarTripCard(trip: trip);
                  },
                ),
        ),
      ],
    );
  }
}

class _CalendarTripCard extends StatelessWidget {
  final Trip trip;
  const _CalendarTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final dateRange = trip.startDate != null && trip.endDate != null
        ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
        : 'No dates set';

    return GestureDetector(
      onTap: () => context.push('/trip/${trip.tripId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.flight_takeoff, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (trip.destination != null)
                      Text(
                        trip.destination!,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}