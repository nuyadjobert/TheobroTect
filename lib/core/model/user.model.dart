class LocalUser {
  final String userId;
  final String email;
  final String createdAt; 

  LocalUser({
    required this.userId,
    required this.email,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'user_id': userId,
        'email': email,
        'created_at': createdAt,
      };

  static LocalUser fromMap(Map<String, Object?> map) => LocalUser(
        userId: map['user_id'] as String,
        email: map['email'] as String,
        createdAt: map['created_at'] as String,
      );
}
