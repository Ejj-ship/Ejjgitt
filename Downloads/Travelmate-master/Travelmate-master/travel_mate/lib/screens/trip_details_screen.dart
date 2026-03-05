import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../models/destination.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/activity_tile.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final Map<String, bool> _expandedDestinations = {};

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;

    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final trip = tripProvider.getTripById(tripId);

        if (trip == null) {
          return Scaffold(
            body: GradientBackground(
              child: Center(
                child: Text(
                  'Trip not found',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context, trip),
                  ),
                  SliverToBoxAdapter(
                    child: _buildProgressSection(trip),
                  ),
                  SliverToBoxAdapter(
                    child: _buildDestinationsHeader(context, trip),
                  ),
                  if (trip.destinations.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyDestinations(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final destination = trip.destinations[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: _buildDestinationCard(
                              context,
                              trip.id,
                              destination,
                            ),
                          );
                        },
                        childCount: trip.destinations.length,
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFAB(context, trip.id),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Trip trip) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.back,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.ellipsis,
                    color: AppTheme.textPrimary,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.pushNamed(
                      context,
                      '/edit-trip',
                      arguments: trip.id,
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, trip.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.pencil, size: 20),
                        SizedBox(width: 12),
                        Text('Edit Trip'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.trash, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete Trip', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Hero(
            tag: 'trip_${trip.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                trip.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 18,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(
                '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          if (trip.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              trip.description,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(Trip trip) {
    final completionPercent = (trip.completionPercentage * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trip Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completionPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: trip.completionPercentage,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(
                    AppTheme.primaryBlue,
                    AppTheme.primaryTeal,
                    trip.completionPercentage,
                  )!,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: CupertinoIcons.map_pin,
                  label: 'Destinations',
                  value: '${trip.destinations.length}',
                ),
                _buildStatItem(
                  icon: CupertinoIcons.checkmark_circle,
                  label: 'Completed',
                  value: '${trip.completedActivitiesCount}',
                ),
                _buildStatItem(
                  icon: CupertinoIcons.list_bullet,
                  label: 'Total',
                  value: '${trip.totalActivities}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationsHeader(BuildContext context, Trip trip) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Destinations',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add-destination',
                arguments: trip.id,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDestinations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.map,
              size: 48,
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No destinations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add destinations to start planning your trip',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    String tripId,
    Destination destination,
  ) {
    final isExpanded = _expandedDestinations[destination.id] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedDestinations[destination.id] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.map_pin_ellipse,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (destination.location.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              destination.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${destination.activities.length} activities',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          icon: Icon(
                            CupertinoIcons.ellipsis_vertical,
                            color: AppTheme.textSecondary,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.pushNamed(
                                context,
                                '/edit-destination',
                                arguments: {
                                  'tripId': tripId,
                                  'destinationId': destination.id,
                                },
                              );
                            } else if (value == 'delete') {
                              _showDeleteDestinationConfirmation(
                                context,
                                tripId,
                                destination.id,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.pencil, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.trash,
                                      size: 20, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            CupertinoIcons.chevron_down,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(context, tripId, destination),
              crossFadeState:
                  isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    String tripId,
    Destination destination,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (destination.notes.isNotEmpty) ...[
            Text(
              destination.notes,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/add-activity',
                    arguments: {
                      'tripId': tripId,
                      'destinationId': destination.id,
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.add,
                        color: AppTheme.primaryTeal,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (destination.activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No activities yet',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...destination.activities.map(
              (activity) => ActivityTile(
                activity: activity,
                onToggle: () {
                  context.read<TripProvider>().toggleActivityCompletion(
                        tripId: tripId,
                        destinationId: destination.id,
                        activityId: activity.id,
                      );
                },
                onDelete: () {
                  context.read<TripProvider>().deleteActivity(
                        tripId: tripId,
                        destinationId: destination.id,
                        activityId: activity.id,
                      );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, String tripId) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-destination',
            arguments: tripId,
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          CupertinoIcons.location_solid,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String tripId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Trip'),
        content: const Text(
            'Are you sure you want to delete this trip? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              context.read<TripProvider>().deleteTrip(tripId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDestinationConfirmation(
    BuildContext context,
    String tripId,
    String destinationId,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Destination'),
        content: const Text(
            'Are you sure you want to delete this destination and all its activities?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              context.read<TripProvider>().deleteDestination(
                    tripId: tripId,
                    destinationId: destinationId,
                  );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

