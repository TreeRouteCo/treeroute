import 'dart:convert';

import 'package:flutter/foundation.dart';

class Profile {
  String? firstName;
  String? lastName;
  String? username;
  String? bio;
  int? campusId;

  bool verified;
  List<int> modCampuses;
  bool admin;
  String? elevationDescription;

  Profile({
    this.firstName,
    this.lastName,
    this.username,
    this.bio,
    this.verified = false,
    this.modCampuses = const [],
    this.admin = false,
    this.elevationDescription,
    this.campusId,
  });

  Profile copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    bool? verified,
    List<int>? modCampuses,
    bool? admin,
    String? elevationDescription,
    int? campusId,
  }) {
    return Profile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      verified: verified ?? this.verified,
      modCampuses: modCampuses ?? this.modCampuses,
      admin: admin ?? this.admin,
      elevationDescription: elevationDescription ?? this.elevationDescription,
      campusId: campusId ?? this.campusId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'bio': bio,
      'verified': verified,
      'modCampuses': modCampuses,
      'admin': admin,
      'elevationDescription': elevationDescription,
      'campusId': campusId,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      firstName: map['firstName'] ?? map['first_name'],
      lastName: map['lastName'] ?? map['last_name'],
      username: map['username'],
      bio: map['bio'],
      verified: map['verified'] ?? false,
      modCampuses:
          List<int>.from(map['modCampuses'] ?? map["mod_campuses"] ?? []),
      admin: map['admin'] ?? false,
      elevationDescription:
          map['elevationDescription'] ?? map['elevation_description'],
      campusId: map['campusId'] ?? map['campus_id'] ?? map['campus'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Profile(firstName: $firstName, lastName: $lastName, username: $username, bio: $bio, verified: $verified, modCampuses: $modCampuses, admin: $admin, elevationDescription: $elevationDescription, campusId: $campusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Profile &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.username == username &&
        other.bio == bio &&
        other.verified == verified &&
        listEquals(other.modCampuses, modCampuses) &&
        other.admin == admin &&
        other.elevationDescription == elevationDescription &&
        other.campusId == campusId;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^
        lastName.hashCode ^
        username.hashCode ^
        bio.hashCode ^
        verified.hashCode ^
        modCampuses.hashCode ^
        admin.hashCode ^
        elevationDescription.hashCode ^
        campusId.hashCode;
  }
}
