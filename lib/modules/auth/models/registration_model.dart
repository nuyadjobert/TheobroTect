class RegistrationRequest {
  final String email;
  final String name;
  final String address;
  final String contact_number;

  const RegistrationRequest({
    required this.email,
    required this.name,
    required this.address,
    required this.contact_number,
  });

  Map<String, dynamic> toJson() => {
        "email": email.trim().toLowerCase(),
        "full_name": name.trim(),
        "address": address.trim(),
        "contact_number": contact_number.trim(),
      };

  bool get isValid =>
      email.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      contact_number.trim().isNotEmpty &&
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
