class RegistrationRequest {
  final String email;
  final String fullName;
  final String address;
  final String contactNumber;

  const RegistrationRequest({
    required this.email,
    required this.fullName,
    required this.address,
    required this.contactNumber,
  });

  Map<String, dynamic> toJson() => {
        "email": email.trim().toLowerCase(),
        "full_name": fullName.trim(),
        "address": address.trim(),
        "contact_number": contactNumber.trim(),
      };

  bool get isValid =>
      email.trim().isNotEmpty &&
      fullName.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      contactNumber.trim().isNotEmpty &&
      _isValidEmail(email);

  static bool _isValidEmail(String email) {
    final e = email.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(e);
  }
}

enum RegistrationStatus {
  pendingApproval,
  alreadyRegistered,
  invalidInput,
  serverError,
  unknown,
}

class RegistrationResponse {
  final RegistrationStatus status;

  const RegistrationResponse({required this.status});

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json["status"] ?? "").toString();

    switch (raw) {
      case "PENDING_APPROVAL":
        return const RegistrationResponse(status: RegistrationStatus.pendingApproval);
      case "ALREADY_REGISTERED":
        return const RegistrationResponse(status: RegistrationStatus.alreadyRegistered);
      case "INVALID_INPUT":
        return const RegistrationResponse(status: RegistrationStatus.invalidInput);
      case "SERVER_ERROR":
        return const RegistrationResponse(status: RegistrationStatus.serverError);
      default:
        return const RegistrationResponse(status: RegistrationStatus.unknown);
    }
  }
}
