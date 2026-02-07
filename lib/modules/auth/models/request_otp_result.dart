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
      retryAfterSeconds: json['retry_after_seconds'],
    );
  }
}