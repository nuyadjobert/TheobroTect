class VerifyOtpResult {
  final String status;
  final String? token;
  final String? role;

  const VerifyOtpResult({
    required this.status,
    this.token,
    this.role,
  });

  factory VerifyOtpResult.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResult(
      status: json['status']?.toString() ?? 'UNKNOWN',
      token: json['token']?.toString(),
      role: json['role']?.toString(),
    );
  }
}