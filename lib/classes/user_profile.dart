class UserProfile {
  final String name;
  final String gender;
  final String place;
  final String email;
  final String mobile;
  final String pincode;
  final String state;

  UserProfile({
    required this.name,
    required this.gender,
    required this.place,
    required this.email,
    required this.mobile,
    required this.pincode,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'place': place,
      'email': email,
      'mobile': mobile,
      'pincode': pincode,
      'state': state,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      place: map['place'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      pincode: map['pincode'] ?? '',
      state: map['state'] ?? '',
    );
  }
}
