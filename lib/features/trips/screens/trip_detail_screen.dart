import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/trips_provider.dart';
import '../models/trip_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/notifications/notification_service.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final _checklistController = TextEditingController();
  Trip? _trip;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrip();
      context.read<TripsProvider>().fetchChecklist(widget.tripId);
    });
  }

  void _loadTrip() {
    final provider = context.read<TripsProvider>();
    try {
      _trip = provider.upcomingTrips
          .firstWhere((t) => t.tripId == widget.tripId);
    } catch (_) {
      _trip = null;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _checklistController.dispose();
    super.dispose();
  }

  Future<void> _scheduleReminder(int daysBefore) async {
    if (_trip!.startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a start date first')),
      );
      return;
    }

    await NotificationService.scheduleReminderNotification(
      id: _trip!.tripId.hashCode + daysBefore,
      tripTitle: _trip!.title,
      tripStartDate: _trip!.startDate!,
      daysBefore: daysBefore,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Reminder set for $daysBefore day${daysBefore == 1 ? '' : 's'} before the trip! 🔔'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsProvider = context.watch<TripsProvider>();
    final dateFormat = DateFormat('MMM d, yyyy');

    if (_trip == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final trip = _trip!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  context.push('/trip/${widget.tripId}/edit', extra: _trip);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                trip.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.flight_takeoff,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Trip info card
                  _SectionCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Destination',
                          value: trip.destination ?? 'Not set',
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Dates',
                          value: trip.startDate != null && trip.endDate != null
                              ? '${dateFormat.format(trip.startDate!)} → ${dateFormat.format(trip.endDate!)}'
                              : 'Not set',
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Budget',
                          value: trip.budget > 0
                              ? '\$${trip.budget.toStringAsFixed(2)}'
                              : 'Not set',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Map section
                  if (trip.latitude != null && trip.longitude != null) ...[
                    _SectionTitle('📍 Location'),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                                trip.latitude!, trip.longitude!),
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.schedly',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                      trip.latitude!, trip.longitude!),
                                  child: Icon(
                                    Icons.location_pin,
                                    color: AppColors.primary,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Checklist section
                  _SectionTitle('✅ Checklist'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _checklistController,
                                decoration: InputDecoration(
                                  hintText: 'Add a checklist item...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    tripsProvider.addChecklistItem(
                                        widget.tripId, value.trim());
                                    _checklistController.clear();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle,
                                  color: AppColors.primary),
                              onPressed: () {
                                final text =
                                    _checklistController.text.trim();
                                if (text.isNotEmpty) {
                                  tripsProvider.addChecklistItem(
                                      widget.tripId, text);
                                  _checklistController.clear();
                                }
                              },
                            ),
                          ],
                        ),

                        if (tripsProvider.checklistItems.isNotEmpty)
                          const Divider(height: 8),

                        ...tripsProvider.checklistItems.map((item) {
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item['label'],
                              style: TextStyle(
                                decoration: item['is_checked']
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item['is_checked']
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            value: item['is_checked'],
                            activeColor: AppColors.primary,
                            onChanged: (_) =>
                                tripsProvider.toggleChecklistItem(
                              item['item_id'],
                              item['is_checked'],
                            ),
                            secondary: IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: AppColors.textSecondary,
                                  size: 20),
                              onPressed: () =>
                                  tripsProvider.deleteChecklistItem(
                                      item['item_id']),
                            ),
                          );
                        }),

                        if (tripsProvider.checklistItems.isEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No items yet — add something above!',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reminders section
                  _SectionTitle('🔔 Reminders'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set a reminder before your trip:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [1, 3, 7, 14].map((days) {
                            return OutlinedButton(
                              onPressed: () => _scheduleReminder(days),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(days == 1
                                  ? '1 day before'
                                  : '$days days before'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}