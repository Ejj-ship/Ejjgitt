import 'activity.dart';

class Destination {
  final String id;
  final String name;
  final String location;
  final String notes;
  List<Activity> activities;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    this.notes = '',
    List<Activity>? activities,
  }) : activities = activities ?? [];

  Destination copyWith({
    String? id,
    String? name,
    String? location,
    String? notes,
    List<Activity>? activities,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activities: activities ?? List.from(this.activities),
    );
  }

  int get completedActivitiesCount {
    return activities.where((activity) => activity.isCompleted).length;
  }

  double get completionPercentage {
    if (activities.isEmpty) return 0.0;
    return completedActivitiesCount / activities.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'notes': notes,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => Activity.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

