import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ActivityTile({
    super.key,
    required this.activity,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: activity.isCompleted
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.isCompleted
              ? AppTheme.primaryTeal.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: activity.isCompleted ? AppTheme.primaryGradient : null,
              color: activity.isCompleted ? null : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activity.isCompleted
                    ? Colors.transparent
                    : AppTheme.primaryTeal,
                width: 2,
              ),
            ),
            child: activity.isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : null,
          ),
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: activity.isCompleted
                ? AppTheme.textSecondary
                : AppTheme.textPrimary,
            fontSize: 16,
            decoration:
                activity.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: AppTheme.textSecondary,
          ),
          child: Text(activity.name),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red.shade300,
            size: 22,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

