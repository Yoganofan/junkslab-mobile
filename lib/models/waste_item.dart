class WasteItem {
  final int? id;
  final String category; 
  final String userEmail; 
  final double weightKg;
  final String description;
  final String? imagePath;
  final DateTime createdAt;
  final bool isListed; 

  WasteItem({
    this.id,
    required this.userEmail,
    required this.category,
    required this.weightKg,
    required this.description,
    this.imagePath,
    required this.createdAt,
    this.isListed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_email': userEmail,
      'category': category,
      'weight_kg': weightKg,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'is_listed': isListed ? 1 : 0,
    };
  }

  factory WasteItem.fromMap(Map<String, dynamic> map) {
    return WasteItem(
      id: map['id'] as int?,
      userEmail: map['user_email'] ?? 'guest', 
      category: map['category'] ?? 'Limbah',
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0.0, 
      description: map['description'] ?? '',
      imagePath: map['image_path'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      isListed: (map['is_listed'] ?? 0) == 1,
    );
  }
}