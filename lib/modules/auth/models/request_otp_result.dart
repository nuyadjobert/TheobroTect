class RequestOtpResult {
  final String status;
  final int? expiresInSeconds;
  final int? retryAfterSeconds;

  const RequestOtpResult({
    required this.status,
    this.expiresInSeconds,
    this.retryAfterSeconds,
  });

  factory RequestOtpResult.fromJson(Map<String, dynamic> json) {
    return RequestOtpResult(
      status: json['status'] ?? '',
      expiresInSeconds: json['expires_in_seconds'],
      retryAfterSeconds: json['retry_after_seconds'],
    );
  }
}