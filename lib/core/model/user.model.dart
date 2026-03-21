class LocalUser {
  final String userId;
  final String email;
  final String? name;
  final String address;
  final String contactNumber;
  final String createdAt; 

  LocalUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'user_id': userId,
        'email': email,
        'name': name,
        'address': address,
        'contact_number': contactNumber,
        'created_at': createdAt,
      };

  static LocalUser fromMap(Map<String, Object?> map) => LocalUser(
        userId: map['user_id'] as String,
        email: map['email'] as String,
        name: map['name'] as String?,
        address: map['address'] as String,
        contactNumber: map['contact_number'] as String,
        createdAt: map['created_at'] as String,
      );
}
