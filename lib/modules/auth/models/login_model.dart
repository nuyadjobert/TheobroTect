class LoginModel {
  String email;
  String? emailError;
  bool isLoading;

  LoginModel({
    this.email = '',
    this.emailError,
    this.isLoading = false,
  });

  bool get isEmailValid {
    final e = email.trim();
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(e);
  }
}
