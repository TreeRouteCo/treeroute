import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAccount {
  User? user;
  String? firstName;
  String? lastName;
  String? username;
  bool verified;
  List<int>? modCampuses;
  bool admin;
  String? elevationDescription;
  String? bio;

  UserAccount({
    this.user,
    this.firstName,
    this.lastName,
    this.username,
    this.verified = false,
    this.modCampuses,
    this.admin = false,
    this.elevationDescription,
    this.bio,
  });

  UserAccount copyWith({
    User? user,
    String? firstName,
    String? lastName,
    String? username,
    bool? verified,
    List<int>? modCampuses,
    bool? admin,
    String? elevationDescription,
    String? bio,
  }) {
    return UserAccount(
      user: user ?? this.user,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      verified: verified ?? this.verified,
      modCampuses: modCampuses ?? this.modCampuses,
      admin: admin ?? this.admin,
      elevationDescription: elevationDescription ?? this.elevationDescription,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'verified': verified,
      'modCampuses': modCampuses,
      'admin': admin,
      'elevationDescription': elevationDescription,
      'bio': bio,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      user: User.fromJson(map['user'])!,
      firstName: map['firstName'],
      lastName: map['lastName'],
      username: map['username'],
      verified: map['verified'] ?? false,
      modCampuses: List<int>.from(map['modCampuses']),
      admin: map['admin'] ?? false,
      elevationDescription: map['elevationDescription'],
      bio: map['bio'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAccount.fromJson(String source) =>
      UserAccount.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserAccount(user: $user, firstName: $firstName, lastName: $lastName, username: $username, verified: $verified, modCampuses: $modCampuses, admin: $admin, elevationDescription: $elevationDescription, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserAccount &&
        other.user == user &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.username == username &&
        other.verified == verified &&
        listEquals(other.modCampuses, modCampuses) &&
        other.admin == admin &&
        other.elevationDescription == elevationDescription &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        username.hashCode ^
        verified.hashCode ^
        modCampuses.hashCode ^
        admin.hashCode ^
        elevationDescription.hashCode ^
        bio.hashCode;
  }
}
