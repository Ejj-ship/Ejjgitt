import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Consumer<TripProvider>(
                builder: (context, tripProvider, child) {
                  final trips = tripProvider.trips;
                  if (trips.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final trip = trips[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildTripCard(context, trip),
                          );
                        },
                        childCount: trips.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'TravelMate',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Plan your perfect journey',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final completionPercent = (trip.completionPercentage * 100).toInt();

    return Hero(
      tag: 'trip_${trip.id}',
      child: GlassCard(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/trip-details',
            arguments: trip.id,
          );
        },
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trip.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completionPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (trip.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                trip.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 6),
                Text(
                  '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  CupertinoIcons.map_pin,
                  size: 16,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  '${trip.destinations.length} destination${trip.destinations.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  CupertinoIcons.checkmark_circle,
                  size: 16,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 6),
                Text(
                  '${trip.completedActivitiesCount}/${trip.totalActivities} activities',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(trip.completionPercentage),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(AppTheme.primaryBlue, AppTheme.primaryTeal, progress)!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.airplane,
            size: 80,
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No trips yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to plan your first adventure!',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
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
          Navigator.pushNamed(context, '/add-trip');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

