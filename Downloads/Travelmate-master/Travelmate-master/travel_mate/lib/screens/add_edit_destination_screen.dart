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

class AddEditDestinationScreen extends StatefulWidget {
  final bool isEditing;

  const AddEditDestinationScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<AddEditDestinationScreen> createState() => _AddEditDestinationScreenState();
}

class _AddEditDestinationScreenState extends State<AddEditDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  String? _tripId;
  String? _destinationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDestinationData();
      });
    }
  }

  void _loadDestinationData() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    _tripId = args['tripId'];
    _destinationId = args['destinationId'];

    if (_tripId != null && _destinationId != null) {
      final destination = context
          .read<TripProvider>()
          .getDestinationById(_tripId!, _destinationId!);
      if (destination != null) {
        setState(() {
          _nameController.text = destination.name;
          _locationController.text = destination.location;
          _notesController.text = destination.notes;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
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
            widget.isEditing ? 'Edit Destination' : 'New Destination',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isEditing
                ? 'Update your destination details'
                : 'Add a new destination to your trip',
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
              'Destination Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GlassTextField(
              controller: _nameController,
              hintText: 'e.g., Paris, France',
              prefixIcon: const Icon(
                CupertinoIcons.map_pin,
                color: AppTheme.primaryTeal,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a destination name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GlassTextField(
              controller: _locationController,
              hintText: 'e.g., Île-de-France region',
              prefixIcon: const Icon(
                CupertinoIcons.location,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GlassTextField(
              controller: _notesController,
              hintText: 'Add any notes about this destination (optional)',
              maxLines: 4,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(
                  CupertinoIcons.doc_text,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: widget.isEditing ? 'Update Destination' : 'Add Destination',
                icon: widget.isEditing
                    ? CupertinoIcons.checkmark_alt
                    : CupertinoIcons.location_solid,
                isLoading: _isLoading,
                onPressed: _saveDestination,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDestination() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final tripProvider = context.read<TripProvider>();
      
      // Get tripId from arguments if not already set
      if (_tripId == null) {
        _tripId = ModalRoute.of(context)!.settings.arguments as String;
      }

      if (widget.isEditing && _tripId != null && _destinationId != null) {
        tripProvider.updateDestination(
          tripId: _tripId!,
          destinationId: _destinationId!,
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          notes: _notesController.text.trim(),
        );
      } else if (_tripId != null) {
        tripProvider.addDestination(
          tripId: _tripId!,
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          notes: _notesController.text.trim(),
        );
      }

      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }
}

