import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trips_provider.dart';
import '../models/trip_model.dart';
import '../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class UpcomingTripsTab extends StatefulWidget {
  const UpcomingTripsTab({super.key});

  @override
  State<UpcomingTripsTab> createState() => _UpcomingTripsTabState();
}

class _UpcomingTripsTabState extends State<UpcomingTripsTab> {
  @override
  void initState() {
    super.initState();
    // Fetch trips as soon as this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripsProvider>().fetchUpcomingTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripsProvider = context.watch<TripsProvider>();

    if (tripsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tripsProvider.errorMessage != null) {
      return Center(child: Text(tripsProvider.errorMessage!));
    }

    if (tripsProvider.upcomingTrips.isEmpty) {
      return _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => tripsProvider.fetchUpcomingTrips(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tripsProvider.upcomingTrips.length,
        itemBuilder: (context, index) {
          final trip = tripsProvider.upcomingTrips[index];
          return _TripCard(trip: trip);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.luggage_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No upcoming trips yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap Quick Add to plan your next adventure!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final dateRange = trip.startDate != null && trip.endDate != null
        ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
        : 'No dates set';

    return Dismissible(
      key: Key(trip.tripId),
      direction: DismissDirection.endToStart, // right to left only
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Trip'),
            content: Text(
                'Are you sure you want to delete "${trip.title}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Delete',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        context.read<TripsProvider>().deleteTrip(trip.tripId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${trip.title}" deleted'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      child: GestureDetector(
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
      ),
    );
  }
}
