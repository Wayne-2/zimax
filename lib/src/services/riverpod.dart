import 'package:flutter_riverpod/legacy.dart';
import 'package:zimax/src/services/model.dart';


class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  // Store user data
  void setUser(UserModel user) {
    state = user;
  }

  // Clear user data
  void clearUser() {
    state = null;
  }
}

// Global provider
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
