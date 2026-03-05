import 'destination.dart';

class Trip {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  List<Destination> destinations;

  Trip({
    required this.id,
    required this.name,
    this.description = '',
    required this.startDate,
    required this.endDate,
    List<Destination>? destinations,
  }) : destinations = destinations ?? [];

  Trip copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<Destination>? destinations,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destinations: destinations ?? List.from(this.destinations),
    );
  }

  int get totalActivities {
    int count = 0;
    for (var destination in destinations) {
      count += destination.activities.length;
    }
    return count;
  }

  int get completedActivitiesCount {
    int count = 0;
    for (var destination in destinations) {
      count += destination.completedActivitiesCount;
    }
    return count;
  }

  double get completionPercentage {
    if (totalActivities == 0) return 0.0;
    return completedActivitiesCount / totalActivities;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'destinations': destinations.map((d) => d.toJson()).toList(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      destinations: (json['destinations'] as List<dynamic>?)
              ?.map((d) => Destination.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

