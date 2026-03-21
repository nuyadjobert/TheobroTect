class VerifyOtpResult {
  final String status;
  final String? token;
  final String? role;
  final String? userId;
  final String? name;
  final String? address;
  final String? contactNumber;
  final String? email;

  const VerifyOtpResult({
    required this.status,
    this.token,
    this.role,
    this.userId,
    this.name,
    this.address,
    this.contactNumber,
    this.email,
  });

factory VerifyOtpResult.fromJson(Map<String, dynamic> json) {
  final userData = json['user'] as Map<String, dynamic>?;

  return VerifyOtpResult(
    status: json['status'] ?? '',
    token: json['token'],
    role: json['role'], 
    userId: userData?['id']?.toString(), 
    name: userData?['name'],
    email: userData?['email'],
    address: userData?['address'],
    contactNumber: userData?['contact_number'], 
  );
}
}
