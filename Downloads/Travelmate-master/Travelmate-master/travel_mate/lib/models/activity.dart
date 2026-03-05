class Activity {
  final String id;
  final String name;
  bool isCompleted;

  Activity({
    required this.id,
    required this.name,
    this.isCompleted = false,
  });

  Activity copyWith({
    String? id,
    String? name,
    bool? isCompleted,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

