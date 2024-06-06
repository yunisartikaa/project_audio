class ModelUser {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? avatar;

  ModelUser({this.id, this.email, this.firstName, this.lastName, this.avatar});

  factory ModelUser.fromJson(Map<String, dynamic> json) {
    return ModelUser(
      id: json['id'].toString(),
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
    );
  }
}