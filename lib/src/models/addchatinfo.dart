class Addchatinfo {
  final String id;
  final String username;
  final String email;
  final String status;
  final String pfp;
  final DateTime? createdAt;

  Addchatinfo({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    required this.pfp,
    required this.createdAt
  });

  factory Addchatinfo.fromMap(Map<String, dynamic> map) {
    return Addchatinfo(
      id: map['id'],
      username: map['fullname'],
      email: map['email'],
      status: map['status'] ?? 'student',
      pfp: map['profile_image_url'] ?? 'https://kldaeoljhumowuegwjyq.supabase.co/storage/v1/object/public/avatar/profile/aaa466ec-c0c3-48f6-9f30-e6110fbf4e4d/nopfp.png',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
