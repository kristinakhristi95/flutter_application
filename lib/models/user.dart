class User {
  final String id;
  final String username;
  final String email;
  final String? name;
  final String? department;
  final String? experience;
  final String? phone;
  final String? address;
  final String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.department,
    this.experience,
    this.phone,
    this.address,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['_id'] ?? json['id'] ?? '',
        username: json['username'] ?? 'Unknown',
        email: json['email'] ?? 'Unknown',
        name: json['name'],
        department: json['department'],
        experience: json['experience'],
        phone: json['phone'],
        address: json['address'],
        profileImage: json['profileImage'],
      );
    } catch (e) {
      print('Error creating User from JSON: $e');
      print('JSON data: $json');
      // Return a fallback user
      return User(
        id: json['_id'] ?? json['id'] ?? 'unknown_id',
        username: json['username'] ?? 'Error: Invalid Data',
        email: json['email'] ?? 'Unknown',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'department': department,
      'experience': experience,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
    };
  }

  // Create a copy of the user with updated fields
  User copyWith({
    String? name,
    String? department,
    String? experience,
    String? phone,
    String? address,
    String? profileImage,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      name: name ?? this.name,
      department: department ?? this.department,
      experience: experience ?? this.experience,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
