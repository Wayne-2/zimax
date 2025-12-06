class Userprofile {
  final String id;
  final String fullname;
  final String email;
  final String department;
  final String level;
  final String idNumber;
  final String status;
  final String pfp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Userprofile({
    required this.id,
    required this.fullname,
    required this.email,
    required this.department,
    required this.level,
    required this.idNumber,
    required this.status,
    required this.pfp,
    this.createdAt,
    this.updatedAt,
  });

  factory Userprofile.fromJson(Map<String, dynamic> json) {
    return Userprofile(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      department: json['department'] ?? '',
      level: json['level'] ?? '',
      idNumber: json['id_number'] ?? '',
      status: json['status'] ?? 'student',
      pfp: json['profile_image_url'] ?? 'https://kldaeoljhumowuegwjyq.supabase.co/storage/v1/object/public/avatar/profile/aaa466ec-c0c3-48f6-9f30-e6110fbf4e4d/nopfp.png',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'department': department,
      'level': level,
      'id_number': idNumber,
      'status': status,
      'profile_image_url':pfp
    };
  }

  @override
  String toString() =>
      'Userprofile(id: $id, fullname: $fullname, email: $email, department:$department, level:$level, status: $status, id_number: $idNumber, pfp: $pfp)';
}



