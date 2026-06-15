class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.googleId,
  });

  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? googleId;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      googleId: json['googleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (googleId != null) 'googleId': googleId,
    };
  }
}
