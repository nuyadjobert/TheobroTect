
import 'package:flutter/material.dart';
import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:flutter/foundation.dart';
import '../../../core/model/user.model.dart';

class UserProfileController extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  LocalUser? user;
  bool isLoading = true;

  Future<void> loadUser() async {
    isLoading = true;
    notifyListeners();

    user = await _repository.getCurrentUser();

    isLoading = false;
    notifyListeners();
  }

  // Future<void> saveProfile({
  //   required String name,
  //   required String contact,
  //   required String address,
  // }) async {
  //   if (user == null) return;

  //   user = user!.copyWith(
  //     fullName: name,
  //     contactNumber: contact,
  //     address: address,
  //   );

    // await _repository.updateUser(user!);

    // notifyListeners();
  // }
}