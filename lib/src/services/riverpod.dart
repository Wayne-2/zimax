import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/models/addchatinfo.dart';
import 'package:zimax/src/models/mediapost.dart';
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

// media_post riverpod streaming

final mediaPostsStreamProvider =
    StreamProvider.autoDispose<List<MediaPost>>((ref) {
  final supabase = Supabase.instance.client;

  final stream = supabase
      .from('media_posts')
      .stream(primaryKey: ['id'])         
      .order('created_at', ascending: false)   
      .map((rows) {
        return rows.map((e) => MediaPost.fromJson(e)).toList();
      });

  return stream;
});

final zimaxHomePostsProvider = StreamProvider.autoDispose<List<MediaPost>>((ref) {
  final supabase = Supabase.instance.client;
  final controller = StreamController<List<MediaPost>>();

  List<MediaPost> cache = [];

  supabase
      .from('media_posts')
      .select()
      .eq('posted_to', 'Zimax home')
      .order('created_at', ascending: false)
      .then((rows) {
        cache = rows.map((e) => MediaPost.fromJson(e)).toList();
        controller.add(cache);
      })
      // ignore: invalid_return_type_for_catch_error
      .catchError((e, st) => controller.addError(e, st));

  final subscription = supabase
      .from('media_posts')
      .stream(primaryKey: ['id'])
      .listen((changes) {
        for (final row in changes) {
          final post = MediaPost.fromJson(row);

          final index = cache.indexWhere((p) => p.id == post.id);

          if (index != -1) {
            cache[index] = post;
          } else {
            cache.insert(0, post);
          }
        }

        controller.add(List<MediaPost>.from(cache));
      }, onError: (e, st) {
        controller.addError(e, st);
      });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});




