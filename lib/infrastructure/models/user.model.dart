class User {
  String id;
  String fullName;
  String? imageUrl;
  List<String> roles;
  String email;
  String jwtToken;

  User({
    required this.id,
    required this.fullName,
    required this.roles,
    required this.email,
    required this.jwtToken,
    this.imageUrl,
  });

  factory User.fromApi(Map<String, dynamic> userData) {
    return User(
      id: userData['id'],
      email: userData['email'],
      fullName: userData['fullName'],
      roles: List<String>.from(userData['roles']),
      jwtToken: userData['token'],
      imageUrl: userData['imageUrl'],
    );
  }
}
