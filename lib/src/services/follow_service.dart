import 'package:supabase_flutter/supabase_flutter.dart';

class FollowService {
  static final _client = Supabase.instance.client;

  static Future<void> followOrRequest(
    String targetId,
    bool isPrivate,
  ) async {
    final uid = _client.auth.currentUser!.id;

    if (uid == targetId) return;

    if (isPrivate) {
      await _client.from('follow_requests').insert({
        'requester_id': uid,
        'target_id': targetId,
      });
    } else {
      await _client.from('follows').insert({
        'follower_id': uid,
        'following_id': targetId,
      });
    }
  }

  static Future<void> unfollow(String targetId) async {
    final uid = _client.auth.currentUser!.id;

    await _client
        .from('follows')
        .delete()
        .eq('follower_id', uid)
        .eq('following_id', targetId);
  }
}
