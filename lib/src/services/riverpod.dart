import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/models/addchatinfo.dart';
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


final usersStreamProvider = StreamProvider.autoDispose((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('user_profile')
      .stream(primaryKey: ['id']) // must match your primary key
      .order('created_at')
      .map((rows) {
        return rows.map((e) => Addchatinfo.fromMap(e)).toList();
      });
});
