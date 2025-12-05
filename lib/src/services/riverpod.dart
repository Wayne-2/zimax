import 'package:flutter_riverpod/legacy.dart';
import 'package:zimax/src/models/userprofile.dart';


class UserNotifier extends StateNotifier<Userprofile?> {
  UserNotifier() : super(null);

  // Store user data
  void setUser(Userprofile user) {
    state = user;
  }

  // Clear user data
  void clearUser() {
    state = null;
  }
}

// Global provider
final userProfileProvider = StateNotifierProvider<UserNotifier, Userprofile?>((ref) {
  return UserNotifier();
});
