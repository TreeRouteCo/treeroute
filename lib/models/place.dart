import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:here_sdk/core.dart';

class Place {
  int id;
  DateTime createdAt;
  String createdBy;

  DateTime? updatedAt;
  String? updatedBy;

  int campusId;
  String slug;
  String? name;
  List<String>? aka;
  GeoCoordinates geoCoordinates;
  List<String>? type;
  String? imageUrl;

  String? description;
  String? address;
  int? postalCode;
  String? state;
  String? city;

  List<String>? departments;
  List<String>? rooms;

  Place({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    required this.campusId,
    required this.slug,
    this.name,
    this.aka,
    required this.geoCoordinates,
    this.type,
    this.imageUrl,
    this.description,
    this.address,
    this.postalCode,
    this.state,
    this.city,
    this.departments,
    this.rooms,
  });

  Place copyWith({
    int? id,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    int? campusId,
    String? slug,
    String? name,
    List<String>? aka,
    GeoCoordinates? geoCoordinates,
    List<String>? type,
    String? imageUrl,
    String? description,
    String? address,
    int? postalCode,
    String? state,
    String? city,
    List<String>? departments,
    List<String>? rooms,
  }) {
    return Place(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      campusId: campusId ?? this.campusId,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      aka: aka ?? this.aka,
      geoCoordinates: geoCoordinates ?? this.geoCoordinates,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      state: state ?? this.state,
      city: city ?? this.city,
      departments: departments ?? this.departments,
      rooms: rooms ?? this.rooms,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'updatedBy': updatedBy,
      'campusId': campusId,
      'slug': slug,
      'name': name,
      'aka': aka,
      'geoCoordinates': {
        'latitude': geoCoordinates.latitude,
        'longitude': geoCoordinates.longitude,
      },
      'type': type,
      'imageUrl': imageUrl,
      'description': description,
      'address': address,
      'postalCode': postalCode,
      'state': state,
      'city': city,
      'departments': departments,
      'rooms': rooms,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? map['created_at']),
      createdBy: map['createdBy'] ?? map["created_by"] ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(
              map['updatedAt'] ?? map['updated_at'] ?? map['last_updated_at'],
            )
          : null,
      updatedBy:
          map['updatedBy'] ?? map["updated_by"] ?? map["last_updated_by"] ?? '',
      campusId: map['campusId']?.toInt() ??
          map["campus_id"] ??
          map["campus_id"] ??
          map["campus"] ??
          0,
      slug: map['slug'] ?? '',
      name: map['name'],
      aka: List<String>.from(map['aka']),
      geoCoordinates: GeoCoordinates(
        map["geoloc"]["lat"],
        map["geoloc"]["lon"],
      ),
      type: List<String>.from(map['type']),
      imageUrl: map['imageUrl'] ?? map["image_url"] ?? '',
      description: map['description'],
      address: map['address'],
      postalCode: map['postalCode'] ?? map["postal_code"] ?? '',
      state: map['state'],
      city: map['city'],
      departments: List<String>.from(map['departments']),
      rooms: List<String>.from(map['rooms']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Place.fromJson(String source) => Place.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Place(id: $id, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy, campusId: $campusId, slug: $slug, name: $name, aka: $aka, geoCoordinates: $geoCoordinates, type: $type, imageUrl: $imageUrl, description: $description, address: $address, postalCode: $postalCode, state: $state, city: $city, departments: $departments, rooms: $rooms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Place &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.updatedAt == updatedAt &&
        other.updatedBy == updatedBy &&
        other.campusId == campusId &&
        other.slug == slug &&
        other.name == name &&
        listEquals(other.aka, aka) &&
        other.geoCoordinates == geoCoordinates &&
        listEquals(other.type, type) &&
        other.imageUrl == imageUrl &&
        other.description == description &&
        other.address == address &&
        other.postalCode == postalCode &&
        other.state == state &&
        other.city == city &&
        listEquals(other.departments, departments) &&
        listEquals(other.rooms, rooms);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdAt.hashCode ^
        createdBy.hashCode ^
        updatedAt.hashCode ^
        updatedBy.hashCode ^
        campusId.hashCode ^
        slug.hashCode ^
        name.hashCode ^
        aka.hashCode ^
        geoCoordinates.hashCode ^
        type.hashCode ^
        imageUrl.hashCode ^
        description.hashCode ^
        address.hashCode ^
        postalCode.hashCode ^
        state.hashCode ^
        city.hashCode ^
        departments.hashCode ^
        rooms.hashCode;
  }
}
