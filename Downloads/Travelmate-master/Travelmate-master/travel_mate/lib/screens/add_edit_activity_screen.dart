import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_button.dart';

class AddEditActivityScreen extends StatefulWidget {
  final bool isEditing;

  const AddEditActivityScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<AddEditActivityScreen> createState() => _AddEditActivityScreenState();
}

class _AddEditActivityScreenState extends State<AddEditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _tripId;
  String? _destinationId;
  String? _activityId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArguments();
    });
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)!.settings.arguments;
    
    if (args is Map<String, String>) {
      _tripId = args['tripId'];
      _destinationId = args['destinationId'];
      _activityId = args['activityId'];
      
      // If editing, load the activity data
      if (widget.isEditing && _tripId != null && _destinationId != null && _activityId != null) {
        _loadActivityData();
      }
    }
  }

  void _loadActivityData() {
    if (_tripId != null && _destinationId != null) {
      final destination = context
          .read<TripProvider>()
          .getDestinationById(_tripId!, _destinationId!);
      if (destination != null && _activityId != null) {
        try {
          final activity = destination.activities.firstWhere(
            (a) => a.id == _activityId,
          );
          setState(() {
            _nameController.text = activity.name;
          });
        } catch (e) {
          // Activity not found
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.isEditing ? 'Edit Activity' : 'New Activity',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isEditing
                ? 'Update your activity'
                : 'Add a new activity to your destination',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GlassTextField(
              controller: _nameController,
              hintText: 'e.g., Visit Eiffel Tower',
              prefixIcon: const Icon(
                CupertinoIcons.checkmark_circle,
                color: AppTheme.primaryTeal,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an activity name';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: widget.isEditing ? 'Update Activity' : 'Add Activity',
                icon: widget.isEditing
                    ? CupertinoIcons.checkmark_alt
                    : CupertinoIcons.add_circled_solid,
                isLoading: _isLoading,
                onPressed: _saveActivity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final tripProvider = context.read<TripProvider>();

      if (widget.isEditing && _tripId != null && _destinationId != null && _activityId != null) {
        tripProvider.updateActivity(
          tripId: _tripId!,
          destinationId: _destinationId!,
          activityId: _activityId!,
          name: _nameController.text.trim(),
        );
      } else if (_tripId != null && _destinationId != null) {
        tripProvider.addActivity(
          tripId: _tripId!,
          destinationId: _destinationId!,
          name: _nameController.text.trim(),
        );
      }

      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }
}

