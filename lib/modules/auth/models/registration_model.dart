class RegistrationRequest {
  final String email;
  final String name;
  final String address;
  final String contactNumber;

  const RegistrationRequest({
    required this.email,
    required this.name,
    required this.address,
    required this.contactNumber,
  });

  Map<String, dynamic> toJson() => {
        "email": email.trim().toLowerCase(),
        "name": name.trim(),
        "address": address.trim(),
        "contact_number": contactNumber.trim(),
      };

  bool get isValid =>
      email.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      contactNumber.trim().isNotEmpty &&
      _isValidEmail(email);

  static bool _isValidEmail(String email) {
    final e = email.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(e);
  }
}



class RegistrationResponse {
  final RegistrationStatus status;
  final String? token;
  final Map<String, dynamic>? user;

  const RegistrationResponse({
    required this.status,
    this.token,
    this.user,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json["status"] ?? "").toString();

    switch (raw) {
      case "OK":                   // ✅ handle success
        return RegistrationResponse(
          status: RegistrationStatus.success,
          token: json["token"],
          user: json["user"],
        );
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

enum RegistrationStatus {
  success,              // ✅ added
  alreadyRegistered,
  invalidInput,
  serverError,
  unknown,
}