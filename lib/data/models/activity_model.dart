class ActivityModel {
  final String id;
  final String name;
  final String icon;
  final String category;
  final bool isCustom;

  ActivityModel({
    required this.id,
    required this.name,
    required this.icon,
    this.category = 'General',
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      category: map['category'] as String? ?? 'General',
      isCustom: (map['isCustom'] as int? ?? 0) == 1,
    );
  }
}

