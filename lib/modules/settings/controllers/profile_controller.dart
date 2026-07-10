import 'package:flutter/material.dart';
import 'package:cacao_apps/core/db/user_repository.dart';
import 'package:flutter/foundation.dart';
import '../../../core/model/user.model.dart';
import '../../../core/db/sync_queue_reporitory.dart';

class UserProfileController extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final syncQueueRepository = SyncQueueRepository();

  LocalUser? user;
  bool isLoading = true;

  Future<void> loadUser() async {
    isLoading = true;
    notifyListeners();

    user = await _repository.getCurrentUser();

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? address,
    String? contactNumber,
  }) async {
    if (user == null) return;

    // Update the database
    await _repository.updateUser(
      userId: user!.userId,
      name: name,
      address: address,
      contactNumber: contactNumber,
    );

    // Update the local object
    user = LocalUser(
      userId: user!.userId,
      email: user!.email,
      createdAt: user!.createdAt,
      name: name ?? user!.name,
      address: address ?? user!.address,
      contactNumber: contactNumber ?? user!.contactNumber,
    );

    await syncQueueRepository.add(
      tableName: 'users',
      recordId: user!.userId,
      action: 'update',
      payload: {
        'name': name,
        'address': address,
        'contact_number': contactNumber,
      },
    );

    notifyListeners();
  }
}
