class UserModel {
  final String id;
  final String username;
  final String email;
  final String department;
  final int regnumber;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.department,
    required this.regnumber,
  });

  /// Primary factory used across the app
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? 'Dear User',
      email: json['email'] ?? '',
      department: json['department']?? '',
      regnumber: json['regnumber']?? 00
    );
  }

  /// Alias for code that expects `fromMap`
  factory UserModel.fromMap(Map<String, dynamic> map) =>
      UserModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email, };
  }

  @override
  String toString() => 'UserModel(id: $id, username: $username, email: $email)';
}
