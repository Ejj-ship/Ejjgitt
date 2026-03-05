import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_button.dart';

class AddEditTripScreen extends StatefulWidget {
  final bool isEditing;

  const AddEditTripScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<AddEditTripScreen> createState() => _AddEditTripScreenState();
}

class _AddEditTripScreenState extends State<AddEditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String? _tripId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTripData();
      });
    }
  }

  void _loadTripData() {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    _tripId = tripId;
    final trip = context.read<TripProvider>().getTripById(tripId);
    if (trip != null) {
      setState(() {
        _nameController.text = trip.name;
        _descriptionController.text = trip.description;
        _startDate = trip.startDate;
        _endDate = trip.endDate;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
            widget.isEditing ? 'Edit Trip' : 'New Trip',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isEditing
                ? 'Update your trip details'
                : 'Plan your next adventure',
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
    final dateFormat = DateFormat('MMM d, yyyy');

    return Form(
      key: _formKey,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GlassTextField(
              controller: _nameController,
              hintText: 'Enter trip name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a trip name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GlassTextField(
              controller: _descriptionController,
              hintText: 'Enter trip description (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Start Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildDatePicker(
              date: _startDate,
              formattedDate: dateFormat.format(_startDate),
              onTap: () => _selectDate(isStartDate: true),
            ),
            const SizedBox(height: 24),
            const Text(
              'End Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildDatePicker(
              date: _endDate,
              formattedDate: dateFormat.format(_endDate),
              onTap: () => _selectDate(isStartDate: false),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: widget.isEditing ? 'Update Trip' : 'Create Trip',
                icon: widget.isEditing
                    ? CupertinoIcons.checkmark_alt
                    : CupertinoIcons.add,
                isLoading: _isLoading,
                onPressed: _saveTrip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime date,
    required String formattedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: AppTheme.primaryTeal,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_down,
              color: AppTheme.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate({required bool isStartDate}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: isStartDate ? _startDate : _endDate,
                minimumDate: isStartDate ? null : _startDate,
                onDateTimeChanged: (date) {
                  setState(() {
                    if (isStartDate) {
                      _startDate = date;
                      if (_endDate.isBefore(_startDate)) {
                        _endDate = _startDate.add(const Duration(days: 1));
                      }
                    } else {
                      _endDate = date;
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Done',
                  height: 48,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTrip() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final tripProvider = context.read<TripProvider>();

      if (widget.isEditing && _tripId != null) {
        tripProvider.updateTrip(
          tripId: _tripId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        tripProvider.addTrip(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }
}

