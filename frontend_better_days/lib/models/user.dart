class User {
  final String id;
  final String email;
  final String name;
  final DateTime dob;
  final double? height;
  final double? weight;
  final String? profileImage; // fixed typo here

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.dob,
    required this.height,
    required this.weight,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      dob: DateTime.parse(json['dob']),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'dob': dob.toIso8601String(),
      'height': height,
      'weight': weight,
      'profile_image': profileImage,
    };
  }

  String get formattedDob {
    return '${dob.day}/${dob.month}/${dob.year}';
  }
}