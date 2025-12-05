class Userprofile {
  final String id;
  final String fullname;
  final String email;
  final String department;
  final String level;
  final String idNumber;
  final String status;
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
      status: json['status'] ?? 'active',
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
    };
  }

  @override
  String toString() =>
      'Userprofile(id: $id, fullname: $fullname, email: $email, department:$department, level:$level, status: $status, id_number: $idNumber)';
}



