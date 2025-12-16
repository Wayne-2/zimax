// import 'dart:async';
// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/models/addchatinfo.dart';
import 'package:zimax/src/models/chatpreview.dart';
import 'package:zimax/src/models/communitymodel.dart';
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

final userProfileProvider = StateNotifierProvider<UserNotifier, Userprofile?>((
  ref,
) {
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

final userServiceStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
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

final mediaPostsStreamProvider = StreamProvider.autoDispose<List<MediaPost>>((
  ref,
) {
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

final zimaxHomePostsProvider = StreamProvider<List<MediaPost>>((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('media_posts')
      .stream(primaryKey: ['id'])
      .eq('posted_to', 'Zimax home')
      .order('created_at', ascending: false)
      .map((rows) => rows.map((e) => MediaPost.fromJson(e)).toList());
});

// chatpreview
class ChatPreviewNotifier extends StateNotifier<Map<String, ChatPreview>> {
  ChatPreviewNotifier() : super({});

  void onNewMessage({
    required String chatroomId,
    required String message,
    required DateTime createdAt,
    required bool isMine,
  }) {
    final current = state[chatroomId];

    state = {
      ...state,
      chatroomId: ChatPreview(
        chatroomId: chatroomId,
        lastMessage: message,
        lastMessageTime: createdAt,
        unreadCount: isMine ? 0 : (current?.unreadCount ?? 0) + 1,
      ),
    };
  }

  void markAsRead(String chatroomId) {
    final preview = state[chatroomId];
    if (preview == null) return;

    state = {
      ...state,
      chatroomId: ChatPreview(
        chatroomId: chatroomId,
        lastMessage: preview.lastMessage,
        lastMessageTime: preview.lastMessageTime,
        unreadCount: 0,
      ),
    };
  }
}

final chatPreviewProvider =
    StateNotifierProvider<ChatPreviewNotifier, Map<String, ChatPreview>>(
      (ref) => ChatPreviewNotifier(),
    );

// community provider
final recentCommunitiesProvider = FutureProvider<List<CommunityModel>>((
  ref,
) async {
  final supabase = Supabase.instance.client;

  final data = await supabase.rpc('get_recent_communities');

  if (data == null) return [];

  print(data);

  return (data as List<dynamic>)
      .map((e) => CommunityModel.fromMap(e as Map<String, dynamic>))
      .toList();
});


final isJoinedProvider = FutureProvider.family<bool, String>((ref, communityId) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  final res = await supabase
      .from('community_members')
      .select()
      .eq('community_id', communityId)
      .eq('user_id', userId)
      .maybeSingle();

  return res != null;
});

