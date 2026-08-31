import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/trips_provider.dart';
import '../models/trip_model.dart';
import '../../../core/constants/app_colors.dart';

class TripHistoryTab extends StatefulWidget {
  const TripHistoryTab({super.key});

  @override
  State<TripHistoryTab> createState() => _TripHistoryTabState();
}

class _TripHistoryTabState extends State<TripHistoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripsProvider>().fetchTripHistory();
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

    if (tripsProvider.tripHistory.isEmpty) {
      return _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => tripsProvider.fetchTripHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tripsProvider.tripHistory.length,
        itemBuilder: (context, index) {
          final trip = tripsProvider.tripHistory[index];
          return _HistoryCard(trip: trip);
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
            Icon(Icons.history, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No past trips yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed trips will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Trip trip;
  const _HistoryCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dateRange = trip.startDate != null && trip.endDate != null
        ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
        : 'No dates set';

    final statusColor = trip.status == 'completed'
        ? AppColors.success
        : AppColors.textSecondary;

    final statusLabel = trip.status == 'completed'
        ? 'Completed'
        : 'Past';

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
              // Greyed out icon for past trips
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.flight_land,
                    color: AppColors.textSecondary),
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
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}