class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? college;
  final String? branch;
  final int? year;
  final int? semester;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.college,
    this.branch,
    this.year,
    this.semester,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      college: json['college'] as String?,
      branch: json['branch'] as String?,
      year: json['year'] as int?,
      semester: json['semester'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'college': college,
      'branch': branch,
      'year': year,
      'semester': semester,
    };
  }
}
