class VerifyOtpResult {
  final String status;
  final String? token;
  final String? role;
  final String? userId;
  final String? email;

  const VerifyOtpResult({
    required this.status,
    this.token,
    this.role,
    this.userId,
    this.email,
  });

  factory VerifyOtpResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return VerifyOtpResult(
      status: json['status']?.toString() ?? 'UNKNOWN',
      token: json['token']?.toString(),
      role: (user?['role'] ?? json['role'])?.toString(),
      userId: user?['id']?.toString(),
      email: user?['email']?.toString(),
    );
  }
}
