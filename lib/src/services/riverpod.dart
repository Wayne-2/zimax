import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/models/addchatinfo.dart';
import 'package:zimax/src/models/userprofile.dart';


class UserNotifier extends StateNotifier<Userprofile?> {
  UserNotifier() : super(null);

  void setUser(Userprofile user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

final userProfileProvider = StateNotifierProvider<UserNotifier, Userprofile?>((ref) {
  return UserNotifier();
});


final usersStreamProvider = StreamProvider.autoDispose((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('user_profile')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((rows) {
        return rows.map((e) => Addchatinfo.fromMap(e)).toList();
      });
});


final userServiceStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('user_profile')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((rows) {
    return rows.map((e) {
      return {
        'id': e['id'],
        'fullname': e['fullname'] ?? '',
        'email': e['email'] ?? '',
        'status': e['status'] ?? '',
        'profile_image_url': e['profile_image_url'] ?? '',
        'created_at': e['created_at'] ?? '',
      };
    }).toList();
  });
});

